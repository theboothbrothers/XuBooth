#!/bin/bash

function quit() {
	exit 0
}

function CreateSshKey() {
	# ask for keyname
	echo "Enter keyname: "
	read filename

	# create key
	ssh-keygen -q -t rsa -b 4096 -N "" -C "XuBooth's DD-WRT Key" -f "ota-ssh-keys/$filename"

	# show usage
	echo ""
	echo " > key created in: ""ota-ssh-keys/$filename"""
	echo " > copy the following text into the ""AuthorizedKeys"" field in DD-WRT's Web-Interface:"
	echo ""
	cat "ota-ssh-keys/$filename.pub"
}

function recoverOTA() {
	# if OTA is not activated, skip this function
	if [ $ota_active -ne 1 ]; then return; fi

	# ----------------------------------------------------
	# we now need root permissions to do the heavy lifting
	# ----------------------------------------------------
	echo " * need root permissions to stop OTA service"
sudo bash <<"EOF" 
	# call configuration
	source XuBooth-tmp-vars.sh
	source "$config_file"

	echo  $config_file
	read

	if [ "$ota_device" == "usb" ]; then
		# shutdown wlan interface
		ifdown $ota_dev_wlan0

		# restore original config files
		cp ./ota-conf/hostapd.orig /etc/default/hostapd
		cp ./ota-conf/dnsmasq.conf.orig /etc/dnsmasq.conf
		cp ./ota-conf/interfaces.orig /etc/network/interfaces

		# restart Network Manager
		service network-manager restart

		# reload wlan interface
		ifdown $ota_dev_wlan0
		ifup $ota_dev_wlan0
	fi

	# restore original config files
	cp ./ota-conf/lighttpd.conf.orig /etc/lighttpd/lighttpd.conf

	# restart ligHTTPd
	service lighttpd restart
EOF

	# delete stored original config files
	rm ./ota-conf/hostapd.orig
	rm ./ota-conf/dnsmasq.conf.orig
	rm ./ota-conf/interfaces.orig
	rm ./ota-conf/lighttpd.conf.orig
}


function RepairXuBooth() {
	if [ -f XuBooth-tmp-vars.sh ]; then
		# call configuration
		source XuBooth-tmp-vars.sh
		source "$config_file"

		# recover OTA
		recoverOTA

		# delete temporary files and lock file
		rm XuBooth-tmp-vars.sh 2> /dev/null
		rm XuBooth.lock 2> /dev/null
	else
		echo "There is no 'XuBooth-tmp-vars.sh'."
		echo "Can't cleanup without the infos provided in that file. Sorry!"
	fi
}

function ListWifiChannels() {
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
	else
		# let user choose the device
		choice=$(dialog --title "Choose wifi device" --menu "" 20 60 10 "${wlan_devices[@]}" 3>&2 2>&1 1>&3)

		clear

		# user cancelled
		if [ -z "$choice" ]; then
			echo "No device selected!"
		else
			echo ""
			sudo iwlist ${wlan_devices[2*$choice - 1]} scan | grep Frequency | sed -r "s/.*Channel (.*)\).*/Channel \1/g" | sort -t " " -k 2n | uniq -c
		fi
	fi
}

function doBenchmark() {

	benchstart=$(date +%s.%N)
	eval "$2"
	benchstop=$(date +%s.%N)
	benchmark=$(echo "$benchstop - $benchstart" | bc)
	echo "$1 || $benchmark sec"

	benchmark_result=$(echo $benchmark_result  + $benchmark | bc)
}

