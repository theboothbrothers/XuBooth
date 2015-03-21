#!/bin/bash

function check_prerequisites() {
	check=0

	echo "Checking prerequisites..."

	if ! type "gphoto2" 2> /dev/null 1> /dev/null; then
		echo " * gPhoto2 is missing!"
		((check++))
	fi

	if ! type "eog" 2> /dev/null 1> /dev/null; then
		echo " * eog is missing!"
		((check++))
	fi

	if ! type "feh" 2> /dev/null 1> /dev/null; then
		echo " * feh is missing!"
		((check++))
	fi

	if ! type "exiftool" 2> /dev/null 1> /dev/null; then
		echo " * exiftool is missing!"
		((check++))
	fi

	if ! type "gm" 2> /dev/null 1> /dev/null; then
		echo " * graphicsmagick is missing!"
		((check++))
	fi

	if ! type "hostapd" 2> /dev/null 1> /dev/null; then
		echo " * hostapd is missing!"
		((check++))
	fi

	if ! type "dnsmasq" 2> /dev/null 1> /dev/null; then
		echo " * dnsmasq is missing!"
		((check++))
	fi

	if ! type "lighttpd" 2> /dev/null 1> /dev/null; then
		echo " * lighttpd is missing!"
		((check++))
	fi

	if ! type "php5-cgi" 2> /dev/null 1> /dev/null; then
		echo " * php5-cgi is missing!"
		((check++))
	fi

	if ! type "git" 2> /dev/null 1> /dev/null; then
		echo " * git is missing!"
		((check++))
	fi

	if [ $check -gt 0 ]; then
		echo
		echo "One or more prerequisites are missing! Please install them."
		echo "Press <enter> to quit"
		read
		exit 1
	else

		if [ -e XuBooth.lock ]; then
			echo " * found XuBooth.lock. XuBooth is still running or hasn't been closed properly."
			echo
			echo "Please check and remove XuBooth.lock before starting XuBooth again."
			read
			exit 1
		fi

		touch XuBooth.lock

		echo " * we have everything we need. Let's start!"
		echo 
	fi
}

function wait_for_camera() {
	while [ `gphoto2 --auto-detect | grep -s -i -c usb` -eq 0 ]
	do
	    sleep 1
	done
}

function cleanup() {
	killall eog 2> /dev/null
	killall feh 2> /dev/null

	rm photo_dir.tmp 2> /dev/null
	rm XuBooth.lock 2> /dev/null

	if [ $ota_active -eq 1 ]; then
		echo "Stopping OTA..."
		stopOTA
	fi

	echo "Done."
	read
}

function ctrl_c() {
	echo
	echo ----------------------------------------------------------------
	echo " Detected ctrl+c. Cleaning up and shutting down script"
	echo ----------------------------------------------------------------
	cleanup
	exit 1
}

function startOTA() {
	# create folders for OTA gallery
	mkdir $photo_dir/ota-medium
	mkdir $photo_dir/ota-small

	# link folders for OTA gallery
	rm ota/img-s 2> /dev/null
	rm ota/img-m 2> /dev/null
	rm ota/img-l 2> /dev/null
	ln -s ../$photo_dir ota/img-l
	ln -s ../$photo_dir/ota-medium ota/img-m
	ln -s ../$photo_dir/ota-small ota/img-s

	# save original config files
	cp /etc/default/hostapd ./ota-conf/hostapd.orig
	cp /etc/dnsmasq.conf ./ota-conf/dnsmasq.conf.orig
	cp /etc/network/interfaces ./ota-conf/interfaces.orig
	cp /etc/lighttpd/lighttpd.conf ./ota-conf/lighttpd.conf.orig

	# ----------------------------------------------------
	# we now need root permissions to do the heavy lifting
	# ----------------------------------------------------
	echo " * need root permissions to run OTA service"
sudo bash <<"EOF" 
	# call standalone config file
	source XuBooth-config.sh

	# put our config files into place and replace placeholders
	cp ./ota-conf/dnsmasq.conf /etc/dnsmasq.conf
	sed -i "s:<<<dev_wlan0>>>:$ota_dev_wlan0:g" /etc/dnsmasq.conf
	sed -i "s:<<<dev_eth0>>>:$ota_dev_eth0:g" /etc/dnsmasq.conf

	cp ./ota-conf/hostapd.conf /etc/hostapd.conf
	sed -i "s:<<<dev_wlan0>>>:$ota_dev_wlan0:g" /etc/hostapd.conf
	sed -i "s:<<<wlan_driver>>>:$ota_wlan_driver:g" /etc/hostapd.conf
	sed -i "s:<<<wlan_ssid>>>:$ota_wlan_ssid:g" /etc/hostapd.conf
	sed -i "s:<<<wlan_pass>>>:$ota_wlan_pass:g" /etc/hostapd.conf
	echo "DAEMON_CONF=/etc/hostapd.conf" > /etc/default/hostapd

	cp ./ota-conf/interfaces /etc/network/interfaces
	sed -i "s:<<<dev_wlan0>>>:$ota_dev_wlan0:g" /etc/network/interfaces
	sed -i "s:<<<dev_eth0>>>:$ota_dev_eth0:g" /etc/network/interfaces

	cp ./ota-conf/lighttpd.conf /etc/lighttpd/lighttpd.conf
	sed -i "s:<<<xubooth_dir>>>:$(pwd):g" /etc/lighttpd/lighttpd.conf

	# restart Network Manager and ligHTTPd
	service network-manager restart
	service lighttpd restart

	# reload wlan interface
	ifdown $ota_dev_wlan0
	ifup $ota_dev_wlan0
EOF

	echo
}

