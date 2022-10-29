XH_MSG_VERSION = GetAddOnMetadata("XH","Version");

-- Colours
COLOR_RED = "|cffff0000";
COLOR_GREEN = "|cff00ff00";
COLOR_BLUE = "|cff0000ff";
COLOR_PURPLE = "|cff700090";
COLOR_YELLOW = "|cffffff00";
COLOR_ORANGE = "|cffff6d00";
COLOR_GREY = "|cff808080";
COLOR_GOLD = "|cffcfb52b";
COLOR_NEON_BLUE = "|cff4d4dff";
COLOR_END = "|r";

-- options
XH_options = {
	["reportTo"] = {["GUILD"] = false,	["PARTY"] = false,},
	["showSkill"] = 180,
	["showRateGraphs"] = true,
}

XH_bubbleReport = {
	[5] = false,
	[10] = false,
	[15] = false,
	[18] = false,
	[19] = false,
}
XH_playedByLevel = {};
XH_bosses = {};

XH = {};
XH.rateGraph={[0]="_",[1]=".",[2]="·",[3]="-",[4]="^"};
XH.rateGraph={[0]="_",[1]="░",[2]="▒",[3]="▓",[4]="█"};

XH.maxLevel = 120;
XH.tempVars = {};
XH.lastUpdate = 0;
XH.bestTime = 0;

XH.restedPC = 0;  -- 0 - 150%  Used to update the rested bar

XH.difficulty = {["party"] = {""," - Heroic"," - Epic"},
		["raid"] = {"", " - 25 Man", " - 10 Man Heroic", " - 25 Man Heroic"},
		["pvp"] = {"","","",""},
		["scenario"] = {"scenario","","","","","",""}
};

-- Instance Tracker
XH_zoneTracker = {};    -- zoneTracker.  should allow resets during an instance to not reset the tracker. Saved Var
XH_instanceTimes = {};  -- times of your instances.  Saved Var
XH_instanceBestTimes = {};  -- best instance times...  saved var
XH.instanceAverage = {};    -- character Instance Average data
XH.resetDungeonTime = 5*60;    -- How long to wait before auto resetting dungeon when outside
XH.reportMilestoneFunctions = {
		["half"] = function(x,best,avg,longest) return ((best>0) and (x>=(best/2))); end,
		["best"] = function(x,best,avg,longest) return ((best>0) and (x>=best)); end,
		["ave"] = function(x,best,avg,longest) return ((avg>0) and (x>avg)); end,
		["longest"] = function(x,best,avg,longest) return ((longest>0) and (x>longest)); end,
};
XH.reportMilestoneMessages = {
		["half"] = " elapsed is halfway to my best instance time.",
		["best"] = " elapsed was my best instance time.",
		["ave"] = " was my average instance time.",
		["longest"] = ". We have passed my longest recorded instance time.",
};

XH.minRateTime = 15*60;  -- minimum time to use to calculate rates
XH.timeRange = 30*60;
--XH.timeRange = 5*60;

-- XP gains
XH.XPGains = {
		["session"] = {},
		["instance"] = {},
		["combat"] = {},
};

-- Rep variables
XH.repGains = {
		["session"] = {},
		["instance"] = {},
		["combat"] = {},
}

XH.currencyGains = {
		["session"] = {},
		["instance"] = {},
}

--XH.repProgress = nil;
-- kill these
--XH.sessionRepGains = {};  -- rep gains for the session
--XH.combatRepGains = {};  -- rep gains for the combat (incase of more than one kill per combat)

--XH.startNode = nil;

-- onload event handler
function XH_OnLoad()
	--register slash commands
	SLASH_XH1 = "/xh";
	SlashCmdList["XH"] = function(msg) XH.Command(msg); end

	XHFrame:RegisterEvent("ADDON_LOADED");

	--ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", XH.FactionGainEvent);
	ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", XH.XPGainEvent);
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", XH.LootGainEvent);
	XHFrame:RegisterEvent("UPDATE_EXHAUSTION");
	XHFrame:RegisterEvent("PLAYER_LEVEL_UP");

	-- Instance tracker
	XHFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	XHFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	XHFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	XHFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	XHFrame:RegisterEvent("CHAT_MSG_SKILL");

	--
	XHFrame:RegisterEvent("UI_ERROR_MESSAGE");
	--XHFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");

	-- Instance Whisper return
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", XH.GetWhisper);
--	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", XH.GetWhisper);

	-- TimePlayed
	XHFrame:RegisterEvent("TIME_PLAYED_MSG");
	--XHFrame:RegisterAllEvents();

	XH.name = UnitName("player");
	XH.realm = GetRealmName();
	XH.faction = select(2, UnitFactionGroup("player"));  -- localized string

	XH.Start();
end

function XH.Start()
	-- Rested Bar
	XH_XPBarRested:SetMinMaxValues(0, 150);
	XH_XPBarRested:SetValue(150);

	-- InstanceTimer
	XH_InstanceTimerBack:SetMinMaxValues( 0, 1 );
	XH_InstanceTimerBack:SetValue( 1 );

	-- SkillBars
	XH_SkillBar:Hide()
	XH_SkillBarCD:Hide()

end
function XH.ADDON_LOADED()
	XH.startedTime = time();
	XH.UpdateRested();
	XH.InstanceAverages()
	-- InstanceList
	XHInstanceList:Hide();
	XH.UpdateRested();
	XH.UpdateBars();
	XH.XPGains.session = XH.InitRate(0, UnitXPMax("player") - UnitXP("player"));
	XH.bubbleSize = UnitXPMax("player") / 20;

	now = time();
--	for x=(now-(XH.timeRange)*60), (now+500) do
--		XH.XPGains.session.rolling[x] = 1;
--	end

