<?php
/*
 * $Id: index.php 73 2010-02-16 11:15:25Z opus $
 */
	$xslFile = "rss.link.xsl";
	$rss_address = "http://xh.zz9-za.com/rss.php";
	$xp = new XsltProcessor();
	$xsl = new DomDocument;
	$xsl->load($xslFile);
	$xp->importStylesheet($xsl);
	
	$rss_xml = file_get_contents($rss_address);
	
	$xml_doc = new DomDocument;
	$xml_doc->loadXML($rss_xml);
	
	$link = $xp->transformToXML($xml_doc);
	
?>
<html>
<head>
    <title>XH WoW addon</title>
	<link	href='<?php print("http://xh.zz9-za.com/rss")?>' 
		rel='alternate' type='application/rss+xml' title='Recent releases'/>
	<link type='text/css' href="xh.css" rel="stylesheet"/>
</head>
<body>
<div class='xh'>
<div class='xh-header'>
<div class='xh-download'>
Download most recent: <?php echo $link; ?><a href="<?php echo $rss_address; ?>"><img src="atom.gif"/></a>
</div>

<div class='xh-title'>
XH - Xp per Hour<br/>
My WorldOfWarcraft Addon
</div>
</div>

<div class='xh-doc'>
<p>This addon presents the user with a progress bar to track XP gain rate, rested XP remaining, and current reputation progress.</p>
<img src="toLvl.jpg" class="floatRight"/>
<p>During normal questing, the 2 bars show rested XP percent remaining (blue bar), XP gain rate (red bar),
and reputation gain for the last faction to get reputation for (green bar).  The rested bar represents 150% as max.</p>

<img src="toNorm.jpg" class="floatRight"/>
<p><b>XP bar:</b> The text on the bars shows how long until the next level (based on the current rate), when that might be, 
(when the best time would have been), and how long each bubble is expected to take. If the rested amount will not last until
the next level, then it will show the time and statistics until rested is exhausted.</p>

<p><b>Rep bar:</b> The reputation progress bar (green in the images above), shows the faction (current standing), 
last amount of faction gained (for this session) -&gt; how much to get for the next standing level (percent remaining). XH will
also show the default WorldOfWarcraft reputation bar.</p>

<p><b>Rep report:</b> A reputation report may be shown with the '/xh rep' command.  This will list all the factions with reputation
change this session.</p>

<img src="mouseOver.jpg" class="floatRight"/>
<p><b>Mouse Over:</b> By mousing over the bars the XP bar will show you XP gain this session, time played,
and the number of bubbles per hour.</p>

<img src="initial.png" class="floatRight"/>
<p><b>Initial display:</b> The Initial display, as above, is like the mouse over, except that no XP gain is shown.  Level capped 
characters will see this (except for the rested bar), and can easily track how long they have played this session.</p>

<img src="playedText.png" class="floatRight"/>
<p><b>Level time tracking:</b> A ding will also prompt a '/played' event, and it will record the current amount of time played.
That list can also be displayed at any time with the '/played' command. The list shows the played time to that level, and the amount
of time spent in that specific level.  The last 5 levels are shown.</p>

<p><b>Auto Bubble Reporting:</b> This will auto report bubble progression and level dings.  This will happen 6 times in a level,
at 5 bubbles (25%), half way, 15 bubbles (75%), 17 bubbles (3 to go), 18 bubbles, and finally at 19 bubbles. A ding message will
also be reported.</p>

<div class="floatRight">
<img src="instanceStartText.png"/>
<img src="instanceInitial.png"/>
<img src="instanceGreen.png"/>
<img src="instanceYellow.png"/>
<img src="instanceRed.png"/>
</div>
<p><b>Instance Timer:</b> Version 1.11 introduced an instance timer and tracking. The tracker records any run that kills all the 
bosses in the list of bosses, so, joining a run before the final boss will not skew the data. When combat starts, the addon will 
tell the party who the bosses are for this instance, and if this is not the first run, it will display the best run time, and the 
average run time. The reputation bar will swap to an instance timer bar showing the instance name, and a timer.
The rep bar can still be seen with the mouse over.</p>
<p>The very first run will show a timer and no other value. Addional runs will start out with a green bar progressing to the best
run time. Once the best time is passed, it will show a yellow bar (with the average time) that spans at least the 95% range (sd x 3)
or longest time at the max, centered around the average time (bar at 50%). Once the previous longest recorded time is reached,
it will show a red bar with the timer, and the previous longest time.</p>
<p>In short, if your party finishes the instance when the green bar is still is shown, this is really good.  When the yellow bar is 
shown then your group is average. Finishing in the green will be progressivly more difficult.
<p><b>Messages to the Party:</b> Milestone messages will be posted to the party when a tracked boss is killed, and at these timed milestones:
<br/>halfway to best time, best time, average time, longest time.</p>
<p><b>Output:</b> Output of instance runs, level progress, and ding can be set to report to PARTY, GUILD, or NONE by using '/XH party',
'/XH guild' or '/XH none'.  The NONE options still shows the messages that would have been sent in your default chat pane.</p>

<p><b>Instance Bragging:</b> '/xh times' can be used to brag to the party the info for your current instance run. You can also brag
about a specific instance using '/xh times &lt;search&gt;'. Any dungeon with data for the current character will display the best time,
average time, standard deviation (sd), and the longest time.</p>

<p><b>Instance Run Listing:</b> '/xh list' will list all instances that this character has run, and how many runs are recorded.
'/xh list &lt;search&gt;' will display run data for any dungeon that matches the search criteria. The list shows the unix style
timestamp of when the run started, and how long it took.  The normal stistics will also be displayed.</p>
<p><b>Removing Run Data:</b> Some dungeons only have one boss that can be tracked, as such, it is possible to have recorded a run that
is way too short, and can skew the statistics.  Using the '/xh rm &lt;timestamp&gt;' from the run list from '/xh list &lt;search&gt;'
will let you remove a bad run.  Be ware, at this time, there is no way to reverse this.</p>

<p><b>Skill Ups:</b> You skilled something, yeah!  Did you miss it with all the stuff going past in your chat window? Now XH can show
a 3rd bar with the last skill gained for a short time. You can control the amount of time this is shown, if at all, using
'/xh showskill #'. Using a value of 0 will turn off the skill display, any positive value will show the message and skill bar for that
number of seconds. Defaults to 120 seconds.</p>

<p><b>Flight time:</b> Things like Quest Helper does this for you, but with Blizzard's new Quest Tracking system, many are not using
Quest Helper.  This feature collects the time a taxi ride takes from flight master to flight master.  If you have flown that flight before
it will show a count down bar till the flight ends.  If it is your first flight, it will simply show a flight timer and record the final
time for future use.</p>


</div>
<div class="xh-footer">
<a href="http://wow.curse.com/downloads/wow-addons/details/hitlist.aspx">Hitlist</a>
<a href="http://wow.curse.com/downloads/wow-addons/details/rested.aspx">Rested</a>
<a href="mailto:xh@zz9-za.com">Contact</a> <!-- $Rev: 1544 $ -->
</div>
</div>
</body>
</html>
