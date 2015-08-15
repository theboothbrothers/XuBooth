<?php

class MyDhcpLease {
	public $time;
	public $mac;
	public $ip;
	public $name;
}

class MyDownloadStat {
	public $date;
	public $ip;
	public $useragent;
	public $file;
}

function fetch_contest_stats() {
	// save script path
	$path = dirname(__FILE__) . "/";

	// read $photo_dir from XuBooth-tmp-vars.sh:
	if(file_exists($path . "../XuBooth-tmp-vars.sh")) {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh");
		preg_match("/export photo_dir=(.*)/", $XuBoothTmpVars, $matches);
		$photo_dir = $matches[1];

		$statsfile1 = "../" . $photo_dir . "/contest.sh";
		$statsfile2 = "../" . $photo_dir . "/contest.csv";

		if(file_exists($statsfile1) && file_exists($statsfile2)) {
			preg_match("/export contest_sticker_images=(.*)/", $XuBoothTmpVars, $matches);
			$sticker_images = trim($matches[1], '"');

			preg_match("/export contest_max_wins=(.*)/", $XuBoothTmpVars, $matches);
			$max_wins = trim($matches[1], '"');

			$contestVars = file_get_contents($statsfile1);
			preg_match("/export contest_remaining_wins=(.*)/", $contestVars, $matches);
			$remaining_wins = trim($matches[1], '"');

			$arResult = array();
			$arResult["sticker_images"] = explode("|", $sticker_images);
			$arResult["max_wins"] = explode("|", $max_wins);
			$arResult["remaining_wins"] = explode("|", $remaining_wins);

			$f = fopen($statsfile2, "r");

			if($f) {
				$line = fgets($f);
				while(($line = fgets($f)) !== false) {
					$ar = explode(";", $line);
					$arResult["winners"][$ar[0]][] = $ar[1];
				}

				fclose($f);
			}

			return $arResult;
		}
	}
}

function fetch_download_stats() {
	// save script path
	$path = dirname(__FILE__) . "/";

	// read $photo_dir from XuBooth-tmp-vars.sh:
	if(file_exists($path . "../XuBooth-tmp-vars.sh")) {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh");
		preg_match("/export photo_dir=(.*)/", $XuBoothTmpVars, $matches);
		$photo_dir = $matches[1];

		$statsfile = "../" . $photo_dir . "/download_stats.csv";
		$f = fopen($statsfile, "r");

		$stats = array();

		if($f) {
			$data = fgetcsv($f, 0, ";", "\"");
			while(($data = fgetcsv($f, 0, ";", "\"")) !== false) {

				$x = new MyDownloadStat();

				$x->date = $data[0];
				$x->ip = $data[1];
				$x->useragent = $data[2];
				$x->file = $data[3];

				$stats[] = $x;
			}

			fclose($f);

			return $stats;
		}
	}
}

function fetch_hostapd_denies() {
	$denyfile = "hostapd.deny";
	$f = fopen($denyfile, "r");

	$macs = array();

	if($f) {
		while(($line = fgets($f)) !== false) {
			if(trim($line)[0] != "#") {
				$macs[] = $line;
			}
		}
	}

	fclose($f);

	return $macs;
}

function fetch_dhcp_leases() {
	$leasefile = "dnsmasq.leases";
	$f = fopen($leasefile, "r");

	$clients = array();

	if($f) {
		while(($line = fgets($f)) !== false) {

			if(trim($line)[0] != "#") {
				$ar = explode(" ", $line);

				$x = new MyDhcpLease();

				// calculate remaining lease time
				$dt1 = new DateTime("now");
				$dt2 = new DateTime();
				$dt2->setTimestamp($ar[0]);
				$remaining = $dt2->diff($dt1);

				$x->time = $remaining->format("%r%H:%I:%S");
				$x->mac = $ar[1];
				$x->ip = $ar[2];
				$x->name = $ar[3];
			
				$clients[] = $x;
			}
		}
	}

	fclose($f);

	return $clients;
}

function release($mac) {

	if(preg_match("^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$", $mac) == 0) {
		// remove mac from dhcp leases
		$leases = file_get_contents("dnsmasq.leases");
		$leases = preg_replace("/^.*" . $mac . ".*$/mi", "# released by admin", $leases);
		file_put_contents("dnsmasq.leases", $leases);

		// fetch dnsmasq's PID
		$pid = file_get_contents("/var/run/dnsmasq/dnsmasq.pid");

		// send SIGHUP to dnsmasq process (this will make dnsmasq reload)
		//posix_kill($pid, SIGHUP);
	}
}

function ban($mac) {

	if(preg_match("^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$", $mac) == 0) {
		// write mac address to hostapd.deny file
		file_put_contents("hostapd.deny", $mac . "\n", FILE_APPEND);

		// fetch hostapd's PID
		$pid = file_get_contents("/var/run/hostapd.pid");

		// send SIGHUP to hostapd process (this will make hostapd reload)
		//posix_kill($pid, SIGHUP);
	}
}


