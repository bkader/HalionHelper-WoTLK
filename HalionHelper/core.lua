local folder, core = ...
local L = core.L
_G.HalionHelper = core

-- globals
local pairs, next, select = pairs, next, select
local unpack, setmetatable = unpack, setmetatable
local tostring, tonumber = tostring, tonumber
local UnitGUID, UnitBuff = UnitGUID, UnitBuff
local IsInInstance = IsInInstance
local IsRaidLeader = IsRaidLeader
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetSpellInfo = GetSpellInfo
local SendChatMessage = SendChatMessage
local PlaySoundFile = PlaySoundFile

-- locals
local halion = {[40142] = true, [39863] = true}
local cached
local combustion = GetSpellInfo(74562)
local consumption = GetSpellInfo(74792)
local texture = [[Interface\BUTTONS\WHITE8X8]]
local enabled, inCombat
local playerGUID, isInside

HalionHelperDB = {}

-- corporeality buffs
local corporeality = {
	[74836] = 1, --  70% less dealt, 100% less taken
	[74835] = 2, --  50% less dealt,  80% less taken
	[74834] = 3, --  30% less dealt,  50% less taken
	[74833] = 4, --  20% less dealt,  30% less taken
	[74832] = 5, --  10% less dealt,  15% less taken
	[74826] = 6, --  normal
	[74827] = 7, --  15% more dealt,  20% more taken
	[74828] = 8, --  30% more dealt,  50% more taken
	[74829] = 9, --  60% more dealt, 100% more taken
	[74830] = 10, -- 100% more dealt, 200% more taken
	[74831] = 11 -- 200% more dealt, 400% more taken
}

-- event handling
local addon = CreateFrame("Frame")
addon:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
addon:RegisterEvent("ADDON_LOADED")

-- addon frame
local HalionBar

-- segments colors & alphas
local colors = {
	[2] = {1, 0, 0},
	[3] = {1, 0, 0},
	[4] = {1, .5, 0},
	[5] = {1, 1, 0},
	[6] = {0, 1, 0},
	[7] = {0, 1, 0},
	[8] = {.8, .8, 0},
	[9] = {1, .5, 0},
	[10] = {1, 0, 0},
	[11] = {1, 0, 0}
}

-- week tables
local new, del
do
	local pool = setmetatable({}, {__mode = "k"})

	function new()
		local t = next(pool) or {}
		pool[t] = nil
		return t
	end

	function del(t)
		if t then
			wipe(t)
			t[true] = true
			t[true] = nil
			setmetatable(t, nil)
			pool[t] = true
		end
		return nil
	end
end

-- play audio file
local function AlertPlayer(file)
	PlaySoundFile("Interface\\AddOns\\HalionHelper\\Sounds\\" .. file .. ".mp3", "Master")
end

