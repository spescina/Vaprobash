#!/usr/bin/env bash

if [ "$1" == "hhvm" ]; then
    # Install HHVM

    echo ">>> Installing HHVM"

    # Get key and add to sources
    sudo add-apt-repository -y ppa:mapnik/boost
    wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
    echo deb http://dl.hhvm.com/ubuntu precise main | sudo tee /etc/apt/sources.list.d/hhvm.list

    # Update
    sudo apt-get update

    # Install HHVM
    sudo apt-get install -y hhvm

    # Replace PHP with HHVM via symlinking
    sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60
else
    # Install PHP
    if [ -z "$2" ]; then
        php_version="distributed"
    else
        php_version="$2"
    fi

    echo ">>> Installing PHP $2 version"

    if [ $php_version == "latest" ]; then
        sudo add-apt-repository -y ppa:ondrej/php5
    fi

    if [ $php_version == "previous" ]; then
        sudo add-apt-repository -y ppa:ondrej/php5-oldstable
    fi

    sudo apt-get update

    # Install PHP
    sudo apt-get install -y php5-cli php5-fpm php5-mysql php5-pgsql php5-sqlite php5-curl php5-gd php5-gmp php5-mcrypt php5-xdebug php5-memcached php5-imagick php5-intl

    # xdebug Config
    cat > $(find /etc/php5 -name xdebug.ini) << EOF
zend_extension=$(find /usr/lib/php5 -name xdebug.so)
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1

; var_dump display
xdebug.var_display_max_depth = 5
xdebug.var_display_max_children = 256
xdebug.var_display_max_data = 1024
EOF

    # PHP Error Reporting Config
    sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini
    sed -i "s/html_errors = .*/html_errors = On/" /etc/php5/fpm/php.ini

    # PHP Date Timezone
    sed -i "s/;date.timezone =.*/date.timezone = ${3/\//\\/}/" /etc/php5/fpm/php.ini
    sed -i "s/;date.timezone =.*/date.timezone = ${3/\//\\/}/" /etc/php5/cli/php.ini

    # Make sure php5-fpm is running as a Unix socket on "distributed" version
    if [ $php_version == "distributed" ]; then
        sed -i "s/listen = .*/listen = \/var\/run\/php5-fpm.sock/" /etc/php5/fpm/pool.d/www.conf
    fi

    sudo service php5-fpm restart
fi

