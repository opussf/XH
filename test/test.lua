#!/usr/bin/env lua

require "wowTest"

-- RestedOptionsFrame_NagTimeSliderText = CreateFontString()
-- RestedOptionsFrame_NagTimeSlider = CreateFrame()
-- RestedFrame = CreateFrame()
-- RestedUIFrame = CreateFrame()
-- RestedUIFrame_TitleText = CreateFontString()
-- RestedScrollFrame_VSlider = CreateFrame()
-- RestedUIFrame_TitleText = CreateFontString()

ParseTOC( "../src/XH.toc" )

test.outFileName = "testOut.xml"

-- addon setup
function test.before()
	XH.OnLoad()
end
function test.after()
end
function test.showCharList()
	--if true then return end
	table.sort( Rested.charList, function( a, b ) return( a[1] > b[1] ); end )
	for k,v in pairs( Rested.charList ) do
		print( k..": "..v[1]..":-:"..v[2] )
	end
end
function test.test_printHelp()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.HelpReport )
	test.showCharList()
end
-- VARIABLES_LOADED Inits data
function test.test_maxLevel_set()
	-- account max level is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertTrue( Rested_misc["maxLevel"] )
end
function test.test_RealmLevelCreated()
	-- current realm table is added if it does not exist.
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertTrue( Rested_restedState["testRealm"] )
end
function test.test_RealmLevelPreserved()
	-- do not overwrite a previous realm table
	Rested_restedState["testRealm"] = {["aPlayer"] = {["initAt"]=6372 }}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( 6372, Rested_restedState["testRealm"]["aPlayer"].initAt )
end
function test.test_PlayerLevelCreated()
	-- current player table is added if it does not exist.
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
end
function test.test_PlayerLevelPreserved()
	-- do not overwrite a previous player table
	Rested_restedState["testRealm"] = {["testPlayer"] = {["initAt"]=6372 }}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( 6372, Rested_restedState["testRealm"]["testPlayer"].initAt )
end
function test.test_PlayerClassIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Warlock", Rested_restedState["testRealm"]["testPlayer"].class )
end
function test.test_PlayerClassIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["class"]="Warrior"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Warlock", Rested_restedState["testRealm"]["testPlayer"].class )
end
function test.test_PlayerFactionIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Alliance", Rested_restedState["testRealm"]["testPlayer"].faction )
end
function test.test_PlayerFactionIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["faction"]="Horde"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Alliance", Rested_restedState["testRealm"]["testPlayer"].faction )
end
function test.test_PlayerRaceIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Human", Rested_restedState["testRealm"]["testPlayer"].race )
end
function test.test_PlayerRaceIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["race"]="Orc"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Human", Rested_restedState["testRealm"]["testPlayer"].race )
end
function test.test_PlayerGenderIsSet()
	-- player class is set
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Female", Rested_restedState["testRealm"]["testPlayer"].gender )
end
function test.test_PlayerGenderIsReset()
	-- player class is reset - always over write this - many paths to this state
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["gender"]="Male"}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( "Female", Rested_restedState["testRealm"]["testPlayer"].gender )
end
function test.testPlayerUpdatedIsSet()
	-- this should always be updated.
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( time(), Rested_restedState["testRealm"]["testPlayer"].updated )
end
function test.testPlayerUpdatedIsUpdated()
	-- this should always be updated.
	Rested_restedState["testRealm"] = {["testPlayer"] =
			{["initAt"]=6372,["updated"]=6372}}
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( time(), Rested_restedState["testRealm"]["testPlayer"].updated )
end
function test.testPlayerIgnoreIsCleared()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["ignore"] = time() + 3600 } }
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertIsNil( Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
-- other base functions
-- FormatName
function test.test_FormatName_CurrentToon()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "testRealm", "testPlayer" )
	assertEquals( COLOR_GREEN.."testRealm:testPlayer"..COLOR_END, rn )
end
function test.test_FormatName_CurrentToon_noColor()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "testRealm", "testPlayer", false )
	assertEquals( "testRealm:testPlayer", rn )
end
function test.test_FormatName_DiffRealm()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "otherRealm", "testPlayer" )
	assertEquals( "otherRealm:testPlayer", rn )
end
function test.test_FormatName_DiffName()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "testRealm", "otherPlayer" )
	assertEquals( "testRealm:otherPlayer", rn )
end
function test.test_FormatName_DiffRealm_DiffName()
	Rested.ADDON_LOADED()
	rn = Rested.FormatName( "otherRealm", "otherPlayer" )
	assertEquals( "otherRealm:otherPlayer", rn )
end
-- ForAllChars
function test.returnOne( realm, name, cstruct )
	return 1
end
function test.test_ForAllChars_returnsCount()
	now = time()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 2, result )
