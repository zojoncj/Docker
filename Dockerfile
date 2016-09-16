FROM debian:sid

MAINTAINER Alt Three <support@alt-three.com>

# Using debian jessie packages instead of compiling from scratch
RUN DEBIAN_FRONTEND=noninteractive \
    echo "APT::Install-Recommends \"0\";" >> /etc/apt/apt.conf.d/02recommends && \
    echo "APT::Install-Suggests \"0\";" >> /etc/apt/apt.conf.d/02recommends && \
    apt-get clean && \
    apt-get -q -y update && \
    apt-get -q -y install \
    ca-certificates php7.0-cli php7.0-fpm php7.0-gd php7.0-mbstring php7.0-mysql php7.0-pgsql php7.0-sqlite php7.0-xm \
    wget sqlite git libsqlite3-dev curl supervisor cron unzip nginx && \
    apt-get clean && apt-get autoremove -q && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man /tmp/*

COPY docker/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker/php-fpm-pool.conf /etc/php/7.0/fpm/pool.d/www.conf

RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf && \
    mkdir /run/php

WORKDIR /var/www/html/

# Install composer
RUN curl -sS https://getcomposer.org/installer | php

#RUN wget https://github.com/zojoncj/Cachet/archive/master.tar.gz && \
RUN wget https://github.com/zojoncj/Cachet/archive/2.4.tar.gz && \
    tar xzvf 2.4.tar.gz --strip-components=1 && \
    chown -R www-data /var/www/html && \
    rm -r 2.4.tar.gz && \
    php composer.phar install --no-dev -o --no-scripts

COPY docker/entrypoint.sh /sbin/entrypoint.sh
COPY docker/.env.docker /var/www/html/.env
COPY docker/crontab /etc/cron.d/artisan-schedule

RUN chmod 0644 /etc/cron.d/artisan-schedule &&\
    touch /var/log/cron.log &&\
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    rm -f /etc/nginx/sites-enabled/* && \
    rm -f /etc/nginx/conf.d/* && \
    chown www-data /var/www/html/.env


COPY docker/nginx-site.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["/sbin/entrypoint.sh"]
