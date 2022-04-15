#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>Welcome to ACS730 Project by Sohel Yousuf Shaikh!!!</h1><h2> My private IP is $myip</h2><br>Built by Terraform!"  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd