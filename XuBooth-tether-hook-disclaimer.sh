#!/bin/bash

function downloadImage() {
	argument=$1

	# read/run tmp-vars
	source "XuBooth-tmp-vars.sh"

	# call configuration
	source "$config_file"

	# read/run session specific tmp-vars
	source "$photo_dir/contest.sh" 2> /dev/null

	# extract filename from $argument
	filename=$(basename $argument)

	# save original image
	cp "$argument" "$photo_dir/sooc/"

	# overlay logo over each image
	if [ $overlay_active -eq 1 ]; then
		# overlay logo over current photo
		gm composite -compress jpeg -quality $overlay_jpeg_quality -compose over -gravity $overlay_orientation -geometry $overlay_geometry -dissolve $overlay_opacity_in_percent $photo_dir/../$overlay_image "$argument" "$argument"
	fi

	# set indicator file for a finished capture
	touch XuBooth-disclaimer-finished.yes

	# kill current slideshow
	killall feh 2> /dev/null

	# show current photo for defined amount of time
	feh -F --hide-pointer --zoom $photo_zoom -D $show_photo_in_sec --cycle-once "$argument" &

	# kill gphoto
	killall gphoto2 2> /dev/null

	# we get here WHILE the photo is already on screen (not yet containing overlay of course!)
	#  => no delay for the user when processing the image now (user is distracted by the current photo or slideshow)

	# remove/set EXIF/IPTC data
	if [ $exif_active -eq 1 ]; then
		# remove ALL EXIF/IPTC data from photo and set user-defined EXIF data
		exiftool -r -overwrite_original -P -all= -Artist="$exif_credit" -XPAuthor="$exif_credit" -OwnerName="$exif_credit" -Credit="$exif_credit" -Copyright="$exif_copyright" -CopyrightNotice="$exif_copyright" -UserComment="$exif_contact" -Contact="$exif_contact" "$argument"
	fi

	# OTA small/medium/large sized files creation
	if [ $ota_active -eq 1 ]; then
		# small sized version (thumbnail)
		gm convert "$argument" -thumbnail x120 -unsharp 0x.5 -bordercolor $ota_thumbnail_border_color -border $ota_thumbnail_border_size -flatten "$photo_dir/ota-small/$filename"

		# medium sized version
		gm convert "$argument" -thumbnail x$ota_image_height -unsharp 0x.5 -bordercolor $ota_image_border_color -border $ota_image_border_size -flatten "$photo_dir/ota-medium/$filename"

		# large sized version
		gm convert "$argument" x$ota_image_height_download -unsharp 0x.5 -flatten "$photo_dir/ota-large/$filename"
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
