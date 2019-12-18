# AWS-DB-Restore
2 funtions to restore Postgresql and mongo from s3
Script was designed to be run from Jenkins using Jenkins secrets

# Requirements: 
- AWS Powershell module (tested with powershell NetCore in both Windows and Linux)
- Intall Jenkins
- Create corresponding secrets for AWS access and secret key
- Create corresponding secret for Mongo and Postgres pass
- Install PG_Restore
- Install Mongo_Restore



# Example of requirement installation for Amazon Linux 
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins
sudo amazon-linux-extras install java-openjdk11
service jenkins start
sudo chkconfig --add jenkins

curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
sudo yum install -y powershell
pwsh -> Install-Module -Name AWSPowerShell.NetCore

vi /etc/yum.repos.d/mongodb-org-3.4.repo
-> 
[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc

sudo yum install -y mongodb-org-tools

