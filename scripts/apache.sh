#!/usr/bin/env bash

# Test if PHP is installed
hhvm -v > /dev/null 2>&1
HHVM_IS_INSTALLED=$?

php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

echo ">>> Installing Apache Server"

[[ -z "$1" ]] && { echo "!!! IP address not set. Check the Vagrant file."; exit 1; }

if [ -z "$2" ]; then
	public_folder="/vagrant"
else
	public_folder="$2"
fi

# Add repo for latest FULL stable Apache
# (Required to remove conflicts with PHP PPA due to partial Apache upgrade within it)
sudo add-apt-repository -y ppa:ondrej/apache2

# Update Again
sudo apt-get update

# Install Apache
sudo apt-get install -y apache2

echo ">>> Configuring Apache"

# Apache Config
sudo a2enmod rewrite actions ssl proxy_fcgi
curl -L https://gist.githubusercontent.com/fideloper/2710970/raw/vhost.sh > vhost
sudo chmod guo+x vhost
sudo mv vhost /usr/local/bin

# Create a virtualhost to start, with SSL certificate
sudo vhost -s $1.xip.io -d $public_folder -p /etc/ssl/xip.io -c xip.io

if [[ $HHVM_IS_INSTALLED -eq 0 ]]; then
    sudo /usr/share/hhvm/install_fastcgi.sh
    sudo service hhvm restart
fi

if [[ $HHVM_IS_INSTALLED -eq 0 || $PHP_IS_INSTALLED -eq 0 ]]; then
    # Add Proxy Pass
    # ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000$public_folder/$1
    # inside of virtualhost
    # by finding "# ProxyPassMatch" and replacing with "ProxyPassMatch"
fi

sudo service apache2 restart
