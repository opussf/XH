#!/usr/bin/env lua

require "wowTest"

XHFrame = CreateFrame()
XH_XPBarRested = CreateFrame()
XH_Text = CreateFrame()
XH_InstanceText = CreateFrame()
XH_InstanceTimerBar = CreateFrame()
XH_InstanceTimerBack = CreateFrame()
XH_SkillBar = CreateFrame()
XH_SkillBarCD = CreateFrame()
XH_RepBar = CreateFrame()
XH_RepText = CreateFrame()
format = string.format
date = os.date

ParseTOC( "../src/XH.toc" )

test.outFileName = "testOut.xml"

-- addon setup
function test.before()
	XH_Gains = nil
	XH.mouseOver = nil
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
function test.test_UPDATE_EXHAUSTION_Sets_Rested()
	-- @TODO UPDATE_EXHAUSTION should probably be called with Player_Entering_World event
	XH.VARIABLES_LOADED()
	XH.UPDATE_EXHAUSTION()
	assertEquals( 3618, XH.rested )
end
function test.test_UPDATE_EXHAUSTION_Sets_RestedPC()
	-- @TODO UPDATE_EXHAUSTION should probably be called with Player_Entering_World event
	XH.VARIABLES_LOADED()
	XH.UPDATE_EXHAUSTION()
	assertEquals( 361.8, XH.restedPC )
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
	XH.VARIABLES_LOADED()
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
function test.test_OnEnter_Sets_mouseOver()
	XH.VARIABLES_LOADED()
	XH.mouseOver = nil
	XH_OnEnter()
	assertTrue( XH.mouseOver )
end
function test.test_OnLeave_Clears_mouseOver()
	XH.VARIABLES_LOADED()
	XH.mouseOver = true
	XH_OnLeave()
	assertIsNil( XH.mouseOver )
end

function test.test_OnUpdate_reset_lastUpdate()
	XH.lastUpdate = 0
	XH.VARIABLES_LOADED()
	XH.OnUpdate()
	assertEquals( time(), XH.lastUpdate )
end
function test.test_OnUpdate_sets_xps()
	XH.lastUpdate = 0
	XH.VARIABLES_LOADED()
	XH.OnUpdate()
	assertEquals( 0, XH.xps )
end
function test.test_OnUpdate_sets_timeToGo()
	XH.lastUpdate = 0
	XH.VARIABLES_LOADED()
	XH.OnUpdate()
	assertEquals( 0, XH.timeToGo )
end
function test.test_OnUpdate_sets_gained()
	XH.lastUpdate = 0
	XH.VARIABLES_LOADED()
	XH.OnUpdate()
	assertEquals( 0, XH.gained )
end
function test.test_OnUpdate_sets_XH_Text()
	XH.lastUpdate = 0
	XH.VARIABLES_LOADED()
	XH.startedTime = time()-92
	XH.OnUpdate()
	assertEquals( "1 Min 32 Sec (8.0 FPS)", XH.Text )
end
function test.test_OnUpdate_sets_XH_Text_withGained_mouseOver()
	XH.lastUpdate = 0
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
	XH.startedTime = time()-92
	XH.XPGainEvent( "Frame", "Event", "You gain 2400 experience." )
	XH.mouseOver = true
	XH.OnUpdate()
	assertEquals( "2400.0 xp in 1 Min 32 Sec (8.0 FPS)", XH.Text )
end
function test.test_OnUpdate_sets_XH_Text_withGained_Normal()
	XH.lastUpdate = 0
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
	XH.startedTime = time()-92
	XH.XPGainEvent( "Frame", "Event", "You gain 2400 experience." )
	XH.OnUpdate()
	assertEquals( 0, XH.tempVars.day, "day should be 0" )
	assertEquals( 0, XH.tempVars.hour, "hour should be 0" )
	assertEquals( 11, XH.tempVars.minute, "minute should be 11" )
	assertEquals( 14, XH.tempVars.sec, "sec should be 14" )
	assertEquals( 1.335, XH.xps, "xps should be 1.335" )
end
function test.test_PLAYER_LEVEL_UP_resets_bestTime()
	XH.bestTime = 6272387642
	XH.PLAYER_LEVEL_UP()
	assertEquals( 0, XH.bestTime )
end
function test.test_PLAYER_LEVEL_UP_sets_lastUpdate_inFuture()
	XH.lastUpdate = 3245
	XH.PLAYER_LEVEL_UP()
	assertEquals( 3250, XH.lastUpdate )
end
function test.test_Rate2_RateGraph()
	rateStruct = {["gained"] = 3, ["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
			["rolling"] = {
				[time()-10] = 1,
				[time()-20] = 1,
				[time()-30] = 1,
			}
	}
	XH.Rate2( rateStruct, true )
	assertEquals( ":█____|_____|_____|_____|_____|_____| : 3(3)", XH_RepText:GetText() )
end
function test.test_Rate2_RateGraph_Progressive()
	rateStruct = {["gained"] = 3, ["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
			["rolling"] = {
			}
	}
	c = 1
	for ts=time()-1798, time() do
		rateStruct["rolling"][ts] = c
		c = c + 1
	end
	XH.Rate2( rateStruct, true )
	assertEquals( ":█████|███▓▓|▓▓▓▓▓|▒▒▒▒▒|▒▒▒░░|░░░░░| : 1799(106170)", XH_RepText:GetText() )
end
function test.test_Rate2_RateGraph_Progressive_Inverse()
	rateStruct = {["gained"] = 3, ["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
			["rolling"] = {
			}
	}
	c = 1
	for ts=time(), time()-1798, -1 do
		rateStruct["rolling"][ts] = c
		c = c + 1
	end
	XH.Rate2( rateStruct, true )
	assertEquals( ":░░░░░|░░▒▒▒|▒▒▒▒▓|▓▓▓▓▓|▓▓███|█████| : 1799(104430)", XH_RepText:GetText() )
end
function test.test_Rate2_RateGraph_Progressive_Dip()
	rateStruct = {["gained"] = 3, ["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
			["rolling"] = {
			}
	}
	for ts=time(), time()-1798, -1 do
		rateStruct["rolling"][ts] = math.abs( ts-(time()-900) ) * 10
	end
	XH.Rate2( rateStruct, true )
	assertEquals( ":████▓|▓▓▓▒▒|▒░░░░|░░░░▒|▒▒▓▓▓|▓████| : 1799(522300)", XH_RepText:GetText() )
end
function test.test_Rate2_RateGraph_Infrequent()
	rateStruct = {["gained"] = 3, ["start"] = 0, ["lastGained"] = 0, ["toGo"] = 0,
			["rolling"] = {
			}
	}
	for ts=time(), time()-1798, -180 do
		rateStruct["rolling"][ts] = math.abs( ts-(time()-900) ) * 10
	end
	XH.Rate2( rateStruct, true )
	assertEquals( ":█__█_|_▓__▒|__░__|___░_|_▒__▓|__█__| : 10(9000)", XH_RepText:GetText() )
end


test.run()
