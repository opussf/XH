#!/usr/bin/env lua

require "wowTest"

-- RestedOptionsFrame_NagTimeSliderText = CreateFontString()
-- RestedOptionsFrame_NagTimeSlider = CreateFrame()
XHFrame = CreateFrame()
XH_XPBarRested = CreateFrame()
XH_InstanceTimerBack = CreateFrame()
XH_SkillBar = CreateFrame()
XH_SkillBarCD = CreateFrame()
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
function test.test_EventHandled_ADDON_LOADED()
	XH.ADDON_LOADED()
end
function test.test_EventHandled_VARIABLES_LOADED()
	XH.VARIABLES_LOADED()
end
function test.test_EventHandled_UPDATE_EXHAUSTION()
	XH.UPDATE_EXHAUSTION()
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

test.run()
