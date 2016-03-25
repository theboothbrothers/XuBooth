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

	# extract picstrip count from filename
	count=$(echo $filename | sed -r 's/^.*picstrip_([0-9]+).*$/\1/i')
	crop=picstrip_crop_$count
	grav=picstrip_cropgravity_$count
	geo=picstrip_geometry_$count

	# calculate timestamp and new filename
	timestamp=$(date "+%Y%m%d-%H%M%S")
	filename_new="$filename_prefix-$timestamp.jpg"

	# process first, last and intermediate photos differently
	case $count in
		# process last photo (or 1st photo if $picstrip_images = 1)
		$picstrip_images)


			if [ -z "${!crop}" ]; then
				# no cropping parameters given => only compose
				if [ $picstrip_images -gt 1 ]; then
					# composite image into intermediate output
					gm composite -compress jpeg -quality $picstrip_quality -compose over -geometry ${!geo} "$argument" "$photo_dir/picstrip.tmp" "$photo_dir/picstrip.tmp"
				else
					# composite first image into template
					gm composite -compress jpeg -quality 100 -compose over -geometry ${!geo} "$argument" "$photo_dir/../$picstrip_template" "$photo_dir/picstrip.tmp"
				fi
			else
				# cropping parameters => first crop, then compose
				gm convert -compress jpeg -quality 100 "$argument" -gravity ${!grav} -thumbnail ${!crop} -extent ${!crop} "$photo_dir/picstrip-crop.tmp"
				if [ $picstrip_images -gt 1 ]; then
					# composite image into intermediate output
					gm composite -compress jpeg -quality $picstrip_quality -compose over -geometry ${!geo} "$photo_dir/picstrip-crop.tmp" "$photo_dir/picstrip.tmp" "$photo_dir/picstrip.tmp"
				else
					# composite first image into template
					gm composite -compress jpeg -quality 100 -compose over -geometry ${!geo} "$photo_dir/picstrip-crop.tmp" "$photo_dir/../$picstrip_template" "$photo_dir/picstrip.tmp"
				fi
				rm "$photo_dir/picstrip-crop.tmp" 2> /dev/null
			fi

			# move original photo to SOOC folder
			mv "$argument" "$photo_dir/sooc/$filename_new"

			# make intermediate output the final image
			mv "$photo_dir/picstrip.tmp" "$photo_dir/$filename_new"

			# overlay logo over image
			if [ $overlay_active -eq 1 ]; then
				# overlay logo over photo
				gm composite -compress jpeg -quality $overlay_jpeg_quality -compose over -gravity $overlay_orientation -geometry $overlay_geometry -dissolve $overlay_opacity_in_percent $photo_dir/../$overlay_image "$photo_dir/$filename_new" "$photo_dir/$filename_new"
			fi

			# set indicator file for a finished PictureStrip
			touch XuBooth-picstrip-finished.yes

			# kill gphoto since we reached the last picture for this picstrip
			killall gphoto2 2> /dev/null

			# kill current slideshow
			killall feh 2> /dev/null

			# 1. show current photo for defined amount of time
			# 2. show randomized slideshow of all photos in defined interval
			feh -F --hide-pointer --zoom $photo_zoom -D $show_photo_in_sec --cycle-once "$photo_dir/$filename_new" && feh -F --hide-pointer --zoom $photo_zoom -D $slideshow_interval_in_sec --randomize $photo_dir/*.jpg &

			# we get here WHILE the photo is already on screen (not yet containing overlay of course!)
			#  => no delay for the user when processing the image now (user is distracted by the current photo or slideshow)

			# remove/set EXIF/IPTC data
			if [ $exif_active -eq 1 ]; then
				# remove ALL EXIF/IPTC data from photo and set user-defined EXIF data
				exiftool -r -overwrite_original -P -all= -Artist="$exif_credit" -XPAuthor="$exif_credit" -OwnerName="$exif_credit" -Credit="$exif_credit" -Copyright="$exif_copyright" -CopyrightNotice="$exif_copyright" -UserComment="$exif_contact" -Contact="$exif_contact" "$photo_dir/$filename_new"
			fi

			# OTA small/medium/large sized files creation
			if [ $ota_active -eq 1 ]; then
				# small sized version (thumbnail)
				gm convert "$photo_dir/$filename_new" -thumbnail x120 -unsharp 0x.5 -bordercolor $ota_thumbnail_border_color -border $ota_thumbnail_border_size -flatten "$photo_dir/ota-small/$filename_new"

				# medium sized version
				gm convert "$photo_dir/$filename_new" -thumbnail x$ota_image_height -unsharp 0x.5 -bordercolor $ota_image_border_color -border $ota_image_border_size -flatten "$photo_dir/ota-medium/$filename_new"

				# large sized version
				gm convert "$photo_dir/$filename_new" x$ota_image_height_download -unsharp 0x.5 -flatten "$photo_dir/ota-large/$filename_new"
			fi

			;;
		# process first photo (only if $picstrip_images >= 2)
		1)
			# start timeout script for gphoto2 in the background and store its PID
			( sleep $picstrip_timeout_in_sec; touch XuBooth-picstrip-timeout.yes; killall gphoto2) & echo $! > XuBooth-picstrip-timeout.pid

			# composite first image into template
			if [ -z "${!crop}" ]; then
				# no cropping parameters given => only compose
				gm composite -compress jpeg -quality 100 -compose over -geometry ${!geo} "$argument" "$photo_dir/../$picstrip_template" "$photo_dir/picstrip.tmp"
			else
				# cropping parameters => first crop, then compose
				gm convert -compress jpeg -quality 100 "$argument" -gravity "${!grav}" -thumbnail ${!crop} -extent ${!crop} "$photo_dir/picstrip-crop.tmp"
				gm composite -compress jpeg -quality 100 -compose over -geometry ${!geo} "$photo_dir/picstrip-crop.tmp" "$photo_dir/../$picstrip_template" "$photo_dir/picstrip.tmp"
				rm "$photo_dir/picstrip-crop.tmp" 2> /dev/null
			fi

			# kill current slideshow
			killall feh 2> /dev/null

			# show photo
			feh -F --hide-pointer --zoom $photo_zoom "$photo_dir/picstrip.tmp" &

			# move original photo to SOOC folder
			mv "$argument" "$photo_dir/sooc/$filename_new"

			;;

		# process intermediate photo (only if $picstrip_images >= 2)
		*)
			# composite image into intermediate output
			if [ -z "${!crop}" ]; then
				# no cropping parameters given => only compose
				gm composite -compress jpeg -quality 100 -compose over -geometry ${!geo} "$argument" "$photo_dir/picstrip.tmp" "$photo_dir/picstrip.tmp"
			else
				# cropping parameters => first crop, then compose
				gm convert -compress jpeg -quality 100 "$argument" -gravity "${!grav}" -thumbnail ${!crop} -extent ${!crop} "$photo_dir/picstrip-crop.tmp"
				gm composite -compress jpeg -quality 100 -compose over -geometry ${!geo} "$photo_dir/picstrip-crop.tmp" "$photo_dir/picstrip.tmp" "$photo_dir/picstrip.tmp"
				rm "$photo_dir/picstrip-crop.tmp" 2> /dev/null
			fi

			# kill current slideshow
			killall feh 2> /dev/null

			# show photo
			feh -F --hide-pointer --zoom $photo_zoom "$photo_dir/picstrip.tmp" &

			# move original photo to SOOC folder
			mv "$argument" "$photo_dir/sooc/$filename_new"

			;;
	esac

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
