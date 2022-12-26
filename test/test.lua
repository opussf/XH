#!/usr/bin/env lua

require "wowTest"

XHFrame = CreateFrame()
XH_XPBarRested = CreateFrame()
XH_InstanceTimerBack = CreateFrame()
XH_SkillBar = CreateFrame()
XH_SkillBarCD = CreateFrame()

ParseTOC( "../src/XH.toc" )

test.outFileName = "testOut.xml"

-- addon setup
function test.before()
	XH_Gains = nil
	XH.OnLoad()
end
function test.after()
end
function test.test_EventHandled_ADDON_LOADED()
	assertTrue( XHFrame.Events["ADDON_LOADED"] )
	XH.ADDON_LOADED()
	assertFalse( XHFrame.Events["ADDON_LOADED"] )
end
function test.test_EventHandled_VARIABLES_LOADED()
	assertTrue( XHFrame.Events["VARIABLES_LOADED"] )
	XH.VARIABLES_LOADED()
	assertFalse( XHFrame.Events["VARIABLES_LOADED"] )
end
function test.test_EventHandled_UPDATE_EXHAUSTION()
	assertTrue( XHFrame.Events["UPDATE_EXHAUSTION"] )
	XH.UPDATE_EXHAUSTION()
end
function test.test_EventHandled_PLAYER_LEVEL_UP()
	assertTrue( XHFrame.Events["PLAYER_LEVEL_UP"] )
	XH.PLAYER_LEVEL_UP()
end
function test.test_ADDON_LOADED_sets_bar_minmax_values()
	XH.ADDON_LOADED()
	assertEquals( 0, XH_XPBarRested.min )
	assertEquals( 150, XH_XPBarRested.max )
end
function test.test_ADDON_LOADED_sets_bar_init_value()
	XH.ADDON_LOADED()
	assertEquals( 150, XH_XPBarRested.value )
end
function test.test_KnowsName()
	assertEquals( "testPlayer", XH.name )
end
function test.test_KnowsRealm()
	assertEquals( "testRealm", XH.realm )
end
function test.test_PlayerSlug()
	assertEquals( "testRealm-testPlayer", XH.playerSlug )
end
function test.test_KnowsFaction()
	assertEquals( "Alliance", XH.faction )
end
function test.test_VARIABLES_LOADED_startedTime_isSet()
	XH.VARIABLES_LOADED()
	assertTrue( XH.startedTime ~= nil, "startedTime is not set." )
end
function test.test_VARIABLES_LOADED_MyData_isSet()
	XH.VARIABLES_LOADED()
	assertTrue( XH.me ~= nil, "XH.me is not set." )
end
function test.test_VARIABLES_LOADED_MyData_hasSessionTable()
	XH.VARIABLES_LOADED()
	assertTrue( XH.me.xp_session )
end
function test.test_VARIABLES_LOADED_MyData_gained_isSet_noSavedData()
	XH.VARIABLES_LOADED()
	assertEquals( 0, XH.me.xp_session.gained )
end
function test.test_VARIABLES_LOADED_MyData_start_isSet_noSavedData()
	XH.VARIABLES_LOADED()
	assertEquals( time(), XH.me.xp_session.start )
end
function test.test_VARIABLES_LOADED_MyData_lastGained_isSet_noSavedData()
	XH.VARIABLES_LOADED()
	assertEquals( 0, XH.me.xp_session.lastGained )
end
function test.test_VARIABLES_LOADED_MyData_toGo_isSet_noSavedData()
	XH.VARIABLES_LOADED()
	assertEquals( 900, XH.me.xp_session.toGo ) -- test data
end
function test.test_VARIABLES_LOADED_MyData_rolling_isSet_noSavedData()
	XH.VARIABLES_LOADED()
	assertEquals( 0, XH.me.xp_session.rolling[time()] )