end
function XH.UpdateBars()
	XH.UpdateXPBarText();
	--XH_XPBarRested:SetMinMaxValues(0, 150);
	--print("XH.restedPC: "..XH.restedPC.."("..math.floor(XH.restedPC)..")")
	XH_XPBarRested:SetValue(math.floor(XH.restedPC or 0))

	-- update instance bar
	-- XH_InstanceTimerBar
	if (not XH.mouseOver) and (XH_zoneTracker ~= nil) and (XH_zoneTracker.start ~= nil) and    -- zoneTracker exists, and start registered
			((XH_zoneTracker.finish == 0) or ((time() - XH_zoneTracker.finish) < 300)) then    -- not finished, or within 10 minutes
		zone = XH_zoneTracker.zoneName;
		-- Background bar
		XH_InstanceTimerBar:Show();
		XH_InstanceText:Show();

		-- Hide Rep Bar
		XH_RepBar:Hide();
		XH_RepText:Hide();
		-- set a count down till reset
		if (XH.leftDungeon) then
			XH_InstanceTimerBar:SetStatusBarColor( 1, 0, 0 );
			XH_InstanceTimerBar:SetMinMaxValues( 0, XH.resetDungeonTime );
			XH_InstanceTimerBar:SetValue( XH.resetDungeonTime - ( time() - XH.leftDungeon ) );
			XH_InstanceText:SetText("Return to "..zone.." within "..SecondsToTime( XH.resetDungeonTime - ( time() - XH.leftDungeon )).." or it will reset.");
			if (time() - XH.leftDungeon) > XH.resetDungeonTime then
				XH_zoneTracker = {};
			end
			return;    -- continue no further
		end
		-- Timer Bar
		if XH_zoneTracker.finish > 0 then
			elapsed = XH_zoneTracker.finish - XH_zoneTracker.start;
		else
			elapsed = time() - XH_zoneTracker.start;
		end

		local best, lowM, highM, longest, avg = 0, 0, 0, 0, 0;
		if (XH.instanceAverage[zone] ~= nil) then
			best = XH.instanceAverage[zone].best;
			longest = XH.instanceAverage[zone].longest;
			lowM = max( 0, XH.instanceAverage[zone].average - (XH.instanceAverage[zone].sd * 2));
			highM = min( longest, XH.instanceAverage[zone].average + (XH.instanceAverage[zone].sd * 2));
			avg = XH.instanceAverage[zone].average;
		end
		textOut = zone.." "..XH_zoneTracker.bossProgressText..": ";
		if elapsed < best then
			XH_InstanceTimerBar:SetMinMaxValues( 0, best );
			XH_InstanceTimerBar:SetStatusBarColor( 0, 0.5, 0 );    -- green?
			textOut = textOut .. SecondsToTime(elapsed) .. " < " .. SecondsToTime(best);
		elseif (elapsed <= highM) then
			XH_InstanceTimerBar:SetMinMaxValues( lowM, highM );
			XH_InstanceTimerBar:SetStatusBarColor( 0.5, 0.5, 0 );    -- yellow?
			textOut = textOut .. SecondsToTime(elapsed) .. " ("..SecondsToTime(avg).." 95%)";
		else
			XH_InstanceTimerBar:SetMinMaxValues( highM, max(longest,elapsed));    -- longest, or now
			XH_InstanceTimerBar:SetStatusBarColor( 0.5, 0, 0 );    -- red?
			textOut = textOut .. SecondsToTime(elapsed) .. " < " ..SecondsToTime(longest);
		end
		XH_InstanceTimerBar:SetValue(elapsed);
		XH_InstanceText:SetText(textOut);
		-- Print responses
		if XH_zoneTracker.finish == 0 then
			for key,f in pairs(XH.reportMilestoneFunctions) do
				if (f(elapsed,best,avg,longest)) and (not XH_zoneTracker.reportMilestones[key]) then
					if XH.instanceAverage[zone].sd > 0 then
						XH.PartyPrint(XH_SecondsToTime(elapsed)..XH.reportMilestoneMessages[key]);
					end
					XH_zoneTracker.reportMilestones[key] = true;
				end
			end
		end
	else
		XH_InstanceTimerBar:Hide();
		XH_InstanceText:Hide();
		XH_RepBar:Show();
		XH_RepText:Show();
	end

	-- Update Rep Bar
	XH.UpdateRepBarText();

	-- Skill bar
	if (XH.skillUpdate) then
		if (time() - XH.skillUpdate > XH_options.showSkill) then
			XH_SkillBar:Hide();
			XH_SkillText:Hide();
			XH_SkillBarCD:Hide();
			XH.skillUpdate = nil;
		else
			cdValue = XH_options.showSkill-(time()-XH.skillUpdate);
			XH_SkillBarCD:SetMinMaxValues(0,XH_options.showSkill);
			XH_SkillBarCD:SetValue(cdValue);
			_,maxSkillValue = XH_SkillBar:GetMinMaxValues();
			skillPercent = XH_SkillBar:GetValue() / maxSkillValue;
			cdPercent = cdValue / XH_options.showSkill;
			--XH_Print(cdValue..":"..cdPercent.."::"..skillPercent);
			if (cdPercent < skillPercent) then
				XH_SkillBarCD:SetFrameLevel( 1 );
				XH_SkillBar:SetFrameLevel( 0 );
			else
				XH_SkillBarCD:SetFrameLevel( 0 );
				XH_SkillBar:SetFrameLevel( 1 );
			end
		end
	end
end
function XH.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_RED..XH_MSG_ADDONNAME.."> "..COLOR_END..msg;
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg );
end
function XH.Debug( msg )
	-- Print Debug Messages
	if XH.debug then
		msg = "debug-"..msg;
		XH.Print( msg );
	end
end
function XH.PartyPrint( msg )
	-- prints to Party
	-- 1.19 - update to output to guild, raid / party or none.
	if (XH_options.reportTo["GUILD"]) and (IsInGuild()) then
		SendChatMessage( msg, "GUILD" );
	end
	if (XH_options.reportTo["PARTY"]) and (IsInRaid()) then
		SendChatMessage( msg, "RAID" );
	elseif (XH_options.reportTo["PARTY"]) and (IsInGroup()) then
		SendChatMessage( msg, "PARTY" );
	else
		XH.Print( COLOR_RED.."XH_ToParty: "..COLOR_END..msg, false );
	end
end
function XH.PrintHelp()
	XH.Print(XH_MSG_ADDONNAME.." by "..XH_MSG_AUTHOR);
	XH.Print("/xh help         -> Shows this menu");
	XH.Print("/xh rep [target] -> Rep Report to optional target");
	XH.Print("/xh reset        -> Forces reset of instance timer");
	XH.Print("/xh party        -> Reports go to party");
	XH.Print("/xh guild        -> Reports go to guild")
	XH.Print("/xh none         -> Reports only to self")
	XH.Print("/xh times        -> Shows instance times");


--	XH.Print("       /xh info   -> Shows info");
--	XH.Print("       /xh update # -> update every # seconds")
--	XH.Print("       /xh showskill # -> sets display time for skill bar");
--	XH.Print("       /xh help   -> Shows this menu");
end
function XH.Command(msg)
	--cmd will be nothing
	local cmd, param = XH.ParseCmd(msg);
	cmd = string.lower(cmd);
	if (cmd == "help") then
		XH.PrintHelp();
		return;
	elseif (cmd == "rep") then
		--XH.Print(param);
		XH.RepReport( XH.repGains.session, "Session Rep gain", param );
		return;
	elseif (cmd == "reset") then
		XH_zoneTracker = {};
		XH.Print("zoneTracker has been reset.");
		return;
	elseif (cmd == "party") or (cmd == "guild") or (cmd == "none") then
		XH.ReportSettings( cmd );
	elseif (cmd == "times") then
		XH.InstanceReport( param );
	elseif (cmd == "list") then
		XH.InstanceList( param );
	elseif (cmd == "rm") then
		XH.RemoveInstanceRunByTimeStamp( param );
	elseif (cmd == "test") then
		XH.Test();
	elseif (cmd == "rates") then
		XH_options.showRateGraphs = not XH_options.showRateGraphs and true or false;
		XH.Print("Rate graphs: "..(XH_options.showRateGraphs and "Enabled" or "Disabled"));
	else
		XH.Print("'"..cmd.."' not known");
		XH.Print("Use '/xh help' for a list of commands.");
		XH.Print("GetRealZoneText: "..GetRealZoneText().." Sub: "..GetSubZoneText());
		iName = GetInstanceInfo();
		numInstances = GetNumSavedInstances();
		XH.Print(iName.." from GetInstanceInfo. "..numInstances.." are saved");
	end
end
function XH.PrintStatus()
	XH.Print("Status Report");
	XH.Print("Version: "..XH_MSG_VERSION);
	XH_ReportSettings();
	XH.Print("Skills shown for "..SecondsToTime(XH_options.showSkill));
	--XH.Print("Memory usage: "..collectgarbage("count").." kB");
end

-- build time format string for when a level is expected based on how far in the future
function XH.MakeTimeFormat(timeToGo,sixty)
	if (timeToGo < 60) and (sixty == 1) then
		return "%Ss";
	elseif (timeToGo < 3600) and (sixty == 1) then
		return "%Mm%S";
	elseif (timeToGo < 86400) and (sixty == 1) then -- less than 24 hours
		return "%Hh%M";
	elseif (timeToGo < 43200) then  -- less than 12 hours
		return "%H:%M";
	elseif (timeToGo < 604800) then -- less than a week
		return "%a at %H:%M";
	elseif (timeToGo < 1209600) then -- less than 2 weeks
		return "Next %a at %H:%M";
	else
		return "%x %X";
	end
end
function XH.SecondsToTime(secsIn)
	if (not secsIn) then
		return;
	end
	-- Blizzard's SecondsToTime() function cannot be printed into Chat.  Has bad escape codes.
	XH.tempVars.day, XH.tempVars.hour, XH.tempVars.minute, XH.tempVars.sec = 0, 0, 0, 0;

	XH.tempVars.day = string.format("%i", (secsIn / 86400)) * 1;	-- LUA integer conversion
	if XH.tempVars.day < 0 then return ""; end
	secsIn = secsIn - (XH.tempVars.day * 86400);
	XH.tempVars.hour = string.format("%i", (secsIn / 3600)) * 1;
	if (XH.tempVars.day > 0) then
		return string.format("%i Day %i Hour", XH.tempVars.day, XH.tempVars.hour);
	end
	secsIn = secsIn - (XH.tempVars.hour * 3600);
	XH.tempVars.minute = string.format("%i", (secsIn / 60)) * 1;
	if (XH.tempVars.hour > 0) then
		return string.format("%ih %im", XH.tempVars.hour, XH.tempVars.minute);
	end
	XH.tempVars.sec = secsIn - (XH.tempVars.minute * 60);
	if (XH.tempVars.minute>0) then
		return string.format("%im %is", XH.tempVars.minute, XH.tempVars.sec);
	end
	return string.format("%is", XH.tempVars.sec);
