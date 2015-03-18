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

# -----------------------------------
# General Settings
# -----------------------------------
export show_photo_in_sec="120"
export slideshow_interval_in_sec="10"

# -----------------------------------
# Overlay Logo
# -----------------------------------
export overlay_active=1
export overlay_image="images/overlay_theboothbrothers.png"
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
export ota_images_per_folder=50
export ota_image_height=1024
export ota_image_border_color="white"
export ota_image_border_size=18
export ota_thumbnail_size=75
export ota_thumbnail_border_color="white"
export ota_thumbnail_border_size=5