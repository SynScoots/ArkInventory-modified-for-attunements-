local rule = ArkInventoryRules:NewModule( 'ArkInventoryRules_Scoots' )
local TTH = nil

function ArkInventoryRules_Scoots_RegisterTTH(tooltip)
    TTH = tooltip
end

local function getItemId()
    return tonumber(string.match(string.match(ArkInventoryRules.Object.h, 'item:%d+'), '%d+'))
end

local function getTooltipLines(tooltip)
    local lines = {}
    local tooltipLines = {tooltip:GetRegions()}
    
    for _, line in ipairs(tooltipLines) do
        if(line:IsObjectType('FontString')) then
            table.insert(lines, line:GetText())
        end
    end
    
    return lines
end

function rule:OnEnable()
    ArkInventoryRules.Register(self, 'RESIST', rule.resist)
    ArkInventoryRules.Register(self, 'MYTHIC', rule.mythic)
    ArkInventoryRules.Register(self, 'ATTUNABLE', rule.attunable)
    ArkInventoryRules.Register(self, 'ATTUNABLEATALL', rule.attunableatall)
    ArkInventoryRules.Register(self, 'ATTUNED', rule.attuned)
    ArkInventoryRules.Register(self, 'OPTIMALFORME', rule.optimalforme)
    ArkInventoryRules.Register(self, 'HASBOUNTY', rule.hasbounty)
end

