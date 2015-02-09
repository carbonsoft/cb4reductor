<?php

$data = file("/tmp/reductor/http.load");

function __encode($line) {
	$url = urlencode($line);
	$url = str_replace("%2F", "/", $url);
	$url = str_replace("%3A", ":", $url);
	$url = str_replace("%3F", "?", $url);
	$url = str_replace("%3D", "=", $url);
	$url = str_replace("%26", "&", $url);
	$url = str_replace("%2C", ",", $url);
	$url = str_replace("%23", "#", $url);
	$url = str_replace("%7E", "~", $url);
	$url = str_replace("%28", "(", $url);
	$url = str_replace("%29", ")", $url);
	$url = str_replace("%40", "@", $url);
	$url = str_replace("%2B", "+", $url);
	return "$url";
}

foreach ($data as $__line) {
	$line = trim($__line);
	if (!strpos($line, '%') || preg_match('/[Á-Ñ]/i', $line)) {
		echo(__encode($line)."\n");
		continue;
	}

	$line2 = iconv("cp1251", "utf-8", urldecode($line));
	echo($line."\n");
	echo(__encode($line2)."\n");
}
?>
