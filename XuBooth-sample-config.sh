#!/bin/bash

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
export exif_contact="www.TheBoothBrothers.de"

# -----------------------------------
# OTA
# -----------------------------------
export ota_active=1

	# OTA AccessPoint
	export ota_dev_wlan0=wlan0
	export ota_dev_eth0=eth0
	export ota_wlan_driver=nl80211
	export ota_wlan_channel=1
	export ota_wlan_ssid="PhotoBooth"
	export ota_wlan_pass="thepassword"

	# OTA WebServer
	export ota_image_height=1024
	export ota_image_border_color="white"
	export ota_image_border_size=18
	export ota_thumbnail_size=75
	export ota_thumbnail_border_color="white"
	export ota_thumbnail_border_size=0
