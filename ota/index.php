<?php

	function myfilefilter($now, $expiration) {
		return function($item) use ($now, $expiration) {
			if(!is_file("img-s/" . $item)) return false;
			if(!is_file("img-l/" . $item)) return false;
			if(filemtime("img-l/" . $item) < ($now - 60*$expiration)) return false;
			return true;
		};
	}

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
			$files = array_filter($files, myfilefilter($now, $expiration));

			// sort images naturally
			natcasesort($files);

			// reverse sort order
			$files = array_reverse($files, false);
			return count($files);
		}

		return 0;
	}


	function echoThumbs() {
		global $files, $currentPage, $totalImagesVisible, $imagesPerPage;

		// correct for out-of-bounds $currentPage
		$numPages = ceil($totalImagesVisible / $imagesPerPage);
		if($currentPage < 1 || $currentPage > $numPages) $currentPage = 1;

		// remove images that are not shown on this page
		$files = array_slice($files, $imagesPerPage*($currentPage-1), $imagesPerPage);

		// iterate over images
		foreach($files as $file) {
			$time = date("H:i:s", filemtime("img-m/" . $file));
			echo '<a href="img-m/' . $file . '" style="background-image:url(img-s/' . $file . ')" title="' . $time . '" alt="img-l/' . $file . '"></a>';
			echo "\r\n";
		}
	}

	function echoPagination() {
		global $currentPage, $totalImagesVisible, $imagesPerPage;

		$numPages = ceil($totalImagesVisible / $imagesPerPage);
		// show max. 5 pages at once
		// left side abbreviation: appears at page 4+ and is $currentPage-2
		$left = ($currentPage >= 4 ? $currentPage-2 : 0);
		// right side abbreviation: appears at page 1+ and is...
		//	a) 5; if there's no left abbreviation yet
		//	b) $currentPage+2; if there's already left abbreviation
		$right = ($left < 1 ? min(5, $numPages+1) : min($currentPage+2, $numPages+1));
		// left side abbreviation fix: if there's no right side abbreviation anymore, shift left side abbreviation $numPages-4
		$left = ($right > $numPages ? $numPages-4 : $left);

		for($i = 1; $i <= $numPages; $i++) {

			if($i == $currentPage) {
				echo sprintf("<a href='' class='current'>%d</a>", $i);
			} else {
				// skip pages left of $left and put "..." at $left				
				if($i <= $left && $i > 1) {
					if($i == $left) echo "...";
				// skip pages right of $right and put "..." at $right
				} else if($i >= $right && $i < $numPages) {
					if($i == $right) echo "...";
				// all the other pages
				} else {
					echo sprintf("<a href='?page=%d'>%d</a>", $i, $i);
				}
			}

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
	//  - ota_title
	//  - ota_caption
	//  - ota_disclaimer
	if(file_exists($path . "../XuBooth-tmp-vars.sh")) {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh");
	} else {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-sample-config.sh");
	}

	preg_match("/export ota_images_per_page=(.*)/", $XuBoothTmpVars, $matches);
	$imagesPerPage = $matches[1];
	preg_match("/export ota_image_expiration_in_min=(.*)/", $XuBoothTmpVars, $matches);
	$expiration = $matches[1];
	preg_match("/export ota_title=\"(.*)\"/", $XuBoothTmpVars, $matches);
	$title = $matches[1];
	preg_match("/export ota_caption=\"(.*)\"/", $XuBoothTmpVars, $matches);
	$caption = $matches[1];
	preg_match("/export ota_disclaimer=\"(.*)\"/", $XuBoothTmpVars, $matches);
	$disclaimer = $matches[1];

	// prepare thumbnails for this page to be echo'd later
	$totalImagesVisible = prepareThumbs();




?>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title><?php echo $title . " | " . $caption; ?></title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, maximum-scale=1.0" />
	<link rel="stylesheet" href="assets/css/styles.css.php" />
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
		<h1><?php echo $title; ?></h1>
		<h2><?php echo $caption; ?></h2>
	</header>

	<div id="reload"><a href="?page="></a></div>
	
	<div id="disclaimer">
		<?php echo $disclaimer; ?>
	</div>

	<div class="thumbs">
		<?php echoThumbs(); ?>
	</div>

	<div id="pagination">
		<?php echoPagination(); ?>
	</div>

	<script src="assets/js/jquery-1.7.1.min.js"></script>
	<script src="assets/touchTouch/touchTouch.jquery.js"></script>
	<script src="assets/js/script.js"></script>

</body>
</html>