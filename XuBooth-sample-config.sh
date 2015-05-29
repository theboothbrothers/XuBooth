#!/bin/bash

#
# PLEASE DO NOT CHANGE THIS UNLESS YOU KNOW WHAT YOU'RE DOING
#
export xubooth_config_version=2



# -----------------------------------
# General Settings
# -----------------------------------
export filename_prefix=theboothbrothers
export show_photo_in_sec="120"
export slideshow_interval_in_sec="10"

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
# EXIF Data
# -----------------------------------
export exif_active=0
export exif_credit="The Booth Brothers"
export exif_copyright="(c) The Booth Brothers"
# -----------------------------------
# OTA
# -----------------------------------
export ota_active=1

	# OTA AccessPoint
	export ota_dev_wlan0=wlan0
	export ota_dev_eth0=eth0
	export ota_dhcp_lease_in_min=10
	export ota_wlan_driver=nl80211
	export ota_wlan_channel=1
	export ota_wlan_ssid="PhotoBooth"
	export ota_wlan_pass="thepassword"
	export ota_wlan_country_code=DE

	# OTA Branding
	export ota_domain="theboothbrothers.de"
	export ota_title="Over-The-Air"
	export ota_caption="Your Photobooth Gallery"
	export ota_disclaimer="<b>Achtung</b>: in unserem WLAN gibt es <b><u>keinen Zugang</u></b> ins öffentliche Internet. Bitte nach dem Download der Bilder wieder aus dem WLAN abmelden, um im Internet surfen zu können."
	export ota_ios_message="Zum Speichern bitte lange auf das Bild tippen."
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