function XH.InitBars()
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

function XH.UpdateBars()
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
