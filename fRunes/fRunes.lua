if (select(2, UnitClass("player")) ~= "DEATHKNIGHT") then return end

local colors = fRunesSettings.colors

local runes = {}

-- Create the frame
fRunes = CreateFrame("Frame", "fRunes", oUF_Tukz_player)
fRunes:SetPoint("BOTTOM", fRunesSettings.anchor, "BOTTOM", fRunesSettings.x, fRunesSettings.y)
if (fRunesSettings.growthDirection == "VERTICAL") then
	fRunes:SetSize(fRunesSettings.barThickness * 6 + 9, fRunesSettings.barLength)
else
	fRunes:SetSize(fRunesSettings.barLength, fRunesSettings.barThickness * 6 + 9)
end

-- Styling
TukuiDB.SetTemplate(fRunes)
TukuiDB.CreateShadow(fRunes)

-- Create the runes
for i = 1, 6 do
	local rune = CreateFrame("StatusBar", "fRunesRune"..i, fRunes)
	rune:SetStatusBarTexture(fRunesSettings.texture)
	rune:SetStatusBarColor(unpack(colors[math.ceil(i/2)]))
	rune:SetMinMaxValues(0, 10)
	
	if (fRunesSettings.growthDirection == "VERTICAL") then
		rune:SetOrientation("VERTICAL")
		rune:SetWidth(fRunesSettings.barThickness)
	else
		rune:SetOrientation("HORIZONTAL")
		rune:SetHeight(fRunesSettings.barThickness)
	end
	
	if (i == 1) then
		rune:SetPoint("TOPLEFT", fRunes, "TOPLEFT", 2, -2)
		if (fRunesSettings.growthDirection == "VERTICAL") then
			rune:SetPoint("BOTTOMLEFT", fRunes, "BOTTOMLEFT", 2, 2)
		else
			rune:SetPoint("TOPRIGHT", fRunes, "TOPRIGHT", -2, -2)
		end
	else
		if (fRunesSettings.growthDirection == "VERTICAL") then
			rune:SetHeight(runes[1]:GetHeight())
			rune:SetPoint("LEFT", runes[i-1], "RIGHT", 1, 0)
		else
			rune:SetWidth(runes[1]:GetWidth())
			rune:SetPoint("TOP", runes[i-1], "BOTTOM", 0, -1)
		end
	end
	
	tinsert(runes, rune)
end

-- Create the RP Bar
if (fRunesSettings.displayRpBar) then
	local rpbarbg = CreateFrame("Frame", "fRunesRunicPower", fRunes)
	TukuiDB.SetTemplate(rpbarbg)
	TukuiDB.CreateShadow(rpbarbg)
	rpbarbg:SetPoint("TOPLEFT", fRunes, "BOTTOMLEFT", 0, -3)
	rpbarbg:SetPoint("TOPRIGHT", fRunes, "BOTTOMRIGHT", 0, -3)
	rpbarbg:SetHeight(fRunesSettings.rpBarThickness or 10)
	
	local rpbar = CreateFrame("StatusBar", nil, rpbarbg)
	rpbar:SetStatusBarTexture(fRunesSettings.texture)
	rpbar:SetStatusBarColor(unpack(colors[5]))
	rpbar:SetMinMaxValues(0, 100)
	
	rpbar:SetPoint("TOPLEFT", rpbarbg, "TOPLEFT", 2, -2)
	rpbar:SetPoint("BOTTOMRIGHT", rpbarbg, "BOTTOMRIGHT", -2, 2)
	
	rpbar:SetScript("OnEvent", function(self, event)
		if (event ~= "UNIT_POWER") then
			local maxrp = UnitPowerMax("player")
			self:SetMinMaxValues(0, maxrp)
		end
		
		local power = UnitPower("player")
		self:SetValue(power)
	end)
	
	rpbar:RegisterEvent("PLAYER_ENTERING_WORLD")
	rpbar:RegisterEvent("PLAYER_TALENT_UPDATE")
	rpbar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	rpbar:RegisterEvent("UNIT_POWER")
end  

-- Function to update runes
local function UpdateRune(id, start, duration, finished)
	local rune = runes[id]
	
	rune:SetStatusBarColor(unpack(colors[GetRuneType(id)]))
	rune:SetMinMaxValues(0, duration)
	
	if (finished) then
		rune:SetValue(duration)
	else
		rune:SetValue(GetTime() - start)
	end
end

local OnUpdate = CreateFrame("Frame")
OnUpdate.TimeSinceLastUpdate = 0
OnUpdate:SetScript("OnUpdate", function(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed; 	

	if (self.TimeSinceLastUpdate > 0.07) then
		for i = 1, 6 do
			UpdateRune(i, GetRuneCooldown(i))
		end
		self.TimeSinceLastUpdate = 0
	end
end)

-- hide blizzard runeframe
RuneFrame:Hide()