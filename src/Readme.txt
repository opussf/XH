Welcome to XH v@VERSION@

This addon will keep track of your XP per Hour gained while playing World of Warcraft.
Rate is measured in xp per second.
It will try to guess when you will reach the next level.


Revision History
3.0     U- Almost full rewrite of system. Got rid of the instance timer. Timers are for Mythics.
           Removed all the commands.  Not even a slash command for now.
           Skill bar has not been working for a while, removed the code.
           Data structure for each character is saved, and pruned when data is expired.
2.01    F- Moved to git
1.24    F- Removed the Taxi TImer code to new addon - FlightTimer
1.23    F- Adding moving time limit rate
        F- Adding moving limit to Reputation
1.22    F- Adding the level timer back in
1.21    F- Adding a flight timer
        F- Added showskill command to control how long the skill bar stays around.
1.20    F- Added a new progress bar for skill ups. 
1.19    F- removed 'report' command.  Now use party (raid included if raid), guild, or none.
		-- also, no longer a toggle 
1.18    F- Removed Rested to create seperate addon
1.17    F- Added new reporting options
        F- Now sorting the rested list by expected amount rested, ascending.
        U- Added boss list to Scholomance dungeon
1.16	F- Added list feature
        F- Added remove feature - I found that a few of the single boss instances can get confused if you join in the middle
        F- ToParty now shows better formatted output when not actually in party
1.15	F- Report time milestones (best/2, best, ave, longest) to the party.
		F- turns off individual rep reports in dungeon to show as a single report per combat
		F- turn off reporting of progress times when there is only 1 run (sd = 0)
1.14	F- Removed updating Rested state from all the time to UPDATE_EXHAUSTION event and when rested report is called
		B- changed the level time report to not error out if a level is missing
		F- reformated the Rested Report to be a bit more formatted
		F- cleaned up update interval to not update bars on each screen update
1.13	B- /played was showing levels out of order.  Fixed to sort.
		B- Fixed a typo for an old instance name
1.12	F- added the ability to remove a character from the rested database
		F- added command to reset an instance timer
		F- color coded the rested report a bit
		F- Changed XH_Print to have a parameter to allow not seeing the defaut msg prefix
		F- Post Combat Reputation report changed to look a bit more 'WoW' like (I hope)
		F- An Unknown raid or instance will no longer show as no name, and 38746348 days
			Should now show the instance name, and the proper elapsed time.
			Will not be able to show instance complete or boss kill times.

1.11.1	F- Status report, shows basic status
		F- New command to reset instance tracker.
		B- 0004 - partyReport option
		B- 0005 - instanceTracker is saved between sessions in case of UI reset
		F- stautsBar updates now? --  Still need to 'fix it'
1.11	F- Ding tracker. Records time to that level. Time to level 1 is always 0. Hooks into /played command for display
			-- Tried to limit to last 5 levels.
		F- XP and rep tracking per combat in instances.
		F- XP and rep tracking per instance.  Reports at the end of the instance.
		F- Instance timer, shows time to kill each boss from start of first combat.
			Also shows total time once all bosses are down.
1.10	Bug fix for showing "to normal" while regaining rested in game
		Added rested state recording and report. Reports non 80 lvl toons not fully rested on last login to them.
		Added tracking of instance time and comparison of player best time
		Added global variable for update time
1.9     Bug fix for best time till end of rested state
        Added rep report for the rep gained this session
1.8     Reputation bar now shows: Shows Faction (Current Status) Rep gain (total rep gain), Rep to go (% to go)
1.7     New feature shows time till rested state expires if it will happen before the next level is gained
1.6.3c  Modified Interface Version for WotLK version #
1.6.2b  Widened from 300 to 350 pixels.  Should allow longer text (towards beginning and slow levels) to fit
1.6.1b  Cleaned up a bug with using date().  Added new function to shorten SecondsToTime()
        Changed Bubble / Hour to 0.00 format
1.6b    Refined XP gain bar.  Cleaned up max Lvl display (no XP gain).
1.5     Added Reputation bar.  Shows Faction (Current Status) Rep gain, Rep to go (% to go)
0.4     Adding the ability to track Rep Gain.  Shows the stats for the last faction
0.3     Changed to show rested percent of max (150% of current lvl),
        and only to show the total XP / hr
        Still has some debug info that is not dismissible
0.2     Added a time to lvl, and a time when expecting to lvl
        Updated Interface number for 1.11.1 patch (I hope)
0.1     Initial

Known Bugs:
Bug# - ver	- Desc
0001 - 1.11 - Instance timer can be restarted after killing final boss by killing a critter.
				-- does not properly reset then if running same instance again.
				-- added "/xh reset" command to allow rerunning same instance
				-- Resets if left the instance while alive

0002 - 1.11 - 'odd' boss kills (Mal'Ganis CoS, UK, and ToC) don't properly trigger end of instance
				-- or trigger it too often.  Mal'Ganis does not die, UK boss dies 2x.  ToC = 3x
				-- /combatlog will record combat events, was unable to find an event to trigger for these
				-- CoS, changed final boss to be the mount dropper
				-- excpet for CoS, bug only over reports, does not improperly record final time
				-- the Lich King does not actually die
0003 - 1.11 - Incomplete dungeon listing. - On going project
0004 - 1.11 - No way to turn off dungeon tracking reporting.
				-- should probably be silent to begin, and alert on instance entry if off.
				-- sticky setting.
			Fixed: new XH_option.partyReport inits as off
				-- use "/xh party" to toggle
0005 - 1.11 - Reloading game or UI resets timer.  Should possibly save?
				-- Make InstanceTracker a saved variable.  Worse case, system crash loses run.
			Fixed: zoneTracker is saved.
0006 - 1.11 - Rested state is a tad optimistic on rested value.  Server not giving rested when down?
				-- not going to fix right now
				-- I believe that the rested value is not adding 5%, but rather the xp that 5% represents
0007 - 1.11 - Account instanceBestTimes is not saving correctly, or gets wiped at some point.
			Fixed.
0008 - 1.12 - Not using instanceBestTimes to show best in game.
0009 - 1.15 - Rep reporting not turned back on as expected.
				-- I want to turn it back on when final boss is killed
				-- or when the instance is reset
				


To do:
-	Clean up code.  Always clean up code
-	Tracking reporting option.  Need command.
-	Tracking reporting comm with other players with XH.  Randomly choose a single person to report.
-	Raid Tracking.
-   Instance timer warnings.
		5 minute alert to best time.
		Alert at passing average time.
		Alert at passing longest time.


------
Change xp rate to use a 'rolling collection of data'
[timestamp] = xp,
[timestamp] = xp,

keep to nearest second
truncate data older than ~15 minutes

Current system is:
["gained"] = gainedValue, 
["start"]=time(), 
["lastGained"]=gainedValue, 
["toGo"]=toGo,
--  adding
["rolling"] = {[timestamp]= xp,}




