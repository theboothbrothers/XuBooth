<?php

	$files = array_slice(scandir('img-m'), 2);
	if(count($files)){
		natcasesort($files);
		$files = array_reverse($files, false);

		foreach($files as $file) {
			if(is_file("img-m/" . $file)) {
				$time = date("H:i:s", filemtime("img-m/" . $file));
				echo '<a href="img-m/' . $file . '" style="background-image:url(img-s/' . $file . ')" title="' . $time . '" alt="img-l/' . $file . '"></a>';
				echo "\r\n";
				$i--;
			}
		}
	}

?>