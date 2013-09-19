FROM ubuntu
MAINTAINER Bryce

ENV DEBIAN_FRONTEND noninteractive

RUN : > /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu precise main" >> /etc/apt/sources.list
RUN echo "deb http://ppa.launchpad.net/ondrej/php5/ubuntu precise main" >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" >> /etc/apt/sources.list
RUN echo "deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu precise main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C E5267A6C 0xcbcb082a1bb943db
RUN apt-get update
RUN apt-get -y upgrade
RUN cat /proc/mounts > /etc/mtab

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

RUN apt-get -y install nginx php5-fpm mariadb-server php5-mysqlnd python python-setuptools curl git unzip pwgen

RUN apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl

RUN sed -i '/O_DIRECT/d' /etc/mysql/my.cnf


#TODO config

RUN /usr/bin/easy_install supervisor
ADD ./supervisord.conf /etc/supervisord.conf
#RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default


#RUN apt-get update
#
## Basic Requirements
#RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server mariadb-client nginx php5-fpm php5-mysqlnd php-apc pwgen python-setuptools curl git unzip
#
## Wordpress Requirements
#
## mysql config
#RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
#
## nginx config
#RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
## since 'upload_max_filesize = 2M' in /etc/php5/fpm/php.ini
#RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 3m/" /etc/nginx/nginx.conf
#RUN echo "daemon off;" >> /etc/nginx/nginx.conf
#
## php-fpm config
#RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
#RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
#RUN find /etc/php5/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;
#
## nginx site conf
#ADD ./nginx-site.conf /etc/nginx/sites-available/default
#
## Supervisor Config
#RUN /usr/bin/easy_install supervisor
#ADD ./supervisord.conf /etc/supervisord.conf
#
## Install Wordpress
ADD http://wordpress.org/latest.tar.gz /wordpress.tar.gz
RUN tar xvzf /wordpress.tar.gz -C /usr/share/nginx
RUN mv /usr/share/nginx/html/5* /usr/share/nginx/wordpress
RUN rm -rf /usr/share/nginx/html
RUN mv /usr/share/nginx/wordpress /usr/share/nginx/www
RUN chown -R www-data:www-data /usr/share/nginx/www
#
## Wordpress Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh
#
## private expose
EXPOSE 80
#
CMD ["/bin/bash", "/start.sh"]
