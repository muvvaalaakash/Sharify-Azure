#!/bin/bash
# Update and install Nginx
apt-get update
apt-get install -y nginx git

# Clean default Nginx page
rm -rf /var/www/html/*

# Clone the repository
git clone https://github.com/muvvaalaakash/Shareify.git /tmp/Shareify

# Copy frontend files to /var/www/html
cp -r /tmp/Shareify/frontend/* /var/www/html/

# Ensure relative API path in app.js
sed -i 's|const API_BASE = ".*";|const API_BASE = "/api";|g' /var/www/html/app.js

# Restart Nginx
systemctl restart nginx
systemctl enable nginx
