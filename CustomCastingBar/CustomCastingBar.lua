CustomCastingBar = {};
CustomCastingBar.notes = GetAddOnMetadata("CustomCastingBar", "Notes");
CustomCastingBar.fontSize = 10;
CustomCastingBar.defaultString = " (%0.2fs)";

CustomCastingBarSettings = {};

function CustomCastingBar.OnEvent(self, event, arg1, ...)
	if (event == "ADDON_LOADED" and arg1 == "CustomCastingBar") then
		CustomCastingBar.OnLoad();
	elseif (event == "PLAYER_ENTERING_WORLD") then
		CustomCastingBar.LoadSettings();
	end
end

function CustomCastingBar.OnLoad()
	-- Set Casting bar movable
	CastingBarFrame:SetMovable(true);
	CastingBarFrame:EnableMouse(true);
	CastingBarFrame:RegisterForDrag("LeftButton");
	CastingBarFrame.Icon:SetSize(40, 40);

	-- Register the events for the dragging
	CastingBarFrame:SetScript("OnDragStart", CustomCastingBar.OnDragStart);
	CastingBarFrame:SetScript("OnDragStop", CustomCastingBar.OnDragStop);

	-- securely post-hooks a script
	CastingBarFrame:HookScript("OnUpdate", CustomCastingBar.OnUpdate);
	CustomCastingBar.LoadPanel();
end

function CustomCastingBar.OnDragStop(self, button)
	self:StopMovingOrSizing();
end

function CustomCastingBar.OnDragStart(self, button)
	if (button == "LeftButton") then
		self:StartMoving();
	end
end

function CustomCastingBar.OnUpdate(self, ...)
	local timerValue = self.maxValue - self.value;
	local textDisplay = self.Text;
	local _, text, displayName, tempText;

	-- Check if we're casting
	if (self.casting) then
		text = UnitCastingInfo(self.unit);
	elseif (self.channeling) then
		text = UnitChannelInfo(self.unit);
		timerValue = self.value;
	end
	
	-- Concatenate the default string
	if (text) then
		displayName = text..CustomCastingBar.defaultString;
	end

	if (displayName ~= nil) then
		if (timerValue) then
			if (timerValue > 0.01) then
				-- Shrink the font a bit to fit more text
				local fontName, fontHeight, fontFlags = textDisplay:GetFont();
				textDisplay:SetFont(fontName, CustomCastingBar.fontSize, fontFlags);
				-- Update with the new text
				textDisplay:SetText(format(displayName, timerValue) );
			end
		end
	end
end

function CustomCastingBar.LoadPanel()
	-- Settings panel
	local panel = CreateFrame("Frame", "CustomCastingBar", UIParent);
	panel.name = "CustomCastingBar";

	-- Listen to events from the interface menu
	panel.okay = function (self) CustomCastingBar.Panel_Okay(); end;
	panel.default = function (self) CustomCastingBar.Panel_Default(); end;
	panel.cancel = function (self) CustomCastingBar.Panel_Cancel(); end;

	-- Title
	local fonttitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	fonttitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -15);
	fonttitle:SetText("CustomCastingBar");

	-- Notes
	local font = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	font:SetPoint("TOPLEFT", fonttitle, "TOPLEFT", 0, -25);
	font:SetText(CustomCastingBar.notes);

	-- Checkbox for showing icon
	local icon = CreateFrame("CheckButton", "ShowIconCheckBox", panel, "InterfaceOptionsCheckButtonTemplate")
	icon.id = "BoneShield"
	icon:SetPoint("TOPLEFT", 16, -60)
	icon:SetScript("OnClick", CustomCastingBar.ChangeState)
	_G[icon:GetName().."Text"]:SetText("Show Casting Icon");

	panel.icon = icon;
	CustomCastingBar.panel = panel;
	InterfaceOptions_AddCategory(panel);
end

function CustomCastingBar.Panel_Okay(self)
	CustomCastingBarSettings.showIcon = CustomCastingBar.panel.icon:GetChecked();
	CastingBarFrame.Icon:SetShown(CustomCastingBarSettings.showIcon);
end

function CustomCastingBar.Panel_Default(self)
	CustomCastingBarSettings = {};
	CustomCastingBar.LoadSettings();
end

function CustomCastingBar.Panel_Cancel(self)
	CastingBarFrame.Icon:SetShown(CustomCastingBarSettings.showIcon);
	CustomCastingBar.panel.icon:SetChecked(CustomCastingBarSettings.showIcon);
end

function CustomCastingBar.ChangeState()
	CastingBarFrame.Icon:SetShown(CustomCastingBar.panel.icon:GetChecked());
end

function CustomCastingBar.LoadSettings()
	CustomCastingBarSettings.showIcon = CustomCastingBarSettings.showIcon or true;
	CastingBarFrame.Icon:SetShown(CustomCastingBarSettings.showIcon);
	CustomCastingBar.panel.icon:SetChecked(CustomCastingBarSettings.showIcon);
end

-- Register for events and listen to them
CastingBarFrame:RegisterEvent("ADDON_LOADED");
CastingBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
CastingBarFrame:HookScript("OnEvent", CustomCastingBar.OnEvent);