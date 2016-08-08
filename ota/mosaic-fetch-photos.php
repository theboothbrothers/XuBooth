<?php
	
	function myfilefilter($newerThan, $olderThan) {
		return function($item) use ($newerThan, $olderThan) {
			$filetime = filemtime("img-m/" . $item);
			if($filetime < $newerThan || $filetime >= $olderThan) return false;
			return true;
		};
	}




	header('Content-Type: application/json');

	// save script path
	$path = dirname(__FILE__) . "/";

	// time variables
	$timestamp = (isset($_GET["timestamp"]) ? $_GET["timestamp"] : 0);
	$now = time();
	
	// save current working dir
	$cwd = getcwd();

	// go to "img-m" and get all the jpg/jpeg files
	chdir("img-m");
	$images = glob('*.{jpg,jpeg}', GLOB_BRACE);
	chdir($cwd);
	
	// found images? 
	if(count($images)){
		// filter out expired files
		$images = array_filter($images, myfilefilter($timestamp, $now));

		// prefix folder to every image
		array_walk($images, function(&$item) { $item = "/img-m/" . $item; });

		// sort images naturally
		natcasesort($images);

		// read variables from XuBooth-tmp-vars.sh:
		//  - ota_mosaic_ads_probability_mode
		//  - ota_mosaic_ads_probability_1_over
		//  - ota_mosaic_ads_text
		//  - ota_mosaic_ads_bgcolor
		//  - ota_mosaic_ads_width
		//  - ota_mosaic_ads_height
		if(file_exists($path . "../XuBooth-tmp-vars.sh")) { $XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh"); }
		else { $XuBoothTmpVars = file_get_contents($path . "../XuBooth-sample-config.sh"); }

		preg_match("/export ota_mosaic_ads_mode=(.*)/", $XuBoothTmpVars, $matches);
		$ota_mosaic_ads_mode = $matches[1];

		preg_match("/export ota_mosaic_ads_probability_1_over=(.*)/", $XuBoothTmpVars, $matches);
		$ota_mosaic_ads_probability_1_over = $matches[1];

		preg_match("/export ota_mosaic_ads_text=\"(.*)\"/", $XuBoothTmpVars, $matches);
		$ota_mosaic_ads_text = $matches[1];

		preg_match("/export ota_mosaic_ads_bgcolor=\"(.*)\"/", $XuBoothTmpVars, $matches);
		$ota_mosaic_ads_bgcolor = $matches[1];

		preg_match("/export ota_mosaic_ads_width=(.*)/", $XuBoothTmpVars, $matches);
		$ota_mosaic_ads_width = $matches[1];

		preg_match("/export ota_mosaic_ads_height=(.*)/", $XuBoothTmpVars, $matches);
		$ota_mosaic_ads_height = $matches[1];
		
		// mix in content randomly (only when new images are present!)
		$content = null;
		if(count($images) && mt_rand(1, $ota_mosaic_ads_probability_1_over) == 1) {
			
			// insert text ads
			if($ota_mosaic_ads_mode == "text") {
				$content["width"] = $ota_mosaic_ads_width;
				$content["height"] = $ota_mosaic_ads_height;
				$content["bgcolor"] = $ota_mosaic_ads_bgcolor;
				$content["data"] = $ota_mosaic_ads_text;
			// insert image ads
			} else {

				chdir("img-ads");
				$ads = glob('*.{jpg,jpeg,gif}', GLOB_BRACE);
				chdir($cwd);

				$images[] = "/img-ads/" . $ads[mt_rand(0, count($ads)-1)];
			}
		}

		// format JSON output
		echo json_encode(array("timestamp" => $now, "images" => array_values($images), "content" => $content));
	} else {
		// format JSON output (empty result)
		echo json_encode(array("timestamp" => $now, "images" => null, "content" => null));
	}

?>