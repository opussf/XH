<?php
header("Content-type: application/xml");

$version = "0.9";

$linkpre = "http://xh.zz9-za.com/";
$dir = ".";
$afiles = array();

if ($dh = opendir($dir)) {
	while (($file = readdir($dh)) != false) {
		if ($file!="." and $file!=".." and strpos($file, ".zip")==true) {
			$mtime = filemtime($file);
			$afiles[$mtime] = $file;
		}
	}
}

print "<?xml version='1.0' encoding='UTF-8'?>\n";
?>
<rss version="2.0">
<channel>
<title>RSS feed for XH (Warcraft Addon)</title>
<link><?php echo $linkpre; ?></link>
<description>WoW Addon - XH</description>
<generator>PHP</generator>
<?php

krsort($afiles);

foreach ($afiles as $d) {
	$u = $linkpre . rawurlencode($d);
	$pubdate = date("r", filemtime($d));
	$size = filesize($d);

	print "<item>\n\t<title>$d</title>\n";
	print "\t<link>$u</link>\n";
	print "\t<guid>$u</guid>\n";
	print "\t<pubDate>$pubdate</pubDate>\n";
	print "\t<enclosure url='$u' length='$size' type='application/gzip'/>\n";
	print "</item>\n";
}
?>
</channel>
</rss>
