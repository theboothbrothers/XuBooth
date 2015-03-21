<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title>Over-The-Air</title>
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
		<h1>Over-The-Air</h1>
		<h2>Your Photobooth Gallery</h2>
	</header>

	<div id="reload"><a href=""></a></div>
	
	<div class="thumbs">
		<?php include("thumbs.php"); ?>
	</div>

	<script src="assets/js/jquery-1.7.1.min.js"></script>
	<script src="assets/touchTouch/touchTouch.jquery.js"></script>
	<script src="assets/js/script.js"></script>

</body>
</html>