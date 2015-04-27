<?php
	// save script path
	$path = dirname(__FILE__) . "/";

	// save current working dir
	$cwd = getcwd();

	// save current time
	$now = time();

	// read $ota_image_expiration_in_min from XuBooth-tmp-vars.sh
	if(file_exists($path . "../XuBooth-tmp-vars.sh")) {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh");
		preg_match("/export ota_image_expiration_in_min=(.*)/", $XuBoothTmpVars, $matches);
		$expiration = $matches[1];
	}

	// go to "img-m" and get all the jpg/jpeg files
	chdir("img-m");
	$files = glob('*.{jpg,jpeg}', GLOB_BRACE);
	chdir($cwd);

	// found images? 
	if(count($files)){

		// sort images naturally and reverse sort order afterwards
		natcasesort($files);
		$files = array_reverse($files, false);

		// print out HTML code for each image that is not yet expired
		foreach($files as $file) {
			if(is_file("img-m/" . $file) && ($now - filemtime("img-m/" . $file)) <= 60*$expiration) {
				$time = date("H:i:s", filemtime("img-m/" . $file));
				echo '<a href="img-m/' . $file . '" style="background-image:url(img-s/' . $file . ')" title="' . $time . '" alt="img-l/' . $file . '"></a>';
				echo "\r\n";
			}
		}
	}

?>