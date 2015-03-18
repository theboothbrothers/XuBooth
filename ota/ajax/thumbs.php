<?php
	$album 		= $_GET['album'];
	$imagesArr	= array();

	if(file_exists('../img-s/'.$album)){
		$files = array_slice(scandir('../img-s/'.$album), 2);
		if(count($files)){
			foreach($files as $file) {
				if($file != '.' && $file != '..'){
					$imagesArr[] = array(	'src' 	=> 'img-s/'.$album.'/'.$file,
								'alt'	=> 'img-m/'.$album.'/'.$file,
								'desc'	=> 'img-l/'.$file);
				}
			}
		}
	}

	$json 		= $imagesArr; 
	$encoded 	= json_encode($json);
	echo $encoded;
	unset($encoded);
?>