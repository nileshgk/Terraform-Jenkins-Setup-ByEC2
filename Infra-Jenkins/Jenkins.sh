#!/bin/bash
set -euxo pipefail

# Log all output
exec > >(tee /var/log/jenkins-install.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "========== Starting Jenkins Installation =========="

# Update OS
dnf update -y

# Replace curl-minimal with curl (only if you really need curl)
dnf swap -y curl-minimal curl

# Install required packages
dnf install -y \
    java-21-amazon-corretto \
    git \
    wget \
    unzip

# Verify Java
java -version

# Add Jenkins repository
wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import Jenkins GPG key
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
dnf install -y jenkins

# Detect JAVA_HOME
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

# Configure JAVA_HOME for Jenkins
mkdir -p /etc/systemd/system/jenkins.service.d

cat <<EOF >/etc/systemd/system/jenkins.service.d/override.conf
[Service]
Environment="JAVA_HOME=${JAVA_HOME}"
EOF

# Reload systemd
systemctl daemon-reload

# Enable and start Jenkins
systemctl enable jenkins
systemctl restart jenkins

# Wait for startup
sleep 15

# Verify Jenkins is running
if systemctl is-active --quiet jenkins; then
    echo "Jenkins started successfully"
else
    echo "Jenkins failed to start"
    journalctl -u jenkins -n 100 --no-pager
    exit 1
fi

# Display initial admin password
cat /var/lib/jenkins/secrets/initialAdminPassword || true

echo "========== Jenkins Installation Completed =========="