function Benchmark() {
	filein1="images/benchmark/10mp.jpg"
	filein2="images/benchmark/18mp.jpg"
	fileout="images/benchmark/tmp.jpg"
	overlay="images/benchmark/overlay_15mp.png"

	benchmark_result=0

	echo "--------------------------------------------------------------------"
	echo " Copying"
	echo "--------------------------------------------------------------------"
	doBenchmark "#1 10mp photo" "cp $filein1 $fileout"
	rm $fileout
	doBenchmark "#2 18mp photo" "cp $filein2 $fileout"
	rm $fileout

	echo ""
	echo "--------------------------------------------------------------------"
	echo " Downsizing"
	echo "--------------------------------------------------------------------"
	doBenchmark "#1 10mp photo to 2048px height" "gm convert $filein1 -thumbnail x2048 -unsharp 0x.5 -flatten $fileout"
	rm $fileout
	doBenchmark "#2 18mp photo to 2048px height" "gm convert $filein2 -thumbnail x2048 -unsharp 0x.5 -flatten $fileout"
	rm $fileout
	doBenchmark "#3 10mp photo to 1024px height" "gm convert $filein1 -thumbnail x1024 -unsharp 0x.5 -flatten $fileout"
	rm $fileout
	doBenchmark "#4 18mp photo to 1024px height" "gm convert $filein2 -thumbnail x1024 -unsharp 0x.5 -flatten $fileout"
	rm $fileout
	doBenchmark "#5 10mp photo to  512px height" "gm convert $filein1 -thumbnail x512 -unsharp 0x.5 -flatten $fileout"
	rm $fileout
	doBenchmark "#6 18mp photo to  512px height" "gm convert $filein2 -thumbnail x512 -unsharp 0x.5 -flatten $fileout"
	rm $fileout

	echo ""
	echo "--------------------------------------------------------------------"
	echo " Overlaying"
	echo "--------------------------------------------------------------------"
	doBenchmark "#1 15mp graphic onto 10mp photo" "gm composite -compress jpeg -quality 80 -compose over -gravity NorthEast -geometry x500+0+0 -dissolve 60 $overlay $filein1 $fileout"
	rm $fileout
	doBenchmark "#2 15mp graphic onto 18mp photo" "gm composite -compress jpeg -quality 80 -compose over -gravity NorthEast -geometry x500+0+0 -dissolve 60 $overlay $filein2 $fileout"
	rm $fileout
	gm convert $overlay -thumbnail 4000x -unsharp 0x.5 $overlay.tmp
	doBenchmark "#3  6mp graphic onto 10mp photo" "gm composite -compress jpeg -quality 80 -compose over -gravity NorthEast -geometry x500+0+0 -dissolve 60 $overlay.tmp $filein1 $fileout"
	rm $fileout
	doBenchmark "#4  6mp graphic onto 18mp photo" "gm composite -compress jpeg -quality 80 -compose over -gravity NorthEast -geometry x500+0+0 -dissolve 60 $overlay.tmp $filein2 $fileout"
	rm $fileout
	gm convert $overlay -thumbnail 2500x -unsharp 0x.5 $overlay.tmp
	doBenchmark "#5  2mp graphic onto 10mp photo" "gm composite -compress jpeg -quality 80 -compose over -gravity NorthEast -geometry x500+0+0 -dissolve 60 $overlay.tmp $filein1 $fileout"
	rm $fileout
	doBenchmark "#6  2mp graphic onto 18mp photo" "gm composite -compress jpeg -quality 80 -compose over -gravity NorthEast -geometry x500+0+0 -dissolve 60 $overlay.tmp $filein2 $fileout"
	rm $fileout
	gm convert $overlay -thumbnail 1500x -unsharp 0x.5 $overlay.tmp
	doBenchmark "#7 .8mp graphic onto 10mp photo" "gm composite -compress jpeg -quality 80 -compose over -gravity NorthEast -geometry x500+0+0 -dissolve 60 $overlay.tmp $filein1 $fileout"
	rm $fileout
	doBenchmark "#8 .8mp graphic onto 18mp photo" "gm composite -compress jpeg -quality 80 -compose over -gravity NorthEast -geometry x500+0+0 -dissolve 60 $overlay.tmp $filein2 $fileout"
	rm $fileout
	rm $overlay.tmp

	echo ""
	echo "--------------------------------------------------------------------"
	echo " Modifying EXIF"
	echo "--------------------------------------------------------------------"
	doBenchmark "#1 modifying EXIF data from 10mp photo" "exiftool -q -r -P -all= -Artist=\"testcredit\" -XPAuthor=\"testauthor\" -OwnerName=\"testcredit\" -Credit=\"testcredit\" -Copyright=\"testcopyright\" -CopyrightNotice=\"testcopyright\" -UserComment=\"testcontact\" -Contact=\"testcontact\" -o $fileout $filein1"
	rm $fileout
	doBenchmark "#2 modifying EXIF data from 18mp photo" "exiftool -q -r -P -all= -Artist=\"testcredit\" -XPAuthor=\"testauthor\" -OwnerName=\"testcredit\" -Credit=\"testcredit\" -Copyright=\"testcopyright\" -CopyrightNotice=\"testcopyright\" -UserComment=\"testcontact\" -Contact=\"testcontact\" -o $fileout $filein2"
	rm $fileout

	echo ""
	echo "--------------------------------------------------------------------"
	echo " RESULTS"
	echo "--------------------------------------------------------------------"
	echo "Total: $benchmark_result sec"
}

