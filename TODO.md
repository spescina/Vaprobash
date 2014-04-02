# To Do

### General:

* Done - Users can select between HHVM or PHP in `Vagrantfile`
* Easy tests needed to determine if HHVM in installed, if PHP is installed or neither
    * This is made complicated because hhvm is symlinked to PHP if it is installed. Perhaps always assume one or the other (as is hopefully setup correctly)

### Apache

* Done - Apache 2.4 uses mod_proxy_fcgi instead of libpache2-mod-fastcgi
* Apache virtualhosts uses `ProxyPassMatch` via uncommenting it
* Done - Add commented `ProxyPassMatch` to vhost by default
* Done - HHVM script to setup fastCGI run if applicable

### Nginx

* HHVM script to setup FastCGI if applicable
* Check `if [ -f /etc/nginx/hhvm.conf ]; then` and include it in Nginx config if exists
* Alternatively create a similar file for php-fpm if applicable
* Make it easy to switch between php-fpm handle conf vs hhvm.conf
    * Perhaps by symlinking file `/etc/nginx/fastcgi.conf` to either hhvm.conf for php-fpm.conf and always include `fastcgi.conf` in Nginx if Apache or Nginx is installed
* Make reliable test for HHVM vs PHP installed (perhaps pass in parameter instead of testing, but needs to handle PHP, HHVM or neither!)
