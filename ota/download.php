<?php

$path = dirname(__FILE__) . "/";
$file = $path . $_GET['f'];

if (file_exists($file) && dirname($file) == $path."img-l") {
	header('Content-Description: File Transfer');
	header('Content-Type: text/html');
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