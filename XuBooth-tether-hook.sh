#!/bin/bash

function getRandom() {
	min=$1
	max=$2
	rand=$(shuf -i $min-$max -n 1)
}

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

	# overlay random sticker for contest mode
	if [ $contest_active -eq 1 ]; then
		# check if $contest_remaining_wins is already set; otherwise set it to $contest_max_wins and store it in $photo_dir/contest.sh
		if [ -z "$contest_remaining_wins" ]; then
			contest_remaining_wins=$contest_max_wins
			echo "#!/bin/bash" > "$photo_dir/contest.sh"
			echo "export contest_remaining_wins=\"$contest_remaining_wins\"" >> "$photo_dir/contest.sh"
			echo "sticker;winner" > "$photo_dir/contest.csv"
		fi

		# convert strings to arrays
		IFS='|' read -a ar_contest_sticker_images <<< "$contest_sticker_images"
		IFS='|' read -a ar_contest_max_wins <<< "$contest_max_wins"
		IFS='|' read -a ar_contest_remaining_wins <<< "$contest_remaining_wins"

		# number of stickers
		contest_stickers_len=${#ar_contest_sticker_images[@]}

		# sum up all remaining wins
		contest_remaining_wins_sum=0
		for (( i=0; i<${contest_stickers_len}; i++ )); do
			contest_remaining_wins_sum=$((contest_remaining_wins_sum + ${ar_contest_remaining_wins[$i]}))
		done

		# remaining wins?
		if [ $contest_remaining_wins_sum -gt 0 ]; then

			# draw random number out of probability pool and check for ZERO
			getRandom 1 $contest_probability_1_over
			if [ $rand -eq 1 ]; then

				# draw random number out of sticker pool (if necessary, repeat until we find a sticker that still has remaining wins)
				getRandom 0 $((contest_stickers_len-1))
				while [ ${ar_contest_remaining_wins[$rand]} -lt 1 ]; do
					getRandom 0 $((contest_stickers_len-1))
				done

				# overlay sticker over current photo
				gm composite -compress jpeg -quality $contest_sticker_jpeg_quality -compose over -gravity $contest_sticker_orientation -geometry $contest_sticker_geometry -dissolve $contest_sticker_opacity_in_percent $photo_dir/../${ar_contest_sticker_images[$rand]} "$argument" "$argument"

				# decrement remaining wins for this sticker and convert array to string
				ar_contest_remaining_wins[$rand]=$((ar_contest_remaining_wins[$rand]-1))
				contest_remaining_wins=$( IFS=$'|'; echo "${ar_contest_remaining_wins[*]}" )

				# update $contest_remaining_wins in $photo_dir/contest.sh
				sed -i "s/^.*export contest_remaining_wins=.*$/export contest_remaining_wins=\"$contest_remaining_wins\"/m" "$photo_dir/contest.sh"

				# update contest winner statistics (for OTA management interface)
				echo "${ar_contest_sticker_images[$rand]};$filename" >> "$photo_dir/contest.csv"
			fi

		fi
	fi

	# overlay logo over each image
	if [ $overlay_active -eq 1 ]; then
		# overlay logo over current photo
		gm composite -compress jpeg -quality $overlay_jpeg_quality -compose over -gravity $overlay_orientation -geometry $overlay_geometry -dissolve $overlay_opacity_in_percent $photo_dir/../$overlay_image "$argument" "$argument"
	fi

	# kill current slideshow
	killall feh 2> /dev/null

	# 1. show current photo for defined amount of time
	# 2. show randomized slideshow of all photos in defined interval
	feh -F --hide-pointer --zoom $photo_zoom -D $show_photo_in_sec --cycle-once "$argument" && feh -F --hide-pointer --zoom $photo_zoom -D $slideshow_interval_in_sec --randomize $photo_dir/*.jpg &

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
		gm convert "$argument" -thumbnail x$ota_image_height_download -unsharp 0x.5 -flatten "$photo_dir/ota-large/$filename"
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
