#!/bin/bash

set -xe

sed -i "s~SSLCertificateFile.*~SSLCertificateFile $HTTPS_CERT~" /etc/apache2/sites-available/ssp-site.conf
sed -i "s~SSLCertificateKeyFile.*~SSLCertificateKeyFile $HTTPS_KEY~" /etc/apache2/sites-available/ssp-site.conf


exec apache2ctl -D FOREGROUND
