#!/bin/bash

KAZOO_RELEASE=R15B

# add 2600hz yum repos
echo "Creating /etc/yum.repos.d/2600hz.repo ..."
cat <<-EOF > /etc/yum.repos.d/2600hz.repo
	[2600hz_base_staging]
	name=2600hz-$releasever - Base Staging
	baseurl=http://repo.2600hz.com/Staging/CentOS_6/x86_64/Base/
	gpgcheck=0
	enabled=1

	[2600hz_${KAZOO_RELEASE}_staging]
	name=2600hz-$releasever - ${KAZOO_RELEASE} Staging
	baseurl=http://repo.2600hz.com/Staging/CentOS_6/x86_64/${KAZOO_RELEASE}/
	gpgcheck=0
	enabled=1
EOF


echo -e "Creating user and group for bigcouch ..."
groupadd -g 48 -r apache
useradd -u 48 --home-dir /var/www --shell /bin/bash --comment 'Apache User' -g apache apache


echo "Installing Apache ..."
yum -y update
yum -y install httpd

echo "Fixing logs for docker ..."
sed -ri 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g;' /etc/httpd/conf/httpd.conf

mkdir -p /var/run/httpd


echo "Installing Monster-ui ..."
yum -y install kazoo-ui


echo "Installing extras ..."
yum -y install bind-utils

echo "Installing JQ ..."
curl -o /usr/local/bin/jq -sSL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
chmod +x /usr/local/bin/jq


# In the future, install other monster-ui components here #


echo "Writing Hostname override fix ..."
tee /usr/local/bin/hostname-fix <<'EOF'
#!/bin/bash

fqdn() {
	local IP=$(/bin/hostname -i | sed 's/\./-/g')
	local DOMAIN='default.pod.cluster.local'
	echo "${IP}.${DOMAIN}"
}

short() {
	local IP=$(/bin/hostname -i | sed 's/\./-/g')
	echo $IP
}

ip() {
	/bin/hostname -i
}

if [[ "$1" == "-f" ]]; then
	fqdn
elif [[ "$1" == "-s" ]]; then
	short
elif [[ "$1" == "-i" ]]; then
	ip
else
	short
fi
EOF
chmod +x /usr/local/bin/hostname-fix

echo "Writing .bashrc ..."
tee ~/.bashrc <<'EOF'
#!/bin/bash

if [ "$KUBERNETES_HOSTNAME_FIX" == true ]; then
	export HOSTNAME=$(hostname -f)
fi
EOF
chown apache:apache ~/.bashrc


echo "Setting Ownership & Permissions ..."

# /etc/httpd
chown -R apache:apache /etc/httpd 
chmod -R 0755 /etc/httpd

# /etc/httpd/conf
find /etc/httpd/conf -type f -exec chmod 0644 {} \;
find /etc/httpd/conf -type d -exec chmod 0700 {} \;

# /etc/httpd/conf.d
find /etc/httpd/conf.d -type f -exec chmod 0644 {} \;
find /etc/httpd/conf.d -type d -exec chmod 0700 {} \;

# /var/log/httpd
chown -R apache:apache /var/log/httpd
chmod -R 0770 /var/log/httpd

# /usr/lib64/httpd
chown -R apache:apache /usr/lib64/httpd
chmod -R 0755 /usr/lib64/httpd

# /var/www
chown -R apache:apache /var/www
chown -R 0755 /var/www

# /var/run/httpd
chown -R apache:apache /var/run/httpd
chmod -R 0755 /var/run/httpd

# /var/www/html/kazoo-ui
chown -R apache:apache /var/www/html/kazoo-ui
chmod -R 0755 /var/www/html/kazoo-ui


echo "Cleaning up ..."
yum clean all
rm -r /tmp/setup.sh
