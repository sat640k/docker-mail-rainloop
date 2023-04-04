FROM centos:7

EXPOSE 25
EXPOSE 80
EXPOSE 443

RUN rm -f /etc/localtime
RUN cp -pf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN yum -y update
RUN yum -y update
#RUN set -o pipefail && curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
RUN yum -y install epel-release
RUN rpm -Uvh https://rpms.remirepo.net/enterprise/remi-release-7.rpm

# install postfix and dovecot
RUN yum -y install postfix dovecot dovecot-devel

# install php
RUN yum -y --enablerepo=remi,remi-php72 install php php-common php-devel php-gd php-mbstring php-json php-curl php-xml

# install apache24
RUN yum -y install httpd mod_ssl
# install patch
RUN yum -y install patch
# install openssl
RUN yum -y install openssl openssl-libs openssl-devel
# install patch
RUN yum -y install patch

# patch httpd setting
WORKDIR /etc/httpd/conf/
RUN cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig
COPY ./conf/apache/httpd.conf.patch /etc/httpd/conf/
RUN patch -u httpd.conf < httpd.conf.patch
# patch httpd ssl setting
WORKDIR /etc/httpd/conf.d/
RUN cp -p /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.orig
COPY ./conf/apache/ssl.conf.patch /etc/httpd/conf.d/
RUN patch -u ssl.conf < ssl.conf.patch

# 
RUN mkdir -p /etc/httpd/certs
WORKDIR /etc/httpd/certs
RUN openssl req -x509 -sha256 -nodes -days 398 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/C=JP/ST=Tokyo/L=Tokyo/O=testmail/OU=testmail/CN=testmail.local"



# set config postfix
COPY ./conf/postfix/main.cf /etc/postfix/
# set config dovecot
COPY ./conf/dovecot/dovecot.conf /etc/dovecot/
COPY ./conf/dovecot/10-auth.conf /etc/dovecot/conf.d/
COPY ./conf/dovecot/10-mail.conf /etc/dovecot/conf.d/
COPY ./conf/dovecot/10-master.conf /etc/dovecot/conf.d/

# install rainloop
WORKDIR /var/www/html
RUN curl -sL https://repository.rainloop.net/installer.php | php

# set rainloop config
COPY ./conf/rainloop/application.ini /var/www/html/data/_data_/_default_/configs/
RUN rm -f /var/www/html/data/_data_/_default_/domains/*.ini
COPY ./conf/rainloop/testmail.local.ini /var/www/html/data/_data_/_default_/domains/
RUN chown -R apache:apache /var/www/html/*

# create user test
RUN useradd test | true
RUN echo -n "test" | passwd --stdin test | true

# run container
WORKDIR /root
COPY ./entrypoint.sh /root/
RUN chmod 700 /root/entrypoint.sh

CMD ["sh", "/root/entrypoint.sh"]