end
function test.test_VARIABLES_LOADED_MyData_pruneOld()
	XH_Gains = {
		["testRealm-testPlayer"] = {
			["xp_session"] = {
				["gained"] = 0,	["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
				["rolling"] = {
					[1] = 1,
					[2] = 1,
					[3] = 1,
				}
			}
		}
	}
	XH.VARIABLES_LOADED()
	assertEquals( 0, #XH.me.xp_session.rolling )
end
function test.test_VARIABLES_LOADED_MyData_gainedReset()
	XH_Gains = {
		["testRealm-testPlayer"] = {
			["xp_session"] = {
				["gained"] = 3, ["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
				["rolling"] = {
					[1] = 1,
					[2] = 1,
					[3] = 1,
				}
			}
		}
	}
	XH.VARIABLES_LOADED()
	assertEquals( 0, XH.me.xp_session.gained )
end
function test.test_VARIABLES_LOADED_OtherData_pruneOld()
	XH_Gains = {
		["otherRealm-otherPlayer"] = {
			["xp_session"] = {
				["gained"] = 0, ["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
				["rolling"] = {
					[1] = 1,
					[2] = 1,
					[3] = 1,
				}
			}
		}
	}
	XH.VARIABLES_LOADED()
	assertIsNil( XH_Gains["otherRealm-otherPlayer"] )
end
function test.test_VARIABLES_LOADED_Sets_Rested()
	XH.VARIABLES_LOADED()
	assertEquals( 3618, XH.rested )
end
function test.test_VARIABLES_LOADED_Sets_RestedPC()
	XH.VARIABLES_LOADED()
	assertEquals( 361.8, XH.restedPC )
end
function test.test_VARIABLES_LOADED_Sets_Xpnow()
	XH.VARIABLES_LOADED()
	assertEquals( 100, XH.xpNow )
end
function test.test_XPGainEvent_sets_EXP_GAIN_TEXT()
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "Steve dies, you gain 2400 experience." )
	assertEquals( "(.+) dies, you gain (%d+) experience%.", XH.EXP_GAIN_TEXT )
end
function test.test_XPGainEvent_sets_RESTED_GAIN_TEXT()
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "Steve dies, you gain 2400 experience." )
	assertEquals( "(%d+) exp (.+) bonus", XH.RESTED_GAIN_TEXT )
end
function test.test_XPGainEvent_sets_XPGAIN_QUEST()
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "You gain 2400 experience." )
	assertEquals( "You gain (%d+) experience", XH.XPGAIN_QUEST )
end
function test.test_XPGainEvent_sets_mobName()
	XH.XPGainEvent( "Frame", "Event", "Steve dies, you gain 2400 experience." )
	assertEquals( "Steve", XH.mobName )
end
function test.test_XPGainEvent_sets_xpGain()
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "Steve dies, you gain 2400 experience." )
	assertEquals( "2400", XH.xpGain )
end
function test.test_XPGainEvent_sets_xpGain_nonCombat()
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "You gain 2400 experience." )
	assertEquals( "2400", XH.xpGain )
end
function test.test_XPGainEvent_sets_xpGainedStruct_gained()
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "You gain 2400 experience." )
	assertEquals( 2400, XH.me.xp_session.gained )
end
function test.test_XPGainEvent_sets_xpGainedStruct_lastGained()
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "You gain 1200 experience." )
	assertEquals( "1200", XH.me.xp_session.lastGained )
end
function test.test_XPGainEvent_sets_xpGainedStruct_toGo()
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "You gain 1200 experience." )
	assertEquals( 900, XH.me.xp_session.toGo )
end
function test.test_XPGainEvent_sets_xpGainedStruct_rolling()
	XH_Gains = {}
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "You gain 2400 experience." )
	assertEquals( 2400, XH.me.xp_session.rolling[time()] )
end
function test.test_XPGainEvent_sets_xpGain_withPrevious()
	XH_Gains = {
		["testRealm-testPlayer"] = {
			["xp_session"] = {
				["gained"] = 3, ["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
				["rolling"] = {
					[time() - 10] = 1,
					[time() - 20] = 1,
					[time() - 30] = 1,
				}
			}
		}
	}
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "You gain 2400 experience." )
	assertEquals( 2400, XH.me.xp_session.gained )
end
function test.test_XPGainEvent_sets_rolling_withPrevious()
	XH_Gains = {
		["testRealm-testPlayer"] = {
			["xp_session"] = {
				["gained"] = 3, ["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
				["rolling"] = {
					[time() - 10] = 1,
					[time() - 20] = 1,
					[time() - 30] = 1,
				}
			}
		}
	}
	XH.VARIABLES_LOADED()
	XH.XPGainEvent( "Frame", "Event", "You gain 2400 experience." )
	assertEquals( 2400, XH.me.xp_session.rolling[time()] )
end

test.run()
