function XH.InitBars()
	-- Rested Bar
	XH_XPBarRested:SetMinMaxValues(0, 150);
	XH_XPBarRested:SetValue(150);

-- 	-- InstanceTimer
-- 	XH_InstanceTimerBack:SetMinMaxValues( 0, 1 );
-- 	XH_InstanceTimerBack:SetValue( 1 );

	-- SkillBars
	XH_SkillBar:Hide()
	XH_SkillBarCD:Hide()
end
-- Enter function, will be ran on mouseover.
function XH.OnEnter()
	XH.mouseOver = true
	XH.UpdateBars()
end
-- Leave function, will be ran on mouseoverleave.
function XH.OnLeave()
	XH.mouseOver = nil
	XH.UpdateBars()
end
function XH.OnDragStart()
	button = GetMouseButtonClicked()
	if button == "RightButton" then
		XHFrame:StartMoving()
		return
	end
end
function XH.OnDragStop()
	XHFrame:StopMovingOrSizing()
end

function XH.UpdateBars()
	XH.UpdateXPBarText()
	--XH_XPBarRested:SetMinMaxValues(0, 150);
	--print("XH.restedPC: "..XH.restedPC.."("..math.floor(XH.restedPC)..")")
	if XH.restedPC ~= XH.restedPC then XH.restedPC = 0; end
	XH_XPBarRested:SetValue(math.floor(tonumber(XH.restedPC) or 0))

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
	--XH.UpdateRepBarText();

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