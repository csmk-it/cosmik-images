#!/bin/sh

mkdir -p /config/registry
cp -v /config.yml /config/registry
if [ "$REGISTRY_AUTH_HTPASSWD" = "" ]; then
	echo "ERROR: htpasswd is empty"
	exit 1
fi
touch /config/registry/htpasswd
REGISTRY_AUTH_HTPASSWD=$(echo $REGISTRY_AUTH_HTPASSWD | sed s/\\\\n/" "/)
for user in $REGISTRY_AUTH_HTPASSWD ; do
	name=`echo "$user" | cut -d ":" -f 1`
	pass=`echo "$user" | cut -d ":" -f 2`
	htpasswd -Bb /config/registry/htpasswd $name $pass
    echo "user $name added"
done
