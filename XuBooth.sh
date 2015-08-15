#!/bin/bash

# ----------------------------------------------------------------------
#  <DEFINITIONS>
# ----------------------------------------------------------------------

	export require_config_version=7
	export xubooth_config_version=-1

# ----------------------------------------------------------------------
#  </DEFINITIONS>
# ----------------------------------------------------------------------




# ----------------------------------------------------------------------
#  <FUNCTIONS>
# ----------------------------------------------------------------------



	# ----------------------------------------------------------------------
	#  FUNCTION: choose_config
	# ----------------------------------------------------------------------
	function choose_config() {

		echo "---------------------------------------------------------------------------"
		echo " Checking configuration file(s)..."
		echo "---------------------------------------------------------------------------"

		# check if there are actually config files
		if [[ -z $(ls -A config/*.sh 2>/dev/null) ]]; then
			echo "Found no configuration files!"
			echo " - copy 'XuBooth-sample-config.sh' to subfolder 'config'"
			echo " - rename to <name-of-choice>.sh"
			echo " - modify settings to your needs"
			echo
			echo "Press <enter> to quit"
			read
			exit 1
		fi

		# if there is only 1 file => just use it
		if [ `ls -1 config/*.sh | wc -l 2> /dev/null` -eq 1 ]; then
			# read/run the config file
			config_file=`ls -1 config/*.sh 2> /dev/null`


		# else let user choose configuration
		else
			let i=0
			config_files=()

			# collect all config files in array
			IFSBACKUP=$IFS
			IFS=$(echo -en "\n\b")
			for f in `ls config/*.sh | sort -fV`; do
				let i=$i+1
				config_files+=($i "$f")
			done
			IFS=$IFSBACKUP

			# let user choose the config file
			choice=$(dialog --title "Choose configuration" --menu "" 20 60 10 "${config_files[@]}" 3>&2 2>&1 1>&3)

			clear
			echo "---------------------------------------------------------------------------"
			echo " Checking configuration file(s)..."
			echo "---------------------------------------------------------------------------"

			# user cancelled
			if [ -z "$choice" ]; then
				echo "No configuration selected! Exiting now."
				echo "Press <enter> to quit"
				read
				exit 1
			else
				config_file=${config_files[2*$choice - 1]}
			fi
		fi

		# load config
		echo " * loading $config_file..."
		echo 
		source "$config_file"

		# check config version mismatch
		if [ "$xubooth_config_version" -ne "$require_config_version" ]; then
			echo "The configuration does NOT match the required version:"
			echo " * Required version: $require_config_version"
			echo " * Provided Version: $xubooth_config_version"
			echo
			echo "Please update it (see XuBooth-sample-config.sh)."
			echo
			echo "Press <enter> to quit"
			read
			exit 1
		fi
	}


	# ----------------------------------------------------------------------
	#  FUNCTION: choose_photodir
	# ----------------------------------------------------------------------
	function choose_photodir() {

		echo "---------------------------------------------------------------------------"
		echo " Checking existing photo directories..."
		echo "---------------------------------------------------------------------------"

		# check if there are already photo directories
		if [[ -z $(ls -Ad photos_* 2>/dev/null) ]]; then
			timestamp=$(date "+%Y%m%d-%H%M%S")
			photo_dir=photos_$timestamp
		else
			let i=0
			photo_dirs=()

			# collect all config files in array
			IFSBACKUP=$IFS
			IFS=$(echo -en "\n\b")
			for f in `ls -Ad photos_* | sort -fV`; do
				let i=$i+1
				photo_dirs+=($i "$f")
			done
			IFS=$IFSBACKUP

			# let user choose the config file
			choice=$(dialog --title "Choose photo directory" --menu "" 20 60 10 "${photo_dirs[@]}" 3>&2 2>&1 1>&3)

			# user cancelled
			if [ -z "$choice" ]; then
				echo "No photo directory selected! Creating new one..."
				timestamp=$(date "+%Y%m%d-%H%M%S")
				photo_dir=photos_$timestamp
			else
				photo_dir=${photo_dirs[2*$choice - 1]}
			fi
		fi

		clear
		echo "---------------------------------------------------------------------------"
		echo " Checking existing photo directories..."
		echo "---------------------------------------------------------------------------"
		echo " * using $photo_dir"
		echo
	}


	# ----------------------------------------------------------------------
	#  FUNCTION: choose_lan_device
	# ----------------------------------------------------------------------
	function choose_lan_device() {

		# if OTA is not activated, skip this function
		if [ $ota_active -ne 1 ]; then return; fi

		let i=0
		lan_devices=()

		# collect all wlan devices in array
		IFSBACKUP=$IFS
		IFS=$(echo -en "\n\b")
		for f in `netstat -i | grep eth | cut -d" " -f1`; do
			let i=$i+1
			lan_devices+=($i "$f")
		done
		IFS=$IFSBACKUP

		if [ ${#lan_devices[@]} -eq 0 ]; then
			echo "Could not find a wired network device! Are you sure this machine is equipped with one?"
			echo
			echo "Press <enter> to quit"
			read
			exit 1
		else
			# let user choose the device
			choice=$(dialog --title "Choose wired network device" --menu "" 20 60 10 "${lan_devices[@]}" 3>&2 2>&1 1>&3)

			clear

			# user cancelled
			if [ -z "$choice" ]; then
				echo "No device selected!"
				echo
				echo "Press <enter> to quit"
				read
				exit 1
			fi

			ota_dev_eth0=${lan_devices[2*$choice - 1]}
		fi
	}


	# ----------------------------------------------------------------------
	#  FUNCTION: choose_wlan_device
	# ----------------------------------------------------------------------
	function choose_wlan_device() {

		# if OTA is not activated, skip this function
		if [ $ota_active -ne 1 ]; then return; fi

		let i=0
		wlan_devices=()

		# collect all wlan devices in array
		IFSBACKUP=$IFS
		IFS=$(echo -en "\n\b")
		for f in `netstat -i | grep wlan | cut -d" " -f1`; do
			let i=$i+1
			wlan_devices+=($i "$f")
		done
		IFS=$IFSBACKUP

		if [ ${#wlan_devices[@]} -eq 0 ]; then
			echo "Could not find a wifi device! Are you sure this machine is equipped with one?"
			echo
			echo "Press <enter> to quit"
			read
			exit 1
		else
			# let user choose the device
			choice=$(dialog --title "Choose wifi device" --menu "" 20 60 10 "${wlan_devices[@]}" 3>&2 2>&1 1>&3)

			clear

			# user cancelled
			if [ -z "$choice" ]; then
				echo "No device selected!"
				echo
				echo "Press <enter> to quit"
				read
				exit 1
			fi

			ota_dev_wlan0=${wlan_devices[2*$choice - 1]}
		fi
	}


	# ----------------------------------------------------------------------
	#  FUNCTION: check_prerequisites
	# ----------------------------------------------------------------------
	function check_prerequisites() {
		check=0

		echo "---------------------------------------------------------------------------"
		echo " Checking prerequisites..."
		echo "---------------------------------------------------------------------------"

		if ! type "dialog" 2> /dev/null 1> /dev/null; then
			echo " * dialog is missing!"
			((check++))
		fi

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
			echo "One or more prerequisites are missing! Please install them (see README for details)."
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


	# ----------------------------------------------------------------------
	#  FUNCTION: wait_for_camera
	# ----------------------------------------------------------------------
	function wait_for_camera() {
		while [ `gphoto2 --auto-detect | grep -s -i -c usb` -eq 0 ]; do
		    sleep 1
		done
	}


	# ----------------------------------------------------------------------
	#  FUNCTION: cleanup
	# ----------------------------------------------------------------------
	function cleanup() {
		# stop slideshow and image viewer
		killall eog 2> /dev/null
		killall feh 2> /dev/null

		# stop OTA
		stopOTA

		# delete temporary files and lock file
		rm XuBooth-tmp-vars.sh 2> /dev/null
		rm XuBooth.lock 2> /dev/null

		echo "---------------------------------------------------------------------------"
		echo " XuBooth exited successfully."
		echo "---------------------------------------------------------------------------"
		echo 
		read
	}



	# ----------------------------------------------------------------------
	#  FUNCTION: ctrl_c
	# ----------------------------------------------------------------------
	function ctrl_c() {
		echo
		echo "---------------------------------------------------------------------------"
		echo " Detected ctrl+c. Cleaning up and shutting down script"
		echo "---------------------------------------------------------------------------"
		cleanup
		exit 1
	}


	# ----------------------------------------------------------------------
	#  FUNCTION: startOTA
	# ----------------------------------------------------------------------
	function startOTA() {

		# if OTA is not activated, skip this function
		if [ $ota_active -ne 1 ]; then return; fi

		echo "---------------------------------------------------------------------------"
		echo " Starting up OTA..."
		echo "---------------------------------------------------------------------------"

		# create folders for OTA gallery
		mkdir $photo_dir/ota-large 2>/dev/null
		mkdir $photo_dir/ota-medium 2>/dev/null
		mkdir $photo_dir/ota-small 2>/dev/null

		# link folders for OTA gallery
		rm ota/img-s 2> /dev/null
		rm ota/img-m 2> /dev/null
		rm ota/img-l 2> /dev/null
		ln -s ../$photo_dir/ota-large ota/img-l
		ln -s ../$photo_dir/ota-medium ota/img-m
		ln -s ../$photo_dir/ota-small ota/img-s

		# put customized OTA files in OTA folder
		echo "$ota_management_user:$ota_management_pass" > ./ota/.htpasswd
		echo "# MAC address filter table" > ./ota/hostapd.deny
		chmod 666 ./ota/hostapd.deny
		echo "# dnsmasq leases" > ./ota/dnsmasq.leases
		chmod 666 ./ota/dnsmasq.leases

		# create download stats file and give write permissions to "others"
		echo "Date;IP;User-Agent;File" > $photo_dir/download_stats.csv
		chmod 777 $photo_dir/download_stats.csv

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
		# call configuration
		source XuBooth-tmp-vars.sh
		source "$config_file"

		# put our config files into place and replace placeholders
		cp ./ota-conf/dnsmasq.conf /etc/dnsmasq.conf
		sed -i "s:<<<dev_wlan0>>>:$ota_dev_wlan0:g" /etc/dnsmasq.conf
		sed -i "s:<<<dev_eth0>>>:$ota_dev_eth0:g" /etc/dnsmasq.conf
		sed -i "s:<<<dhcp_lease_in_min>>>:$ota_dhcp_lease_in_min:g" /etc/dnsmasq.conf
		sed -i "s:<<<xubooth_dir>>>:$script_path:g" /etc/dnsmasq.conf

		cp ./ota-conf/hostapd.conf /etc/hostapd.conf
		sed -i "s:<<<dev_wlan0>>>:$ota_dev_wlan0:g" /etc/hostapd.conf
		sed -i "s:<<<wlan_driver>>>:$ota_wlan_driver:g" /etc/hostapd.conf
		sed -i "s:<<<wlan_channel>>>:$ota_wlan_channel:g" /etc/hostapd.conf
		sed -i "s:<<<wlan_ssid>>>:$ota_wlan_ssid:g" /etc/hostapd.conf
		sed -i "s:<<<wlan_pass>>>:$ota_wlan_pass:g" /etc/hostapd.conf
		sed -i "s:<<<wlan_country_code>>>:$ota_wlan_country_code:g" /etc/hostapd.conf
		sed -i "s:<<<xubooth_dir>>>:$script_path:g" /etc/hostapd.conf
		echo "DAEMON_CONF=/etc/hostapd.conf" > /etc/default/hostapd

		cp ./ota-conf/interfaces /etc/network/interfaces
		sed -i "s:<<<dev_wlan0>>>:$ota_dev_wlan0:g" /etc/network/interfaces
		sed -i "s:<<<dev_eth0>>>:$ota_dev_eth0:g" /etc/network/interfaces

		cp ./ota-conf/lighttpd.conf /etc/lighttpd/lighttpd.conf
		sed -i "s:<<<xubooth_dir>>>:$script_path:g" /etc/lighttpd/lighttpd.conf
		sed -i "s#<<<domain>>>#$ota_domain#g" /etc/lighttpd/lighttpd.conf

		# restart Network Manager and ligHTTPd
		service network-manager restart
		service lighttpd restart

		# reload wlan interface
		ifdown $ota_dev_wlan0
		ifup $ota_dev_wlan0
EOF

		echo
	}


	# ----------------------------------------------------------------------
	#  FUNCTION: stopOTA
	# ----------------------------------------------------------------------
	function stopOTA() {

		# if OTA is not activated, skip this function
		if [ $ota_active -ne 1 ]; then return; fi

		echo "---------------------------------------------------------------------------"
		echo " Stopping OTA..."
		echo "---------------------------------------------------------------------------"

		# ----------------------------------------------------
		# we now need root permissions to do the heavy lifting
		# ----------------------------------------------------
		echo " * need root permissions to stop OTA service"
sudo bash <<"EOF" 
		# call configuration
		source XuBooth-tmp-vars.sh
		source "$config_file"

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


# ----------------------------------------------------------------------
#  </FUNCTIONS>
# ----------------------------------------------------------------------





# ----------------------------------------------------------------------
#  <MAIN>
# ----------------------------------------------------------------------

	# get script path
	script_path=$(cd `dirname "$0"` && pwd)

	# define function that is called when ctrl+c is pressed
	trap ctrl_c SIGINT

	# choose config
	choose_config

	# choose photo directory
	choose_photodir

	# let user choose lan and wlan devices (if OTA is set active)
	choose_lan_device
	choose_wlan_device

	# check if prerequisites are installed
	check_prerequisites

	# save global variables to tmp-vars
	echo "#!/bin/bash" > XuBooth-tmp-vars.sh
	echo "export script_path=$script_path" >> XuBooth-tmp-vars.sh
	echo "export config_file=$config_file" >> XuBooth-tmp-vars.sh
	echo "export photo_dir=$photo_dir" >> XuBooth-tmp-vars.sh
	echo "export ota_dev_eth0=$ota_dev_eth0" >> XuBooth-tmp-vars.sh
	echo "export ota_dev_wlan0=$ota_dev_wlan0" >> XuBooth-tmp-vars.sh
	echo "export ota_images_per_page=$ota_images_per_page" >> XuBooth-tmp-vars.sh
	echo "export ota_image_expiration_in_min=$ota_image_expiration_in_min" >> XuBooth-tmp-vars.sh
	echo "export ota_title=\"$ota_title\"" >> XuBooth-tmp-vars.sh
	echo "export ota_caption=\"$ota_caption\"" >> XuBooth-tmp-vars.sh
	echo "export ota_disclaimer=\"$ota_disclaimer\"" >> XuBooth-tmp-vars.sh
	echo "export ota_domain=\"$ota_domain\"" >> XuBooth-tmp-vars.sh
	echo "export ota_body_bgcolor=\"$ota_body_bgcolor\"" >> XuBooth-tmp-vars.sh
	echo "export ota_header_bgcolor_1=\"$ota_header_bgcolor_1\"" >> XuBooth-tmp-vars.sh
	echo "export ota_header_bgcolor_2=\"$ota_header_bgcolor_2\"" >> XuBooth-tmp-vars.sh
	echo "export ota_ios_message=\"$ota_ios_message\"" >> XuBooth-tmp-vars.sh
	echo "export contest_active=\"$contest_active\"" >> XuBooth-tmp-vars.sh
	echo "export contest_probability_1_over=\"$contest_probability_1_over\"" >> XuBooth-tmp-vars.sh
	echo "export contest_max_wins=\"$contest_max_wins\"" >> XuBooth-tmp-vars.sh
	echo "export contest_sticker_images=\"$contest_sticker_images\"" >> XuBooth-tmp-vars.sh
	echo "export contest_sticker_opacity_in_percent=\"$contest_sticker_opacity_in_percent\"" >> XuBooth-tmp-vars.sh
	echo "export contest_sticker_orientation=\"$contest_sticker_orientation\"" >> XuBooth-tmp-vars.sh
	echo "export contest_sticker_geometry=\"$contest_sticker_geometry\"" >> XuBooth-tmp-vars.sh
	echo "export contest_sticker_jpeg_quality=\"$contest_sticker_jpeg_quality\"" >> XuBooth-tmp-vars.sh

	# create photo dir (incl. sooc folder) and copy initial ad photos there
	mkdir $photo_dir 2>/dev/null
	mkdir $photo_dir/sooc 2>/dev/null
	cp images/ads/*.jpg $photo_dir 2> /dev/null
	cp images/ads/*.png $photo_dir 2> /dev/null

	# start OTA (if set active)
	startOTA

	# wait for camera to show up
	echo "---------------------------------------------------------------------------"
	echo " Waiting for camera..."
	echo "---------------------------------------------------------------------------"
	wait_for_camera

	# user interaction
	echo "---------------------------------------------------------------------------"
	echo " Ready. Start tethering mode by pressing <enter> (auto-starts in 10 seconds...)"
	echo "---------------------------------------------------------------------------"
	read -t 10 tmp

	# infinite loop (restart gPhoto2 if connection gets interrupted)
	while [ 1 -gt 0 ]; do
		# open background image in fullscreen mode
		killall eog 2> /dev/null
		eog -f -w images/black.gif &

		# wait a second
		sleep 1

		# start slideshow
		feh -F --hide-pointer --zoom $photo_zoom -D 5 --randomize $photo_dir/*.jpg &

		# start gPhoto2 in tethering mode
		echo "---------------------------------------------------------------------------"
		echo " Starting gphoto2 in tethering mode..."
		echo "---------------------------------------------------------------------------"
		gphoto2 --quiet --capture-tethered --hook-script=XuBooth-tether-hook.sh --filename="$photo_dir/$filename_prefix-%Y%m%d-%H%M%S.%C" --force-overwrite

		# we get here when the connection was interrupted
		killall eog 2> /dev/null
		killall feh 2> /dev/null
		echo "---------------------------------------------------------------------------"
		echo  "Lost connection to camera! Waiting for it to come back on..."
		echo "---------------------------------------------------------------------------"
		eog -f -w $intermission_image &
		read -t 5 tmp

		# wait for camera to show up again
		wait_for_camera
	done;

	# run the cleanup
	cleanup