function TestOverlays() {
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
			read
		else
			config_file=${config_files[2*$choice - 1]}
		fi
	fi

	# load config
	echo " * loading $config_file..."
	echo 
	source "$config_file"

	# overlay logo over benchmark photo (10 megapixels)
	echo " * applying overlay to 10MP image..."
	gm composite -compress jpeg -quality $overlay_jpeg_quality -compose over -gravity $overlay_orientation -geometry $overlay_geometry -dissolve $overlay_opacity_in_percent $overlay_image "images/benchmark/10mp.jpg" "images/benchmark/10mp_overlay_test.jpg"
	feh -F --hide-pointer --zoom $photo_zoom "images/benchmark/10mp_overlay_test.jpg"

	echo Press \<enter\> to continue...
	read

	# overlay logo over benchmark photo (18 megapixels)
	echo " * applying overlay to 18MP image..."
	gm composite -compress jpeg -quality $overlay_jpeg_quality -compose over -gravity $overlay_orientation -geometry $overlay_geometry -dissolve $overlay_opacity_in_percent $overlay_image "images/benchmark/18mp.jpg" "images/benchmark/18mp_overlay_test.jpg"
	feh -F --hide-pointer --zoom $photo_zoom "images/benchmark/18mp_overlay_test.jpg"

	echo Press \<enter\> to continue...
	read

	# delete overlay images
	rm "images/benchmark/10mp_overlay_test.jpg"
	rm "images/benchmark/18mp_overlay_test.jpg"
}

function FindDisclaimerKeyboardSettings() {
	echo "1. find disclaimer keyboard name"
	echo "------------------------------------------------------"
	echo " * this will list all input devices currently connected"
	echo " * search for something that matches your keyboard's maker and/or model name"
	echo
	xinput | grep --color=never "id="
	
	echo
	echo "Press <Enter> for next step"
	read	

	echo "2. find disclaimer keyboard action key"
	echo "------------------------------------------------------"
	echo " * press the key you wish to use"
	echo " * look for the name of the shown keysym"
	echo " * close the GUI window when you're done"
	echo
	xev -name "Press action key on disclaimer keyboard" -rv -geometry 600x250+0+0 | grep --color=always "(keysym .*)"
}

function TestDisclaimerMode() {
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
			read
		else
			config_file=${config_files[2*$choice - 1]}
		fi
	fi

	# load config
	echo " * loading $config_file..."
	echo 
	source "$config_file"
 
	# determine id and master for disclaimer keyboard
	tmp=`xinput list | grep -i "$disclaimer_kb_name" | sed -r 's/.*id=([0-9]+).+\[.+\(([0-9]+)\).*\].*/\1 \2/g'`
	disclaimer_kb_id=`echo $tmp | sed -r 's/([0-9]+)\s([0-9]+)/\1/g'`
	disclaimer_kb_master=`echo $tmp | sed -r 's/([0-9]+)\s([0-9]+)/\2/g'`

	# quit when we can't detect the disclaimer keyboard
	if [ -z "$disclaimer_kb_id" ] || [ -z "$disclaimer_kb_master" ]; then
		echo "Couldn't find the disclaimer keyboard (searched for '$disclaimer_kb_name')!"
		read
	else
		echo "We found the disclaimer keyboard. Starting tests right now..."
		echo

		# disable disclaimer keyboard
		xinput float $disclaimer_kb_id

		echo "Test #1 - disabling disclaimer keyboard"
		echo "--------------------------------------------------"
		echo " * please use the keyboard now"
		echo " * you should NOT see what you type on that keyboard"
		echo " * press <Enter> on the internal keyboard for the next test"
		read
		echo

		# enable disclaimer keyboard
		xinput reattach $disclaimer_kb_id $disclaimer_kb_master

		echo "Test #2 - enabling disclaimer keyboard"
		echo "--------------------------------------------------"
		echo " * please use the keyboard now"
		echo " * you should see what you type on that keyboard"
		echo " * press <Enter> on either keyboard to finish the tests"
		read
	fi
}




# ------------------------------
#  MAIN
# ------------------------------


while [ 1 -gt 0 ]; do
	menu_entries=()
	menu_entries+=(1 "ListWifiChannels")
	menu_entries+=(2 "Benchmark")
	menu_entries+=(3 "RepairXuBooth")
	menu_entries+=(4 "TestOverlays")
	menu_entries+=(5 "TestDisclaimerMode")
	menu_entries+=(6 "FindDisclaimerKeyboardSettings")
	menu_entries+=(7 "CreateSshKey")
	menu_entries+=(q "quit")
	choice=$(dialog --title "Choose the tool you would like to start" --menu "" 20 60 10 "${menu_entries[@]}" 3>&2 2>&1 1>&3)

	# user cancelled
	if [ -z "$choice" ]; then
		echo "No tool selected! Exiting now."
		exit 1
	else
		tool=${menu_entries[2*$choice - 1]}
	fi

	# run chosen tool
	clear
	$tool

	# wait for <Enter>
	echo
	echo "---------------------------------------------"
	echo "Done. Press <enter>"
	echo "---------------------------------------------"
	read
done;
