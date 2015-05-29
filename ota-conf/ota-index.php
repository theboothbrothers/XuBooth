<?php

	function prepareThumbs() {
		global $files, $expiration;

		// save current working dir
		$cwd = getcwd();

		// save current time
		$now = time();

		// go to "img-m" and get all the jpg/jpeg files
		chdir("img-m");
		$files = glob('*.{jpg,jpeg}', GLOB_BRACE);
		chdir($cwd);

		// found images? 
		if(count($files)){

			// filter out expired files
			$files = array_filter($files, function(&$file, &$index) {
				if(!is_file("img-l/" . $file)) return false;
				if(filemtime("img-l/" . $file) < ($now - 60*$expiration)) return false;
				return true;
			});

			// sort images naturally
			natcasesort($files);

			// reverse sort order
			$files = array_reverse($files, false);

			return count($files);
		}

		return 0;
	}


	function echoThumbs() {
		global $files, $currentPage, $imagesPerPage;

		// remove images that are not shown on this page
		$files = array_slice($files, $imagesPerPage*($currentPage-1), $imagesPerPage);

		// iterate over images
		foreach($files as $file) {
			$time = date("H:i:s", filemtime("img-m/" . $file));
			echo '<a href="img-m/' . $file . '" style="background-image:url(img-s/' . $file . ')" title="' . $time . '" alt="img-l/' . $file . '"></a>';
			echo "\r\n";
		}
	}

	function echoPrevPage() {
		global $currentPage;

		if($currentPage > 1) {
			echo '<a href="?page=' . ($currentPage-1) . '"> <<< </a>';
		}
	}

	function echoNextPage() {
		global $currentPage, $totalImagesVisible, $imagesPerPage;

		if($currentPage*$imagesPerPage < $totalImagesVisible) {
			echo '<a href="?page=' . ($currentPage+1) . '"> >>> </a>';
		}
	}


	$files = array();
	$currentPage = 1;
	if( isset($_GET["page"]) &&  !empty($_GET["page"]) ) {
		// strip all non-digits from $_GET["page"]
		$currentPage = preg_replace("/[^0-9]/", "", $_GET["page"]);
	}

	// save script path
	$path = dirname(__FILE__) . "/";

	// read variables from XuBooth-tmp-vars.sh:
	//  - ota_images_per_page
	//  - ota_image_expiration_in_min
	if(file_exists($path . "../XuBooth-tmp-vars.sh")) {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh");
		preg_match("/export ota_images_per_page=(.*)/", $XuBoothTmpVars, $matches);
		$imagesPerPage = $matches[1];
		preg_match("/export ota_image_expiration_in_min=(.*)/", $XuBoothTmpVars, $matches);
		$expiration = $matches[1];
	}

	// prepare thumbnails for this page to be echo'd later
	$totalImagesVisible = prepareThumbs();




?>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title><<<title>>> | <<<caption>>></title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, maximum-scale=1.0" />
	<link rel="stylesheet" href="assets/css/styles.css" />
	<link rel="stylesheet" href="assets/touchTouch/touchTouch.css" />
	<style>
		@font-face {
			font-family: 'Dancing Script';
			font-style: normal;
			font-weight: 400;
			src: local('Dancing Script'), local('DancingScript'), url(/assets/ttf/DancingScript.ttf) format('truetype');
		}
	</style>

	<!--[if lt IE 9]>
		<script src="assets/js/html5.js"></script>
	<![endif]-->
</head>

<body>

	<header>
		<h1><<<title>>></h1>
		<h2><<<caption>>></h2>
	</header>

	<div id="reload"><a href=""></a></div>
	
	<div id="disclaimer">
		<<<disclaimer>>>
	</div>

	<div class="thumbs">
		<?php echoThumbs(); ?>
	</div>

	<div id="pagination">
		<span id="prevpage"><?php echoPrevPage(); ?></span>
		<span id="nextpage"><?php echoNextPage(); ?></span>
	</div>

	<script src="assets/js/jquery-1.7.1.min.js"></script>
	<script src="assets/touchTouch/touchTouch.jquery.js"></script>
	<script src="assets/js/script.js"></script>

</body>
</html>