-- frame creation
local CreateHalionBar
do
	local function AnnounceToRaid(msg)
		if IsRaidLeader() and msg and msg ~= "" then
			SendChatMessage(tostring(msg), "RAID_WARNING")
		end
	end

	local function OnDragStop(self)
		self:StopMovingOrSizing()
		self:SetUserPlaced(false)
		local point, _, _, x, y = self:GetPoint(1)
		HalionHelperDB.point = point
		HalionHelperDB.x = x
		HalionHelperDB.y = y
	end

	local function MoveIndicator(self, i)
		if self.position ~= i then
			self.position = i
			self.indicator:SetPoint("CENTER", self.segments[i], "RIGHT")

			-- change text for here & there
			if isInside then
				self.here:SetText(L["Inside"])
				self.there:SetText(L["Outside"])
			else
				self.here:SetText(L["Outside"])
				self.there:SetText(L["Inside"])
			end

			-- change message
			if i < 5 then
				self.message:SetText(L["Stop All Damage!"])
				self.message:SetTextColor(1, 0.5, 0)
				AnnounceToRaid(isInside and L["Stop DPS Inside!"] or L["Stop DPS Outside!"])
				AlertPlayer("dpsstop")
			elseif i == 5 then
				self.message:SetText(L["Slow Down!"])
				self.message:SetTextColor(1, 1, 0)
				AnnounceToRaid(isInside and L["Slow DPS Inside!"] or L["Slow DPS Outside!"])
				AlertPlayer("dpsslow")
			elseif i == 6 then
				self.message:SetText("")
				AnnounceToRaid(L["DPS Both Sides!"])
			elseif i == 7 then
				self.message:SetText(L["Harder! Faster!"])
				self.message:SetTextColor(1, 1, 0)
				AnnounceToRaid(isInside and L["Slow DPS Outside!"] or L["Slow DPS Inside!"])
				AlertPlayer("dpsmore")
			elseif i > 7 then
				self.message:SetText(L["OMG MORE DAMAGE!"])
				self.message:SetTextColor(1, 0.5, 0)
				AnnounceToRaid(isInside and L["Stop DPS Outside!"] or L["Stop DPS Inside!"])
				AlertPlayer("dpshard")
			end
		end
	end

	function CreateHalionBar()
		if HalionBar then
			return
		end
		HalionBar = CreateFrame("Frame", "HalionHelperFrame", UIParent)
		HalionBar:SetSize(210, 20)
		HalionBar:SetBackdrop({
			bgFile = texture,
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = false,
			tileSize = 16,
			edgeSize = 16,
			insets = {left = 4, right = 4, top = 4, bottom = 4}
		})
		HalionBar:SetBackdropColor(0, 0, 0, 1)
		HalionBar:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

		HalionBar:EnableMouse(true)
		HalionBar:SetMovable(true)
		HalionBar:RegisterForDrag("LeftButton")
		HalionBar:SetUserPlaced(false)
		HalionBar:SetScript("OnDragStart", HalionBar.StartMoving)
		HalionBar:SetScript("OnDragStop", OnDragStop)

		-- create bar segments
		HalionBar.segments = {}
		for i = 1, 11 do
			local t = HalionBar:CreateTexture(nil, "ARTWORK")
			t:SetTexture(texture)
			if i == 1 then
				t:SetPoint("RIGHT", HalionBar, "LEFT", 5, 0)
				t:SetSize(1, 10)
				t:SetAlpha(0)
			else
				t:SetPoint("LEFT", HalionBar.segments[i - 1], "RIGHT", 0, 0)
				t:SetSize(20, 10)
				t:SetVertexColor(unpack(colors[i]))
				if i <= 5 then
					t:SetAlpha(0.5)
				elseif i == 6 or i == 7 then
					t:SetAlpha(0.8)
				end
			end
			HalionBar.segments[i] = t
		end

		-- message
		HalionBar.message = HalionBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		HalionBar.message:SetPoint("BOTTOM", HalionBar, "TOP", 0, 5)
		HalionBar.message:SetText("")

		-- here
		HalionBar.here = HalionBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		HalionBar.here:SetPoint("TOPRIGHT", HalionBar, "BOTTOMRIGHT", -5, -5)
		HalionBar.here:SetText(L["Outside"])

		-- there
		HalionBar.there = HalionBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		HalionBar.there:SetPoint("TOPLEFT", HalionBar, "BOTTOMLEFT", 5, -5)
		HalionBar.there:SetText(L["Inside"])

		-- corporeality indicator
		HalionBar.indicator = HalionBar:CreateTexture(nil, "OVERLAY")
		HalionBar.indicator:SetPoint("CENTER", HalionBar.segments[6], "RIGHT")
		HalionBar.indicator:SetWidth(10)
		HalionBar.indicator:SetHeight(30)
		HalionBar.indicator:SetTexture([[Interface\WorldStateFrame\WorldState-CaptureBar]])
		HalionBar.indicator:SetTexCoord(0.77734375, 0.796875, 0, 0.28125)
		HalionBar.indicator:SetDesaturated(true)

		HalionBar.MoveIndicator = MoveIndicator

		-- position
		HalionBar:SetScript("OnHide", function(self)
			self.position = nil
			self.message:SetText("")
			self.indicator:SetPoint("CENTER", HalionBar.segments[6], "RIGHT")
		end)
		HalionBar:SetPoint(HalionHelperDB.point or "CENTER", HalionHelperDB.x or 0, HalionHelperDB.y or 0)
		HalionBar:Hide()
	end
