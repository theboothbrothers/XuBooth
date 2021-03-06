<?php

	/*
		this script provides the user-configured iOS message
		it is queried via JSON through "assets/touchTouch/touchTouch.jquery.js"
	*/

	// save script path
	$path = dirname(__FILE__) . "/";

	// read $ota_image_expiration_in_min from XuBooth-tmp-vars.sh
	if(file_exists($path . "../XuBooth-tmp-vars.sh")) {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh");
		preg_match("/export ota_ios_message=(.*)/", $XuBoothTmpVars, $matches);
		$iosMessage = trim($matches[1], '"');

		// output the message
		echo $iosMessage;
	}
?>