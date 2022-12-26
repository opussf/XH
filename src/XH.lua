XH_SLUG, XH = ...
XH_MSG_ADDONNAME = GetAddOnMetadata( XH_SLUG, "Title" )
XH_MSG_AUTHOR    = GetAddOnMetadata( XH_SLUG, "Author" )
XH_MSG_VERSION   = GetAddOnMetadata( XH_SLUG, "Version" )

-- Colours
COLOR_RED = "|cffff0000"
COLOR_GREEN = "|cff00ff00"
COLOR_BLUE = "|cff0000ff"
COLOR_PURPLE = "|cff700090"
COLOR_YELLOW = "|cffffff00"
COLOR_ORANGE = "|cffff6d00"
COLOR_GREY = "|cff808080"
COLOR_GOLD = "|cffcfb52b"
COLOR_NEON_BLUE = "|cff4d4dff"
COLOR_END = "|r"

--[[
XH.rateGraph={[0]="_",[1]=".",[2]="·",[3]="-",[4]="^"};
XH.rateGraph={[0]="_",[1]="░",[2]="▒",[3]="▓",[4]="█"};
]]

XH.lastUpdate = 0

function XH.OnLoad()
	-- register events
	XHFrame:RegisterEvent( "ADDON_LOADED" )
	XHFrame:RegisterEvent( "VARIABLES_LOADED" )
	XHFrame:RegisterEvent( "UPDATE_EXHAUSTION" )
	-- Do this later
	XHFrame:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED" )


	--XHFrame:RegisterEvent( "PLAYER_XP_UPDATE" )
	ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", XH.XPGainEvent)
	-- register slash commands
	-- get char data
	XH.name = UnitName( "player" )
	XH.realm = GetRealmName()
	XH.playerSlug = XH.realm.."-"..XH.name
	XH.faction = select( 2, UnitFactionGroup( "player" ) )  -- localized string
end

-- event handling
function XH.ADDON_LOADED()
	XHFrame:UnregisterEvent( "ADDON_LOADED" )
	XH.InitBars()
end
function XH.VARIABLES_LOADED()
	XH.startedTime = time()

	XH_Gains = XH_Gains or {}
	if not XH_Gains[XH.playerSlug] then
		XH_Gains[XH.playerSlug] = {
			["xp_session"] = XH.InitRate( 0, UnitXPMax("player") - UnitXP("player") ),
			["xp_instance"] = XH.InitRate( 0, UnitXPMax("player") - UnitXP("player") ),
			--["kills_session"] = {},
			--["kills_instance"] = {}
		}
	end

	XH.me = XH_Gains[XH.playerSlug]
	XH.UPDATE_EXHAUSTION()
	XH.xpNow = UnitXP( "player" )
end
function XH.UPDATE_EXHAUSTION()
	-- update XH.restedPC to the correct value
	XH.rested = GetXPExhaustion() or 0  -- XP till Exhaustion
	XH.restedPC = (XH.rested / UnitXPMax("player")) * 100
	XH.xpNow = UnitXP( "player" )

	print(string.format("Rested @%d: %s (%0.2f%%)",time(),XH.rested, XH.restedPC))
end
function XH.COMBAT_LOG_EVENT_UNFILTERED( )
	local ets, subEvent, _, sourceID, sourceName, sourceFlags, sourceRaidFlags,
			destID, destName, destFlags, _, spellID, spName, _, ext1, ext2, ext3 = CombatLogGetCurrentEventInfo()
	if( subEvent and subEvent == "PARTY_KILL") then
		print( ets, subEvent, sourceName, destName )
	end
	-- if (arg2 and arg2 == "UNIT_DIED") then
	-- 	print( "Unit Died: ", arg9, arg8)
	-- end
end

function XH.OnUpdate()  -- use XH_ since it is referenced outside of this file (before the XH. is created)
	if (time() < XH.lastUpdate + 1) then	-- short cut out
		return
	end
	XH.lastUpdate = time()
	XH.UpdateBars()
end


--
function XH.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_RED..XH_MSG_ADDONNAME.."> "..COLOR_END..msg;
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg );
end
-- Converts string.format to a string.find pattern: "%s hits %s for %d." to "(.+) hits (.+) for (%d+)"
-- based on Recap by Gello
function XH.FormatToPattern(formatString)
	local patternString = formatString

	patternString = string.gsub(patternString, "%%%d+%$([diouXxfgbcsq])", "%%%1") -- reordering specifiers (e.g. %2$s) stripped
	patternString = string.gsub(patternString, "([%$%(%)%.%[%]%*%+%-%?%^])", "%%%1") -- convert regex special characters

	patternString = string.gsub(patternString, "%%c", "(.)") -- %c to (.)
	patternString = string.gsub(patternString, "%%s", "(.+)") -- %s to (.+)
	patternString = string.gsub(patternString, "%%[du]", "(%%d+)") -- %d to (%d+)
	patternString = string.gsub(patternString, "%%([gf])", "(%%d+%%.*%%d*)") -- %g or %f to (%d+%.*%d*)

	return patternString
