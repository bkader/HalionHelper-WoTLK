--[[
Translators:

frFR: bkader#5341
esES: Ícar#8167
zhCN: meatgaga#9470

]]
local _, core = ...

local _G = _G
local setmetatable = _G.setmetatable
local tostring, format = _G.tostring, _G.string.format
local rawset, rawget = _G.rawset, _G.rawget

local L = setmetatable({}, {
	__newindex = function(self, key, value)
		rawset(self, key, value == true and key or value)
	end,
	__index = function(self, key)
		return key
	end
})

-- Displayed texts:
L["Inside"] = true
L["Outside"] = true
L["Harder! Faster!"] = true
L["OMG MORE DAMAGE!"] = true
L["Slow Down!"] = true
L["Stop All Damage!"] = true

-- Raid Warnings:
L["DPS Both Sides!"] = true
L["Stop DPS Inside!"] = true
L["Slow DPS Inside!"] = true
L["Stop DPS Outside!"] = true
L["Slow DPS Outside!"] = true

local GAME_LOCALE = GetLocale()

if GAME_LOCALE == "deDE" then
	-- L["Inside"] = ""
	-- L["Outside"] = ""
	-- L["Harder! Faster!"] = ""
	-- L["OMG MORE DAMAGE!"] = ""
	-- L["Slow Down!"] = ""
	-- L["Stop All Damage!"] = ""
	-- L["DPS Both Sides!"] = ""
	-- L["Stop DPS Inside!"] = ""
	-- L["Slow DPS Inside!"] = ""
	-- L["Stop DPS Outside!"] = ""
	-- L["Slow DPS Outside!"] = ""
elseif GAME_LOCALE == "esES" then
	L["Inside"] = "Dentro"
	L["Outside"] = "Fuera"
	L["Harder! Faster!"] = "¡Más fuerte! ¡Más rápido!"
	L["OMG MORE DAMAGE!"] = "¡POR DIOS MÁS DAÑO!"
	L["Slow Down!"] = "¡Frena!"
	L["Stop All Damage!"] = "¡Para el daño!"
	L["DPS Both Sides!"] = "¡Atacad ambos sitios!"
	L["Stop DPS Inside!"] = "¡Parad el daño dentro!"
	L["Slow DPS Inside!"] = "¡Frenad el daño dentro!"
	L["Stop DPS Outside!"] = "¡Parad el daño fuera!"
	L["Slow DPS Outside!"] = "¡Frenad el daño fuera!"
elseif GAME_LOCALE == "esMX" then
	-- L["Inside"] = ""
	-- L["Outside"] = ""
	-- L["Harder! Faster!"] = ""
	-- L["OMG MORE DAMAGE!"] = ""
	-- L["Slow Down!"] = ""
	-- L["Stop All Damage!"] = ""
	-- L["DPS Both Sides!"] = ""
	-- L["Stop DPS Inside!"] = ""
	-- L["Slow DPS Inside!"] = ""
	-- L["Stop DPS Outside!"] = ""
	-- L["Slow DPS Outside!"] = ""
elseif GAME_LOCALE == "frFR" then -- by Kader
	L["Inside"] = "Dedans"
	L["Outside"] = "Dehors"
	L["Harder! Faster!"] = "Plus fort! Plus vite!"
	L["OMG MORE DAMAGE!"] = "OMG PLUS DE DÉGÂTS!"
	L["Slow Down!"] = "Doucement!"
	L["Stop All Damage!"] = "Arrêtez tous les dégâts!"
	L["DPS Both Sides!"] = "Les deux côtés DPS!"
	L["Stop DPS Inside!"] = "Arrêtez DPS à l'intérieur!"
	L["Slow DPS Inside!"] = "DPS doucement à l'intérieur"
	L["Stop DPS Outside!"] = "Arrêtez le DPS à l'extérieur!"
	L["Slow DPS Outside!"] = "DPS doucement à l'extérieur"
elseif GAME_LOCALE == "koKR" then
	-- L["Inside"] = ""
	-- L["Outside"] = ""
	-- L["Harder! Faster!"] = ""
	-- L["OMG MORE DAMAGE!"] = ""
	-- L["Slow Down!"] = ""
	-- L["Stop All Damage!"] = ""
	-- L["DPS Both Sides!"] = ""
	-- L["Stop DPS Inside!"] = ""
	-- L["Slow DPS Inside!"] = ""
	-- L["Stop DPS Outside!"] = ""
	-- L["Slow DPS Outside!"] = ""
elseif GAME_LOCALE == "ruRU" then
	-- L["Inside"] = ""
	-- L["Outside"] = ""
	-- L["Harder! Faster!"] = ""
	-- L["OMG MORE DAMAGE!"] = ""
	-- L["Slow Down!"] = ""
	-- L["Stop All Damage!"] = ""
	-- L["DPS Both Sides!"] = ""
	-- L["Stop DPS Inside!"] = ""
	-- L["Slow DPS Inside!"] = ""
	-- L["Stop DPS Outside!"] = ""
	-- L["Slow DPS Outside!"] = ""
elseif GAME_LOCALE == "zhCN" then
	L["Inside"] = "内场"
	L["Outside"] = "外场"
	L["Harder! Faster!"] = "再猛一点！再快一点！"
	L["OMG MORE DAMAGE!"] = "偶滴个神，加大输出！"
	L["Slow Down!"] = "慢一点！"
	L["Stop All Damage!"] = "全部停手！"
	L["DPS Both Sides!"] = "内外场同时输出！"
	L["Stop DPS Inside!"] = "内场停手！"
	L["Slow DPS Inside!"] = "内场输出慢一点！"
	L["Stop DPS Outside!"] = "外场停手！"
	L["Slow DPS Outside!"] = "外场输出慢一点！"
elseif GAME_LOCALE == "zhTW" then
-- L["Inside"] = ""
-- L["Outside"] = ""
-- L["Harder! Faster!"] = ""
-- L["OMG MORE DAMAGE!"] = ""
-- L["Slow Down!"] = ""
-- L["Stop All Damage!"] = ""
-- L["DPS Both Sides!"] = ""
-- L["Stop DPS Inside!"] = ""
-- L["Slow DPS Inside!"] = ""
-- L["Stop DPS Outside!"] = ""
-- L["Slow DPS Outside!"] = ""
end

core.L = L