end
function test.test_ForAllChars_returnsCount_ignoreChar()
	now = time()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 1, result )
end
function test.test_ForAllChars_returnsCount_includeIgnoreChar()
	now = time()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( test.returnOne, true )
	assertEquals( 2, result )
end

-- Filter
function test.test_ForAllChars_filter_lvlNow_ignored()
	now = time()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = 10
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 0, result )
end
function test.test_ForAllChars_filter_lvlNow_includeIgnoreChar_10()
	now = time()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = 10
	result = Rested.ForAllChars( test.returnOne, true )
	assertEquals( 1, result )
end
function test.test_ForAllChars_filter_lvlNow_includeIgnoreChar_2()
	now = time()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = 2
	result = Rested.ForAllChars( test.returnOne )
	assertEquals( 1, result )
end
function test.test_ForAllChars_callBack_returnsNil()
	now = time()
	Rested_restedState = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = time()+3600 } }
	Rested.filter = nil
	result = Rested.ForAllChars( function() end, true )
	assertEquals( 0, result )
end
-- Event callbacks
-- InitCallback
function test.test_InitCallback_RegisterdAndCalledFromVARIABLES_LOADED()
	Rested.miscVariable = nil
	Rested.InitCallback( function() Rested.miscVariable = 19; end )
	assertIsNil( Rested.miscVariable )
	Rested.ADDON_LOADED()
	assertIsNil( Rested.miscVariable )
	Rested.VARIABLES_LOADED()
	assertEquals( 19, Rested.miscVariable )
end
-- EventCallBack
function test.test_EventCallback_RegistersEvent()
	-- calling EventCallback registers the event
	Rested.EventCallback( "NONSENSE_EVENT", function() Rested.nonsense=42; end )
	assertTrue( RestedFrame.Events["NONSENSE_EVENT"] )
end
function test.test_EventCallback_RegistersEvent_notADDON_LOADED()
	-- don't allow this function / event to be registered
	assertIsNil( Rested.EventCallback( "ADDON_LOADED", function() Rested.nonsense=19; end ) )
end
function test.test_EventCallback_RegisterEvent_notVARIABLES_LOADED()
	-- don't allow this function / event to be registered
	assertIsNil( Rested.EventCallback( "VARIABLES_LOADED", function() Rested.nonsense=19; end ) )
end
function test.test_EventCallback_EventAddedTo_eventFunctions()
	Rested.eventFunctions["EVENT_ADDED"] = nil
	Rested.EventCallback( "EVENT_ADDED", function() return; end )
	assertTrue( Rested.eventFunctions["EVENT_ADDED"] )
end
function test.test_EventCallback_CreatesFunction()
	Rested.EVENT_FUNCTION = nil
	Rested.EventCallback( "EVENT_FUNCTION", function() return; end )
	assertTrue( Rested.EVENT_FUNCTION )
end
function test.test_EventCallback_2functions()
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.bleh5=48; end )
	Rested.EventCallback( "PLAYER_ENTERING_WORLD", function() Rested.yonks=49; end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 48, Rested.bleh5 )
	assertEquals( 49, Rested.yonks )
end
function test.test_EventCallback_noADDON_LOADED()
	Rested.EventCallback( "ADDON_LOADED", function() Rested.bleh2=37; end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertIsNil( Rested.bleh2 )
end
function test.test_EventCallback_noVARIABLES_LOADED()
	Rested.EventCallback( "VARIABLES_LOADED", function() Rested.lala=96; end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertIsNil( Rested.lala )
end
function test.test_EventCallback_EventTakesParameter()
	Rested.EventCallback( "WITH_PARAM", function( thing ) Rested.bleh6=thing; end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.WITH_PARAM( "ThisParam" )
	assertEquals( "ThisParam", Rested.bleh6 )
end

-- OnUpdate
function test.test_OnUpdate_registerCallBack()
	-- the OnUpdate 'event' should be special as it is not an event from the API
	originalOnUpdateFunctions = Rested.onUpdateFunctions
	Rested.onUpdateFunctions = {}
	local testFunc = function() return( { [0] = { "0 reminder", } } ) end
	Rested.OnUpdateCallback( testFunc )
	for k, f in pairs( Rested.onUpdateFunctions ) do
		if f == testFunc then
			found = true
		end
	end
	Rested.onUpdateFunctions = originalReminderFunctions
	assertTrue( found )
end
function test.test_OnUpdate_callOnUpdate()
	originalOnUpdateFunctions = Rested.onUpdateFunctions
	Rested.onUpdateFunctions = {}
	Rested.OnUpdateCallback( function() Rested.updated = time(); end )
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.OnUpdate()
	assertTrue( Rested.updated )
end
-- Reminders
function test.test_Reminders_registerCallBack()
	local testFunc = function() return( { [0] = { "0 reminder", } } ) end
	Rested.ReminderCallback( testFunc )
	for k, f in pairs( Rested.reminderFunctions ) do
		if f == testFunc then
			found = true
		end
	end
	assertTrue( found )
end
function test.test_Reminders_makeReminderSchedule_oneChar()
	originalReminderFunctions = Rested.reminderFunctions
	Rested.reminderFunctions = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time() } }
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	Rested.reminderFunctions = originalReminderFunctions
	assertEquals( "testPlayer-testRealm is resting.", Rested.reminders[0][1] )
end
function test.test_Reminders_makeReminderSchedule_badReturnStruct()
	-- test if the reminder function does not return an expected table
	originalReminderFunctions = Rested.reminderFunctions
	Rested.reminderFunctions = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isRested"] = true, ["updated"] = time() } }
	Rested.ReminderCallback( function() return true; end )
	Rested.MakeReminderSchedule()
	Rested.reminderFunctions = originalReminderFunctions
	assertEquals( 0, #Rested.reminders )
end
function test.test_Reminders_makeReminderSchedule_oneChar_isIgnored()
	-- ignored char should not show up in reminders
	originalReminderFunctions = Rested.reminderFunctions
	Rested.reminderFunctions = {}
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time(), ["ignore"] = time()+60 } }
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	Rested.reminderFunctions = originalReminderFunctions
	assertIsNil( Rested.reminders[0] )
