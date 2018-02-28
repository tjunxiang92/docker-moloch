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
nohup exec $MOLOCH_INSTALL_DIR/bin/moloch-capture 2>&1 | tee  $MOLOCH_INSTALL_DIR/logs/capture.log

# Launch viewer
nohup exec $MOLOCH_INSTALL_DIR/bin/node $MOLOCH_INSTALL_DIR/viewer/viewer.js -c $MOLOCH_INSTALL_DIR/etc/config.ini 2>&1 | tee $MOLOCH_INSTALL_DIR/logs/viewer.log

echo "Look at log files for errors"
echo "  /data/moloch/logs/viewer.log"
echo "  /data/moloch/logs/capture.log"
echo "Visit http://127.0.0.1:8005 with your favorite browser."
echo "  user: admin"
echo "  password: $MOLOCH_ADMIN_PASSWORD"