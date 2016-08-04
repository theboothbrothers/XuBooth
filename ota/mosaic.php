<!DOCTYPE html>
<html>
	<head>
		<title>Over-The-Air: Mosaic Slideshow</title>
		<meta content="text/html; charset=utf-8" http-equiv="content-type">
		<script type="text/javascript" src="assets/js/jquery-1.10.2.min.js"></script>
		<script type="text/javascript" src="assets/js/freewall.js"></script>
		<link rel="stylesheet" type="text/css" href="assets/css/mosaic-styles.css" />
	</head>
	<body>

            	<button id="fullscreen" style="position: absolute; top: 10px; left: 10px; width: 30px; height: 30px; z-index: 999"> &uarr; </button>

		<div id="freewall" class="free-wall"></div>
		
		<script type="text/javascript">

			// update interval (ask server for new photos) in msec
			var updateInterval = 2000;

			// max. amount of new images
			var maxNewImages = 35;

			// turn on browsers's fullscreen mode
			var e = document.getElementById("fullscreen");
			e.addEventListener("click", function() {
				var elem = document.getElementsByTagName("body")[0];
				if (elem.requestFullScreen) {
					elem.requestFullScreen();
				} else if (elem.mozRequestFullScreen) {
					elem.mozRequestFullScreen();
				} else if (elem.webkitRequestFullScreen) {
					elem.webkitRequestFullScreen();
				}
				document.getElementById("fullscreen").style.display = "none";
			});

			// returns random integer in range between $min and $max
			function getRandomInt(min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }
		
			// cell sizes to be used
			var arSizes = new Array();
			arSizes[0] = new Array("300", "200");
			arSizes[1] = new Array("300", "200");
			arSizes[2] = new Array("300", "200");
			arSizes[3] = new Array("300", "200");
			arSizes[4] = new Array("150", "100");
			arSizes[5] = new Array("150", "100");
			arSizes[6] = new Array("150", "100");
			arSizes[7] = new Array("600", "400");
			
			$(function() {

				var wall = new Freewall("#freewall");
				wall.reset({
					selector: '.cell',
					animate: true,
					cellW: 150,
					cellH: 100,
					delay: 0,
					gutterX: 8,
					gutterY: 8,
					onResize: function() {
						wall.fitWidth();
					}
				});
				wall.fitWidth();
				
				// timestamp of latest photo retrieval
				var timestamp = 1432426255;
				var timestamp = 0;
				
				// html template for new cells
				var tmpl = '<div class="cell" style="width: {width}px; height: {height}px; background-image: url({url})"></div>';
				
				// repeatedly ask server for new images
				setInterval(function() {
					
					$.getJSON("mosaic-fetch-photos.php?timestamp=" + timestamp, function(json) {
						if(json.files != null) {
							// save timestamp to only retrieve newer files next time
							timestamp = json.timestamp;
							
							// limit number of new images if greater than "maxNewImages"
							var iStart = (json.files.length > maxNewImages ? json.files.length - maxNewImages : 0);

							// append all new photos
							for(var i = iStart; i < json.files.length; i++) {
								// determine random cell size
								var rnd = getRandomInt(0, arSizes.length-1);
								
								// replace cell size and photo url placeholders
								var html = tmpl.replace('{width}', arSizes[rnd][0])
										.replace('{height}', arSizes[rnd][1])
										.replace('{url}', "/img-s/" + json.files[i]);
								
								// append block to current layout
								wall.appendBlock(html);
								
								// auto scroll to bottom of page
								var $target = $('html,body'); 
								$target.animate({scrollTop: $target.height()+500}, 250);
							}
						}
					});
				}, updateInterval);
			});
			
		</script>
	
	</body>
</html>