end
function test.test_Reminders_PrintReminders()
	-- test that the current reminder is processed
	-- the reminders that are printed are removed from the table
	now = time()
	Rested.reminders = { [now] = { "Reminder", "Another" }, [now+5] = { "Future" }, [now-5] = { "Past" } }
	Rested.PrintReminders()
	assertIsNil( Rested.reminders[now] )   -- primary test
	assertTrue( Rested.reminders[now+5] )  -- These are secondary tests only
	assertIsNil( Rested.reminders[now-5] )
end

-- ignore code
function test.test_Ignore_SetIgnore_name()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore testplayer" )
	assertEquals( time()+ 604800, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_realm()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore otherrealm" )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_partial()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore rp" )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_dot()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore ." )
	assertEquals( time()+ 604800, Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
	assertEquals( time()+ 604800, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.notest_Ignore_SetIgnore_noParam()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore" )
	assertIsNil( Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
	assertIsNil( Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.notest_Ignore_clearIgnore_TiedTo_PLAYER_ENTERING_WORLD()
	-- TODO:  Fix this
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600, ["ignore"] = now-5 } }
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertIsNil( Rested_restedState["otherRealm"]["otherPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_60seconds()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 60" )
	assertEquals( time() + 60, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_minute()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 1m" )
	assertEquals( time() + 60, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_minute_setsOption()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 5m" )
	assertEquals( 300, Rested_options.ignoreTime )
end
function test.test_Ignore_SetIgnore_name_withTime_hour()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 1h" )
	assertEquals( time() + 3600, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_day()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 1d" )
	assertEquals( time() + 86400, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_week()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 1w" )
	assertEquals( time() + 604800, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_name_withTime_1year()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore Player 52w" )
	assertEquals( time() + 31449600, Rested_restedState["testRealm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_realm_withSpace_withTime()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore test Realm 1d" )
	assertEquals( time() + 86400, Rested_restedState["test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_realm_withSpace_withComplexTime()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore test Realm 1d12h" )
	assertEquals( time() + 129600, Rested_restedState["test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_SetIgnore_realm_withSpace_withComplexTimeWithSpaces()
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "ignore test Realm 1d 12h" )
	assertEquals( time() + 129600, Rested_restedState["test Realm"]["testPlayer"]["ignore"] )
end
function test.test_Ignore_IgnoreReport_ShortTime()
	-- the ignore report changes based on how long the char is ignored for.
	now = time()
	Rested_options = { ["ignoreTime"] = 604800, ["ignoreDateLimit"] = 7776000 }  -- 7 days and 90 days
	Rested_restedState["test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.VARIABLES_LOADED()
	Rested.Command( "ignore test Realm 1d 12h" )
	assertEquals( time() + 129600, Rested_restedState["test Realm"]["testPlayer"]["ignore"] )

	Rested.ForAllChars( Rested.IgnoredCharacters, true )  -- need to report on ignored toons
	test.showCharList()
	assertEquals( 1, #Rested.charList, "There should be 1 entry" )
	assertEquals( "1 Day 12 Hr: test Realm:testPlayer", Rested.charList[1][2] )
end
function test.test_Ignore_IgnoreReport_LongTime()
	-- the ignore report changes based on how long the char is ignored for.
	now = time()
	Rested_options = { ["ignoreTime"] = 604800, ["ignoreDateLimit"] = 7776000 }  -- 7 days and 90 days
	Rested_restedState["test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.VARIABLES_LOADED()
	Rested.Command( "ignore test Realm 100d" )
	assertEquals( time() + 8640000, Rested_restedState["test Realm"]["testPlayer"]["ignore"] )

	Rested.ForAllChars( Rested.IgnoredCharacters, true )  -- need to report on ignored toons
	test.showCharList()
	assertEquals( 1, #Rested.charList, "There should be 1 entry" )
	expected = string.format( "%s: test Realm:testPlayer", date( "%x %X", now + 8640000 ) )
	assertEquals( expected, Rested.charList[1][2] )
end
function test.test_Ignore_IgnoreReport_LongTime_noOptionSet()
	-- the ignore report changes based on how long the char is ignored for.
	now = time()
	Rested_options = { ["ignoreTime"] = 604800 }  -- 7 days
	Rested_restedState["test Realm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.VARIABLES_LOADED()
	Rested.Command( "ignore test Realm 100d" )
	assertEquals( time() + 8640000, Rested_restedState["test Realm"]["testPlayer"]["ignore"] )

	Rested.ForAllChars( Rested.IgnoredCharacters, true )  -- need to report on ignored toons
	test.showCharList()
	assertEquals( 1, #Rested.charList, "There should be 1 entry" )
	expected = string.format( "%s: test Realm:testPlayer", date( "%x %X", now + 8640000 ) )
	assertEquals( expected, Rested.charList[1][2] )
end
-- Rested.me
function test.test_RestedMe_isSet()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	assertEquals( Rested_restedState["testRealm"]["testPlayer"], Rested.me, "Rested.me should be set, and point to the current toon." )
end

-- FormatRested
function test.test_FormatRested_restedOutStr_useInitAt()
	charStruct = {["initAt"] = time() - 3600 }
	outStr, rVal, code, timeTill = Rested.FormatRested( charStruct )
	assertEquals( "0.2%", outStr )
	assertEquals( "-", code )
end
function test.test_FormatRested_restedOutStr_noInitAt()
	charStruct = {}
	outStr, rVal, code, timeTill = Rested.FormatRested( charStruct )
	assertEquals( "|cff00ff00Fully Rested|r", outStr )
	assertIsNil( timeTill )
end
function test.test_FormatRested_restedOutStr_isResting()
	charStruct = {["isResting"] = true}
	outStr, rVal, code, timeTill = Rested.FormatRested( charStruct )
	assertEquals( "|cff00ff00Fully Rested|r", outStr )
	assertEquals( "+", code )
end
function test.test_FormatRested_restedValue_beyondCurrentLevel()
	charStruct = {["initAt"] = time() - 14400, ["isResting"] = true, ["xpNow"] = 98, ["xpMax"] = 100 }
	outStr, rVal, code, timeTill = Rested.FormatRested( charStruct )
	assertEquals( "|cff00ff002.5%|r", outStr )
	assertEquals( "+", code )
	assertEquals( 2.5, rVal )
end

-- Mounts
--require "RestedMounts"
function test.test_Mounts_Report_SingleMount_halfLife()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-30] = "Garn Nighthowl",
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Report_SingleMount_Recent()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()] = "Garn Nighthowl",
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 150, Rested.charList[1][1] )
end
function test.test_Mounts_Report_SingleMount_Oldest()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-59] = "Garn Nighthowl",
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 2.5, Rested.charList[1][1] )
end
function test.test_Mounts_Report_NoMounts()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 0, #Rested.charList )
end
function test.test_Mounts_Report_TwoMounts_Same()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-59] = "Garn Nighthowl", [time()-30] = "Garn Nighthowl"
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Report_TwoMounts_Diff()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-60] = "Garn Nighthowl", [time()-30] = "Other Mount"
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Report_TwoMounts_TooOldMount()
	now = time()
	Rested_options.mountHistoryAge = 60
	Rested_misc = { ["mountHistory"] = { [time()-120] = "Garn Nighthowl", [time()-30] = "Other Mount"
		} }
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }

	Rested.ForAllChars( Rested.MountReport )

	test.showCharList()
	assertEquals( 1, #Rested.charList )
	assertEquals( 75, Rested.charList[1][1] )
end
function test.test_Mounts_Set_HistoryAge_Day()
	Rested_options.mountHistoryAge = 259200
	Rested.Command( "setMountAge 1d" )
	assertEquals( 86400, Rested_options.mountHistoryAge )
end

-- remove
function test.test_Remove_oneAlt()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["testRealm"]["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm otherPlayer" )
	assertIsNil( Rested_restedState["testRealm"]["otherPlayer"] )
end
function test.test_Remove_pruneEmptyRealm()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "rm otherPlayer" )
	assertIsNil( Rested_restedState["otherRealm"] )
end
function test.test_Remove_notCurrentToon()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.Command( "rm testPlayer" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
end
function test.test_Remove_withRealm()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-otherRealm" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["otherRealm"]["testPlayer"] )
end
function test.test_Remove_withRealm_colon()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer:otherRealm" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["otherRealm"]["testPlayer"] )
end
function test.test_Remove_realmWithSpace()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["other Realm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["other Realm"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-other Realm" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["other Realm"]["testPlayer"] )
end
function test.test_Remove_realmWithPunc()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-blade's edge" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["Blade's Edge"]["testPlayer"] )
end
function test.test_Remove_realmWithPunc_incomplete()
	Rested.ADDON_LOADED()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["Blade's Edge"]["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 }
	Rested.Command( "rm testPlayer-blade" )
	assertTrue( Rested_restedState["testRealm"]["testPlayer"] )
	assertIsNil( Rested_restedState["Blade's Edge"]["testPlayer"] )
end

-- set nag time
function test.test_NagTime_Set_Day()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 1d" )
	assertEquals( 86400, Rested_options.nagStart )
end
function test.test_NagTime_Set_Day_defaultUnit()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 1" )
	assertEquals( 86400, Rested_options.nagStart )
end
function test.test_NagTime_Set_Hour()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 1h" )
	assertEquals( 3600, Rested_options.nagStart )
end
function test.test_NagTime_Set_2Values()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 1d1m" )
	assertEquals( 86460, Rested_options.nagStart )
end
function test.test_NagTime_Set_CannotBeGreaterThanStale()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 10d1m" )
	assertEquals( 604800, Rested_options.nagStart )
end
function test.test_NagTime_Set_CanBeEqualToStale()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 10d" )
	assertEquals( 864000, Rested_options.nagStart )
end
function test.test_NagTime_Set_EmptyDoesNotChange()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag" )
	assertEquals( 7 * 86400, Rested_options.nagStart )
end
function test.test_NagTime_Set_SetToZero()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setNag 0" )
	assertEquals( 7 * 86400, Rested_options.nagStart )
end

-- set stale time
function test.test_StaleTime_Set_Day()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 9d" )
	assertEquals( 777600, Rested_options.staleStart )
end
function test.test_StaleTime_Set_Day_defaultUnit()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 12" )
	assertEquals( 1036800, Rested_options.staleStart )
end
function test.test_StaleTime_Set_Week()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 2w" )
	assertEquals( 1209600, Rested_options.staleStart )
end
function test.test_StaleTime_Set_CannotBeLessThanNag()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 5d" )
	assertEquals( 864000, Rested_options.staleStart )
end
function test.test_StaleTime_Set_CanBeEqualToNag()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested.Command( "setstale 7d" )
	assertEquals( 604800, Rested_options.staleStart )
end
function test.test_StaleTime_Set_EmptyDoesNotChange()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 864000
	Rested.Command( "setstale" )
	assertEquals( 8640000, Rested_options.staleStart )
end


-- Professions
--require "RestedProfessions"
function test.test_Profession_01()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.SaveProfessionInfo()
end

-- gold
--require "RestedGold"
function test.before_gold()
	oldMyCopper = myCopper
end
function test.after_gold()
	myCopper = 0
end
function test.test_Gold_01()
	test.before_gold()
	myCopper = 847394
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()
	Rested.PLAYER_ENTERING_WORLD()

	Rested.SaveGold()
	assertEquals( 847394, Rested_restedState["testRealm"]["testPlayer"].gold )
	test.after_gold()
end
function test.test_Gold_Report_01()
	test.before_gold()

	--Rested.ADDON_LOADED()
	--Rested.VARIABLES_LOADED()
	--Rested.PLAYER_ENTERING_WORLD()

	Rested_restedState = nil
	Rested_restedState = {}
	Rested_restedState["goldRealm"] = { ["goldPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = time(), ["gold"] = 872648 } }

	Rested.ForAllChars( Rested.GoldReport )
	assertEquals( "87g 26s 48c :: goldRealm:goldPlayer", Rested.charList[1][2] )
	test.after_gold()
end

-- Rested Export tests
function myPrint( str )
	stdOut = stdOut or {}
	table.insert( stdOut, str )
end
function test.test_Export_01()
	stdOut = nil
	originalPrint = print
	print = myPrint
	arg = {"./", "json"}
	loadfile( "../src/Rested_Export.lua" )() -- Rested_Export reads from arg, not actually the parameters passed
--	for _,v in pairs( stdOut ) do
--		originalPrint( v )
--	end
	print = originalPrint
	--print( strOut )
end

--[[


originalPrint = print
out = {}
function print( str )
	table.insert( out, str )
	originalPrint( str )
end
arg = {"./","json"}
local X = loadfile( "../src/Rested_Export.lua" )()  -- Rested_Export reads from arg, not actually the parameters passed

originalPrint( #out )

arg = {"./", "xml"}
loadfile( "../src/Rested_Export.lua" )()  -- Rested_Export reads from arg, not actually the parameters passed
]]

--[[

-- core data


function test.notest_Reminders_makeReminders_noMaxLvl()
	now = time()
	print( "maxLevel = "..Rested.maxLevel )
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 89, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time() } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["updated"] = time() } }
	Rested.reminderFunctions = {}
	Rested.ReminderCallback(
		function( realm, name, struct )
			return( { [0] = { name.."-"..realm.." is"..( struct.isResting and "" or " not").." resting." } } )
		end
	)
	Rested.MakeReminderSchedule()
	assertEquals( 1, #Rested.reminders[0] )
end
function test.test_Reminders_ReminderOnUpdate()
	-- make sure that this sets Rested.lastReminderUpdate
	Rested.ReminderOnUpdate()
	assertEquals( time(), Rested.lastReminderUpdate )
end

function test.test_Reminders_ReminderOnUpdate_printsCurrentReminder()
	now = time()
	Rested.reminders = { [now] = { "Reminder", "Another" }, [now+5] = { "Future" }, [now-5] = { "Past" } }
	Rested.ReminderOnUpdate()
	assertIsNil( Rested.reminders[now] )   -- primary test
	assertTrue( Rested.reminders[now-5] )  -- These are secondary tests only
	assertTrue( Rested.reminders[now+5] )
end

-- status code
function test.test_Status_status()
	Rested.Status()
end
function test.test_Status_command()
	Rested.Command( "status" )
end

-- base data
function test.test_BaseData_lvlNow()
	-- lvlNow always gets set
	Rested_restedState = {}
	Rested.ADDON_LOADED()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_PLAYER_XP_UPDATE()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_XP_UPDATE()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_PLAYER_UPDATE_RESTING()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_UPDATE_RESTING()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_UPDATE_EXHAUSTION()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.UPDATE_EXHAUSTION()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_lvlNow_CHANNEL_UI_UPDATE()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["lvlNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.CHANNEL_UI_UPDATE()
	assertEquals( 60, Rested_restedState["testRealm"]["testPlayer"]["lvlNow"] )
end
function test.test_BaseData_xpNow_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["xpNow"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 100, Rested_restedState["testRealm"]["testPlayer"]["xpNow"] )
end
function test.test_BaseData_xpMax_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["xpMax"] = 2 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 1000, Rested_restedState["testRealm"]["testPlayer"]["xpMax"] )
end
function test.test_BaseData_isResting_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["isResting"] = false } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertTrue( Rested_restedState["testRealm"]["testPlayer"]["isResting"] )
end
function test.test_BaseData_rested_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["rested"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 3618, Rested_restedState["testRealm"]["testPlayer"]["rested"] )
end
function test.test_BaseData_restedPC_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["restedPC"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 361.8, Rested_restedState["testRealm"]["testPlayer"]["restedPC"] )
end
function test.test_BaseData_RestedReminder()
	now = time()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested_restedState["otherRealm"] = { ["otherPlayer"] =
			{ ["lvlNow"] = 10, ["xpNow"] = 0, ["xpMax"] = 4000, ["isResting"] = false, ["restedPC"] = 0, ["updated"] = now-3600 } }
	Rested.reminderFunctions = {}
	Rested.ReminderCallback( Rested.RestedReminderValues )
	Rested.MakeReminderSchedule()
	assertEquals( "|cff00ff00RESTED:|r 5 days until testRealm:testPlayer is fully rested.", Rested.reminders[now+428400][1] )
end
-- RestedDeaths
function test.test_RestedDeaths_deaths_PLAYER_ENTERING_WORLD()
	Rested_restedState["testRealm"] = { ["testPlayer"] = { ["deaths"] = 918273987 } }
	Rested.ADDON_LOADED()
	Rested.PLAYER_ENTERING_WORLD()
	assertEquals( 42, Rested_restedState["testRealm"]["testPlayer"]["deaths"] )
end

--
function test.test_PruneByAge_noPrune()
	now = time()
	tableWithSubTable = { ["subTable"] = { [now-30] = "-30", [now] = "0", [now-60] = "-60", [now-180] = "-180" } }
	Rested.PruneByAge( tableWithSubTable["subTable"], 240 )
	assertEquals( "-180", tableWithSubTable["subTable"][now-180] )
end
function test.test_PruneByAge_pruneOne()
	now = time()
	tableWithSubTable = { ["subTable"] = { [now-30] = "-30", [now] = "0", [now-60] = "-60", [now-180] = "-180" } }
	Rested.PruneByAge( tableWithSubTable["subTable"], 120 )
	assertIsNil( tableWithSubTable["subTable"][now-180] )
end
]]

-- Nag MountReport
function test.test_NagReport_MaxLevel_InNagRange()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_MaxLevel"] =
			{ ["lvlNow"] = Rested.maxLevel, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(8*86400) } }

	Rested.VARIABLES_LOADED()
	print( Rested_options.nagStart )
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( "90 :: 8 Day 0 Hr : testRealm:testPlayer_MaxLevel", Rested.charList[1][2] )
end
function test.test_NagReport_MaxLevel_LessThanNagRange()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_MaxLevel"] =
			{ ["lvlNow"] = Rested.maxLevel, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(6*86400) } }

	Rested.VARIABLES_LOADED()
	print( Rested_options.nagStart )
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_NagReport_MaxLevel_GreaterThanNagRange()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_MaxLevel"] =
			{ ["lvlNow"] = Rested.maxLevel, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(10.2*86400) } }

	Rested.VARIABLES_LOADED()
	print( Rested_options.nagStart )
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedLessThanLevel_Resting_True()
	-- TODO: fix this
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(2*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedLessThanLevel_Resting_False()
	-- TODO: fix this
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 0,
			["updated"] = now-(2*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanLevel_Resting_True()
	-- fix this
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(8.5*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( "2 :: |cff00ff00127.5%|r : testRealm:testPlayer_lvl2", Rested.charList[1][2] )
end
function test.notest_NagReport_Leveling_RestedGreaterThanLevel_Resting_False()
	-- fix this
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 0,
			["updated"] = now-(8.5*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanMax_Resting_True()
	-- TODO: fix this
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 0,
			["updated"] = now-(17*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanMax_Resting_False()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 0,
			["updated"] = now-(70*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanLevel_FullyRested_Resting_True()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = true, ["restedPC"] = 150,
			["updated"] = now-(1*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.notest_NagReport_Leveling_RestedGreaterThanLevel_FullyRested_Resting_False()
	now = time()
	Rested.ADDON_LOADED()
	Rested_options["nagStart"] = 7 * 86400
	Rested_options["staleStart"] = 10 * 86400
	Rested_restedState["testRealm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150,
			["updated"] = now-(1*86400) } }

	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_NagReport_NotResting()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer_lvl2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150,
			["updated"] = now-(1*3600) } }
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.NagCharacters )

	test.showCharList()
	assertEquals( "2 :: 1 Hr 0 Min : testRealm:testPlayer_lvl2 NOT RESTING", Rested.charList[1][2] )
end

-- Offline tests
function myPrint( str )
	stdOut = stdOut or {}
	table.insert( stdOut, str )
end
function test.after_Offline()
	ParseTOC( "../src/Rested.toc" )
--	require "Rested"
--	require "RestedUI"
--	require "RestedBase"
--	require "RestedDeaths"
--	require "RestedGuild"
--	require "RestediLvl"
--	require "RestedPlayed"
end
function test.notest_Offline_01()
	stdOut = nil
	originalPrint = print
	print = myPrint
	arg = {[0] = "../src/Rested_Offline.lua", "./", "nag"}
	loadfile( "../src/Rested_Offline.lua" )() -- Rested_Export reads from arg, not actually the parameters passed
	for _,v in pairs( stdOut ) do
		originalPrint( v )
	end
	print = originalPrint
	--print( strOut )
	test.after_Offline()
end

-- Auction tests
function test.test_AuctionReport_noAuctions()
	Rested.ForAllChars( Rested.AuctionsReport )
	--test.showCharList()
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_AuctionReport_newAuction_12hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150,
			["updated"] = now-(1*86400),
			["Auctions"] = {
				[550] = {
					["created"] = now,
					["duration"] = 12 * 3600
				},
			} } }
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.AuctionsReport )
	--test.showCharList()
	assertEquals( "1 (12 Hr 0 Min to go) |cff00ff00testRealm:testPlayer|r", Rested.charList[1][2] )
end
function test.test_AuctionReport_newAuction_24hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			["Auctions"] = {
				[550] = {
					["created"] = now,
					["duration"] = 24 * 3600
				},
			} } }
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.AuctionsReport )
	--test.showCharList()
	assertEquals( "1 (1 Day 0 Hr to go) |cff00ff00testRealm:testPlayer|r", Rested.charList[1][2] )
end
function test.test_AuctionReport_newAuction_48hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			["Auctions"] = {
				[550] = {
					["created"] = now,
					["duration"] = 48 * 3600
				},
			} } }
	Rested.VARIABLES_LOADED()
	Rested.ForAllChars( Rested.AuctionsReport )
	--test.showCharList()
	assertEquals( "1 (2 Day 0 Hr to go) |cff00ff00testRealm:testPlayer|r", Rested.charList[1][2] )
end
function test.test_AuctionReport_clearOldAuction_12hours_Init()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			["Auctions"] = {
				[550] = {
					["created"] = now-(12*3600) - 5,  -- 12 hours, 5 seconds ago
					["duration"] = 12 * 3600
				},
			} } }
	Rested.VARIABLES_LOADED()  -- calls init functions
	Rested.ForAllChars( Rested.AuctionsReport )
	--test.showCharList()
	assertIsNil( Rested_restedState["testRealm"]["testPlayer"]["Auctions"] )
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_AuctionReport_clearOldAuction_12hours_PLAYER_ENTERING_WORLD()
	now = time()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()  -- calls init functions
	Rested_restedState["testRealm"]["testPlayer"]["Auctions"] = {
			[550] = {
				["created"] = now-(12*3600) - 5,  -- 12 hours, 5 seconds ago
				["duration"] = 12 * 3600
			},
	}
	Rested.PLAYER_ENTERING_WORLD()
	Rested.ForAllChars( Rested.AuctionsReport )
	--test.showCharList()
	assertIsNil( Rested_restedState["testRealm"]["testPlayer"]["Auctions"] )
	assertEquals( 0, #Rested.charList, "There should be 0 entries" )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_12Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostCommodity( {}, 1, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 15 )  -- This event has a payload....  The auction ID
	assertEquals( 12*3600, Rested_restedState["testRealm"]["testPlayer"]["Auctions"][15].duration )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_24Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostCommodity( {}, 2, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 15 )  -- This event has a payload....  The auction ID
	assertEquals( 24*3600, Rested_restedState["testRealm"]["testPlayer"]["Auctions"][15].duration )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_48Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostCommodity( {}, 3, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 15 )  -- This event has a payload....  The auction ID
	assertEquals( 48*3600, Rested_restedState["testRealm"]["testPlayer"]["Auctions"][15].duration )
end
function test.test_AuctionReport_CreateAuction_PostItem_12Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostItem( {}, 1, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 16 )  -- This event has a payload....  The auction ID
	assertEquals( 12*3600, Rested_restedState["testRealm"]["testPlayer"]["Auctions"][16].duration )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_24Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostItem( {}, 2, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 16 )  -- This event has a payload....  The auction ID
	assertEquals( 24*3600, Rested_restedState["testRealm"]["testPlayer"]["Auctions"][16].duration )
end
function test.test_AuctionReport_CreateAuction_PostCommodity_48Hours()
	now = time()
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 200000, ["isResting"] = false, ["restedPC"] = 150, ["updated"] = now-(1*86400),
			} }
	Rested.VARIABLES_LOADED()
	C_AuctionHouse.PostItem( {}, 3, 1, 1 ) -- item(table), durationKey, quantiy, unitPrice
	Rested.AUCTION_HOUSE_AUCTION_CREATED( 16 )  -- This event has a payload....  The auction ID
	assertEquals( 48*3600, Rested_restedState["testRealm"]["testPlayer"]["Auctions"][16].duration )
