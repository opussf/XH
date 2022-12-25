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

function XH.OnLoad()
	-- register events
	XHFrame:RegisterEvent( "ADDON_LOADED" )
	XHFrame:RegisterEvent( "VARIABLES_LOADED" )
	XHFrame:RegisterEvent( "UPDATE_EXHAUSTION" )
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
end
function XH.VARIABLES_LOADED()
	XH.startedTime = time()

	XH_Gains = XH_Gains or {}
	if not XH_Gains[XH.playerSlug] then
		XH_Gains[XH.playerSlug] = {
			["xp_session"] = {},
			["xp_instance"] = {},
			["kills_session"] = {},
			["kills_instance"] = {}
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

	-- Hmmm
	--XH.Print(XH.EXP_GAIN_TEXT..":"..XH.RESTED_GAIN_TEXT);
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