end

XH_SecondsToTime = XH.SecondsToTime;

-- Converts string.format to a string.find pattern: "%s hits %s for %d." to "(.+) hits (.+) for (%d+)"
-- based on Recap by Gello
function XH.FormatToPattern(formatString)

	local patternString = formatString;

	patternString = string.gsub(patternString, "%%%d+%$([diouXxfgbcsq])", "%%%1"); -- reordering specifiers (e.g. %2$s) stripped
	patternString = string.gsub(patternString, "([%$%(%)%.%[%]%*%+%-%?%^])", "%%%1"); -- convert regex special characters

	patternString = string.gsub(patternString, "%%c", "(.)"); -- %c to (.)
	patternString = string.gsub(patternString, "%%s", "(.+)"); -- %s to (.+)
	patternString = string.gsub(patternString, "%%[du]", "(%%d+)"); -- %d to (%d+)
	patternString = string.gsub(patternString, "%%([gf])", "(%%d+%%.*%%d*)"); -- %g or %f to (%d+%.*%d*)

	return patternString;

end
function XH.ParseCmd(msg)
	if msg then
		local a,b,c = strfind(msg, "(%S+)");  --contiguous string of non-space characters
		if a then
			return c, strsub(msg, b+2);
		else
			return "";
		end
	end
end
function XH.UpdateRested()
		-- update XH.restedPC to the correct value
		XH.rested = GetXPExhaustion() or 0;  -- XP till Exhaustion
		XH.restedPC = (XH.rested / UnitXPMax("player")) * 100;

		--XH.Print(format("Rested @%d: %s (%0.2f%%)",time(),XH.rested, XH.restedPC));
end

XH.eventHandlers = {
	["ADDON_LOADED"] = function()
		XH.ADDON_LOADED();
		XHFrame:UnregisterEvent("ADDON_LOADED");
	end,
	["PLAYER_ENTERING_WORLD"] = function()
		XH.PlayerEnteringWorld();
	end,
	["PLAYER_REGEN_DISABLED"] = function()
		-- XH_CombatStart();  -- for tracking rep gain per fight
		if XH.inDungeon then  -- player is in a dungeon
			XH.OnPLAYER_REGEN_DISABLED();
		end
	end,
	["COMBAT_LOG_EVENT_UNFILTERED"] = function(event, ...)
		arg1, arg2, _, _, _, _, _, arg8, arg9 = select(1, ...);
		-- arg2 is event name, arg8 is unit name, arg1 is time stamp (ms accuracy)
		-- Note.  arg1 is server side time
		if (arg2 and arg2 == "UNIT_DIED") then
			--XH.Print(arg2..": "..arg9.. " died at "..arg1);
			XH.OnUNIT_DIED( arg9,arg8 );
		end
	end,
	["CHAT_MSG_SKILL"] = function(event, ...)
		arg1 = select(1, ...);
		XH.OnSkill( arg1 );
	end,
	["UI_ERROR_MESSAGE"] = function(event, ...)
		arg1 = select(1, ...);
		XH.OnSkill( arg1 );
	end,
	["PLAYER_REGEN_ENABLED"] = function()
	end,
	["UPDATE_EXHAUSTION"] = XH.UpdateRested,
	["PLAYER_LEVEL_UP"] = function(event, ...)
		XH.ding = select(1, ...);
		XH.XPGainEvent();
		XH.ResetBubbleReport();
		XH.bestTime = 0;
		XH.lastUpdate = XH.lastUpdate + 5;
		RequestTimePlayed();  -- fires off /played
	end,
	["TIME_PLAYED_MSG"] = function(event, ...)
		XH.TimePlayedMsg(event, ...);
	end,
	--["UPDATE_PARTY_MEMBERS"] = XH.UpdatePartyMembers,
}
function XH_OnEvent(event, ...)
	local handler = XH.eventHandlers[event];
	if handler then
		handler(event, ...);
	else
		local out = event;
		arg1, arg2, arg3 = select(1, ...);
		if (arg1) then out = out .. " arg1:"..arg1; end
		if (arg2) then out = out .. " arg2:"..arg2; end
		if (arg3) then out = out .. " arg3:"..arg3; end
		arg4, arg5, arg6, arg7, arg8, arg9 = select(4, ...);
		if (arg4) then out = out .. " arg4:"..arg4; end
		if (arg5) then out = out .. " arg5:"..arg5; end
		if (arg6) then out = out .. " arg6:"..arg6; end
		if (arg7) then out = out .. " arg7:"..arg7; end
		if (arg8) then out = out .. " arg8:"..arg8; end
		if (arg9) then out = out .. " arg9:"..arg9; end

		XH.Print(out);
	end
end

-- Prevent moving of LAX
function XH_OnDragStart()
	XHFrame:StartMoving();
end
function XH_OnDragStop()
	XHFrame:StopMovingOrSizing();
end
function XH_OnUpdate(arg1)  -- use XH_ since it is referenced outside of this file (before the XH. is created)
	if (time() < XH.lastUpdate + 1) then	-- short cut out
		return;
	end
	XH.lastUpdate = time();
	XH.BubbleReport();
	if (XH.doCurrencyReport) then
		XH.CurrencyGainReport();
		XH.doCurrencyReport = nil;
	end
	--XH.Text = SecondsToTime(XH.lastUpdate - XH.startedTime, false, false, 5);  -- use the built in function
	--XH.Text = format("%s (%0.1f)", XH.Text, GetFramerate());


	XH.UpdateBars();
--[[
	if (XH.mouseOver) then
		XH_Text:SetText(XP_total_str);
	else
		XH_Out();
	end
]]--
end

-- Enter function, will be ran on mouseover.
function XH_OnEnter()
	XH.mouseOver = true;
	XH.UpdateBars();
end

-- Leave function, will be ran on mouseoverleave.
function XH_OnLeave()
	XH.mouseOver = nil;
	XH.UpdateBars();
end

-- Instance Timer Code
function XH.PlayerEnteringWorld()
	XH.UpdateRested();
	local inInstance, instanceType = IsInInstance();  -- 1nil, string( arena, none, party, pvp, raid)
	if (inInstance) then
		local iName, iType, iDiff, _, _, _, _, instanceID = GetInstanceInfo();
		XH.Print((inInstance and "true" or "nil")..":"..(instanceType or "unknown instanceType").." mapID:"..(instanceID or "nil mapID"))

		if iType and iDiff then
			XH.Print("Welcome to: "..iName.." ("..iType..":"..iDiff..")");
		end
		XH.inDungeon = nil;
		XH.leftDungeon = nil;
	else
		--XH.Print("Leaving Dungeon");
		XH.inDungeon = nil;
		-- if tracking a dungeon, not done, and not deadOrGhost
		if (XH_zoneTracker) and (XH_zoneTracker.finish == 0) and (not UnitIsDeadOrGhost("player")) then
			XH.leftDungeon = time();
		end
	end
