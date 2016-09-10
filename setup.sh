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


echo -e "Creating user and group for apache ..."
groupadd -g 48 -r apache
useradd -u 48 --home-dir /var/www --shell /bin/bash --comment 'Apache User' -g apache apache


echo "Installing Apache ..."
yum -y update
yum -y install httpd

echo "Fixing logs for docker ..."
sed -ri 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g;' /etc/httpd/conf/httpd.conf

# Disable directory listings
sed -ri 's/ Indexes / -Indexes /g' /etc/httpd/conf/httpd.conf

mkdir -p /var/run/httpd


echo "Installing Monster-ui ..."
yum -y install kazoo-ui


echo "Fixing kazoo-ui path ..."
mv /var/www/html/kazoo-ui/* /var/www/html/


echo "Installing extras ..."
yum -y install bind-utils


rm -f /var/www/html/config/config.js 
echo "Writing config.js ..."
tee /var/www/html/config/config.js <<'EOF'
//window.translate = [];
( function(winkstart, amplify, $) {

    winkstart.config =  {
        /* Was winkstart.debug */
        debug: false,

        ws_server: 'wss://ws.valuphone.com:8080',

        advancedView: false,

        /* Registration Type */
        register_type: 'onboard',

        /* Do you want the signup button or not ? default to false if not set */
        hide_registration: true,

        onboard_roles: {
            'default': {
                apps: {
                    voip: {
                        label: 'Hosted PBX',
                        icon: 'phone',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    },
                    pbxs: {
                        label: 'PBX Connector',
                        icon: 'device',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    },
                    numbers: {
                        label: 'Number Manager',
                        icon: 'menu1',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    }
                },
                available_apps: ['voip', 'cluster', 'userportal', 'accounts', 'developer', 'numbers', 'pbxs'],
                default_api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
            },
            'reseller': {
                apps: {
                    voip: {
                        label: 'Hosted PBX',
                        icon: 'phone',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    },
                    accounts: {
                        label: 'Accounts',
                        icon: 'account',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    },
                    numbers: {
                        label: 'Number Manager',
                        icon: 'menu1',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    }
                },
                available_apps: ['voip', 'cluster', 'userportal', 'accounts', 'developer', 'numbers', 'pbxs'],
                default_api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
            },
            'small_office': {
                apps: {
                    voip: {
                        label: 'Hosted PBX',
                        icon: 'phone',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    },
                    numbers: {
                        label: 'Number Manager',
                        icon: 'menu1',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    }
                },
                available_apps: ['voip', 'cluster', 'userportal', 'accounts', 'developer', 'numbers', 'pbxs'],
                default_api_url: 'http://plasma.valuphone.com:8000/v1'
            },
            'single_phone': {
                apps: {
                    voip: {
                        label: 'Hosted PBX',
                        icon: 'phone',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    },
                    numbers: {
                        label: 'Number Manager',
                        icon: 'menu1',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    }
                },
                available_apps: ['voip', 'cluster', 'userportal', 'accounts', 'developer', 'numbers', 'pbxs'],
                default_api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
            },
            'api_developer': {
                apps: {
                    developer: {
                        label: 'Developer Tool',
                        icon: 'connectivity',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    },
                    numbers: {
                        label: 'Number Manager',
                        icon: 'menu1',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    }
                },
                available_apps: ['voip', 'cluster', 'userportal', 'accounts', 'developer', 'numbers', 'pbxs'],
                default_api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
            },
            'voip_minutes': {
                apps: {
                    pbxs: {
                        label: 'PBX Connector',
                        icon: 'device',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    },
                    numbers: {
                        label: 'Number Manager',
                        icon: 'menu1',
                        api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
                    }
                },
                available_apps: ['voip', 'cluster', 'userportal', 'accounts', 'developer', 'numbers', 'pbxs'],
                default_api_url: 'http://plasma.valuphone.com:8000/v1' //'http://plasma.valuphone.com:8000/v1'
            }
        },

        device_threshold: [5, 20, 50, 100],

        /* web server used by the cdr module to show the link to the logs */
        logs_web_server_url: 'http://cdrs.valuphone.com/',

        /* Customized name displayed in the application (login page, resource module..) */
        company_name: 'valuphone',

        base_urls: {
            'u.2600hz.com': {
                /* If this was set to true, Winkstart would look for u_2600hz_com.png in config/images/logos */
                custom_logo: false
            },
            'apps.2600hz.com': {
                custom_logo: false
            }
        },

        /* Was winkstart.realm_suffix */
        realm_suffix: {
            login: '.sip.valuphone.com',
            register: '.trial.valuphone.com'
        },

        /* What applications is available for a user that just registered */
        register_apps: {
            cluster: {
               label: 'Cluster Manager',
               icon: 'cluster_manager',
               api_url: 'https://api.valuphone.com/v1'
            },
            voip: {
                label: 'Trial PBX',
                icon: 'phone',
                api_url: 'https://api.valuphone.com/v1'
            },
            accounts: {
                label: 'Accounts',
                icon: 'account',
                api_url: 'https://api.valuphone.com/v1'
            }
        },

        /* Custom links */
        nav: {
            help: 'http://help.valuphone.com',
            learn_more: 'http://www.valuphone.com/'
        },

        default_api_url: 'https://api.valuphone.com/v1',
        default_api_v2_url: 'http://api.valuphone.com/v2',

        available_apps: {
            'voip': {
                id: 'voip',
                label: _t('config', 'voip_label'),
                icon: 'device',
                desc: _t('config', 'voip_desc')
            },
            'cluster': {
                id: 'cluster',
                label: _t('config', 'cluster_label'),
                icon: 'cluster_manager',
                desc: _t('config', 'cluster_desc')
            },
            'userportal': {
                id: 'userportal',
                label: _t('config', 'userportal_label'),
                icon: 'user',
                desc: _t('config', 'userportal_desc')
            },
            'accounts': {
                id: 'accounts',
                label: _t('config', 'accounts_label'),
                icon: 'account',
                desc: _t('config', 'accounts_desc')
            },
            'developer': {
                id: 'developer',
                label: _t('config', 'developer_label'),
                icon: 'connectivity',
                desc: _t('config', 'developer_desc')
            },
            'pbxs': {
                id: 'pbxs',
                label:  _t('config', 'pbxs_label'),
                icon: 'device',
                desc: _t('config', 'pbxs_desc')
            },
            'numbers': {
                id: 'numbers',
                label:  _t('config', 'numbers_label'),
                icon: 'menu1',
                desc: _t('config', 'numbers_desc')
            },
            'browserphone': {
                id: 'browserphone',
                label: _t('config', 'browserphone_label'),
                icon: 'menu1',
                desc: _t('config', 'browserphone_desc')
            }
        }
    };

    winkstart.apps = {
        'auth' : {
            api_url: 'https://api.valuphone.com/v1',
            /* These are some settings that are set automatically. You are free to override them here.
            account_id: null,
            auth_token: null,
            user_id: null,
            realm: null
            */
        },
        'myaccount': {}
    };

    amplify.cache = false;

})(window.winkstart = window.winkstart || {}, window.amplify = window.amplify || {}, window.language, jQuery);
EOF


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
