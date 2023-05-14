#!/bin/bash

/usr/libexec/dovecot/prestartscript
#/usr/sbin/portrelease dovecot | true
/usr/sbin/dovecot

/usr/libexec/postfix/aliasesdb | true
/usr/libexec/postfix/chroot-update | true
/usr/sbin/restorecon -R /var/spool/postfix/pid/master.pid
/usr/libexec/postfix/aliasesdb
/usr/libexec/postfix/chroot-update
/usr/sbin/postfix start

/usr/sbin/php-fpm 
/usr/sbin/httpd -DFOREGROUND

#tail -f /dev/null