function stopOTA() {
	# ----------------------------------------------------
	# we now need root permissions to do the heavy lifting
	# ----------------------------------------------------
	echo " * need root permissions to stop OTA service"
sudo bash <<"EOF" 
	# call standalone config file
	source XuBooth-config.sh

	# shutdown wlan interface
	ifdown $ota_dev_wlan0

	# restore original config files
	cp ./ota-conf/hostapd.orig /etc/default/hostapd
	cp ./ota-conf/dnsmasq.conf.orig /etc/dnsmasq.conf
	cp ./ota-conf/interfaces.orig /etc/network/interfaces
	cp ./ota-conf/lighttpd.conf.orig /etc/lighttpd/lighttpd.conf

	# restart Network Manager and ligHTTPd
	service network-manager restart
	service lighttpd restart

	# reload wlan interface
	ifdown $ota_dev_wlan0
	ifup $ota_dev_wlan0
EOF

	# delete stored original config files
	rm ./ota-conf/hostapd.orig
	rm ./ota-conf/dnsmasq.conf.orig
	rm ./ota-conf/interfaces.orig
	rm ./ota-conf/lighttpd.conf.orig
}

# call standalone config file
if [ ! -f XuBooth-config.sh ]; then
	echo "XuBooth-config.sh is missing. Please copy XuBooth-config.sh.sample and modify it to your needs."
	read
	exit 1
else
	source XuBooth-config.sh
fi

# check if prerequisites are installed
check_prerequisites

# define function that is called when ctrl+c is pressed
trap ctrl_c SIGINT

# define timestamp
timestamp=$(date "+%Y%m%d-%H%M%S")

# define photo dir and save this in photo_dir.tmp
photo_dir=photos_$timestamp
echo $photo_dir > photo_dir.tmp

# create photo dir (incl. sooc folder) and copy initial advertisement photos there
mkdir $photo_dir
mkdir $photo_dir/sooc
cp advertisement/*.jpg $photo_dir

# start OTA if set active
if [ $ota_active -eq 1 ]; then
	echo "Starting up OTA..."
	startOTA
fi

# wait for camera to show up
echo "Waiting for camera...."
wait_for_camera

# user interaction
echo
echo "Ready. Start tethering mode by pressing <enter> (auto-starts in 10 seconds...)"
echo
read -t 10 tmp

# infinite loop (restart gPhoto2 if connection gets interrupted)
while [ 1 -gt 0 ]; do
	# open background image in fullscreen mode
	killall eog 2> /dev/null
	eog -f -w images/black.gif &

	# wait a second
	sleep 1

	# start slideshow
	feh -F --hide-pointer --zoom fill -D 5 --randomize $photo_dir/*.jpg &

	# start gPhoto2 in tethering mode
	echo ----------------------------------------------------------------
	echo " Starting gphoto2 in tethering mode..."
	echo ----------------------------------------------------------------
	gphoto2 --quiet --capture-tethered --hook-script=tether-hook.sh --filename="$photo_dir/$filename_prefix-%Y%m%d-%H%M%S.%C" --force-overwrite

	# we get here when the connection was interrupted
	killall eog 2> /dev/null
	killall feh 2> /dev/null
	echo ----------------------------------------------------------------
	echo  "Lost connection to camera! Waiting for it to come back on..."
	echo ----------------------------------------------------------------
	eog -f -w images/wait.gif &
	read -t 5 tmp

	# wait for camera to show up again
	wait_for_camera
done;

# run the cleanup
cleanup