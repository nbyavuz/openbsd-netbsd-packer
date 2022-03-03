#!/bin/sh

# Save to /etc/rc.local, to be ran on startup

### get instance hostname ###

instance_hostname=$(/usr/local/bin/curl -s -H "Metadata-Flavor: Google"  http://metadata.google.internal/computeMetadata/v1/instance/name)
current_hostname=$(hostname)

if [ "$instance_hostname" != "" ]
then
    if [ "$instance_hostname" != "$current_hostname" ]
    then
        echo "Setting hostname to $instance_hostname"
        hostname $instance_hostname
        echo $instance_hostname > /etc/myname
        rcctl restart syslogd > /dev/null
    else
        echo "Hostname is correct"
    fi
else
        echo "Could not discover hostname"
fi

### set up user's keys ###

instance_keys=$(/usr/local/bin/curl -s -H "Metadata-Flavor: Google"  http://metadata.google.internal/computeMetadata/v1/project/attributes/ssh-keys)

if [ "$instance_keys" != "" ]
then
    echo "$instance_keys" | while read line
    do
        username="$(echo $line | cut -d: -f1)"
        user_key="$(echo $line | cut -d: -f2-)"
        key_comment="$(echo $line | awk '{print $NF}')"

        if [ "$username" != "" ]
        then
            /usr/sbin/useradd ${username}
            mkdir -p /home/${username}/.ssh
            touch /home/${username}/.ssh/authorized_keys
            chown -R ${username}:${username} /home/${username}

            if [ "$(grep -c "$user_key" /home/${username}/.ssh/authorized_keys)" == "0" ]
            then
                echo "$user_key" >> /home/${username}/.ssh/authorized_keys
                # Add ssh key to root
                echo "$user_key" >> /root/.ssh/authorized_keys
                chmod 600 /home/${username}/.ssh/authorized_keys
                echo "$username: added ssh-key $key_comment"
            else
                echo "$username: ssh-key $key_comment already exists"
            fi
        fi
    done
else
    echo "No keys found"
fi

### Check for bootstrap value ###

instance_bootstrap=$(/usr/local/bin/curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/bootstrap)

if [ "$instance_bootstrap" != "" ]
then
    if [ "$(echo "$instance_bootstrap" | grep -c 'was not found')" != "1" ]
    then
        if [ ! -f /var/log/bootstrap ] || [ "$(grep -c "$instance_bootstrap" /var/log/bootstrap)" == "0" ]
        then
            echo "Bootstrap: starting"
            export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin
            ftp -V -o - $instance_bootstrap | sh
            echo $instance_bootstrap >> /var/log/bootstrap
        else
            echo "Bootstrap: completed"
        fi
    else
        echo "Bootstrap: metadata not found"
    fi
else
    echo "Bootstrap: empty curl"
fi

/sbin/sysctl kern.seminfo.semmni=2048 && \
/sbin/sysctl kern.seminfo.semmns=32768
