#!/bin/sh

echo "Giving ES time to start..."
sleep 5
until curl -sS "http://$ES_HOST:$ES_PORT/_cluster/health?wait_for_status=yellow"
do
    echo "Waiting for ES to start"
    sleep 1
done
echo

if [ ! -f /data/initialized ]; then
	/data/moloch/db/db.pl http://$ES_HOST:$ES_PORT init
	/data/moloch/bin/moloch_add_user.sh admin "Admin User" $MOLOCH_ADMIN_PASSWORD --admin
else
	touch /data/initialized
fi

# Launch capture
nohup $MOLOCHDIR/bin/moloch-capture > $MOLOCHDIR/logs/capture.log

# Launch viewer
nohup $MOLOCHDIR/bin/node $MOLOCHDIR/viewer/viewer.js -c $MOLOCHDIR/etc/config.ini > $MOLOCHDIR/logs/viewer.log

echo "Look at log files for errors"
echo "  /data/moloch/logs/viewer.log"
echo "  /data/moloch/logs/capture.log"
echo "Visit http://127.0.0.1:8005 with your favorite browser."
echo "  user: admin"
echo "  password: $MOLOCH_ADMIN_PASSWORD"