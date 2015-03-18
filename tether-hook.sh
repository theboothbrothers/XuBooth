#!/bin/bash

#########################################################################
# XuBooth 1.2
#########################################################################
#  2015-01-24	initial release
#  2015-03-11	moved from ImageMagick to GraphicsMagick (performance)
#		introduced XuBooth OTA Gallery
#		added "sooc" subfolder that holds unaltered images
#  2015-03-17	optimized OTA webserver
#		introduced standalone config file
#########################################################################

function downloadImage() {
	argument=$1

	# call standalone config file
	chmod a+x XuBooth-config.sh
	source XuBooth-config.sh

	# read photo_dir.tmp
	photo_dir=`cat photo_dir.tmp`

	# extract filename from $argument
	filename=$(basename $argument)

	# kill current slideshow
	killall feh 2> /dev/null

	# 1. show current photo for defined amount of time
	# 2. show randomized slideshow of all photos in defined interval
	feh -F --hide-pointer --zoom fill -D $show_photo_in_sec --cycle-once "$argument" && feh -F --hide-pointer --zoom fill -D $slideshow_interval_in_sec --randomize $photo_dir/*.jpg &

	# we get here WHILE the photo is already on screen (not yet containing overlay of course!)
	#  => no delay for the user when processing the image now (user is distracted by the current photo or slideshow)

		# save original image
		cp "$argument" "$photo_dir/sooc/"

		# remove/set EXIF/IPTC data
		if [ $exif_active -eq 1 ]; then
			# remove ALL EXIF/IPTC data from photo
			exiftool -r -overwrite_original -P -all= "$argument"

			# set EXIF/IPTC data in photo
			exiftool -r -overwrite_original -P -Artist="$exif_credit" -XPAuthor="$exif_credit" -OwnerName="$exif_credit" -Credit="$exif_credit" -Copyright="$exif_copyright" -CopyrightNotice="$exif_copyright" -UserComment="$exif_contact" -Contact="$exif_contact" "$argument"
		fi

		# overlay logo over each image
		if [ $overlay_active -eq 1 ]; then
			# overlay logo over current photo
			gm composite -compress jpeg -quality $overlay_jpeg_quality -compose over -gravity $overlay_orientation -geometry $overlay_geometry -dissolve $overlay_opacity_in_percent $photo_dir/../$overlay_image "$argument" "$argument"
		fi

		# OTA small/medium sized files creation
		if [ $ota_active -eq 1 ]; then
			# increase ota_counter and store it
			ota_counter=`cat ota_counter.tmp`
			ota_counter=$((ota_counter+1))
			echo $ota_counter > ota_counter.tmp

			# create subfolders if necessary
			ota_lo=`echo "1 + ($ota_images_per_folder * (($ota_counter-1)/$ota_images_per_folder))" | bc`
			ota_hi=`echo "$ota_lo + $ota_images_per_folder - 1" | bc`
			ota_subdir=$ota_lo-$ota_hi
			mkdir -p "$photo_dir/ota-small/$ota_subdir"
			mkdir -p "$photo_dir/ota-medium/$ota_subdir"

			# medium sized version
			gm convert "$argument" -thumbnail x$ota_image_height -unsharp 0x.5 -bordercolor $ota_image_border_color -border $ota_image_border_size -flatten "$photo_dir/ota-medium/$ota_subdir/$filename"

			# small sized version (thumbnail)
			gm convert "$argument" -thumbnail x$ota_thumbnail_size -unsharp 0x.5 -bordercolor $ota_thumbnail_border_color -border $ota_thumbnail_border_size -flatten "$photo_dir/ota-small/$ota_subdir/$filename"
		fi
}

self=`basename $0`

case "$ACTION" in
    init)
	echo "$self: INIT"
	;;
    start)
	echo "$self: START"
	;;
    download)
	echo "$self: DOWNLOAD to $ARGUMENT"
	downloadImage $ARGUMENT
	;;
    stop)
	echo "$self: STOP"
	;;
    *)
	echo "$self: Unknown action: $ACTION"
	;;
esac

exit 0
