#!/bin/bash

#
# PLEASE DO NOT CHANGE THE FOLLOWING LINE UNLESS YOU KNOW WHAT YOU'RE DOING
#
export xubooth_config_version=13



# -----------------------------------
# General Settings
# -----------------------------------
export filename_prefix=theboothbrothers
export show_photo_in_sec="120"
export slideshow_interval_in_sec="10"
export photo_zoom=max
#export photo_zoom=fill
export intermission_image="images/intermission/theboothbrothers1.gif"
export shooting_mode=default
#export shooting_mode=picstrip
#export shooting_mode=disclaimer

# -----------------------------------
# PictureStrip Mode
# -----------------------------------
export picstrip_timeout_in_sec="300"
export picstrip_template="images/picstrip/theboothbrothers.jpg"
export picstrip_images="1"
export picstrip_quality="80"
export picstrip_images="4"
export picstrip_quality="80"
export picstrip_crop_1=""
export picstrip_cropgravity_1=""
export picstrip_geometry_1="689x459!+70+70"
export picstrip_crop_2=""
export picstrip_cropgravity_2=""
export picstrip_geometry_2="689x459!+834+70"
export picstrip_crop_3=""
export picstrip_cropgravity_3=""
export picstrip_geometry_3="689x459!+1597+70"
export picstrip_crop_4=""
export picstrip_cropgravity_4=""
export picstrip_geometry_4="1457x971!+829+598"


# -----------------------------------
# Dislaimer Mode
# -----------------------------------
export disclaimer_kb_name="Dell USB"
export disclaimer_kb_action_key="KP_Enter"
export disclaimer_image1="images/disclaimer/theboothbrothers1.jpg"
export disclaimer_image2="images/disclaimer/theboothbrothers2.jpg"
export disclaimer_timeout_in_sec="300"

# -----------------------------------
# Overlay Logo
# -----------------------------------
export overlay_active=1
export overlay_image="images/overlays/theboothbrothers.png"
export overlay_opacity_in_percent="60"
export overlay_orientation="NorthEast"
export overlay_geometry="x500+0+0"
export overlay_jpeg_quality="80"

# -----------------------------------
# Contest Mode
# -----------------------------------
export contest_active=0
export contest_probability_1_over=100
export contest_max_wins="5|5"
export contest_sticker_images="images/stickers/theboothbrothers1.png|images/stickers/theboothbrothers2.png"
export contest_sticker_opacity_in_percent="100"
export contest_sticker_orientation="SouthWest"
export contest_sticker_geometry="x450+100+75"
export contest_sticker_jpeg_quality="80"

# -----------------------------------
# EXIF Data
# -----------------------------------
export exif_active=1
export exif_credit="The Booth Brothers"
export exif_copyright="(c) The Booth Brothers"

# -----------------------------------
# OTA
# -----------------------------------
export ota_active=0

	# OTA AccessPoint
	export ota_dhcp_lease_in_min=1440
	export ota_wlan_ssid="PhotoBooth"
	export ota_wlan_pass="thepassword"
	export ota_device=ddwrt
#	export ota_device=usb

	# OTA AccessPoint (DD-WRT Router)
	export ota_ddwrt_ip=192.168.1.1
	export ota_ddwrt_ssh_port=2531
	export ota_ddwrt_ssh_keyfile=ota-ssh-keys/theboothbrothers

	# OTA AccessPoint (USB Wifi)
	export ota_wlan_driver=nl80211
	export ota_wlan_channel=13
	export ota_wlan_country_code=DE

	# OTA Branding
	export ota_domain="fotobox.link"
	export ota_title="Over-The-Air"
	export ota_caption="Your Photobooth Gallery"
	export ota_disclaimer="<b>Please note</b>: there is <b><u>no public access</u></b> to the internet in this wifi. Please disconnect from this wifi when finished downloading. Otherwise you won't be able to surf the internet and share your images online."
#	export ota_disclaimer="<b>Achtung</b>: Dieses WLAN bietet <b><u>keinen Zugriff</u></b> ins öffentliche Internet. Bitte trennen Sie die Verbindung nach dem Download. Anderenfalls werden Sie nicht online surfen können."
	export ota_ios_message="How do I save? Long-press on the following image."
#	export ota_ios_message="Wie speichere ich? Langes Drücken auf das folgende Bild!"
	export ota_body_bgcolor="#7f2a41"
	export ota_header_bgcolor_1="#ffffff"
	export ota_header_bgcolor_2="#ededed"

	# OTA Images
	export ota_images_per_page=12
	export ota_image_expiration_in_min=10
	export ota_image_height=1024
	export ota_image_height_download=2048
	export ota_image_border_color="white"
	export ota_image_border_size=18
	export ota_thumbnail_size=75
	export ota_thumbnail_border_color="white"
	export ota_thumbnail_border_size=0

	# OTA Management Portal
	export ota_management_user="admin"
	export ota_management_pass="thepassword"