end

function addon:ADDON_LOADED(name)
	if name ~= folder then
		return
	end
	self:UnregisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	playerGUID = UnitGUID("player")

	SLASH_HALIONHELPERCOMMAND1 = "/halionhelper"
	SlashCmdList["HALIONHELPERCOMMAND"] = function()
		CreateHalionBar()
		if HalionBar:IsShown() then
			HalionBar:Hide()
		else
			HalionBar:Show()
		end
	end
end

function addon:PLAYER_ENTERING_WORLD()
	playerGUID = playerGUID or UnitGUID("player")
	print("here", playerGUID)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:ZONE_CHANGED_NEW_AREA()
end

function addon:PLAYER_REGEN_DISABLED()
	inCombat, cached = true, new()
end

function addon:PLAYER_REGEN_ENABLED()
	inCombat, cached = false, del(cached)
	if HalionBar then
		HalionBar:Hide()
	end
end

function addon:UNIT_AURA(unit)
	if unit == "boss1" and UnitExists(unit) and not self.firstrun then
		for id, _ in pairs(corporeality) do
			local spellid = select(11, UnitBuff(unit, GetSpellInfo(id)))
			if spellid then
				if HalionBar then
					HalionBar:Show()
					HalionBar:MoveIndicator(corporeality[spellid])
				end
				self.firstrun = true
				break
			end
		end
	end
end

function addon:ZONE_CHANGED_NEW_AREA()
	local inInstance, instanceType = IsInInstance()
	if not inInstance or instanceType ~= "raid" then
		enabled = false
		return
	end

	local mapID = GetCurrentMapAreaID()
	enabled = (mapID == 610)

	if enabled then
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		self:RegisterEvent("UNIT_AURA")
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function addon:UpdateCorporeality()
	if UnitExists("boss1") then
		for id, _ in pairs(corporeality) do
			local spellid = select(11, UnitBuff("boss1", GetSpellInfo(id)))
			if spellid and HalionBar then
				HalionBar:MoveIndicator(corporeality[spellid])
				break
			end
		end
	end
end

function addon:IsHalion(guid)
	if tonumber(guid) then
		if cached and cached[guid] then
			return cached[guid]
		end

		local id = tonumber(guid:sub(9, 12), 16)
		if id and halion[id] then
			cached = cached or new()
			cached[guid] = id
			return id
		end
	end
end

function addon:COMBAT_LOG_EVENT_UNFILTERED(_, event, srcGUID, _, _, dstGUID, dstName, _, spellid, spellname)
	if not enabled or not inCombat then
		return
	end

	-- create the bar if not created
	CreateHalionBar()

	if self:IsHalion(srcGUID) == 40142 and not isInside then
		isInside = true
		if HalionBar then
			HalionBar.here:SetText(L["Inside"])
			HalionBar.there:SetText(L["Outside"])
			self:UpdateCorporeality()
		end
	elseif self:IsHalion(srcGUID) == 39863 and isInside then
		isInside = false
		if HalionBar then
			HalionBar.here:SetText(L["Outside"])
			HalionBar.there:SetText(L["Inside"])
			self:UpdateCorporeality()
		end
	end

	if event == "SPELL_AURA_APPLIED" then
		-- combustion/consumption
		if spellname == combustion then
			if dstGUID == playerGUID then
				AlertPlayer("combustion")
			end

			if isInside then
				isInside = false
			end
		elseif spellname == consumption then
			if dstGUID == playerGUID then
				AlertPlayer("consumption")
			end

			if not isInside then
				isInside = true
			end
		end

		-- halion corporeality
		if (self:IsHalion(dstGUID) or self:IsHalion(srcGUID)) and corporeality[spellid] then
			if not HalionBar:IsShown() then
				HalionBar:Show()
			end
			HalionBar:MoveIndicator(corporeality[spellid])
		end
	end
end