local rule = ArkInventoryRules:NewModule( 'ArkInventoryRules_Scoots' )
local TTH = nil

function ArkInventoryRules_Scoots_RegisterTTH(tooltip)
    TTH = tooltip
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
    ArkInventoryRules.Register(self, 'ATTUNEDANYAFFIX', rule.attunedanyaffix)
    ArkInventoryRules.Register(self, 'OPTIMALFORME', rule.optimalforme)
    ArkInventoryRules.Register(self, 'HASBOUNTY', rule.hasbounty)
    ArkInventoryRules.Register(self, 'HASAFFIX', rule.hasaffix)
    ArkInventoryRules.Register(self, 'HASATTUNEABLEUPGRADE', rule.hasattuneableupgrade)
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
    
    local fn = 'attunable'
    
    return CanAttuneItemHelper(CustomExtractItemId(ArkInventoryRules.Object.h)) > 0
end

function rule.attunableatall(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    if(IsAttunableBySomeone == nil) then
        return false
    end
    
    local fn = 'attunableatall'
    
    local check = IsAttunableBySomeone(CustomExtractItemId(ArkInventoryRules.Object.h))
    if(check ~= nil and check ~= 0) then
        return true
    end
    
    return false
end

function rule.attuned(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    if(GetItemLinkAttuneProgress == nil) then
        return false
    end
    
    local fn = 'attuned'
    
    if(rule.attunableatall() == false) then
        return false
    end
    
    if(tonumber(GetItemLinkAttuneProgress(ArkInventoryRules.Object.h)) < 100) then
        return false
    end
    
    return true
end

function rule.attunedanyaffix(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    local ac = select('#', ...)
    local fn = 'attunedanyaffix'
    
    if(rule.attunableatall() == false) then
        return false
    end
    
    if(GetItemAttuneForge == nil or GetItemLinkTitanforge == nil) then
        return false
    end
    
    local forgeLevel = GetItemAttuneForge(CustomExtractItemId(ArkInventoryRules.Object.h))
    if(ac == 0) then
        return forgeLevel >= GetItemLinkTitanforge(ArkInventoryRules.Object.h)
    end
    
    local arg = select(1, ...)
    if(type(arg) ~= 'number') then
        error(string.format(ArkInventory.Localise['RULE_FAILED_ARGUMENT_IS_INVALID'], fn, ax, string.format('%s', ArkInventory.Localise['STRING']), 0))
    end
    
    arg = math.floor(arg)
    if(arg > 3) then
        error(string.format(ArkInventory.Localise['RULE_FAILED_ARGUMENT_IS_INVALID'], fn, ax, string.format('%s', ArkInventory.Localise['STRING']), 0))
    end
    
    return forgeLevel >= arg
end

function rule.optimalforme(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    local fn = 'optimalforme'
    
    local playerClasses = {}
    local _, _, _, _, itemMinLevel, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(ArkInventoryRules.Object.h)
    
    local validWeaponsForAll = {
        ['Miscellaneous'] = true,
        ['Fishing Poles'] = true
    }
    
    local validArmourForAll = {
        ['INVTYPE_NECK'] = true,
        ['INVTYPE_FINGER'] = true,
        ['INVTYPE_TRINKET'] = true,
        ['INVTYPE_CLOAK'] = true,
        ['INVTYPE_HOLDABLE'] = true,
        ['INVTYPE_TABARD'] = true
    }
    
    if((itemType == 'Weapon' and validWeaponsForAll[itemSubType]) or (itemType == 'Armor' and validArmourForAll[itemEquipLoc])) then
        return true
    end
    
    if(CustomGetClassMask == nil) then
        local _, playerClass = UnitClass('player')
        table.insert(playerClasses, strupper(playerClass))
    else
        local mask = CustomGetClassMask()
        local classList = {
            ['DEATHKNIGHT'] = 6,
            ['DRUID'] = 11,
            ['HUNTER'] = 3,
            ['MAGE'] = 8,
            ['PALADIN'] = 2,
            ['PRIEST'] = 5,
            ['ROGUE'] = 4,
            ['SHAMAN'] = 7,
            ['WARLOCK'] = 9,
            ['WARRIOR'] = 1
        }
        
        for className, classId in pairs(classList) do
            if(bit.band(mask, bit.lshift(1, classId - 1)) > 0) then
                playerClasses[className] = true
            end
        end
    end
    
    local map = {}
    
    TTH:ClearLines()
    TTH:SetOwner(UIParent)
    TTH:SetHyperlink(ArkInventoryRules.Object.h)
    local lines = getTooltipLines(TTH)
    TTH:Hide()
    
    for _, line in pairs(lines) do
        local check = string.match(line, '^Classes: (.*)$')
        if(check) then
            local itemClasses = string.gmatch(check, '([^, ]*)')
            local classMatch = false
            
            for itemClass in itemClasses do
                if(playerClasses[string.upper(itemClass)]) then
                    classMatch = true
                    break
                end
            end
            
            if(classMatch == false) then
                return false
            end
            
            break
        end
    end
    
    if(itemType == 'Weapon') then
        map = {
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
                ['DRUID'] = true,
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
    elseif(itemType == 'Armor') then
        if(itemSubType == 'Cloth') then
            map.MAGE = true
            map.PRIEST = true
            map.WARLOCK = true
        elseif(itemSubType == 'Leather') then
            map.DRUID = true
            map.ROGUE = true
            
            if(itemMinLevel ~= nil and itemMinLevel < 40) then
                map.HUNTER = true
                map.SHAMAN = true
            end
        elseif(itemSubType == 'Mail') then
            map.HUNTER = true
            map.SHAMAN = true
            
            if(itemMinLevel ~= nil and itemMinLevel < 40) then
                map.HUNTER = false
                map.SHAMAN = false
                
                map.DEATHKNIGHT = true
                map.PALADIN = true
                map.WARRIOR = true
            end
        elseif(itemSubType == 'Plate') then
            map.DEATHKNIGHT = true
            map.PALADIN = true
            map.WARRIOR = true
        elseif(itemSubType == 'Idols') then
            map.DRUID = true
        elseif(itemSubType == 'Librams') then
            map.PALADIN = true
        elseif(itemSubType == 'Totems') then
            map.SHAMAN = true
        elseif(itemSubType == 'Sigils') then
            map.DEATHKNIGHT = true
        elseif(itemSubType == 'Shields') then
            map.PALADIN = true
            map.SHAMAN = true
            map.WARRIOR = true
        else
            return true
        end
    end
    
    local noOffhandWeapons = {
        ['DRUID'] = true,
        ['MAGE'] = true,
        ['PRIEST'] = true,
        ['WARLOCK'] = true
    }
    
    for playerClass, _ in pairs(playerClasses) do
        if(itemType == 'Weapon') then
            if(map[itemSubType][playerClass]) then
                if(itemEquipLoc ~= 'INVTYPE_WEAPONOFFHAND' or noOffhandWeapons[playerClass] == nil) then
                    return true
                end
            end
        elseif(itemType == 'Armor') then
            if(map[playerClass]) then
                return true
            end
        else
            return true
        end
    end
    
    return false
end

function rule.hasbounty(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    local fn = 'hasbounty'
    
    local arg = select(1, ...)
    if(arg == nil) then
        return GetCustomGameData(31, CustomExtractItemId(ArkInventoryRules.Object.h)) > 0
    else
        if(type(arg) ~= 'number') then
            error(string.format(ArkInventory.Localise['RULE_FAILED_ARGUMENT_IS_INVALID'], fn, ax, string.format('%s', ArkInventory.Localise['STRING']), 0))
        end
        
        arg = math.floor(arg)
        if(arg < 0) then
            error(string.format(ArkInventory.Localise['RULE_FAILED_ARGUMENT_IS_INVALID'], fn, ax, string.format('%s', ArkInventory.Localise['STRING']), 0))
        end
        
        return GetCustomGameData(31, CustomExtractItemId(ArkInventoryRules.Object.h)) >= arg
    end
end

function rule.hasaffix(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    local fn = 'hasaffix'
    
    local check = {}
    for substring in string.gmatch(ArkInventoryRules.Object.h, '([^:]*)') do
        if(substring and substring ~= '') then
            table.insert(check, substring)
        end
    end
    
    if(not check[8]) then
        return false
    end
    
    check = string.match(check[8], '-?%d+')
    
    return check and check ~= '0'
end

function rule.hasattuneableupgrade(...)
    if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= 'item' then
        return false
    end
    
    if not CustomExtractItemId or not CanAttuneItemHelper or not GetItemAttuneForge then
        return false
    end
    
    local fn = 'hasattuneableupgrade'
    local itemId = CustomExtractItemId(ArkInventoryRules.Object.h)
    local showIfAttuned = select(1, ...) and true
    local map = {
        [2944] = {2943},
        [4243] = {4244},
        [4246] = {4249},
        [4255] = {3844},
        [4368] = {4385},
        [4385] = {10500},
        [5966] = {7938},
        [7387] = {10721},
        [9149] = {13503},
        [10026] = {7189, 10724},
        [10500] = {10545, 16008},
        [10502] = {15999},
        [10543] = {10588},
        [13503] = {35748, 35749, 35750, 35751},
        [14044] = {15138},
        [16666] = {22102},
        [16667] = {22097},
        [16668] = {22100},
        [16669] = {22101},
        [16670] = {22096},
        [16671] = {22095},
        [16672] = {22099},
        [16673] = {22098},
        [16674] = {22060},
        [16675] = {22061},
        [16676] = {22015},
        [16677] = {22013},
        [16678] = {22017},
        [16679] = {22016},
        [16680] = {22010},
        [16681] = {22011},
        [16682] = {22064},
        [16683] = {22063},
        [16684] = {22066},
        [16685] = {22062},
        [16686] = {22065},
        [16687] = {22067},
        [16688] = {22069},
        [16689] = {22068},
        [16690] = {22083},
        [16691] = {22084},
        [16692] = {22081},
        [16693] = {22080},
        [16694] = {22085},
        [16695] = {22082},
        [16696] = {22078},
        [16697] = {22079},
        [16698] = {22074},
        [16699] = {22072},
        [16700] = {22075},
        [16701] = {22073},
        [16702] = {22070},
        [16703] = {22071},
        [16704] = {22076},
        [16705] = {22077},
        [16706] = {22113},
        [16707] = {22005},
        [16708] = {22008},
        [16709] = {22007},
        [16710] = {22004},
        [16711] = {22003},
        [16712] = {22006},
        [16713] = {22002},
        [16714] = {22108},
        [16715] = {22107},
        [16716] = {22106},
        [16717] = {22110},
        [16718] = {22112},
        [16719] = {22111},
        [16720] = {22109},
        [16721] = {22009},
        [16722] = {22088},
        [16723] = {22086},
        [16724] = {22090},
        [16725] = {22087},
        [16726] = {22089},
        [16727] = {22091},
        [16728] = {22092},
        [16729] = {22093},
        [16730] = {21997},
        [16731] = {21999},
        [16732] = {22000},
        [16733] = {22001},
        [16734] = {21995},
        [16735] = {21996},
        [16736] = {21994},
        [16737] = {21998},
        [17193] = {17182},
        [17204] = {17182},
        [18608] = {18609},
        [21196] = {21197},
        [21197] = {21198},
        [21198] = {21199},
        [21199] = {21200},
        [21201] = {21202},
        [21202] = {21203},
        [21203] = {21204},
        [21204] = {21205},
        [21206] = {21207},
        [21207] = {21208},
        [21208] = {21209},
        [21209] = {21210},
        [23563] = {23564},
        [23564] = {23565},
        [28425] = {28426},
        [28426] = {28427},
        [28428] = {28429},
        [28429] = {28430},
        [28431] = {28432},
        [28432] = {28433},
        [28434] = {28435},
        [28435] = {28436},
        [28437] = {28438},
        [28438] = {28439},
        [28440] = {28441},
        [28441] = {28442},
        [28483] = {28484},
        [28484] = {28485},
        [29276] = {29277},
        [29277] = {29278},
        [29278] = {29279},
        [29280] = {29281},
        [29281] = {29282},
        [29282] = {29283},
        [29284] = {29285},
        [29285] = {29286},
        [29286] = {29287},
        [29288] = {29289},
        [29289] = {29291},
        [29291] = {29290},
        [29294] = {29295},
        [29295] = {29296},
        [29296] = {29297},
        [29298] = {29299},
        [29299] = {29300},
        [29300] = {29301},
        [29302] = {29303},
        [29303] = {29304},
        [29304] = {29305},
        [29306] = {29308},
        [29307] = {29306},
        [29308] = {29309},
        [32461] = {34354},
        [32472] = {35185},
        [32473] = {34357},
        [32474] = {34356},
        [32475] = {35184},
        [32476] = {34355},
        [32478] = {34353},
        [32479] = {35183},
        [32480] = {35182},
        [32494] = {34847},
        [32495] = {35181},
        [32649] = {32757},
        [34167] = {34382},
        [34169] = {34384},
        [34170] = {34386},
        [34180] = {34381},
        [34186] = {34383},
        [34188] = {34385},
        [34192] = {34388},
        [34193] = {34389},
        [34195] = {34392},
        [34202] = {34393},
        [34208] = {34390},
        [34209] = {34391},
        [34211] = {34397},
        [34212] = {34398},
        [34215] = {34394},
        [34216] = {34395},
        [34229] = {34396},
        [34233] = {34399},
        [34234] = {34408},
        [34243] = {34401},
        [34244] = {34404},
        [34245] = {34403},
        [34332] = {34402},
        [34339] = {34405},
        [34342] = {34406},
        [34345] = {34400},
        [34350] = {34409},
        [34351] = {34407},
        [40585] = {45691},
        [40586] = {45688},
        [41245] = {47589, 47590},
        [41355] = {47572, 47573},
        [41520] = {41544},
        [44934] = {45689},
        [44935] = {45690},
        [45688] = {48954},
        [45689] = {48955},
        [45690] = {48956},
        [45691] = {48957},
        [48954] = {51560},
        [48955] = {51558},
        [48956] = {51559},
        [48957] = {51557},
        [49302] = {49301},
        [49496] = {49497},
        [49888] = {49623},
        [50078] = {51214},
        [50079] = {51213},
        [50080] = {51212},
        [50081] = {51211},
        [50082] = {51210},
        [50087] = {51189},
        [50088] = {51188},
        [50089] = {51187},
        [50090] = {51186},
        [50094] = {51129},
        [50095] = {51128},
        [50096] = {51127},
        [50097] = {51126},
        [50098] = {51125},
        [50105] = {51185},
        [50106] = {51139},
        [50107] = {51138},
        [50108] = {51137},
        [50109] = {51136},
        [50113] = {51135},
        [50114] = {51154},
        [50115] = {51153},
        [50116] = {51152},
        [50117] = {51151},
        [50118] = {51150},
        [50240] = {51209},
        [50241] = {51208},
        [50242] = {51207},
        [50243] = {51206},
        [50244] = {51205},
        [50275] = {51159},
        [50276] = {51158},
        [50277] = {51157},
        [50278] = {51156},
        [50279] = {51155},
        [50324] = {51160},
        [50325] = {51161},
        [50326] = {51162},
        [50327] = {51163},
        [50328] = {51164},
        [50375] = {50388},
        [50376] = {50387},
        [50377] = {50384},
        [50378] = {50386},
        [50384] = {50397},
        [50386] = {50399},
        [50387] = {50401},
        [50388] = {50403},
        [50391] = {51183},
        [50392] = {51184},
        [50393] = {51181},
        [50394] = {51180},
        [50396] = {51182},
        [50397] = {50398},
        [50399] = {50400},
        [50401] = {50402},
        [50403] = {50404},
        [50765] = {51178},
        [50766] = {51179},
        [50767] = {51175},
        [50768] = {51176},
        [50769] = {51177},
        [50819] = {51147},
        [50820] = {51146},
        [50821] = {51149},
        [50822] = {51148},
        [50823] = {51145},
        [50824] = {51140},
        [50825] = {51142},
        [50826] = {51143},
        [50827] = {51144},
        [50828] = {51141},
        [50830] = {51195},
        [50831] = {51196},
        [50832] = {51197},
        [50833] = {51198},
        [50834] = {51199},
        [50835] = {51190},
        [50836] = {51191},
        [50837] = {51192},
        [50838] = {51193},
        [50839] = {51194},
        [50841] = {51200},
        [50842] = {51201},
        [50843] = {51202},
        [50844] = {51203},
        [50845] = {51204},
        [50846] = {51215},
        [50847] = {51216},
        [50848] = {51218},
        [50849] = {51217},
        [50850] = {51219},
        [50853] = {51130},
        [50854] = {51131},
        [50855] = {51133},
        [50856] = {51132},
        [50857] = {51134},
        [50860] = {51170},
        [50861] = {51171},
        [50862] = {51173},
        [50863] = {51172},
        [50864] = {51174},
        [50865] = {51166},
        [50866] = {51168},
        [50867] = {51167},
        [50868] = {51169},
        [50869] = {51165},
        [51125] = {51314},
        [51126] = {51313},
        [51127] = {51312},
        [51128] = {51311},
        [51129] = {51310},
        [51130] = {51309},
        [51131] = {51308},
        [51132] = {51307},
        [51133] = {51306},
        [51134] = {51305},
        [51135] = {51304},
        [51136] = {51303},
        [51137] = {51302},
        [51138] = {51301},
        [51139] = {51300},
        [51140] = {51299},
        [51141] = {51298},
        [51142] = {51297},
        [51143] = {51296},
        [51144] = {51295},
        [51145] = {51294},
        [51146] = {51293},
        [51147] = {51292},
        [51148] = {51291},
        [51149] = {51290},
        [51150] = {51289},
        [51151] = {51288},
        [51152] = {51287},
        [51153] = {51286},
        [51154] = {51285},
        [51155] = {51284},
        [51156] = {51283},
        [51157] = {51282},
        [51158] = {51281},
        [51159] = {51280},
        [51160] = {51279},
        [51161] = {51278},
        [51162] = {51277},
        [51163] = {51276},
        [51164] = {51275},
        [51165] = {51274},
        [51166] = {51273},
        [51167] = {51272},
        [51168] = {51271},
        [51169] = {51270},
        [51170] = {51269},
        [51171] = {51268},
        [51172] = {51267},
        [51173] = {51266},
        [51174] = {51265},
        [51175] = {51264},
        [51176] = {51263},
        [51177] = {51262},
        [51178] = {51261},
        [51179] = {51260},
        [51180] = {51259},
        [51181] = {51258},
        [51182] = {51257},
        [51183] = {51256},
        [51184] = {51255},
        [51185] = {51254},
        [51186] = {51253},
        [51187] = {51252},
        [51188] = {51251},
        [51189] = {51250},
        [51190] = {51249},
        [51191] = {51248},
        [51192] = {51247},
        [51193] = {51246},
        [51194] = {51245},
        [51195] = {51244},
        [51196] = {51243},
        [51197] = {51242},
        [51198] = {51241},
        [51199] = {51240},
        [51200] = {51239},
        [51201] = {51238},
        [51202] = {51237},
        [51203] = {51236},
        [51204] = {51235},
        [51205] = {51234},
        [51206] = {51233},
        [51207] = {51232},
        [51208] = {51231},
        [51209] = {51230},
        [51210] = {51229},
        [51211] = {51228},
        [51212] = {51227},
        [51213] = {51226},
        [51214] = {51225},
        [51215] = {51224},
        [51216] = {51223},
        [51217] = {51222},
        [51218] = {51221},
        [51219] = {51220},
        [52569] = {52570},
        [52570] = {52571},
        [52571] = {52572},
    }
    
    if(map[itemId] ~= nil) then
        for _, subItemId in pairs(map[itemId]) do
            if(CanAttuneItemHelper(subItemId) and (showIfAttuned or GetItemAttuneForge(subItemId) == -1)) then
                return true
            end
        end
    end
    
    return false
end