end
function XH.OnPLAYER_REGEN_DISABLED()
	-- called when a fight starts in an instance
	--local zoneName = GetZoneText();
	local zoneName, iType, iDiff = GetInstanceInfo();
	local diff = XH.difficulty[iType][iDiff];
	zoneName = zoneName ..diff;

	-- clear it if finish is set
	-- clear it if zonename does not match
	if (XH_zoneTracker == nil) or ((XH_zoneTracker.zoneName ~= zoneName) or (XH_zoneTracker.finish ~= 0)) then
		if (XH_zoneTracker and XH_zoneTracker.zoneName ~= zoneName) then
			XH.StartZoneTracker( zoneName );
		end
	end
	if (XH_zoneTracker.start == 0) then  -- start the instance timer
		XH.combatStart = time();
		--XH.Print("Started at: "..XH.combatStart);
		local zoneBosses = XH_instanceBosses[zoneName];
		if (zoneBosses) then  -- start of zone
			XH.PartyPrint(zoneName.." tracking started");
			XH_zoneTracker.start = XH.combatStart;
			XH_zoneTracker.zoneName = zoneName;
			for k,bossName in pairs(zoneBosses) do
				XH_zoneTracker.bosses[bossName] = 0;
			end
			XH_zoneTracker.bossProgressText = XH.InstanceBossReport( false, true );  -- bosses to go
			if (XH.instanceAverage[zoneName]) then
				XH.PartyPrint(format("My Best time: %s. Ave: %s",
						XH_SecondsToTime(XH.instanceAverage[zoneName].best),
						XH_SecondsToTime(XH.instanceAverage[zoneName].average)));
			end
		else
			XH.Print("Zone '"..zoneName.."' not known");
			XH_zoneTracker.start = XH.combatStart;
			XH_zoneTracker.zoneName = zoneName;
		end
	end
end
function XH.StartZoneTracker( zoneName )
	XH_zoneTracker = {};
	XH_zoneTracker.start = 0;
	XH_zoneTracker.finish = 0;
	XH_zoneTracker.zoneName = "";
	XH_zoneTracker.xpGain = 0;
	XH_zoneTracker.repGain = {};
	XH_zoneTracker.bosses = {};
	XH_zoneTracker.mobs = {};
	XH_zoneTracker.reportMilestones = {};
	XH_zoneTracker.bossProgressText = "";
	XH_zoneTracker.partyMembers = {};
	for key in pairs(XH.reportMilestoneFunctions) do
		XH_zoneTracker.reportMilestones[key] = false;
	end
	XH.Print("ZONE STARTED");
end
function XH.InstanceAverages()
	-- computes XH.instanceAverage from character data
	-- also stores best instance time into XH_instanceBestTimes
	-- stored variables:
	-- average, best, count, longest, sd
	for zone,times in pairs( XH_instanceTimes ) do
		XH.instanceAverage[zone] = {};
		local sum, count, best, longest = 0, 0, 0, 0;
		for start,values in pairs( times ) do
			runtime = values.finish - start;
			sum = sum + runtime;
			count = count + 1;
			if (runtime < best) or (best == 0) then
				best = runtime;
				-- update XH_instanceBestTimes
			end
			longest = max(longest, runtime);
		end
		m = sum / count;
		XH.instanceAverage[zone].average = m;
		XH.instanceAverage[zone].best = best;
		XH.instanceAverage[zone].count = count;
		XH.instanceAverage[zone].longest = longest;
		-- compute sd from data
		local vm, sum, count = 0, 0, 0;
		for start,values in pairs( times ) do
			runtime = values.finish - start;
			vm = runtime - m;
			sum = sum + (vm * vm);
			count = count + 1;
		end
		if (count > 1) then
			XH.instanceAverage[zone].sd = math.sqrt( sum / (count-1) );
		else
			XH.instanceAverage[zone].sd = 0;
		end
		--XH.Print(zone.." m:".. m.." +- "..XH.instanceAverage[zone].sd);
	end
end
function XH.InstanceBossReport( completed, togo )
	-- output one or 2 lines of:
	-- "Completed: 'bosslist'"
	-- "'bossCount' to go: 'bossList'"
	-- return "(Killed of total)"
	local deadBosses, aliveBosses, aliveBossCount, bossCount = "", "", 0, 0;
	if not XH_zoneTracker.bosses then
		return;
	end
	for boss,time in pairs( XH_zoneTracker.bosses) do
		if time>0 then
			deadBosses = deadBosses .. boss .. ", ";
		else
			aliveBosses = aliveBosses .. boss .. ", ";
			aliveBossCount = aliveBossCount + 1;
		end
		bossCount = bossCount + 1;
	end
	if (completed) and (strlen(deadBosses) > 0) then
		XH.PartyPrint("Completed: "..deadBosses);
	end
	if (togo ~= nil) and (togo == true) and (strlen(aliveBosses) > 0) then
		XH.PartyPrint(aliveBossCount.." to go: "..aliveBosses);
	end
	return format("(%i of %i)", bossCount-aliveBossCount, bossCount);
end
function XH.OnUNIT_DIED( unitName, unitGUID )
	zoneName = GetZoneText();
	if (IsInInstance()) then
		local iName, iType, iDiff = GetInstanceInfo();
		zoneName = iName;
		local diff = XH.difficulty[iType][iDiff];
		zoneName = zoneName .. (diff or (" iType: "..iType.." iDiff: "..iDiff) )
		print(zoneName)
	end
	now = time();
	bossesLeft = 0; bossCountTotal = 0; bossName = nil;
	bossReport = false;
	local XH_instanceElapsed = 0;
	--XH.Debug("OnUNIT_DIED @ "..now);
	if (XH_zoneTracker.bosses) then
		--XH.Debug("Good Bosses table.");
		for bossNameTest,killedAt in pairs(XH_zoneTracker.bosses) do
			--XH.Debug(bossNameTest..":"..killedAt);
			bossCountTotal = bossCountTotal + 1;
			if (unitName == bossNameTest) then
				--XH.Debug("Boss killed");
				bossReport = true;
				XH_zoneTracker["bosses"][bossNameTest] = now;
				if (XH_zoneTracker.bossNameGUID) then
					XH_zoneTracker.bossNameGUID[unitGUID]=bossNameTest;
				else
					XH_zoneTracker.bossNameGUID={[unitGUID]=bossNameTest};
				end
				XH_bosses[unitGUID]=bossNameTest;
				XH_instanceElapsed = time() - XH_zoneTracker.start;
				bossName = bossNameTest;
			elseif (killedAt == 0) then
				bossesLeft = bossesLeft + 1;
			end
		end
		if bossName then
			XH.PartyPrint(format("%s (boss %i of %i) was killed at %s",
					bossName, bossCountTotal-bossesLeft, bossCountTotal, XH.SecondsToTime(XH_instanceElapsed)));
			XH_zoneTracker.bossProgressText = format("(%i of %i)", bossCountTotal-bossesLeft, bossCountTotal);
		end
		if (bossReport) then
			if (bossesLeft == 0) then	-- Final boss killed
				XH_zoneTracker.finish = time();
				XH.PartyPrint("Finished "..zoneName.." in "..XH_SecondsToTime(XH_instanceElapsed));
				for k,v in pairs(XH_instanceBestTimes) do	-- Find best time
					if (k == zoneName) then
						bestStart = XH_instanceBestTimes[zoneName].start;
						bestFinish = XH_instanceBestTimes[zoneName].finish;
					end
				end
				-- Store player time
				zoneFound = false;
				for zone, v in pairs(XH_instanceTimes) do
					if (zone == zoneName) then
						zoneFound = true;
						XH.Debug("Zone Found in player times");
					end
				end
				if not zoneFound then
					XH_instanceTimes[zoneName] = {};
					XH.Debug("No Zone found for player.  Init.");
				end
				XH_instanceTimes[zoneName][XH_zoneTracker.start] = {};
				XH_instanceTimes[zoneName][XH_zoneTracker.start]["finish"] = XH_zoneTracker.finish;
				-- instance data saved, recompute averages
				XH.InstanceAverages();

				-- Record Best Times
				if (bestStart == nil) or (bestFinish == nil) then
					bestTime = 0;
				else
					bestTime = bestFinish - bestStart;
				end
				if (bestTime == 0) or (XH_instanceElapsed < bestTime) then	-- store global best
					XH.Print("Storing BestTime for zone: "..zoneName);
					XH_instanceBestTimes[zoneName] = {};
					XH_instanceBestTimes[zoneName].start = XH_zoneTracker.start;
					XH_instanceBestTimes[zoneName].finish = XH_zoneTracker.finish;
					XH_instanceBestTimes[zoneName].realm = XH.realm;
					XH_instanceBestTimes[zoneName].playerName = XH.name;
					strOut = "New record time for "..zoneName..".";
					if bestTime > 0 then
						strOut = strOut .. " Previous record: "..XH_SecondsToTime(bestTime);
					end
					XH.PartyPrint( strOut );
				end
				XH.Print(string.format("best/ave/longest/sd %s/%s/%s/%s",
					XH.SecondsToTime(XH.instanceAverage[zoneName].best),
					XH.SecondsToTime(XH.instanceAverage[zoneName].average),
					XH.SecondsToTime(XH.instanceAverage[zoneName].longest),
					XH.SecondsToTime(XH.instanceAverage[zoneName].sd)));

				if (XH_instanceElapsed <= XH.instanceAverage[zoneName].best) then
					XH.Print("We beat my best time of "..XH.SecondsToTime(XH.instanceAverage[zoneName].best));
				elseif (XH_instanceElapsed <= XH.instanceAverage[zoneName].longest) then
					XH.Print("Not the longest run.");
					diffFromAverage = XH_instanceElapsed - XH.instanceAverage[zoneName].average;
					XH.Print(string.format("Was %0.1f sd from average.",
						diffFromAverage / XH.instanceAverage[zoneName].sd));
				end

				--XH.CurrencyGainReport();
				-- Print kill records

				--XH_RepReport( XH_zoneTracker.repGain, "Instance Rep Gain" );
				-- Restore faction reporting
				-- Moved else where
				-- XH_FactionOutput( XH_zoneTracker.repGainReport );
			end
		end
	end
	if (bossName) then  -- comment
		return;
	end
	if (XH_zoneTracker.mobs) then
