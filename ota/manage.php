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

function fetch_download_stats() {
	// read $photo_dir from XuBooth-tmp-vars.sh:
	if(file_exists($path . "../XuBooth-tmp-vars.sh")) {
		$XuBoothTmpVars = file_get_contents($path . "../XuBooth-tmp-vars.sh");
		preg_match("/export photo_dir=(.*)/", $XuBoothTmpVars, $matches);
		$photo_dir = $matches[1];

		$statsfile = "../" . $photo_dir . "/download_stats.csv";
		$f = fopen($statsfile, "r");

		$stats = array();

		if($f) {
			$line = fgets($f);
			while(($line = fgets($f)) !== false) {

				$ar = explode(";", $line);
				$x = new MyDownloadStat();

				$x->date = date("Y-m-d H:i:s", $ar[0]);
				$x->ip = $ar[1];
				$x->useragent = $ar[2];
				$x->file = $ar[3];
		
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

				$x->time = $remaining->format("%r%H:%m:%S");
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
		table {
			border: 2px solid #666;
			background-color: #eee;
			width: 100%;
		}
		td {
			border: thin solid #aaa;
			background-color: #fff;
		}

		.myframe {
			border: thin dashed #ccc;
			background-color: #eef;
			padding: 10px;
			max-height: 200px;
			width: 90%;
			margin: 0 5%;
			overflow: auto;
		}
	</style>
</head>

<body>

<div><?php checkGET(); ?></div>

<h1>Top 10 Downloads</h1>
<div class="myframe"><ol>
<?php
	$stats = fetch_download_stats();
	$stats_by_file = array_count_values(array_map( function($element) { return $element->file; }, $stats));
	arsort($stats_by_file);
	array_splice($stats_by_file, 10);
	foreach($stats_by_file as $file => $count) {
		echo sprintf("<li><a href='img-m/%s' target='_new'>%s</a> (%d)</li>", $file, $file, $count);
	}
?>
</ol></div>

<h1>Download Statistics</h1>
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

<h1>Bans</h1>
<div class="myframe"><ol>
<?php
	$macs = fetch_hostapd_denies();
	foreach($macs as $mac) {
		echo sprintf("<li><a href='?unban=%s'>%s</a></li>", urlencode($mac), $mac);
	}
?>
</ol></div>




</body>
</html>