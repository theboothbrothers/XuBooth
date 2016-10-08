	/* global XuBoothConfig object */
	var oConfig = null;

	/* CONSTANTS */
	currentXuBoothConfigVersion = 14;
	sMsgCouldNotDetectXuBoothConfigVersion = "Sorry, could not detect this config file's version. Stopping.";
	sMsgOldXuBoothConfigVersion = "We need a config file of version " + currentXuBoothConfigVersion + ". Yours is: ";

	/* attributes that need further interpretion */
	attributeNeedsInterpretation = [
		"xubooth_config_version",
		"overlay_active",
		"exif_active",
		"ota_active"
	];

	/* attributes that don't need wrapping quotes */
	attributeNoQuotes = [
		"xubooth_config_version",
		"filename_prefix",
		"photo_zoom",
		"shooting_mode",
		"overlay_active",
		"contest_active",
		"contest_probability_1_over",
		"exif_active",
		"ota_active",
		"ota_dhcp_lease_in_min",
		"ota_device",
		"ota_ddwrt_ip",
		"ota_ddwrt_ssh_port",
		"ota_ddwrt_ssh_keyfile",
		"ota_wlan_driver",
		"ota_wlan_channel",
		"ota_wlan_country_code",
		"ota_images_per_page",
		"ota_image_expiration_in_min",
		"ota_image_height",
		"ota_image_height_download",
		"ota_image_border_size",
		"ota_thumbnail_size",
		"ota_thumbnail_border_size",
		"ota_mosaic_ads_mode",
		"ota_mosaic_ads_probability_1_over"
	];


	/* checks parameter for type "function" */
	function isFunction(functionToCheck) {
		var getType = {};
		return functionToCheck && getType.toString.call(functionToCheck) === '[object Function]';
	}


	/* parses config for attributes */
	function parseXuBoothConfig(configRaw, p) {
		if (configRaw !== null) {
			var lines = configRaw.split("\n");
			var numLines = lines.length;
			var needle = "export " + p + "=";
			
			for (i = 0; i < numLines; i++) {
				var idx = lines[i].indexOf(needle);
				var idxHash = lines[i].indexOf("#");
				if (idx > -1 && (idxHash < 0 || idxHash > idx)) {
					var result = lines[i].substring(idx + needle.length);
					if(attributeNoQuotes.indexOf(p) < 0) result = result.substring(1, result.length-1);
					return result;
					break;
				}
			}
		}
		
		return null;
	}


	/* write XuBoothConfig attributes to HTML form */
	function fillInForm(oConfig) {
		// check XuBoothConfig version
		if (oConfig["xubooth_config_version"] === null) { alert(sMsgCouldNotDetectXuBoothConfigVersion); return; }
		if (oConfig["xubooth_config_version"] < currentXuBoothConfigVersion) alert(sMsgOldXuBoothConfigVersion + oConfig["xubooth_config_version"]);
		
		/* process basic attributes */
		for (var p in oConfig) {
			if (oConfig.hasOwnProperty(p) && !isFunction(oConfig[p]) && attributeNeedsInterpretation.indexOf(p) < 0) {
				document.getElementById(p).value = oConfig[p];
			}
		}
		
		/* special attributes */
		document.getElementById("overlay_active").checked = (oConfig["overlay_active"] == 1);
		document.getElementById("exif_active").checked = (oConfig["exif_active"] == 1);
		document.getElementById("ota_active").checked = (oConfig["ota_active"] == 1);
		document.getElementById("contest_active").checked = (oConfig["contest_active"] == 1);
		
		/* preview of OTA Disclaimer */
		document.getElementById("ota_disclaimer_preview").innerHTML = oConfig["ota_disclaimer"];
		document.getElementById("ota_mosaic_ads_text_preview").innerHTML = oConfig["ota_mosaic_ads_text"];
		
		/* preview of OTA colors */
		document.getElementById("ota_thumbnail_border_color_preview").style.background = oConfig["ota_thumbnail_border_color"];
		document.getElementById("ota_image_border_color_preview").style.background = oConfig["ota_image_border_color"];
		document.getElementById("ota_body_bgcolor_preview").style.background = oConfig["ota_body_bgcolor"];
		document.getElementById("ota_header_bgcolor_1_preview").style.background = oConfig["ota_header_bgcolor_1"];
		document.getElementById("ota_header_bgcolor_2_preview").style.background = oConfig["ota_header_bgcolor_2"];
		document.getElementById("ota_mosaic_ads_bgcolor_preview").style.background = oConfig["ota_mosaic_ads_bgcolor"];
	}


	/* creates download link out of XuBoothConfig */
	function createDownloadLink(oConfig) {
		var data = "#!/bin/bash\n";
		for(var p in oConfig) {
			if(attributeNoQuotes.indexOf(p) > -1) {
				data = data + "export " + p + "=" + oConfig[p] + "\n";
			} else {
				data = data + "export " + p + "=\"" + oConfig[p] + "\"\n";
			}
		}
		
		var e = document.getElementById("download-button");
		e.setAttribute("download", "rename-me.txt");
		e.setAttribute("href", "data:text/plain;base64," + btoa(data.replace(/\n/g, '\r\n')));
		e.setAttribute("class", "cursor-pointer");
	}


	/* OBJECT CONSTRUCTOR: XuBoothConfig*/
	function XuBoothConfig(configRaw) {

		this.xubooth_config_version = parseXuBoothConfig(configRaw, "xubooth_config_version");

		/* General Settings */
		this.shooting_mode = parseXuBoothConfig(configRaw, "shooting_mode")
		this.filename_prefix = parseXuBoothConfig(configRaw, "filename_prefix");
		this.show_photo_in_sec = parseXuBoothConfig(configRaw, "show_photo_in_sec")
		this.slideshow_interval_in_sec = parseXuBoothConfig(configRaw, "slideshow_interval_in_sec")
		this.photo_zoom = parseXuBoothConfig(configRaw, "photo_zoom")
		this.intermission_image = parseXuBoothConfig(configRaw, "intermission_image")

		/* PictureStrip Mode */
		this.picstrip_timeout_in_sec = parseXuBoothConfig(configRaw, "picstrip_timeout_in_sec")
		this.picstrip_template = parseXuBoothConfig(configRaw, "picstrip_template")
		this.picstrip_images = parseXuBoothConfig(configRaw, "picstrip_images")
		this.picstrip_quality = parseXuBoothConfig(configRaw, "picstrip_quality")
		this.picstrip_crop_1 = parseXuBoothConfig(configRaw, "picstrip_crop_1")
		this.picstrip_cropgravity_1 = parseXuBoothConfig(configRaw, "picstrip_cropgravity_1")
		this.picstrip_geometry_1 = parseXuBoothConfig(configRaw, "picstrip_geometry_1")
		/* ... */

		/* Dislcaimer Mode */
		this.disclaimer_kb_name = parseXuBoothConfig(configRaw, "disclaimer_kb_name")
		this.disclaimer_kb_action_key = parseXuBoothConfig(configRaw, "disclaimer_kb_action_key")
		this.disclaimer_image1 = parseXuBoothConfig(configRaw, "disclaimer_image1")
		this.disclaimer_image2 = parseXuBoothConfig(configRaw, "disclaimer_image2")
		this.disclaimer_timeout_in_sec = parseXuBoothConfig(configRaw, "disclaimer_timeout_in_sec")

		/* Overlay Logo */
		this.overlay_active = parseXuBoothConfig(configRaw, "overlay_active")
		this.overlay_image = parseXuBoothConfig(configRaw, "overlay_image")
		this.overlay_opacity_in_percent = parseXuBoothConfig(configRaw, "overlay_opacity_in_percent")
		this.overlay_orientation = parseXuBoothConfig(configRaw, "overlay_orientation")
		this.overlay_geometry = parseXuBoothConfig(configRaw, "overlay_geometry")
		this.overlay_jpeg_quality = parseXuBoothConfig(configRaw, "overlay_jpeg_quality")

		/* Contest Mode */
		this.contest_active = parseXuBoothConfig(configRaw, "contest_active")
		this.contest_probability_1_over = parseXuBoothConfig(configRaw, "contest_probability_1_over")
		this.contest_max_wins = parseXuBoothConfig(configRaw, "contest_max_wins")
		this.contest_sticker_images = parseXuBoothConfig(configRaw, "contest_sticker_images")
		this.contest_sticker_opacity_in_percent = parseXuBoothConfig(configRaw, "contest_sticker_opacity_in_percent")
		this.contest_sticker_orientation = parseXuBoothConfig(configRaw, "contest_sticker_orientation")
		this.contest_sticker_geometry = parseXuBoothConfig(configRaw, "contest_sticker_geometry")
		this.contest_sticker_jpeg_quality = parseXuBoothConfig(configRaw, "contest_sticker_jpeg_quality")

		/* EXIF Data */
		this.exif_active = parseXuBoothConfig(configRaw, "exif_active")
		this.exif_credit = parseXuBoothConfig(configRaw, "exif_credit")
		this.exif_copyright = parseXuBoothConfig(configRaw, "exif_copyright")

		/* OTA */
		this.ota_active = parseXuBoothConfig(configRaw, "ota_active")

		/* OTA AccessPoint */
		this.ota_dhcp_lease_in_min = parseXuBoothConfig(configRaw, "ota_dhcp_lease_in_min")
		this.ota_wlan_ssid = parseXuBoothConfig(configRaw, "ota_wlan_ssid")
		this.ota_wlan_pass = parseXuBoothConfig(configRaw, "ota_wlan_pass")
		this.ota_device = parseXuBoothConfig(configRaw, "ota_device")

		/* OTA AccessPoint (DD-WRT Router) */
		this.ota_ddwrt_ip = parseXuBoothConfig(configRaw, "ota_ddwrt_ip")
		this.ota_ddwrt_ssh_port = parseXuBoothConfig(configRaw, "ota_ddwrt_ssh_port")
		this.ota_ddwrt_ssh_keyfile = parseXuBoothConfig(configRaw, "ota_ddwrt_ssh_keyfile")

		/* OTA AccessPoint (USB Wifi) */
		this.ota_wlan_driver = parseXuBoothConfig(configRaw, "ota_wlan_driver")
		this.ota_wlan_channel = parseXuBoothConfig(configRaw, "ota_wlan_channel")
		this.ota_wlan_country_code = parseXuBoothConfig(configRaw, "ota_wlan_country_code")

		/* OTA Branding */
		this.ota_domain = parseXuBoothConfig(configRaw, "ota_domain")
		this.ota_title = parseXuBoothConfig(configRaw, "ota_title")
		this.ota_caption = parseXuBoothConfig(configRaw, "ota_caption")
		this.ota_disclaimer = parseXuBoothConfig(configRaw, "ota_disclaimer")
		this.ota_ios_message = parseXuBoothConfig(configRaw, "ota_ios_message")
		this.ota_body_bgcolor = parseXuBoothConfig(configRaw, "ota_body_bgcolor")
		this.ota_header_bgcolor_1 = parseXuBoothConfig(configRaw, "ota_header_bgcolor_1")
		this.ota_header_bgcolor_2 = parseXuBoothConfig(configRaw, "ota_header_bgcolor_2")

		/* OTA Images */
		this.ota_images_per_page = parseXuBoothConfig(configRaw, "ota_images_per_page")
		this.ota_image_expiration_in_min = parseXuBoothConfig(configRaw, "ota_image_expiration_in_min")
		this.ota_image_height = parseXuBoothConfig(configRaw, "ota_image_height")
		this.ota_image_height_download = parseXuBoothConfig(configRaw, "ota_image_height_download")
		this.ota_image_border_color = parseXuBoothConfig(configRaw, "ota_image_border_color")
		this.ota_image_border_size = parseXuBoothConfig(configRaw, "ota_image_border_size")
		this.ota_thumbnail_size = parseXuBoothConfig(configRaw, "ota_thumbnail_size")
		this.ota_thumbnail_border_color = parseXuBoothConfig(configRaw, "ota_thumbnail_border_color")
		this.ota_thumbnail_border_size = parseXuBoothConfig(configRaw, "ota_thumbnail_border_size")

		/* OTA Mosaic Slideshow */
		this.ota_mosaic_ads_mode = parseXuBoothConfig(configRaw, "ota_mosaic_ads_mode")
		this.ota_mosaic_ads_probability_1_over = parseXuBoothConfig(configRaw, "ota_mosaic_ads_probability_1_over")
		this.ota_mosaic_ads_text = parseXuBoothConfig(configRaw, "ota_mosaic_ads_text")
		this.ota_mosaic_ads_bgcolor = parseXuBoothConfig(configRaw, "ota_mosaic_ads_bgcolor")

		/* OTA Management Portal */
		this.ota_management_user = parseXuBoothConfig(configRaw, "ota_management_user")
		this.ota_management_pass = parseXuBoothConfig(configRaw, "ota_management_pass")
	}


	/* handle file passed via upload */
	function handleFileSelect(evt) {
		var reader = new FileReader();
		reader.onload = (function(theFile) {
			return function(e) {
				// create config object from raw config
				oConfig = new XuBoothConfig(e.target.result);
				
				// load settings into HTML form
				fillInForm(oConfig);
				
				// create download link from config object
				createDownloadLink(oConfig);
			};
		})(evt.target.files[0]);
		reader.readAsText(evt.target.files[0]);
	}


	/* handle file passed via upload */
	function handleFileSelect2(evt) {
		document.getElementById(evt.target.name).value = evt.target.alt + evt.target.files[0].name;
	}


	/* process input on HTML form elements */
	function processInput(evt) {
		oConfig[evt.srcElement.name] = evt.srcElement.value;
		createDownloadLink(oConfig);
		
		/* preview of OTA Disclaimer */
		if(evt.srcElement.name == "ota_disclaimer") document.getElementById("ota_disclaimer_preview").innerHTML = evt.srcElement.value;
		
		/* preview of OTA colors */
		if(evt.srcElement.name == "ota_thumbnail_border_color") document.getElementById("ota_thumbnail_border_color_preview").style.background = evt.srcElement.value;
		if(evt.srcElement.name == "ota_image_border_color") document.getElementById("ota_image_border_color_preview").style.background = evt.srcElement.value;
		if(evt.srcElement.name == "ota_body_bgcolor") document.getElementById("ota_body_bgcolor_preview").style.background = evt.srcElement.value;
		if(evt.srcElement.name == "ota_header_bgcolor_1") document.getElementById("ota_header_bgcolor_1_preview").style.background = evt.srcElement.value;
		if(evt.srcElement.name == "ota_header_bgcolor_2") document.getElementById("ota_header_bgcolor_2_preview").style.background = evt.srcElement.value;
	}


	/* setup listeners for file choosers */
	function setupListeners() {
		// config file chooser
		document.getElementById("config_file_chooser").addEventListener("change", handleFileSelect, false);
		
		// XuBoothConfig file choosers
		document.getElementById("intermission_image_chooser").addEventListener("change", handleFileSelect2, false);
		document.getElementById("picstrip_template_chooser").addEventListener("change", handleFileSelect2, false);
		document.getElementById("disclaimer_image1_chooser").addEventListener("change", handleFileSelect2, false);
		document.getElementById("disclaimer_image2_chooser").addEventListener("change", handleFileSelect2, false);
		document.getElementById("overlay_image_chooser").addEventListener("change", handleFileSelect2, false);
		document.getElementById("ota_ddwrt_ssh_keyfile_chooser").addEventListener("change", handleFileSelect2, false);
		
		// input on HTML form
		document.getElementById("settings").addEventListener("input", processInput, false);
	}


	function onBodyLoad() {
		// create empty XuBoothConfig object
		oConfig = new XuBoothConfig(null);
		
		// setup event listeners
		setupListeners();
	}