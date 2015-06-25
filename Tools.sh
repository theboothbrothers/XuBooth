#!/bin/bash

function quit() {
	exit 0
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








# ------------------------------
#  MAIN
# ------------------------------


while [ 1 -gt 0 ]; do
	menu_entries=()
	menu_entries+=(1 "ListWifiChannels")
	menu_entries+=(2 "Benchmark")
	menu_entries+=(3 "RepairXuBooth")
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
