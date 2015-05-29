<?php

class MyDhcpLease {
	public $time;
	public $mac;
	public $ip;
	public $name;
}

function fetch_dhcp_leases() {
	$leasefile = "/var/lib/misc/dnsmasq.leases";
	$f = fopen($leasefile, "r");

	$clients = array();

	if($f) {
		while(($line = fgets($f)) !== false) {
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

	fclose($f);

	return $clients;
}





?>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title>Over-The-Air | Management</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, maximum-scale=1.0" />
</head>

<body>

<h1>Access Point</h1>
<a href="?wifichannel=1">Wifi Channel 1</a>

<h1>DHCP Leases</h1>
<table>
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
		echo sprintf("<td><a href='?ban=%s'>ban</a>&nbsp;<a href='?release=%s'>release</a></td>", $client->mac, $client->mac);
		echo sprintf("<td>%s</td>", $client->name);
		echo sprintf("<td>%s</td>", $client->mac);
		echo sprintf("<td>%s</td>", $client->ip);
		echo sprintf("<td>%s</td>", $client->time);
		echo "</tr>";
	}
?>
</table>

</body>
</html>