FROM debian:buster


ENV HTTPS_CERT "/etc/ssl/certs/ssl-cert-snakeoil.pem"
ENV HTTPS_KEY  "/etc/ssl/private/ssl-cert-snakeoil.key"


ENV SSP_VERSION 1.3
ENV SSP_PACKAGE ltb-project-self-service-password

ARG DEBIAN_FRONTEND=noninteractive

# https://ltb-project.org/documentation/self-service-password
# https://github.com/openfrontier/docker-ldap-ssp
# https://linuxize.com/post/how-to-install-apache-on-debian-10/
# https://www.linode.com/docs/security/ssl/ssl-apache2-debian-ubuntu/
# https://www.linode.com/docs/security/ssl/create-a-self-signed-tls-certificate/
# https://www.linode.com/docs/websites/hosting-a-website-ubuntu-18-04/

# RUN \
#     sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
#     sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list

RUN \
    apt-get -q -y update && \
    apt-get install -q -y procps vim-tiny curl && \
    apt-get install -q -y apache2 libapache2-mod-php php-mbstring php-curl php-ldap

COPY ssp-site.conf /etc/apache2/sites-available/
COPY docker-entrypoint.sh /

RUN \
    chown root:root /etc/apache2/sites-available/ssp-site.conf && \
    chmod 644 /etc/apache2/sites-available/ssp-site.conf && \
    chown root:root /docker-entrypoint.sh && \
    chmod 744 /docker-entrypoint.sh && \
    a2enmod ssl && \
    a2dissite *default && \
    a2ensite ssp-site.conf && \
    curl -L https://ltb-project.org/archives/${SSP_PACKAGE}-${SSP_VERSION}.tar.gz -o ssp.tar.gz  && \
    tar xf ssp.tar.gz -C /var/www/html && rm -f ssp.tar.gz && \
    mv /var/www/html/${SSP_PACKAGE}-${SSP_VERSION} /var/www/html/ssp && \
    chown -R www-data:www-data /var/www/html/ssp && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


EXPOSE 443
WORKDIR /var/www/html/

ENTRYPOINT ["/docker-entrypoint.sh"]
