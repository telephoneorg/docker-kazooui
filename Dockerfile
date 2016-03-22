FROM centos:6

MAINTAINER joe <joe@valuphone.com>

LABEL   os="linux" \
        os.distro="centos" \
        os.version="6"

LABEL   image.name="kazoo-ui" \
        image.version="1"

ENV     TERM=xterm

COPY    setup.sh /tmp/setup.sh
RUN     /tmp/setup.sh

COPY    entrypoint /usr/bin/entrypoint

ENV     HOME=/var/www \
        PATH=/var/www/bin:$PATH \
        KUBERNETES_HOSTNAME_FIX=true

VOLUME  ["/var/www/html/kazoo-ui"]

EXPOSE  80 443

# USER    apache

WORKDIR /var/www

CMD     ["/usr/bin/entrypoint"]
