<?php
	
	header('Content-Type: application/json');

	function myfilefilter($newerThan, $olderThan) {
		return function($item) use ($newerThan, $olderThan) {
			$filetime = filemtime("img-m/" . $item);
			if($filetime < $newerThan || $filetime >= $olderThan) return false;
			return true;
		};
	}
	
	// time variables
	$timestamp = (isset($_GET["timestamp"]) ? $_GET["timestamp"] : 0);
	$now = time();
	
	// save current working dir
	$cwd = getcwd();

	// go to "img-m" and get all the jpg/jpeg files
	chdir("img-m");
	$files = glob('*.{jpg,jpeg}', GLOB_BRACE);
	chdir($cwd);
	
	// found images? 
	if(count($files)){
		// filter out expired files
		$files = array_filter($files, myfilefilter($timestamp, $now));
		
		// sort images naturally
		natcasesort($files);
		
		// format JSON output
		echo json_encode(array("timestamp" => $now, "files" => array_values($files)));
	} else {
		// format JSON output
		echo json_encode(array("timestamp" => $now, "files" => null));
	}

?>