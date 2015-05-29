<?php
	// save script path
	$path = dirname(__FILE__) . "/";

	// get passed argument
	$file = $path . $_GET['f'];

	// save current time
	$now = time();

	// read $photo_dir and $ota_image_expiration_in_min from XuBooth-tmp-vars.sh
	if(file_exists($path . "../XuBooth-tmp-vars.sh")) {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh");
		preg_match("/export photo_dir=(.*)/", $XuBoothTmpVars, $matches);
		$csvFile = realpath($path . "../" . $matches[1]) . "/download_stats.csv";
		preg_match("/export ota_image_expiration_in_min=(.*)/", $XuBoothTmpVars, $matches);
		$expiration = $matches[1];
	}

	if (file_exists($file) && dirname($file) == $path."img-l" && filemtime($file) >= ($now - 60*$expiration)) {
		// open CSV file and write download statistics
		$fp = fopen($csvFile, "a");
		if(flock($fp, LOCK_EX)) {
			fputcsv($fp, array(date("Y-m-d H:i:s"), $_SERVER["REMOTE_ADDR"], $_SERVER["HTTP_USER_AGENT"], basename($file)), ";");
			flock($fp, LOCK_UN);
		}
		fclose($fp);

		// provide browser with the requested file
		header('Content-Description: File Transfer');
		header('Content-Type: image/jpeg');
		header('Content-Disposition: attachment; filename=' . basename($file));
		header('Content-Transfer-Encoding: binary');
		header('Expires: 0');
		header('Cache-Control: must-revalidate');
		header('Pragma: public');
		header('Content-Length: ' . filesize($file));
		ob_clean();
		flush();
		readfile($file);
		exit;
	} else {
		header("HTTP/1.0 404 Not Found");
		echo "<h1>404 Not Found</h1>";
		echo "The page that you have requested could not be found.";
		exit();
	}

?>
