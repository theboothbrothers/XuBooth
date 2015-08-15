<?php

	// save script path
	$path = dirname(__FILE__) . "/";

	// read variables from XuBooth-tmp-vars.sh:
	//  - ota_title
	//  - ota_caption
	//  - ota_domain
	if(file_exists($path . "../XuBooth-tmp-vars.sh")) {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh");
	} else {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-sample-config.sh");
	}

	preg_match("/export ota_title=\"(.*)\"/", $XuBoothTmpVars, $matches);
	$title = $matches[1];
	preg_match("/export ota_caption=\"(.*)\"/", $XuBoothTmpVars, $matches);
	$caption = $matches[1];
	preg_match("/export ota_domain=\"(.*)\"/", $XuBoothTmpVars, $matches);
	$domain = $matches[1];

?>
<html>
<head>
	<title>Redirecting...</title>
	<meta http-equiv="refresh" content="0; URL=http://<?php echo $domain; ?>">
</head>
<body>

<?php echo "<a href=\"http://$domain\">$title | $caption</a>"; ?>

</body>
</html>
