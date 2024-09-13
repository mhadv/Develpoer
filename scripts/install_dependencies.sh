#!/bin/bash
i
# Define variables
TOMCAT_DIR="/opt/tomcat"
WAR_FILE="/home/ubuntu/index.war"
INDEX_JSP_CONTENT="<%@ page contentType=\"text/html;charset=UTF-8\" language=\"java\" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset=\"UTF-8\">
    <title>Index Page</title>
</head>
<body>
    <h1>Welcome to Tomcat!</h1>
    <p>This is the index.jsp page.</p>
</body>
</html>"

# Update and upgrade the system
echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

# Install prerequisites
echo "Installing prerequisites..."
sudo apt install ruby wget openjdk-11-jdk -y

# Download and install CodeDeploy agent
echo "Downloading and installing CodeDeploy agent..."
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start

# Download and install Apache Tomcat
echo "Downloading and installing Apache Tomcat..."
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.90/bin/apache-tomcat-9.0.90.tar.gz
tar xvf apache-tomcat-9.0.90.tar.gz
sudo mv apache-tomcat-9.0.90 /opt/tomcat

# Configure environment variables
echo "Configuring environment variables..."
echo 'export CATALINA_HOME=/opt/tomcat' >> ~/.bashrc
echo 'export PATH=$PATH:$CATALINA_HOME/bin' >> ~/.bashrc
source ~/.bashrc

# Set ownership for Tomcat directory
echo "Setting ownership for Tomcat directory..."
sudo chown -R ubuntu:ubuntu /opt/tomcat

# Create Tomcat systemd service file
echo "Creating Tomcat systemd service file..."
sudo bash -c 'cat > /etc/systemd/system/tomcat.service <<EOL
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=ubuntu
Group=ubuntu
Environment="CATALINA_HOME=/opt/tomcat"
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOL'

# Reload systemd, start and enable Tomcat service
echo "Reloading systemd, starting and enabling Tomcat service..."
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo systemctl status tomcat.service

# Deploy WAR file and create index.jsp
echo "Deploying WAR file and creating index.jsp..."
sudo cp "$WAR_FILE" "$TOMCAT_DIR/webapps/"
echo "$INDEX_JSP_CONTENT" | sudo tee "$TOMCAT_DIR/webapps/ROOT/index.jsp" > /dev/null

# Set permissions for Tomcat directory
echo "Setting permissions for Tomcat directory..."
sudo chown -R ubuntu:ubuntu /opt/tomcat

# Verify Java and Tomcat
echo "Verifying Java and Tomcat..."
echo "JAVA_HOME: $JAVA_HOME"
$TOMCAT_DIR/bin/startup.sh
sudo systemctl status tomcat.service
sudo journalctl -xeu tomcat.service

echo "Script completed."