function rule.resist(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    local ac = select('#', ...)
    local query = {}
    
    local fn = 'resist'
    
    TTH:ClearLines()
    TTH:SetOwner(UIParent)
    TTH:SetHyperlink(ArkInventoryRules.Object.h)
    local lines = getTooltipLines(TTH)
    TTH:Hide()
    
    local resistLines = {}
    
    for _, line in ipairs(lines) do
        line = string.lower(line)
        if(not string.find(line, '%(%d+%) set:') and string.find(line, '%+%d+ [acdefhinorstuw]+ resistance')) then
            table.insert(resistLines, line)
        end
    end
    
    if(table.getn(resistLines) == 0) then
        return false
    end
    
    if(ac == 0) then
        return true
    end
    
    for ax = 1, ac do
        local arg = select(ax, ...)
        
        if type(arg) == "string" then
            for _, line in ipairs(resistLines) do
                line = string.lower(line)
                if(string.find(line, '%+%d+ ' .. arg .. ' resistance')) then
                    return true
                end
            end
        else
            error(string.format(ArkInventory.Localise["RULE_FAILED_ARGUMENT_IS_INVALID"], fn, ax, string.format( "%s", ArkInventory.Localise["STRING"]), 0))
        end
    end
    
    return false
end

function rule.mythic(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    local fn = 'mythic'
    
    TTH:ClearLines()
    TTH:SetOwner(UIParent)
    TTH:SetHyperlink(ArkInventoryRules.Object.h)
    local lines = getTooltipLines(TTH)
    TTH:Hide()
    
    for _, line in ipairs(lines) do
        if(line == 'Mythic') then
            return true
        end
    end
    
    return false
end

function rule.attunable(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    if(CanAttuneItemHelper == nil) then
        return false
    end
    
    local fn = 'attunable'
    
    return rule.attunableatall() and rule.optimalforme()
end

function rule.attunableatall(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    if(IsAttunableBySomeone == nil) then
        return false
    end
    
    local fn = 'attunableatall'
    
    local check = IsAttunableBySomeone(getItemId())
    if(check ~= nil and check ~= 0) then
        return true
    end
    
    return false
end

function rule.attuned(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    if(CanAttuneItemHelper == nil or GetItemLinkAttuneProgress == nil) then
        return false
    end
    
    local fn = 'attuned'
    
    if(CanAttuneItemHelper(getItemId()) <= 0) then
        return false
    end
    
    if(tonumber(GetItemLinkAttuneProgress(ArkInventoryRules.Object.h)) < 100) then
        return false
    end
    
    return true
end

function rule.optimalforme(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    local fn = 'optimalforme'
    
    local _, playerClass = UnitClass('player')
    playerClass = strupper(playerClass)
    local _, _, _, _, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(ArkInventoryRules.Object.h)
    
    if(itemType == 'Weapon') then
        local validForAll = {
            ['Miscellaneous'] = true,
            ['Fishing Poles'] = true
        }
        
        if(validForAll[itemSubType] ~= nil) then
            return true
        end
    
        local map = {
            ['Daggers'] = {
                ['DRUID'] = true,
                ['HUNTER'] = true,
                ['MAGE'] = true,
                ['PRIEST'] = true,
                ['ROGUE'] = true,
                ['SHAMAN'] = true,
                ['WARLOCK'] = true,
                ['WARRIOR'] = true
            },
            ['Fist Weapons'] = {
                ['DRUID'] = true,
                ['HUNTER'] = true,
                ['ROGUE'] = true,
                ['SHAMAN'] = true,
                ['WARRIOR'] = true
            },
            ['One-Handed Swords'] = {
                ['DEATHKNIGHT'] = true,
                ['HUNTER'] = true,
                ['MAGE'] = true,
                ['PALADIN'] = true,
                ['ROGUE'] = true,
                ['WARLOCK'] = true,
                ['WARRIOR'] = true
            },
            ['Two-Handed Swords'] = {
                ['DEATHKNIGHT'] = true,
                ['HUNTER'] = true,
                ['PALADIN'] = true,
                ['WARRIOR'] = true
            },
            ['One-Handed Axes'] = {
                ['DEATHKNIGHT'] = true,
                ['HUNTER'] = true,
                ['PALADIN'] = true,
                ['ROGUE'] = true,
                ['SHAMAN'] = true,
                ['WARRIOR'] = true
            },
            ['Two-Handed Axes'] = {
                ['DEATHKNIGHT'] = true,
                ['HUNTER'] = true,
                ['PALADIN'] = true,
                ['SHAMAN'] = true,
                ['WARRIOR'] = true
            },
            ['One-Handed Maces'] = {
                ['DEATHKNIGHT'] = true,
                ['DRUID'] = true,
                ['PALADIN'] = true,
                ['PRIEST'] = true,
                ['ROGUE'] = true,
                ['SHAMAN'] = true,
                ['WARRIOR'] = true
            },
            ['Two-Handed Maces'] = {
                ['DEATHKNIGHT'] = true,
                ['DRUID'] = true,
                ['PALADIN'] = true,
                ['SHAMAN'] = true,
                ['WARRIOR'] = true
            },
            ['Polearms'] = {
                ['DEATHKNIGHT'] = true,
                ['HUNTER'] = true,
                ['PALADIN'] = true,
                ['WARRIOR'] = true
            },
            ['Staves'] = {
                ['DRUID'] = true,
                ['HUNTER'] = true,
                ['MAGE'] = true,
                ['PRIEST'] = true,
                ['SHAMAN'] = true,
                ['WARLOCK'] = true,
                ['WARRIOR'] = true
            },
            ['Thrown'] = {
                ['HUNTER'] = true,
                ['ROGUE'] = true,
                ['WARRIOR'] = true
            },
            ['Bows'] = {
                ['HUNTER'] = true,
                ['ROGUE'] = true,
                ['WARRIOR'] = true
            },
            ['Crossbows'] = {
                ['HUNTER'] = true,
                ['ROGUE'] = true,
                ['WARRIOR'] = true
            },
            ['Guns'] = {
                ['HUNTER'] = true,
                ['ROGUE'] = true,
                ['WARRIOR'] = true
            },
            ['Wands'] = {
                ['MAGE'] = true,
                ['PRIEST'] = true,
                ['WARLOCK'] = true
            }
        }
        
        local noOffhandWeapons = {
            ['DRUID'] = true,
            ['MAGE'] = true,
            ['PRIEST'] = true,
            ['WARLOCK'] = true
        }

        if(map[itemSubType][playerClass] ~= nil) then
            if(itemEquipLoc == 'INVTYPE_WEAPONOFFHAND' and noOffhandWeapons[playerClass] ~= nil) then
                return false
            end
            
            return true
        end
        
        return false
    elseif(itemType == 'Armor') then
        local validForAll = {
            ['INVTYPE_NECK'] = true,
            ['INVTYPE_FINGER'] = true,
            ['INVTYPE_TRINKET'] = true,
            ['INVTYPE_CLOAK'] = true,
            ['INVTYPE_HOLDABLE'] = true,
            ['INVTYPE_TABARD'] = true,
        }
        
        if(validForAll[itemEquipLoc] ~= nil) then
            return true
        end
        
        local map = {}
        if(itemSubType == 'Cloth') then
            map = {
                ['MAGE'] = true,
                ['PRIEST'] = true,
                ['WARLOCK'] = true
            }
        elseif(itemSubType == 'Leather') then
            map = {
                ['DRUID'] = true,
                ['ROGUE'] = true
            }
            
            if(itemMinLevel ~= nil and itemMinLevel < 40) then
                map.HUNTER = true
                map.SHAMAN = true
            end
        elseif(itemSubType == 'Mail') then
            map = {
                ['HUNTER'] = true,
                ['SHAMAN'] = true
            }
            
            if(itemMinLevel ~= nil and itemMinLevel < 40) then
                map.PALADIN = true
                map.WARRIOR = true
            end
        elseif(itemSubType == 'Plate') then
            map = {
                ['DEATHKNIGHT'] = true,
                ['PALADIN'] = true,
                ['WARRIOR'] = true
            }
        elseif(itemSubType == 'Idols') then
            map = {
                ['DRUID'] = true
            }
        elseif(itemSubType == 'Librams') then
            map = {
                ['PALADIN'] = true
            }
        elseif(itemSubType == 'Totems') then
            map = {
                ['SHAMAN'] = true
            }
        elseif(itemSubType == 'Sigils') then
            map = {
                ['DEATHKNIGHT'] = true
            }
        elseif(itemSubType == 'Shields') then
            map = {
                ['PALADIN'] = true,
                ['SHAMAN'] = true,
                ['WARRIOR'] = true
            }
        else
            return true
        end
        
        if(map[playerClass] ~= nil) then
            return true
        end
        
        return false
    end
    
    return true
end

function rule.hasbounty(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    if(IsAttunableBySomeone == nil) then
        return false
    end
    
    local fn = 'attunableatall'
    
    return GetCustomGameData(31, getItemId()) > 0
end