--[[
		if (XH_zoneTracker.mobs[unitGUID]) then
			XH_zoneTracker.mobs[unitGUID].count = XH_zoneTracker.mobs[unitGUID].count + 1;
		else
			XH_zoneTracker.mobs[unitGUID] = {["count"]=1, ["name"]=unitName};
		end
]]--
		if (XH_zoneTracker.mobs[unitName]) then
			XH_zoneTracker.mobs[unitName].count = XH_zoneTracker.mobs[unitName].count + 1;
			XH_zoneTracker.mobs[unitName].guids[unitGUID]=1;
		else
			XH_zoneTracker.mobs[unitName]={};
			XH_zoneTracker.mobs[unitName].count = 1;
			XH_zoneTracker.mobs[unitName].guids={[unitGUID]=1};
		end
	end
end
function XH.ReportSettings( param )
	-- set report settings, or report report settings
	local tf = {COLOR_GREEN.."on"..COLOR_END, COLOR_RED.."off"..COLOR_END};    -- 1 and 2

	if ( param ) then
		param = strupper( param );
		XH.Debug("Report Settings ("..param..")");
		for k,_ in pairs(XH_options.reportTo) do	-- set one on, the others off.
			if ( k == param ) then
				XH_options.reportTo[k] = true;
			else
				XH_options.reportTo[k] = false;
			end
		end
	end

	-- generate report list
	for k,_ in pairs(XH_options.reportTo) do
		local v = 2;
		if ( XH_options.reportTo[k] == true ) then
			v = 1;
		end
		XH.Print("Reporting to "..k.." is "..tf[v], false );
	end

	XH.Debug("End Report Settings");
