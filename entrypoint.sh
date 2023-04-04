#!/bin/bash

/usr/libexec/dovecot/prestartscript
/usr/sbin/portrelease dovecot | true
/usr/sbin/dovecot

/usr/libexec/postfix/aliasesdb | true
/usr/libexec/postfix/chroot-update | true
/usr/sbin/postfix -c /etc/postfix start

/usr/sbin/httpd -DFOREGROUND
#tail -f /dev/null
