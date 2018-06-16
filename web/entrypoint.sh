#!/bin/bash

rm -f /run/nginx.pid

/usr/sbin/varnishd -a :80 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s malloc,32m &
varnish_pid="$!"; pids="$varnish_pid"

# set environment variables for php fpm
env_conf_file="/opt/phpbrew/php/php-7/etc/php-fpm.d/www-env.conf"
echo "[www]" > $env_conf_file
old_IFS="$IFS"
IFS='
'
for current in $(env); do
	env_key=${current%=*}
	env_value=${current#*=}
	if [ "$env_key" != "_" ]; then
		conf_entry="env[$env_key] = \"$env_value\""
		# check if conf line is not longer than 1024 chars
		if [ ${#conf_entry} -gt 1024 ]; then
			>&2 echo "WARNING: $env_key is to long and was not written to $env_conf_file"
		else
			echo "env[$env_key] = \"$env_value\"" >> $env_conf_file
		fi
	fi
done
IFS="$old_IFS"

export PHP_INI_SCAN_DIR=/opt/phpbrew/php/php-7/etc/fpm
source ~/.phpbrew/bashrc
phpbrew --no-interact switch php-7
phpbrew --no-interact fpm start php-7 &
phpfpm_pid="$!"; pids="$pids $phpfpm_pid"

for pid in $pids; do
	if [ "$pid" = "$varnish_pid" ]; then
		proc_name="varnishd"
	elif [ "$pid" = "$phpfpm_pid" ]; then
		proc_name="php-fpm"
	fi
	if wait "$pid"; then
		echo "Starting $proc_name DONE"
	else
		echo "Starting $proc_name ERROR"
	fi
done

service nginx start