function unban($mac) {
	if(preg_match("^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$", $mac) == 0) {
		// remove mac from dhcp leases
		$macs = file_get_contents("hostapd.deny");
		$macs = preg_replace("/^.*" . $mac . ".*$/mi", "# unbanned by admin", $macs);
		file_put_contents("hostapd.deny", $macs);

		// fetch hostapd's PID
		$pid = file_get_contents("/var/run/hostapd.pid");

		// send SIGHUP to hostapd process (this will make hostapd reload)
		//posix_kill($pid, SIGHUP);
	}
}

function checkGET() {
	if( isset($_GET["ban"]) &&  !empty($_GET["ban"]) ) {
		echo "Banned: " . $_GET["ban"];
		ban($_GET["ban"]);
		release($_GET["ban"]);
	}

	if( isset($_GET["release"]) &&  !empty($_GET["release"]) ) {
		echo "Released: " . $_GET["release"];
		release($_GET["release"]);
	}

	if( isset($_GET["unban"]) &&  !empty($_GET["unban"]) ) {
		echo "Unbanned: " . $_GET["unban"];
		unban($_GET["unban"]);
	}

}




?>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title>Over-The-Air | Management</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, maximum-scale=1.0" />
	<style>
		* {
			font-family: "Segoe UI", Arial, sans-serif;
		}

		body {
			font-size: 1.0rem;	
			margin: 0;
			padding: 0;
			background-color: #7F2A41;
		}

		#main {
			padding: 15px 10px;
		}

		#navigation {
			position: fixed;
			top: 0px;
			left: 0px;
			width: 100%;
			height: 20px;
			padding: 10px 15px;
			background-color: #fff;
		}

		#navigation ul {
			margin: 0;
			padding: 0;
		}

		#navigation li {
			list-style: none;
			display: inline;
			margin: 0;
			padding: 5px 10px;
			background-color: #333;
			border-radius: 5px;
		}

		#navigation li.reload {
			background-color: #7F2A41;
			border: 4px solid #aaa;
			padding: 3px 8px;
		}

		#navigation a {
			font-weight: bold;
			text-decoration: none;
			color: #fff;
		}

		#navigation a:hover {
			color: #995567;
		}

		#navigation li.reload a:hover {
			color: #000;
		}

		#content {
			margin: 40px 0 0 0;
		}

		h1 {
			font-size: 1.0rem;
			color: #fff;
			line-height: 1.0rem;
			margin: 22px 0 8px;
		}

		ol {
			margin: 0 0;
			padding: 5px 20px;
		}

		li {
			font-size: 0.75rem;
		}

		table {
			border: 1px solid #666;
			background-color: #eee;
			width: 100%;
			padding: 5px;
		}

		th {
			border-left: 1px solid #aaa;
			border-right: 1px solid #aaa;
			background-color: #ccc;
			padding: 5px;
			font-size: 0.75rem;
		}

		td {
			background-color: #fff;
			padding: 5px;
			font-size: 0.7rem;
		}

		.myframe {
			border: 3px solid #333;
			background: rgb(255, 255, 255);
			background: rgba(255, 255, 255, 0.8);
			padding: 10px;
			width: 95%;
		}

		#tab_downloads_top10, #tab_downloads_statistics, #tab_contest_statistics, #tab_dhcp_leases, #tab_bans {
			display: none;
		}

		#tab_downloads_top10 {
			display: block;
		}
	</style>
	<script>
		function showTab(elem) {
			document.getElementById("tab_downloads_top10").style.display = 'none';
			document.getElementById("tab_downloads_statistics").style.display = 'none';
			document.getElementById("tab_contest_statistics").style.display = 'none';			
			document.getElementById("tab_dhcp_leases").style.display = 'none';
			document.getElementById("tab_bans").style.display = 'none';

			document.getElementById(elem).style.display = 'block';
		}

		function onload() {
			document.getElementById("bt_downloads_top10").addEventListener("click", function(e) { showTab("tab_downloads_top10"); });
			document.getElementById("bt_downloads_statistics").addEventListener("click", function(e) { showTab("tab_downloads_statistics"); });
			document.getElementById("bt_contest_statistics").addEventListener("click", function(e) { showTab("tab_contest_statistics"); });
			document.getElementById("bt_dhcp_leases").addEventListener("click", function(e) { showTab("tab_dhcp_leases"); });
			document.getElementById("bt_bans").addEventListener("click", function(e) { showTab("tab_bans"); });
		}
	</script>
</head>

<body onLoad="onload()">

