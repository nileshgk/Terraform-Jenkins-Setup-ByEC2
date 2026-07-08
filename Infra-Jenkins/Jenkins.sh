#!/bin/bash
# Update the system packages
dnf update -y

# Install Java 17 (Required for modern Jenkins versions)
dnf install java-17-amazon-corretto-devel -y

# Import the Jenkins repository and key
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Upgrade packages to ensure repository metadata is fresh
dnf upgrade -y

# Install Jenkins
dnf install jenkins -y

# Enable Jenkins to start on boot and start the service immediately
systemctl enable jenkins
systemctl start jenkins