end
-- XP Code
function XH.XPGainEvent( frame, event, message, ... )
	if not message then
		return
	end
	--XH.Print(event..":"..message)

	if (not XH.EXP_GAIN_TEXT) then
		XH.EXP_GAIN_TEXT = XH.FormatToPattern(COMBATLOG_XPGAIN_FIRSTPERSON)
	end
	if (not XH.RESTED_GAIN_TEXT) then
		XH.Print(COMBATLOG_XPGAIN_EXHAUSTION1)
		local _, _, restedstr = string.find(COMBATLOG_XPGAIN_EXHAUSTION1, "%(%%s(.*)%)")
		restedstr = "%d"..restedstr
		--XH.Print(restedstr)
		XH.RESTED_GAIN_TEXT = XH.FormatToPattern( restedstr )
	end
	XH.xpGain = nil;
	_, _, XH.mobName, XH.xpGain = string.find(message, XH.EXP_GAIN_TEXT);
	if (not XH.xpGain) then  -- xpgain is not from combat
		--XH.Print("No xpGain", false)
		if (not XH.XPGAIN_QUEST) then
			XH.XPGAIN_QUEST = XH.FormatToPattern("You gain %d experience")
		end
		--XH.Print(XH.XPGAIN_QUEST)
		_,_,XH.xpGain = string.find(message, XH.XPGAIN_QUEST);
		--XH.Print("xpGain:"..XH.xpGain);
	end

	XH.Print( string.format("%s (%s)", XH.xpGain, ""))
	-- Hmmm
	--XH.Print(XH.EXP_GAIN_TEXT..":"..XH.RESTED_GAIN_TEXT);
	for counter, gainStruct in pairs(XH.me) do
		if( gainStruct.gained ) then
			gainStruct.gained = gainStruct.gained + XH.xpGain
			gainStruct.lastGained  = XH.xpGain
			gainStruct.toGo = UnitXPMax("player") - UnitXP("player")
			local now = time()
			gainStruct.rolling[now] = ( gainStruct.rolling[now] and gainStruct.rolling[now] + XH.xpGain )
					or XH.xpGain
		else
			XH_XPGains[counter] = XH.InitRate( XH.xpGain, UnitXPMax("player") - UnitXP("player") )
		end
		print( counter, gainStruct )
	end
	-- for counter, gain in pairs(XH_XPGains) do
	-- 	if (gain.gained) then
	-- 		gain.gained = gain.gained + XH.xpGain;
	-- 		gain.lastGained = XH.xpGain;
	-- 		gain.toGo = UnitXPMax("player") - UnitXP("player");  -- this needs to happen for lvling
	-- 		local now = time();

	-- 		XH_XPGains[counter].rolling[now] =
	-- 			(XH_XPGains[counter].rolling[now] and XH_XPGains[counter].rolling[now] + XH.xpGain) -- entry exists
	-- 			or XH.xpGain;  -- extry does not exist
	-- 	else  -- odd.  Cannot do gain={}.  seems to fail
	-- 		XH_XPGains[counter] = XH.InitRate(xpGain, UnitXPMax("player") - UnitXP("player"));
	-- 	end
	-- end
end

function XH.InitRate( gainedValue, toGo )
	return {
			["gained"] = gainedValue,
			["start"] = time(),
			["lastGained"] = gainedValue,
			["toGo"] = toGo,
			["rolling"] = {[time()] = gainedValue},
	}
end

function XH.UpdateXPBarText(self)
	XH.xps, XH.timeToGo, XH.gained = XH.Rate2( XH_XPGains.session );

	if (XH.gained) and (XH.gained > 0) and (not XH.mouseOver) then
--		XH.xps, XH.timeToGo = XH.Rate( XH_XPGains.session );
		--XH.Text = format("%d XP in %s (%0.2f xp/s) %s to go. (%0.1f FPS)",
		--		XH_XPGains.session.gained, XH.SecondsToTime(time()-XH_XPGains.session.start),
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
		if (XH_XPGains.session.gained and XH_XPGains.session.gained > 0) then
			XH.Text = format("%s xp (%0.2f bubbles) in %s (%0.1f FPS)",
					XH_XPGains.session.gained, (XH_XPGains.session.gained / XH.bubbleSize), XH.Text, GetFramerate());
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
				--XH_XPGains.session.rolling[key] = nil;
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
			--local timeRemain = XH_XPGains.session.toGo / rate;
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