<div id="main">

	<div id="navigation">
		<ul>
			<li class="reload"><a href="">reload</a></li>
			<li><a href="#" id="bt_downloads_top10">Downloads: Top 10</a></li>
			<li><a href="#" id="bt_downloads_statistics">Downloads: Statistics</a></li>
			<li><a href="#" id="bt_contest_statistics">Contest Statistics</a></li>
			<li><a href="#" id="bt_dhcp_leases">DHCP Leases</a></li>
			<li><a href="#" id="bt_bans">Bans</a></li>
		</ul>
	</div>

	<div id="content">

		<div><?php checkGET(); ?></div>


		<div id="tab_downloads_top10">
			<h1>Downloads: Top 10</h1>
			<div class="myframe"><table>
			<tr>
				<th></th>
				<th>Downloads</th>
				<th>Image</th>
			</tr>
			<?php
				$stats = fetch_download_stats();
				$stats_by_file = array_count_values(array_map( function($element) { return $element->file; }, $stats));
				arsort($stats_by_file);
				array_splice($stats_by_file, 10);
				$i = 0;
				foreach($stats_by_file as $file => $count) {
					$i++;
					echo sprintf("<tr><td>#%d</td><td>%d</td><td><a href='img-m/%s' target='_new'>%s</a></td></li>", $i, $file, $count, $file);
				}
			?>
			</table></div>
		</div>

		<div id="tab_downloads_statistics">
			<h1>Downloads: Statistics</h1>
			<div class="myframe"><table>
			<tr>
				<th>Timestamp</th>
				<th>IP</th>
				<th>User-Agent</th>
				<th>File</th>
			</tr>
			<?php
				foreach($stats as $stat) {
					echo "<tr>";
					echo sprintf("<td>%s</td>", $stat->date);
					echo sprintf("<td>%s</td>", $stat->ip);
					echo sprintf("<td>%s</td>", $stat->useragent);
					echo sprintf("<td><a href='img-m/%s' target='_new'>%s</a></td>", $stat->file, $stat->file);
					echo "</tr>";
				}
				echo sprintf("<tr><td colspan=4 align=center>%d</td></tr>", sizeof($stats));
			?>
			</table></div>
		</div>

		<div id="tab_contest_statistics">
			<h1>Contest Statistics</h1>
			<div class="myframe"><table>
			<tr>
				<th>Sticker</th>
				<th>Wins</th>
				<th>Remaining Wins</th>
				<th>Total Wins</th>

			</tr>

			<?php
				$contest_stats = fetch_contest_stats();
				if($contest_stats) {
					for($i = 0; $i < count($contest_stats["sticker_images"]); $i++) {
						$wins = $contest_stats["max_wins"][$i] - $contest_stats["remaining_wins"][$i];
						echo "<tr>";
						echo sprintf("<td>%s</td>", $contest_stats["sticker_images"][$i]);
						echo sprintf("<td>%s</td>", $contest_stats["max_wins"][$i] - $contest_stats["remaining_wins"][$i]);
						echo sprintf("<td>%s</td>", $contest_stats["remaining_wins"][$i]);
						echo sprintf("<td>%s</td>", $contest_stats["max_wins"][$i]);
						echo "</tr>";

						$arTmp = array_map( function($element) { return sprintf("<a href='img-m/%s' target='_new'><img src='img-s/%s' border=2 /></a>&nbsp;", $element, $element); }, $contest_stats["winners"][$contest_stats["sticker_images"][$i]]);

						echo "<tr>";
						echo sprintf("<td colspan=4><ol>%s</ol></td>", implode("", $arTmp));
						echo "</tr>";

					}
				}
			?>
			</table></div>
		</div>

		<div id="tab_dhcp_leases">
			<h1>DHCP Leases</h1>
			<div class="myframe"><table>
			<tr>
				<th>&nbsp;</th>
				<th>Hostname</th>
				<th>MAC</th>
				<th>IP</th>
				<th>TTL</th>
			</tr>
			<?php
				$clients = fetch_dhcp_leases();
				foreach($clients as $client) {
					echo "<tr>";
					echo sprintf("<td><a href='?ban=%s'>ban</a>&nbsp;<a href='?release=%s'>release</a></td>", urlencode($client->mac), urlencode($client->mac));
					echo sprintf("<td>%s</td>", $client->name);
					echo sprintf("<td>%s</td>", $client->mac);
					echo sprintf("<td>%s</td>", $client->ip);
					echo sprintf("<td>%s</td>", $client->time);
					echo "</tr>";
				}
				echo sprintf("<tr><td colspan=5 align=center>%d</td></tr>", sizeof($clients));
			?>
			</table></div>
		</div>

		<div id="tab_bans">
			<h1>Bans</h1>
			<div class="myframe"><ol>
			<?php
				$macs = fetch_hostapd_denies();
				foreach($macs as $mac) {
					echo sprintf("<li><a href='?unban=%s'>%s</a></li>", urlencode($mac), $mac);
				}
			?>
			</ol></div>
		</div>
	</div>
</div>

</body>
</html>