end
function XH.InstanceReport( instanceSearch )
	-- reports InstanceData
	-- instanceSearch will be a text to search on
	XH.Print("InstanceReport - "..instanceSearch);
	local searchTxt = "No Instance";
	if (instanceSearch ~= nil) and (instanceSearch ~= "") then    -- report on specific instance
		searchTxt = instanceSearch;
		--XH.Print("Search given");
	elseif (XH_zoneTracker.zoneName ~= nil) then    -- otherwise, if an instance is given, report on it.
		searchTxt = XH_zoneTracker.zoneName;
		--XH.Print("Use ZoneTracker Zone")
	end
	searchTxt = strupper( searchTxt );
	--XH.Print(">"..searchTxt.."<");
	for zone,values in pairs( XH.instanceAverage ) do
		-- strOut = zone.." run "..values.count.." times. My best time: "..SecondsToTime( values.best ).." Average time: "..SecondsToTime( values.average ).. " +- "..SecondsToTime( values.sd );
		-- XH.Print( strOut );
		--strOut = format("%s: My best: %s. Average: %s (sd: %s). Longest: %s",
		strOut = format("%s: Best/Ave(sd)/Longest %s/%s(%s)/%s",
				zone, XH.SecondsToTime( values.best ), XH.SecondsToTime( values.average ), XH.SecondsToTime( values.sd ),
				XH.SecondsToTime( values.longest ));
		--XH.Print( strOut );
		--if (XH_zoneTracker.zoneName ~= nil) and (XH_zoneTracker.zoneName == zone) then
		if (string.find( strupper(zone), searchTxt ) ~= nil) then    -- print to party if found
			XH.PartyPrint( strOut );
		end
	end
	if ( instanceSearch ~= "" ) then -- don't want to report any more if doing a search
		return;
	end

	if (XH_zoneTracker.zoneName ~= nil) then
		if XH_zoneTracker.finish > 0 then
			elapsed = XH_zoneTracker.finish - XH_zoneTracker.start;
		else
			elapsed = time() - XH_zoneTracker.start;
		end
		--XH_Print("Current Instance: "..XH_zoneTracker.zoneName.." - "..SecondsToTime(elapsed));
		XH.PartyPrint("Current elapsed time: "..XH_SecondsToTime(elapsed));
		XH.InstanceBossReport( true, true );    -- completed, and togo
		if XH_zoneTracker.finish>0 then
			elapsed = XH_zoneTracker.finish - XH_zoneTracker.start;
			XH.Print("Finished in "..XH_SecondsToTime(elapsed));
		end
	end
	--XH_RepReport( XH_zoneTracker.repGain, "Instance Rep Gain" );
	if XH_zoneTracker.xpGain ~= nil and XH_zoneTracker.xpGain > 0 then
		XH.Print(XH_zoneTracker.xpGain.." xp gained.");
	end
end
function XH.InstanceList( instanceSearch )
	XH.Print("InstanceList - "..instanceSearch);
	local searchTxt = ".";
	local printData = false;
	if (instanceSearch ~= nil) and (instanceSearch ~= "") then    -- report on specific instance
		searchTxt = instanceSearch;
		printData = true;
	end
	searchTxt = strupper( searchTxt );
	local runCount = 0
	for zone,values in pairs( XH_instanceTimes ) do
		runCount = tableLen( values );
		if (string.find( strupper(zone), searchTxt ) ~= nil) then
			XH.Print(zone..": runs: "..runCount, false );
			if (printData == true) then
				table.sort(values);
				for start,data in pairs( values ) do
					XH.Print("   "..start.." ran for "..SecondsToTime( data["finish"] - start ), false );
				end
				XH.Print("Best: "..SecondsToTime( XH.instanceAverage[zone].best )..
						 " -- Longest: " .. SecondsToTime( XH.instanceAverage[zone].longest ), false );
				XH.Print("Ave: "..SecondsToTime( XH.instanceAverage[zone].average )..
						 " (sd: "..SecondsToTime( XH.instanceAverage[zone].sd )..")", false );
				XH.Print("==========",false);
			end
		end
	end
	if ( instanceSearch ~= "" ) then -- don't want to report any more if doing a search
		return;
	end
end
function XH.RemoveInstanceRunByTimeStamp( timestamp )
	if timestamp == "" then
		return;
	end
	timestamp = timestamp * 1;  -- timestamp comes in as a string.  need to convert to integer.
	--XH_Print("Removing instance starting at: "..timestamp);
	local recalc = false;
	for zone,values in pairs( XH_instanceTimes ) do
		for start, data in pairs( values ) do
			if start == timestamp then
				XH.Print("Deleting instance info for: "..zone.." starting at: "..start);
				XH_instanceTimes[zone][start] = nil;
				recalc = zone;
			end
		end
	end
	if recalc then
		XH.InstanceAverages();
		XH.Print("Best: "..SecondsToTime( XH.instanceAverage[recalc].best )..
				 " -- Longest: " .. SecondsToTime( XH.instanceAverage[recalc].longest ), false );
		XH.Print("Ave: "..SecondsToTime( XH.instanceAverage[recalc].average )..
				 " (sd: "..SecondsToTime( XH.instanceAverage[recalc].sd )..")", false );
	else
		XH.Print("No timestamp match found");
	end
end

-- Currency Code
function XH.LootGainEvent( frame, event, message, ...)
	--XH.Print(event..":"..message);
	if (not XH.CURRENCY_GAIN_TEXT) then
		XH.CURRENCY_GAIN_TEXT = XH.FormatToPattern("You receive currency: %s x%d.");
	end
	local _, _, currencyName, num = string.find(message, XH.CURRENCY_GAIN_TEXT);
	--XH.Print(format("You gained %i of %s.", num or 0, currencyName or "nothing"));
	--XH.Print(XH.CURRENCY_GAIN_TEXT, true);
	if (currencyName and XH_zoneTracker) then
		if (XH_zoneTracker.currency) then
			if (XH_zoneTracker.currency[currencyName]) then
				XH_zoneTracker.currency[currencyName] = XH_zoneTracker.currency[currencyName] + num;
			else
				XH_zoneTracker.currency[currencyName] = num;
			end
		else
			XH_zoneTracker.currency = {[currencyName] = num};
		end
		XH.doCurrencyReport = true;
		XH.lastUpdate = time();
	end
end

function XH.CurrencyGainReport()
	if (XH_zoneTracker and XH_zoneTracker.currency) then
		local elapsed;
		if (XH_zoneTracker.finish and XH_zoneTracker.finish > 0) then
			elapsed = (XH_zoneTracker.finish - XH_zoneTracker.start);
		elseif (XH_zoneTracker.start and XH_zoneTracker.start > 0) then
			elapsed = time()-XH_zoneTracker.start;
		else
			elapsed = time()-XH.startedTime;
		end
		for c,n in pairs(XH_zoneTracker.currency) do
			XH.PartyPrint(format("%s: %d in %s (%0.2f / min)", c,n,XH.SecondsToTime(elapsed), n/(elapsed/60.0)));
		end
	end
end

-- XP Code
function XH.XPGainEvent( frame, event, message, ... )
	if not message then
		return
	end
	--XH.Print(event..":"..message);
	XH.UpdateRested();
	if (not XH.EXP_GAIN_TEXT) then
		XH.EXP_GAIN_TEXT = XH.FormatToPattern(COMBATLOG_XPGAIN_FIRSTPERSON);
	end
	if (not XH.RESTED_GAIN_TEXT) then
		--XH.Print(COMBATLOG_XPGAIN_EXHAUSTION1);
		local _, _, restedstr = string.find(COMBATLOG_XPGAIN_EXHAUSTION1, "%(%%s(.*)%)");
		restedstr = "%d"..restedstr;
		--XH.Print(restedstr);
		XH.RESTED_GAIN_TEXT = XH.FormatToPattern( restedstr );
		--XH.RESTED_GAIN_TEXT = XH.FormatToPattern(COMBATLOG_XPGAIN_EXHAUSTION1);
	end
	XH.xpGain = nil;
	_, _, XH.mobName, XH.xpGain = string.find(message, XH.EXP_GAIN_TEXT);
	if (not XH.xpGain) then  -- xpgain is not from combat
		--XH.Print("No xpGain", false);
		if (not XH.XPGAIN_QUEST) then
			XH.XPGAIN_QUEST = XH.FormatToPattern("You gain %d experience");
		end
		--XH.Print(XH.XPGAIN_QUEST);
		_,_,XH.xpGain = string.find(message, XH.XPGAIN_QUEST);
		--XH.Print("xpGain:"..xpGain);
	end
--	local _, _, bonusXP, xpType = string.find(message, XH.RESTED_GAIN_TEXT);
--[[
	if (mobName) then
		XH.Print("Killed:"..mobName.." for "..xpGain);
	elseif (xpGain) then
		XH.Print("XPGain:"..xpGain);
	end
]]--
--	if (bonusXP) then
--		XH.Print(xpType..":"..bonusXP);
--	end
	--XH.Print(XH.EXP_GAIN_TEXT..":"..XH.RESTED_GAIN_TEXT);
	for counter, gain in pairs(XH.XPGains) do
		if (gain.gained) then
			gain.gained = gain.gained + XH.xpGain;
			gain.lastGained = XH.xpGain;
			gain.toGo = UnitXPMax("player") - UnitXP("player");  -- this needs to happen for lvling
			local now = time();

			XH.XPGains[counter].rolling[now] =
				(XH.XPGains[counter].rolling[now] and XH.XPGains[counter].rolling[now] + XH.xpGain) -- entry exists
				or XH.xpGain;  -- extry does not exist
		else  -- odd.  Cannot do gain={}.  seems to fail
			XH.XPGains[counter] = XH.InitRate(xpGain, UnitXPMax("player") - UnitXP("player"));
		end
	end
end
function XH.UpdateXPBarText(self)
	XH.xps, XH.timeToGo, XH.gained = XH.Rate2( XH.XPGains.session );

	if (XH.gained) and (XH.gained > 0) and (not XH.mouseOver) then
--		XH.xps, XH.timeToGo = XH.Rate( XH.XPGains.session );
		--XH.Text = format("%d XP in %s (%0.2f xp/s) %s to go. (%0.1f FPS)",
		--		XH.XPGains.session.gained, XH.SecondsToTime(time()-XH.XPGains.session.start),
		--		xps, XH.SecondsToTime(timeToGo), GetFramerate());
		if (XH.bestTime > time()+XH.timeToGo) or (XH.bestTime < time()) then
			XH.bestTime = time()+XH.timeToGo;
			--XH.Print(date("%x %X",XH.bestTime));
		end
		XH.Text = format("%s :: Lvl at %s (%s). (%0.2f xp/s)",
				XH.SecondsToTime(XH.timeToGo),
				date(XH.MakeTimeFormat(XH.timeToGo), time()+XH.timeToGo),
				date(XH.MakeTimeFormat(XH.timeToGo), XH.bestTime),
				XH.xps);
	else
		XH.Text = SecondsToTime(XH.lastUpdate - XH.startedTime, false, false, 5);  -- use the built in function
		if (XH.XPGains.session.gained and XH.XPGains.session.gained > 0) then
			XH.Text = format("%s xp (%0.2f bubbles) in %s (%0.1f FPS)",
					XH.XPGains.session.gained, (XH.XPGains.session.gained / XH.bubbleSize), XH.Text, GetFramerate());
		else
			XH.Text = format("%s (%0.1f FPS)", XH.Text, GetFramerate());
		end
	end
	XH_Text:SetText(XH.Text);
	--XH.Print(XH.Text);
	--[[
	if (XH_total_XPS > 0) then
		XH_tolvl_str = string.format("%s :: Lvl at %s (%s) %s/B", XH_time_to_lvl_str, XH_lvl_time_str, XH_lvl_time_best_str, XH_time_per_bubble_str);
		XH_tonorm_str = string.format("%s :: Norm at %s (%s) %s/B", XH_time_to_norm_str, XH_norm_time_str, XH_norm_time_best_str, XH_time_per_bubble_str);
		if (XH.showRested) and (XH.rested > 0) and (XH_time_to_norm < XH_time_to_lvl) then
			XH_tolvl_str = XH_tonorm_str;	-- show rested
		elseif XH.showRested and (XH.rested < 1) then
			if XH.info then XH_Print("Rested done"); end
			XH.showRested = false;
		end
	end
	]]--
end
function XH.BubbleReport()
	if (UnitLevel("player") < XH.maxLevel) then
		-- report to the party that you have passed a bubble milestone
		XH.bubbleSize = UnitXPMax("player") / 20;
		XH.bubblesDone = UnitXP("player") / XH.bubbleSize;
		--XH.Print(format("%0.2f x %d", XH.bubblesDone, XH.bubbleSize));
		for b,done in pairs(XH_bubbleReport) do
			if (b <= XH.bubblesDone) and (not done) then
				local fmt = "Halfway through this level.";
				if (b<10) then
					fmt = format("%d bubble%%s done.", b);
				elseif (b>10) then
					fmt = format("%d bubble%%s to go.", 20-b);
				end
				if (b>1) and (b<19) and (b~=10) then
					fmt = format(fmt, "s");
				else
					fmt = format(fmt, "");
				end

				XH.PartyPrint(fmt);
				XH_bubbleReport[b] = time();
			end
		end
	end
end
function XH.ResetBubbleReport()
	-- reset the values
	XH.Print("Reseting Bubble Report");
	for bubble in pairs(XH_bubbleReport) do
		XH_bubbleReport[bubble] = false;
	end
end

-- Skill code
function XH.OnSkill( arg1 )
	if (not XH.SKILL_RANK_UP) then
		XH.SKILL_RANK_UP = gsub(SKILL_RANK_UP, "%%s", "(.+)");
		XH.SKILL_RANK_UP = gsub(XH.SKILL_RANK_UP, "%%d", "(.+)");
	end
	if (not XH.SKILL_FAIL) then
		XH.SKILL_FAIL = "Requires (.+) (.+)";
	end
	local skill, val = nil, nil;
	if arg1 then
		_, _, skill, val = strfind(arg1, XH.SKILL_RANK_UP);
	end
	if not val then  -- value failed to be found
		_, _, skill, val = strfind(arg1, XH.SKILL_FAIL);
	end
	--XH.Print(skill..":"..val..":"..XH_options.showSkill..":"..arg1);

	if skill and (XH_options.showSkill > 0) then
		local skillIndexes = {GetProfessions()};
		for k,i in pairs(skillIndexes) do
			local skillName, icon, skillRank, skillMaxRank, numAbilities, spellOffset, skillLine, skillModifier = GetProfessionInfo(i);
			--XH.Print(">"..skillName.."<:"..">"..skill.."<"..skillRank);
			if (skillName == skill) then
				XH_SkillBar:Show();
				XH_SkillText:Show();
				XH_SkillBarCD:Show();
				XH_SkillBar:SetMinMaxValues(0, skillMaxRank);
				XH_SkillBar:SetValue(skillRank);
				skillText = skillName..": "..skillRank;
				if (skillModifier > 0) then
					skillText = skillText .." ("..COLOR_GREEN.."+"..skillModifier..COLOR_END	..")";
				end
				skillText = skillText .." / "..skillMaxRank;
				XH_SkillText:SetText(skillText);
				XH.skillUpdate = time();
			end
		end
	end
end

-- Faction code
function XH.FactionGainEvent( frame, event, message, ... )
	--XH.Print(event..":"..message);
	if (not XH.FACTION_STANDING_DECREASED_PATTERN) then
		XH.FACTION_STANDING_DECREASED_PATTERN = XH.FormatToPattern(FACTION_STANDING_DECREASED);
	end
	local _, _, factionName, amount = string.find(message, XH.FACTION_STANDING_DECREASED_PATTERN);
	if (factionName) then
		amount = -amount;
	else
		if (not XH.FACTION_STANDING_INCREASED_PATTERN) then
			XH.FACTION_STANDING_INCREASED_PATTERN = XH.FormatToPattern(FACTION_STANDING_INCREASED);
		end
		_, _, factionName, amount = string.find(message, XH.FACTION_STANDING_INCREASED_PATTERN);
		amount = tonumber(amount);
	end

	XH.FactionGain( factionName, amount );
end

-- return a list of faction info
function XH.GetFactionInfo( factionNameIn )
	for factionIndex = 1, GetNumFactions() do
		local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
				canToggleAtWar, isHeader, isCollapsed, isWatched = GetFactionInfo(factionIndex);
		local barBottomValue = 0;
		local barTopValue = topValue - bottomValue;
		local barEarnedValue = earnedValue - bottomValue;
		local standingStr = getglobal("FACTION_STANDING_LABEL"..standingId);
		if name == factionNameIn then
			return name, description, standingStr, barBottomValue, barTopValue, barEarnedValue, atWarWith,
					canToggleAtWar, isHeader, isCollapsed, isWatched, factionIndex;
		end
	end
	if not name then
		XH.Print("No faction found that matches: "..factionNameIn);
		CollapseAllFactionHeaders();
		ExpandAllFactionHeaders();
	end
end
function XH.FactionGain( factionNameIn, repGainIn )
	--XH.GetFactionInfo( factionNameIn );
	local name, description, standingStr, barBottomValue, barTopValue, barEarnedValue, atWarWith,
			canToggleAtWar, isHeader, isCollapsed, isWatched, factionIndex = XH.GetFactionInfo( factionNameIn );
	if name then
		for counter, gain in pairs(XH.repGains) do
			--XH.Print("Counter: "..counter);
			if (gain[factionNameIn]) then
				gain[factionNameIn].gained = gain[factionNameIn].gained + repGainIn;
				gain[factionNameIn].lastGained = repGainIn;
				gain[factionNameIn].toGo = barTopValue - barEarnedValue;
				local now = time();

				XH.repGains[counter][factionNameIn].rolling[now] =
						(XH.repGains[counter][factionNameIn].rolling[now] and XH.repGains[counter][factionNameIn].rolling[now] + repGainIn) -- entry exists
						or repGainIn;  -- extry does not exist
			else
				XH.Print(factionNameIn..":"..barTopValue-barEarnedValue);
				XH.repGains[counter][factionNameIn] = XH.InitRate(repGainIn, barTopValue-barEarnedValue);
			end
		end

		if not isWatched then
			SetWatchedFactionIndex(factionIndex);
		end

		-- format report string
		XH.repStrFmt = format("%s (%s) : %d (%d) -> %d (%%s)",
				name, standingStr, repGainIn, XH.repGains.session[factionNameIn].gained, barTopValue - barEarnedValue );
		XH.repProgress = factionNameIn;
		XH_RepBar:SetMinMaxValues(barBottomValue, barTopValue);
		XH_RepBar:SetValue(barEarnedValue);
		XH.UpdateRepBarText();
	end
end
function XH.InitRate( gainedValue, toGo )
	return {["gained"] = gainedValue,
			["start"] = time(),
			["lastGained"] = gainedValue,
			["toGo"] = toGo,
			["rolling"] = {[time()] = gainedValue},
			};
end

function XH.Rate2( rateStruct )
	-- returns rate/second, seconds till threshold, totalgained
	local change = nil;
	XH.rateMax = 0;
	if rateStruct.gained then
		XH.rateByMin={};
		local newKey = 0;
		XH.xpSum = 0; XH.xpCount = 0;
		XH.startTS, XH.mostRecentTS = time(), time()-XH.timeRange;
		for key, val in pairs(rateStruct.rolling) do
			XH.xpCount = XH.xpCount +1;
			XH.startTS = min(XH.startTS, key);
			XH.mostRecentTS = max(XH.mostRecentTS, key);
			XH.xpSum = XH.xpSum + val;
			--XH.Print(key.." ("..(time()-key).."):"..val.."("..XH.xpSum..")"..math.floor((time()-key)/60));
			newKey = math.floor((time()-key)/60);

			XH.rateByMin[newKey] = (XH.rateByMin[newKey] and XH.rateByMin[newKey] + val) or val;
			XH.rateMax = max(XH.rateMax, XH.rateByMin[newKey]);

			if ((key+XH.timeRange) <= time()) then
				--XH.XPGains.session.rolling[key] = nil;
				rateStruct.rolling[key] = nil;
				change = true;
			end

		end
		if (XH_options.showRateGraphs) and (XH.xpCount > 0) and (XH.xpSum > 0) and (time()%10 == 0) then
			-- Every 10 seconds if there is +data
			local strOut = ":";
			for key=0,((XH.timeRange/60)-1) do
	--			strOut = strOut .. (XH.rateByMin[key] and '*' or XH.rateGraph[0]);
				strOut = strOut .. (XH.rateByMin[key] and
						(XH.rateGraph[ceil((XH.rateByMin[key] * 4)/max(XH.rateMax,1))]) or XH.rateGraph[0]);
				if (key>0) and ((key+1)%5 == 0) then
					strOut = strOut .. "|";
				end
			end
			XH_RepText:SetText(strOut.." : "..XH.xpCount.."("..XH.rateMax..")");
			XH_RepText:Show();
			--XH.Print(strOut.." : "..XH.xpCount.."("..XH.rateMax.."): "..XH.SecondsToTime( rateStruct.toGo/(XH.xpSum/XH.timeRange) ));
		end
--		if (XH.xpSum > 0) and (not XH.xpSumOld or XH.xpSum ~= XH.xpSumOld) then
		if false and change then
			--local rate = XH.xpSum / (XH.mostRecentTS-XH.startTS);
			--local timeRemain = XH.XPGains.session.toGo / rate;
			XH.Print(string.format("%d in (%s -%i- %s) %0.2f /sec %s",
					XH.xpSum,
					XH.SecondsToTime(time() - XH.mostRecentTS),
					XH.xpCount,
					XH.SecondsToTime(XH.mostRecentTS-XH.startTS),
					XH.xpSum / (XH.timeRange),
					XH.SecondsToTime( rateStruct.toGo/(XH.xpSum/XH.timeRange) )));
			--XH.Print(collectgarbage("count"));
			XH.xpSumOld = XH.xpSum;
		end
		if (XH.xpSum > 0) then
			--XH.Print(rateStruct.toGo..":"..XH.xpSum..":"..XH.timeRange);
			return ((XH.mostRecentTS-XH.startTS)>0) and XH.xpSum / (XH.timeRange) or 0,
					rateStruct.toGo/(XH.xpSum/XH.timeRange),
					XH.xpSum;
		end
	end
	return 0, 0, 0;
end

-- returns rate/second, and expected remaining time
function XH.Rate( rateStruct )
	XH.r = rateStruct.gained / max((time() - rateStruct.start), XH.minRateTime);  -- not using local to avoid garbage collection
	if rateStruct.toGo then
		return XH.r, rateStruct.toGo / XH.r;
	end
	return XH.r;
end
function XH.UpdateRepBarText()
	if (XH.repProgress) then
		if XH.GetFactionInfo( XH.repProgress ) then  -- checks first return (name)
			_, XH.remainingTime = XH.Rate2(XH.repGains.session[XH.repProgress]);

--			if (_>0) and (XH.lastPrinted and (time()>=XH.lastPrinted+30)) or (not XH.lastPrinted) then
--				XH.Print(format("%s: %0.2fr/s : %s -> %s",
--					XH.repProgress, _, XH.SecondsToTime(XH.remainingTime),
--					date(XH.MakeTimeFormat(XH.remainingTime),XH.remainingTime+time())));
--				XH.lastPrinted = time();
--			end
			XH.repStr = format(XH.repStrFmt, XH.SecondsToTime(XH.remainingTime));
			XH_RepText:SetText(XH.repStr);
		end
	end
end
function XH.RepReport( repTable, title, chatType )
	-- set a table to report from
	if not XH.FACTION_STANDING_INCREASED then
		XH.FACTION_STANDING_INCREASED = FACTION_STANDING_INCREASED .. " %s %d / %d (%0.2f%%)";
	end
	if not XH.FACTION_STANDING_DECREASED then
		XH.FACTION_STANDING_DECREASED = FACTION_STANDING_DECREASED .. " %s %d / %d (%0.2f%%)";
	end
	if repTable then
		if title then XH.Print( title ); end
		for fac, rateStruct in pairs( repTable ) do
			rep = rateStruct.gained;
			if rep then
				fmt = XH.FACTION_STANDING_INCREASED;
				if (rep<0) then fmt = XH.FACTION_STANDING_DECREASED; end
				local name, description, standingStr, barBottomValue, barTopValue, barEarnedValue, atWarWith,
						canToggleAtWar, isHeader, isCollapsed, isWatched, factionIndex = XH.GetFactionInfo( fac );
				if name then
					lineOut = format(fmt, fac, abs(rep), standingStr, barEarnedValue, barTopValue, (barEarnedValue/barTopValue)*100);
					if strlen(chatType)>0 then
						SendChatMessage(lineOut, chatType, nil);
					else
						XH.Print(lineOut, false);    -- supress addon message
					end
				end
			end
		end
	end
end

-- Instance whispers
function XH.GetWhisper( frame, event, message, ...)
	whoFrom = select(1, ...);
	--if (XH.name == whoFrom) then
	if (XH.name == whoFrom or not (UnitInParty(whoFrom) or UnitInRaid(whoFrom))) then
		if (XH_zoneTracker) then
			if (XH_zoneTracker.whisperPeople) then
				if (not XH_zoneTracker.whisperPeople[whoFrom]) then  -- Not had a whisper from
					XH_zoneTracker.whisperPeople[whoFrom] = 2;
				end
			else
				XH_zoneTracker.whisperPeople = {[whoFrom]=2};
			end
--[[
			for name, i in pairs(XH_zoneTracker.whisperPeople) do
				XH.Print(format("%s: %s", i, name));
			end
]]--
		end
		XH.SendInInstanceReply();
	end
end
function XH.SendInInstanceReply()
	XH.Print("SendInInstanceReply");
	if (XH_zoneTracker and XH_zoneTracker.whisperPeople and XH_zoneTracker.finish==0) then
		XH.Print("Haz ZoneTracker, and not done");
		local linesOut = {};
		table.insert(linesOut,format("I'm in %s for the last %s with %s bosses down.",
				XH_zoneTracker.zoneName, XH.SecondsToTime(time()-XH_zoneTracker.start), XH_zoneTracker.bossProgressText));
		--table.insert(linesOut,"Line2");
		for name, val in pairs(XH_zoneTracker.whisperPeople) do
			if (val==2) then
				XH_zoneTracker.whisperPeople[name] = 0;
				for i,lineOut in ipairs(linesOut) do
					SendChatMessage(lineOut, "WHISPER", nil, name);
				end
			end
		end
	end
end
function XH.SendInstanceUpdates(msg)
	XH.Print("SendInstanceUpdates: "..msg);
	for name, val in pairs(XH_zoneTracker.whisperPeople) do
		XH_zoneTracker.whisperPeople[name] = 1;
	end
end
function XH.Test()
	if (XHInstanceList:IsVisible()) then
		XHInstanceList:Hide();
		XH.Print("Hiding");
	else
		XHInstanceList:Show();
		XH.Print("Showing");
	end
end
function tableLen( t )
	count = 0;
	for x in pairs(t) do
		count = count +1;
	end
	return count;
end

-- Time played
function XH.TimePlayedMsg(event, arg1, arg2, ...)  -- for TIME_PLAYED_MSG - total, current lvl
	--XH.Print("Time Played: "..event..":"..SecondsToTime(arg1)..":"..SecondsToTime(arg2));
	if XH.ding and XH.ding > 0 then
		XH.Print("Total time: "..arg1.." to level "..XH.ding..".");
		XH_playedByLevel[XH.ding-1] = arg1;  -- Store time in that level.  ding is the new level
		XH.ding = nil;
	end
	local displayCount = 5;  -- how many of the last levels to show
	-- sort does not seem to work.  Want to display this is ascending order.
	local minLvl, maxLvl = 200, 1;  -- find the min and max recorded levels
	for lvl in pairs(XH_playedByLevel) do
		minLvl = min(minLvl, lvl);
		maxLvl = max(maxLvl, lvl);
	end
	local lastShown = XH_playedByLevel[max(maxLvl-displayCount, minLvl)];
	for lvl=max(maxLvl-displayCount+1, minLvl), maxLvl do
		local current = XH_playedByLevel[lvl];
		if current ~= nil then
			local elapsed = current - lastShown;
			XH.Print(string.format("Level %s in : %s (%s)", lvl+1, SecondsToTime(current), SecondsToTime(elapsed)));
		end
		lastShown = current;
	end
end

