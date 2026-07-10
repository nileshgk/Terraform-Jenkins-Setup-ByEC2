#!/bin/bash

# ==============================================================================
# SCRIPT NAME: Jenkins.sh (User Data Bootstrap)
# PURPOSE: Automatically installs, configures, and secures Jenkins and Docker
#          on Amazon Linux 2023. Additionally deploys an automated backup script.
# ==============================================================================

# 'set -euxo pipefail' is a DevOps best-practice for robust error handling:
#  -e: Tells the script to exit immediately if any command returns a non-zero status.
#  -u: Treats unset variables as an error and exits immediately.
#  -x: Print commands and their arguments as they are executed (excellent for debugging).
#  -o pipefail: Ensures that if any command in a pipeline fails, the whole pipeline fails.
set -euxo pipefail

# SYSTEM LOGGING SETUP:
# This intercepts all standard output (stdout) and standard error (stderr) from this script.
# It saves them locally to '/var/log/jenkins-install.log' AND duplicates them into the
# AWS system console logs so you can debug directly from the AWS Web Console.
exec > >(tee /var/log/jenkins-install.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "========== Starting Jenkins & Docker Installation =========="

# 1. Update OS packages to ensure we have the latest security patches
echo "--> Updating system packages..."
dnf update -y

# 2. Swap out the minimal version of curl for the full feature version 
#    This ensures we have no missing feature flags when making web requests.
echo "--> Swapping to full-feature curl..."
dnf swap -y curl-minimal curl

# 3. Install core system packages and the native Docker engine
#    - java-21-amazon-corretto: Amazon's long-term supported OpenJDK (required by modern Jenkins)
#    - git/wget/unzip: Standard utilities needed for source control and artifact fetching
#    - docker: The native container engine for AL2023
echo "--> Installing core packages and Docker..."
dnf install -y \
    java-21-amazon-corretto \
    git \
    wget \
    unzip \
    docker

# 4. Fire up the Docker service daemon and configure it to start automatically on system boots
echo "--> Starting and enabling Docker service..."
systemctl start docker
systemctl enable docker

# 5. Connect to the official Jenkins RedHat-stable package repository
echo "--> Adding the Jenkins package repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# 6. Import the official Jenkins GPG signing key to verify package integrity before installing
echo "--> Importing Jenkins GPG key..."
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# 7. Install the actual Jenkins automation engine package
echo "--> Installing Jenkins server package..."
dnf install -y jenkins

# 8. CRITICAL SECURITY STEP: Bridge Jenkins execution profile to the Docker security group.
#    By default, the 'jenkins' service user does not have root permissions to access the 
#    Docker UNIX socket. This command adds the 'jenkins' user to the 'docker' group, 
#    allowing your CI/CD pipelines to natively run 'docker build' and 'docker run'.
echo "--> Adding 'jenkins' user to the 'docker' group..."
usermod -aG docker jenkins

# 9. Configure Java Environment Settings explicitly for the Jenkins Systemd Service.
#    This dynamically looks up where Java 21 was installed, creates a systemd override folder,
#    and writes an 'override.conf' file so Jenkins safely knows exactly which Java binary to use.
echo "--> Configuring JAVA_HOME systemd overrides for Jenkins..."
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
mkdir -p /etc/systemd/system/jenkins.service.d

cat <<EOF >/etc/systemd/system/jenkins.service.d/override.conf
[Service]
Environment="JAVA_HOME=${JAVA_HOME}"
EOF

# 10. Reload systemd to pick up the new override file, then enable and restart Jenkins.
#     Restarting Jenkins here forces the new Docker group membership permissions to take effect.
echo "--> Starting and enabling Jenkins service..."
systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

# Give the background system services a brief 15-second window to fully stabilize and boot
echo "--> Waiting for Jenkins service to initialize..."
sleep 15

# 11. SANITY CHECK DIAGNOSTIC: Check if Jenkins successfully moved into an active/running state.
#     If it failed, dump the last 100 lines of system logs to the console and crash out explicitly.
if systemctl is-active --quiet jenkins; then
    echo "Jenkins started successfully"
else
    echo "Jenkins failed to start. Reviewing system logs:"
    journalctl -u jenkins -n 100 --no-pager
    exit 1
fi

# 12. Print the initial setup security token directly to the log file.
#     You can grab this token from /var/log/jenkins-install.log to unlock your Jenkins web UI.
echo "--> Displaying initial admin password for first-time login setup:"
cat /var/lib/jenkins/secrets/initialAdminPassword || true

echo "========== Creating Embedded Backup Architecture =========="

# 13. WRITE THE BACKUP SCRIPT LOCALLY ON THE HOST MACHINE:
#     Using single quotes around 'EOF' tells the shell to treat everything inside literally.
#     This prevents variables like $TIMESTAMP from evaluating right now during installation; 
#     instead, they are saved as code text to execute later when the backup script runs.
echo "--> Deploying the local automated S3 backup utility script..."
cat << 'EOF' > /usr/local/bin/jenkins_backup.sh
#!/bin/bash
# Enable basic error protections inside the backup automation process
set -eo pipefail

# Configuration Environment variables
JENKINS_HOME="/var/lib/jenkins"
BACKUP_DIR="/tmp/jenkins_backups"
S3_BUCKET="s3://nk-jenkins-data-backup-bucket-11072026"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_NAME="jenkins_backup_$TIMESTAMP.tar.gz"

# Ensure the temporary backup sandbox folder exists
mkdir -p $BACKUP_DIR

# Compresses everything inside $JENKINS_HOME into an archive bundle.
# EXCLUSIONS INPLACE: We explicitly bypass workspaces, caches, and raw compiled binaries 
# because they are massive and throw away data. We only keep configs, jobs, and user structures.
tar --exclude="$JENKINS_HOME/workspace" \
    --exclude="$JENKINS_HOME/caches" \
    --exclude="$JENKINS_HOME/plugins" \
    -czf $BACKUP_DIR/$BACKUP_NAME -C $JENKINS_HOME .

# Securely streams the compressed backup bundle up to AWS S3 storage
# using the EC2 server's assigned IAM Instance Profile credentials.
aws s3 cp $BACKUP_DIR/$BACKUP_NAME $S3_BUCKET/$BACKUP_NAME

# Wipe local trace copies to ensure we don't clog up server storage disk space over time
rm -rf $BACKUP_DIR/$BACKUP_NAME
EOF

# 14. Make the written backup script system-executable so it can be called cleanly
echo "--> Finalizing execution permissions..."
chmod +x /usr/local/bin/jenkins_backup.sh

echo "========== One-Click Provisioning Execution Completed =========="