end
function test.test_AuctionReport_ExpiredAuction_Report()
	now = time()
	Rested.ADDON_LOADED()
	Rested.VARIABLES_LOADED()  -- calls init functions
	Rested_restedState["testRealm"]["testPlayer"]["Auctions"] = {
			[550] = {
				["created"] = now-(12*3600) - 5,  -- 12 hours, 5 seconds ago
				["duration"] = 12 * 3600
			},
	}
	Rested.ForAllChars( Rested.AuctionsReport )
	--test.showCharList()
	assertEquals( "1 (EXPIRED) |cff00ff00testRealm:testPlayer|r", Rested.charList[1][2] )
end
function test.test_AuctionReport_ExipredReminders()
	now = time()
	Rested.reminders = {}
	Rested.ADDON_LOADED()
	Rested_restedState["testRealm"] = { ["testPlayer2"] =
			{ ["lvlNow"] = 2, ["xpNow"] = 0, ["xpMax"] = 1000, ["isResting"] = true, ["updated"] = time(), ["restedPC"] = 150,
			["Auctions"] = {
				[550] = {
					["created"] = now-(12*3600) - 25,  -- 12 hours, 5 seconds ago
					["duration"] = 12 * 3600
				}
	} } }
	Rested.VARIABLES_LOADED()
	Rested.MakeReminderSchedule()
	assertEquals( "testRealm:testPlayer2 has 1 expired auctions.", Rested.reminders[time()+60][1] )
end

test.run()
