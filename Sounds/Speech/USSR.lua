--Speech construction protocol "NATO"

local base = _G

module('USSR')

local common = base.require('common')

--inheritance from common table
base.setmetatable(base.getfenv(), common)

local p = base.require('phrase')
local u = base.require('utils')

local gettext = base.require("i_18n")
local _ = gettext.translate
PhoneticAlphabet = {  --start adds by JTAC mod
    make = function(self, str)
        local length = base.string.len(str)
        local result = p.start()
        for i = 1, length do
            local pos = ''
            if i == length then
                pos = '-end'
            elseif i == 1 then
                pos = '-begin'
            else
                pos = '-continue'
            end        
            local char = base.string.upper(base.string.sub(str, i, i))
            local phrase = self.phrases[char]
            if phrase ~= nil then
                result = result + p._p( { char, 'Alphabet/'..phrase..pos,  phrase} )
            else
                local number = base.tonumber(char)
                if number then
                    result = result + p._p( { char, 'Digits/'..char..pos, char } )
                else
                    result = result + p._p( { char, 'Alphabet/'..char..pos, char } )
                end
            end
        end
        return result
    end,
    phrases = {    ['A'] = 'Alpha',
                ['B'] = 'Bravo',
                ['C'] = 'Charlie',
                ['D'] = 'Delta',
                ['E'] = 'Echo',
                ['F'] = 'Foxtrot',
                ['G'] = 'Golf',
                ['H'] = 'Hotel',
                ['I'] = 'India',
                ['J'] = 'Juliett',
                ['K'] = 'Kilo',
                ['L'] = 'Lima',
                ['M'] = 'Mike',
                ['N'] = 'November',
                ['O'] = 'Oscar',
                ['P'] = 'Papa',
                ['Q'] = 'Quebec',
                ['R'] = 'Romeo',
                ['S'] = 'Sierra',
                ['T'] = 'Tango',
                ['U'] = 'Uniform',
                ['V'] = 'Victor',
                ['W'] = 'Whiskey',
                ['X'] = 'X-ray',
                ['Y'] = 'Yankee',
                ['Z'] = 'Zulu'},
    pos3 = true,
    directory = 'Alphabet'
}

Time = {
    make = function(self, timeSec, zulu)
        local hh, mm, ss = u.getTime(timeSec)
        return self.sub.Number:make(hh) + self.sub.Number:make(mm) + ' '  + (zulu and self.sub.Zulu:make() or self.sub.UTC:make())
    end,
    sub = {    Number    = Number,
            Zulu    = Phrase:new({_('Zulu'),     'Zulu'}),
            UTC        = Phrase:new({_('UTC'),     'UTC'})    }
}

wantRR = true   --Доб Ми-8--
wantLL = true   --Доб Ка-50--
MGRS = {
    make = function(self, point, accuracy, zone, digraph)
        
        if zone == nil then
            zone = false
        end
        if digraph == nil then
            digraph = true
        end
        
        local lat, lon = base.coord.LOtoLL(point)
        local MGRS = base.coord.LLtoMGRS(lat, lon)
        
        if     accuracy and
            accuracy < 5 then
            MGRS.Easting = base.math.floor(MGRS.Easting / 10 ^ (5 - accuracy) + 0.5)
            MGRS.Northing = base.math.floor(MGRS.Northing / 10 ^ (5 - accuracy) + 0.5)
        end
        
        local str = ""
        if zone then
            str = str..MGRS.UTMZone
        end
        if digraph then
            str = str..MGRS.MGRSDigraph
        end
        local fmt = '%0'..accuracy..'d'
        if wantLL then                               --Доб Ка-50
            -- Convert lat/lon to degrees & minutes
            local decimals = 0.1 -- decimals in minutes
            local latDeg = base.math.floor(lat)
            local lonDeg = base.math.floor(lon)
            local latMin = u.round((60*(lat - latDeg)), decimals)
            local lonMin = u.round((60*(lon - lonDeg)), decimals)
            return self.sub.North:make() +  self.sub.PhoneticAlphabet:make(latDeg) + self.sub.And:make() +  self.sub.PhoneticAlphabet:make(latMin) + comma_space_ +  self.sub.East:make() + 0 + self.sub.PhoneticAlphabet:make(lonDeg) +  self.sub.And:make() + self.sub.PhoneticAlphabet:make(lonMin)
            --return self.sub.North:make() +  self.sub.PhoneticAlphabet:make(u.round(lat, 0.001)) + comma_space_ +  self.sub.East:make() + self.sub.PhoneticAlphabet:make(u.round(lon,  0.001))        
        end                                                    --
        ----------------------------
        if wantRR then
        ----------------------------
        ----------Координаты
            local num1 = base.coord.LLtoMGRS(lat, lon);
            local east_num_kvadrat, east_coord_ishodn = base.math.modf( num1.Easting/10000);
            local north_num_kvadrat, north_coord_ishodn = base.math.modf( num1.Northing/10000);
            --Улитка начало    1
            local east_coord, east_coord_3 = base.math.modf ( east_coord_ishodn*100);
            local north_coord, north_coord_3 = base.math.modf (north_coord_ishodn*100);
            local ulitka_1 = 0;
            if east_coord <= 33 and north_coord > 66 then ulitka_1 = 1; end
            if east_coord > 33 and east_coord <= 66 and north_coord > 66 then ulitka_1 = 2; end
            if east_coord > 66  and north_coord > 66 then ulitka_1 = 3; end
            if east_coord > 66  and north_coord <= 66 and north_coord > 33 then ulitka_1 = 4; end
            if east_coord > 66 and north_coord <= 33 then ulitka_1 = 5; end
            if east_coord > 33 and east_coord <= 66 and north_coord <= 33 then ulitka_1 = 6; end
            if east_coord <= 33 and north_coord <= 33 then ulitka_1 = 7; end
            if east_coord <= 33 and north_coord <= 66 and north_coord > 33 then ulitka_1 = 8; end
            if east_coord > 33 and east_coord <= 66 and  north_coord <= 66 and north_coord > 33 then ulitka_1 = 9; end
            --Улитка конец    1
            --Улитка начало    2                
            local east_coord_2 = east_coord_3*100;
            local north_coord_2 = north_coord_3*100;
            local ulitka_2 = 0;
            if east_coord_2 <= 33 and north_coord_2 > 66 then ulitka_2 = 1; end
            if east_coord_2 > 33 and east_coord_2 <= 66 and north_coord_2 > 66 then ulitka_2 = 2; end
            if east_coord_2 > 66  and north_coord_2 > 66 then ulitka_2 = 3; end
            if east_coord_2 > 66  and north_coord_2 <= 66 and north_coord_2 > 33 then ulitka_2 = 4; end
            if east_coord_2 > 66 and north_coord_2 <= 33 then ulitka_2 = 5; end
            if east_coord_2 > 33 and east_coord_2 <= 66 and north_coord_2 <= 33 then ulitka_2 = 6; end
            if east_coord_2 <= 33 and north_coord_2 <= 33 then ulitka_2 = 7; end
            if east_coord_2 <= 33 and north_coord_2 <= 66 and north_coord_2 > 33 then ulitka_2 = 8; end
            if east_coord_2 > 33 and east_coord_2 <= 66 and  north_coord_2 <= 66 and north_coord_2 > 33 then ulitka_2 = 9; end
            --Улитка конец    2    
            star = num1.MGRSDigraph    
            return self.sub.Kvadrat:make() + space_ +  self.sub.PhoneticAlphabet:make(star) +  self.sub.PhoneticAlphabet:make(east_num_kvadrat) +  self.sub.PhoneticAlphabet:make(north_num_kvadrat) + space_ +  self.sub.PoUlitke:make() + space_ +  self.sub.PhoneticAlphabet:make(ulitka_1) +  self.sub.PhoneticAlphabet:make(ulitka_2)
            --return self.sub.PhoneticAlphabet:make(star) +  self.sub.PhoneticAlphabet:make(east_num_kvadrat) +  self.sub.PhoneticAlphabet:make(north_num_kvadrat) + space_ +  self.sub.PhoneticAlphabet:make(ulitka_1) +  self.sub.PhoneticAlphabet:make(ulitka_2)
        end
        -----------------------------
        
        str = str..base.string.format(fmt, MGRS.Easting)..base.string.format(fmt, MGRS.Northing)
        return self.sub.PhoneticAlphabet:make(str)
            
    end,
    sub = {
        PhoneticAlphabet    = PhoneticAlphabet        
        ,North = Phrase:new({_('N'), 'N'})    --Доб Ка-50--
        ,East = Phrase:new({_('E'), 'E'})     --Доб Ка-50--
        ,And = Phrase:new({'\'', 'and'})    --Доб Ка-50--
        ,Kvadrat = Phrase:new({_('Grid'), 'grid'})    --------------------
        ,PoUlitke = Phrase:new({_('Cell'), 'cell'})        ---------------------
        --------------------------------
    }
}  --end adds by JTAC mod

--AWACS -> PLAYER

AWACSpictureHandler = {
	make = function(self, message, language)
		
		local pUnit = message.sender:getUnit()
		
		local result = self.sub.AWACSToClientHandler:make(message, language)
		
		local groupsQty = #message.parameters.groups
		base.assert(groupsQty > 0)
		
		if groupsQty > 1 then
			result = result + comma_space_ + self.sub.Number:make(groupsQty) + ' ' + self.sub.groups:make()
			for targetIndex, target in base.pairs(message.parameters.groups) do
				local desc
				if targetIndex == 1 then
					desc = self.sub.firstGroup:make()
				else
					desc = self.sub.additionalGroup:make()
				end		
				result = result + CR_ + desc + ' ' + self.sub.AWACSTargetDir:make(target, message.receiver, pUnit:getCountry())
			end
		else
			local group = message.parameters.groups[1]
			result = result + ' ' + self.sub.oneGroup:make() + CR_ + self.sub.AWACSTargetDir:make(group, message.receiver, pUnit:getCountry())
		end
		return result
		
	end,
	sub = {	AWACSToClientHandler	= AWACSToClientHandler,
			groups					= Phrase:new({_('groups'),				'groups'}),
			firstGroup				= Phrase:new({_('First group'),			'First group'}),
			additionalGroup			= Phrase:new({_('Additional group'),	'Additional group'}),
			oneGroup				= Phrase:new({_('single group'),		'single group'}),
			AWACSTargetDir			= AWACSTargetDir,
			Number					= Number}
}

AWACSBullVectorHandler = {
	make = function(self, message, language)
		local pUnit = message.sender:getUnit()
		local receiverPos = message.receiver:getUnit():getPosition().p
		local dir = {	x = message.parameters.point.x - receiverPos.x,
						y = message.parameters.point.y - receiverPos.y,
						z = message.parameters.point.z - receiverPos.z }
		return 	self.sub.AWACSToClientHandler:make(message, language) + ' ' +
				self.sub.Direction:make(dir, pUnit:getCountry())
	end,
	sub = {	AWACSToClientHandler	= AWACSToClientHandler,
			Direction				= Direction }
}

--PLAYER -> ATC
--start adds by JTAC mod
--JTAC

CallsignJTAC = {
    make = function(self, pComm)
        if pComm == nil then
            return p.start()
        end
        local pUnit = pComm:getUnit()
        local callsign = pComm:getCallsign()
        if isHeavyAircraft(pUnit) then
            local groupName = base.math.floor(callsign / 100)
            return self.sub.UnitCallname:make(pUnit, groupName)
        else
            local groupName, flightNum, aircraftNum = encodeCallsign(callsign)
            return ' ' + self.sub.DigitGroups:make('%d-%d', flightNum, aircraftNum)
        end
    end,
    sub = { UnitCallname     = UnitCallname:new({'Air', 'Ground Units'} , false, {'A-10A', 'A-10C'}, 'Callsign'),
            DigitGroups        = DigitGroups}
}

do

local SUU25 = {_('SUU-25'),                 'SUU-25'}
local TGP    = {'targeting pod equipped',     'TGP'}

WeaponType = {
    make = function(self, wsType)
        if base.type(wsType) == 'table' then    
            return self:make_(wsType)
        else
            wsTypeTable = {}
            wsTypeTable[4] = base.math.floor(wsType / 256 / 256 / 256)
            wsType = wsType - wsTypeTable[4] * 256 * 256 * 256
            wsTypeTable[3] = base.math.floor(wsType / 256 / 256)
            wsType = wsType - wsTypeTable[3] * 256 * 256
            wsTypeTable[2] = base.math.floor(wsType / 256 )
            wsType = wsType - wsTypeTable[2] * 256    
            wsTypeTable[1] = wsType
            return self:make_(wsTypeTable)
        end
    end,
    make_ = function(self, wsType)
        base.assert(wsType[1] == base.wsType_Weapon)
        return self.sub[wsType[2]]:make(wsType[4])        
    end,
    sub = {
        [base.wsType_Shell]        = PhraseRandom:new({{_('cannon'),     'cannon'},
                                                    {_('gun'),        'gun'} }, 'Weapon' ),
        [base.wsType_Missile]    = Phrases:new({    [base.AGM_65K]    = {_('AGM-65K'), 'AGM-65K'},
                                                [base.AGM_65E]    = {_('AGM-65E'), 'AGM-65E'},
                                                [base.AGM_65D]    = {_('AGM-65D'), 'AGM-65D'},
                                                [base.AGM_65H]    = {_('AGM-65H'), 'AGM-65H'},
                                                [base.AGM_65G]    = {_('AGM-65G'), 'AGM-65G'},
                                                [base.AGM_114K]    = {_('Radar Hellfire'), 'Radar Hellfire'},
                                                [base.AGM_114]    = {_('Laser Hellfire'), 'Laser Hellfire'},
                                                [base.AGM_45]     = {_('Shrike'), 'Shrike'},
                                                --[base.AGM_84A]     = {_('AGM-84A'), 'AGM-84A'},
                                                --[base.AGM_84E]     = {_('AGM-84E'), 'AGM-84E'},
                                                [base.AGM_88]     = {_('HARM'), 'HARM'},
                                                --[base.Sea_Eagle]= {_('Sea Eagle'), 'Sea Eagle'},
                                                [base.AGM_130]    = {_('AGM-130'), 'AGM-130'},
                                                --[base.ALARM]    =   {_('Alarm'), 'Alarm'},                                                
                                                --[base.Kormoran] = {_('Kormoran'), 'Kormoran'},
                                                [base.AGM_154]    = {_('JSOW'), 'JSOW'},
                                                [base.Vikhr]    = {_('Vikhr'), 'Vikhr'},
                                                [base.Vikhr_M]    = {_('Vikhr'), 'Vikhr'},
                                                [base.X_25ML]    = {_('X-25ML'), 'X-25ML'},
                                                [base.AT_6_9M114]    = {_('Shturm'), 'Shturm'} }, 'Weapon'),
        [base.wsType_Bomb]        = Phrases:new({ [base.Mk_81]    = {_('Mk-81'), 'Mk-81'},
                                                [base.Mk_82]    = {_('Mk-82'), 'Mk-82'},
                                                [base.MK_82AIR] = {_('Mk-82 Air'), 'Mk-82 Air'},
                                                [base.Mk_83]    = {_('Mk-83'), 'Mk-83'},
                                                [base.Mk_84]    = {_('Mk-84'), 'Mk-84'},
                                                [base.CBU_97]    = {_('CBU-97'), 'CBU-97'},
                                                [base.CBU_87]    = {_('CBU-87'), 'CBU-87'},
                                                --[base.CBU_89]    = {_('CBU-89'), 'CBU-89'},
                                                [123045]        = {_('CBU-103'), 'CBU-103'},
                                                [base.ROCKEYE]    = {_('Mk-20'), 'Mk-20'},
                                                [base.GBU_10]    = {_('GBU-10'), 'GBU-10'},
                                                --[base.GBU_11]    = {_('GBU-11'), 'GBU-11'},
                                                [base.GBU_12]    = {_('GBU-12'), 'GBU-12'},
                                                [base.GBU_17]    = {_('GBU-17'), 'GBU-17'},
                                                [base.GBU_24]    = {_('GBU-24'), 'GBU-24'},
                                                [base.GBU_15]    = {_('GBU-15'), 'GBU-15'},
                                                [base.GBU_27]    = {_('GBU-27'), 'GBU-27'},
                                                [base.GBU_22]    = {_('GBU-22'), 'GBU-22'},
                                                [base.GBU_28]    = {_('GBU-28'), 'GBU-28'},
                                                [base.GBU_29]    = {_('GBU-29'), 'GBU-29'},
                                                [base.GBU_30]    = {_('GBU-30'), 'GBU-30'},
                                                [base.GBU_31]    = {_('GBU-31'), 'GBU-31'},
                                                [base.GBU_38]    = {_('GBU-38'), 'GBU-38'},
                                                --[base.Durandal] =   {_('Durandal'), 'Durandal'},                                                  
                                                [base.LUU_2B]    = SUU25,
                                                [base.LUU_19]    = SUU25,
                                                [base.LUU_2AB]    = SUU25,
                                                [base.LUU_2BB]    = SUU25}, 'Weapon', {_('bombs'), 'bombs'}),
        [base.wsType_NURS]        = Phrase:new({_('rockets'), 'rockets'}, 'Weapon'),
        [base.wsType_GContainer]= Phrases:new( {[base.AN_AAQ_28_LITENING]    = TGP,
                                                [base.FLIR_POD]             = TGP,
                                                [base.LANTIRN]                = TGP,
                                                [base.LANTIRN_F14]            = TGP,
                                                [base.LANTIRN_F18]            = TGP}, 'Weapon' )
    }
}
end

TargetTypes = {
    make = function(self, typeId, column, size, moving)
        return self.sub[typeId]:make(column, size, moving)
    end
}

do
    local AAA = {_('AAA'), 'AAA', 'tripple A'}
    local SAM = {_('SAM'), 'SAM'}

    TargetType = {
        new = function(self, name, groupName, columnName, position)
            base.assert(name ~= nil)
            local targetType = {     sub = {    name        = Phrase:new(name, 'Target'),
                                            groupName    = groupName and Phrase:new(groupName, 'Target') or nil,
                                            columnName    = columnName and Phrase:new(columnName, 'Target') or nil,
                                            position    = position,
                                            Number         = Number}}
            base.setmetatable(targetType, self)
            return targetType
        end,
        make = function(self, column, size, moving)
            if size > 1 then
                if     column and
                    self.sub.columnName then
                    return self.sub.columnName:make()
                elseif self.sub.groupName then
                    return self.sub.groupName:make()
                else
                    return self.sub.name:make()
                end
            else
                return self.sub.name:make()
            end
        end,
    }
    
    TargetType.__index = TargetType
        
    TargetTypes.sub = {
        TargetType:new( {_('ground unit'),                 'ground unit'},
                        {_('ground units'),             'ground units'},
                        {_('column of ground units'),     {'column of', 'ground units'},        'column of ground units'} ),
        TargetType:new( {_('vehicle'),                     'vehicle'},
                        {_('vehicles'),                 'vehicles'},    
                        {_('column of vehicles'),        {'column of', 'vehicles'},            'column of vehicles'} ),
        TargetType:new( {_('armored vehicle'),            'armored vehicle'},
                        {_('armored vehicles'),         'armored vehicles'},
                        {_('column of armored vehicles'),{'column of', 'armored vehicle'},    'column of armored vehicles'} ),

        TargetType:new( {_('infantry'),                 'infantry'},
                        nil,
                        {_('infantry column'),            {'infantry', 'column'},                'infantry column'} ),
        TargetType:new( {_('mechanized infantry'),         'mechanized infantry'},
                        {_('mechanized infantry'),         'mechanized infantry'},
                        {_('mechanized infantry column'),{'mechanized infantry', 'column'},    'mechanized infantry column'} ),

        TargetType:new( {_('APC'),                         'APC',                                'A Pe Ce'},
                        nil,
                        {_('APC column'),                  {'APC', 'column'},                    'A Pe Ce column'} ),
        TargetType:new( {_('IFV'),                         'IFV',                                'I eF Ve'},
                        nil,
                        {_('IFV column'),                 {'IFV', 'column'},                    'I eF Ve column'} ),
        TargetType:new( {_('tank'),                     'tank'},
                        {_('tanks'),                     'tanks'},
                        {_('tank column'),                 {'tank', 'column'},                    'tank column'} ),

        TargetType:new( {_('artillery'),                'artillery'},
                        nil,
                        {_('artillery column'),         {'artillery', 'column'},            'artillery column'} ),
        
        TargetType:new( {_('car'),                        'car'},
                        {_('cars'),                        'cars'},
                        {_('car convoy'),                {'car', 'convoy'},                    'car convoy'} ),
        TargetType:new( {_('car'),                        'car'},
                        {_('cars'),                        'cars'},
                        {_('car convoy'),                {'car', 'convoy'},                    'car convoy'} ), 
        TargetType:new( {_('truck'),                    'truck'},
                        {_('trucks'),                    'trucks'},
                        {_('truck convoy'),                {'truck', 'convoy'},                'truck convoy'} ), 

        TargetType:new( {_('bunker'),                    'bunker'},
                        {_('bunkers'),                    'bunkers'},
                        nil ),
        TargetType:new( {_('radar'),                    'radar'},
                        {_('radars'),                    'radars'},
                        nil ),
        TargetType:new( AAA,
                        AAA,
                        nil ),
        TargetType:new( SAM,
                        SAM,
                        nil ),
    }
end

TargetDescription = {
    make = function(self, target_description)

        local targetType = target_description.type[#target_description.type]
        
        local vel_scalar = target_description.velocity and u.get_lengthZX(target_description.velocity)
        local moving = vel_scalar and vel_scalar > 1.0        
        
        local result = self.sub.TargetTypes:make(targetType + 1, target_description.column, target_description.size, moving)
        
        if target_description.on_road then
            result = result + ' ' + self.sub.onRoad:make()
        end
        if moving then
            result = result + comma_space_ + self.sub.moving:make() + ' '   +   self.sub.CompassDirection8:make(u.get_azimuth(target_description.velocity))
        end
        
        return result
    end,
    sub = {
        TargetTypes         = TargetTypes,
        moving                = Phrase:new({_('moving'),        'moving'}),
        onRoad                = Phrase:new({_('on a road'),    'on a road'}),
        CompassDirection8    = CompassDirection8,
    },
    directory = 'Target'
}

TargetData = {
    make = function(self, target_data)        
        return self.sub.TargetDescription:make(target_data) + comma_space_ + self.sub.MGRS:make(target_data.point, 3)        
    end,
    sub = {
        TargetDescription    = TargetDescription,
        MGRS                = MGRS
    }
}

NineLineBrief = {
    make = function(self, _9_line_brief)
        local IP
        local Heading
        local Distnace
        if _9_line_brief.IP and _9_line_brief.dir then
            IP = self.sub.NamesIP:make(_9_line_brief.IP)
            Heading = self.sub.Digits:make(u.round(u.get_azimuth(_9_line_brief.dir) * u.units.deg.coeff, 1), '%03d')
            Distnace = self.sub.Number:make(u.adv_round(u.get_lengthZX(_9_line_brief.dir) * u.units.nm.coeff))
        end
        
        local offset
        if _9_line_brief.offset == -1 then
            offset = self.sub.left:make()
        elseif _9_line_brief.offset == 1 then
            offset = self.sub.right:make()
        end
                
        local target_location
        if _9_line_brief.target_location then
            target_location = self.sub.MGRS:make(_9_line_brief.target_location, 3)
        else
            target_location = self.sub.NA:make().subtitle
        end
                
        local laser_code
        if _9_line_brief.code then
            laser_code = self.sub.Digits:make(_9_line_brief.code)
        end
        
        local location_of_friendlies = self.sub.noFactor:make()
        if _9_line_brief.friendlies then
            location_of_friendlies =   self.sub.CompassDirection8:make(u.get_azimuth(_9_line_brief.friendlies.dir))   + ' ' +   self.sub.Number:make(u.adv_round(u.get_lengthZX(_9_line_brief.friendlies.dir)   * u.units.m.coeff))
            if _9_line_brief.friendlies.troopsInContact then
                location_of_friendlies = location_of_friendlies + ' ' +   self.sub.m:make() + comma_space_ + self.sub.troopsInContact:make()
            end
        else
            location_of_friendlies = self.sub.noFactor:make()
        end    
        
        local egress_to = p.start()
        if _9_line_brief.egress_direction then
            egress_to = egress_to + self.sub.CompassDirection4:make(_9_line_brief.egress_direction)
        end
        if _9_line_brief.egress_control_point then
            egress_to = egress_to + ' ' + self.sub.to:make() + ' ' + self.sub.NamesIP:make(_9_line_brief.egress_control_point)
        end
                
        local result =     p.start()
        if IP == nil then
            result = result + self.sub.Digits:make(1) + comma_space_ +   self.sub.Digits:make(2) + comma_space_ + self.sub.Digits:make(3) + ' ' +   self.sub.NA:make() + CR_
        else
            result =     result +
                        p._S(_('1. IP: '))                + IP + CR_ +
                        p._S(_('2. Heading: '))         + Heading + ' ' + p._S(_('Offset: ')) + (offset or '') + CR_ +
                        p._S(_('3. Distance: '))        + Distnace + ' ' + self.sub.nm:make() + CR_
        end
    
        result =     result +
                    p._S(_('4. Elevation: '))            +   self.sub.Number:make(u.adv_round(_9_line_brief.target_elevation, 1)) + '   ' + self.sub.m:make() + ' ' + self.sub.MSL:make() + CR_ +
                    p._S(_('5. Target: '))                +   self.sub.TargetDescription:make(_9_line_brief.target_description) + CR_  +
                    p._S(_('6. Coordinates: '))            + target_location + CR_ +
                    p._S(_('7. '))                        + self.sub.markType:make(_9_line_brief.mark_type + 1)
        if laser_code then
            result = result + comma_space_ + laser_code
        end
        result = result + CR_
        result =     result +
                    p._S(_('8. Friendlies: '))            + location_of_friendlies + CR_ +
                    p._S(_('9. ')) + self.sub.egress:make()    + ' ' + egress_to
                    
        return result
    end,
    sub = {
        NamesIP                = NamesIP,
        NA                    = Phrase:new({_('N/A'),                 'NA',                 'eN A'}),
        left                = Phrase:new({_('left'),                 'left'}),
        right                = Phrase:new({_('right'),                 'right'}),
        troopsInContact        = Phrase:new({_('troops in contact'),    'troops in contact'}),
        noFactor            = Phrase:new({_('no factor'),             'no factor'}),
        to                    = Phrase:new({_('to'),                     'to'}),
        nm                    = Phrase:new({_('nautical'),             'nautical'}),
        m                    = Phrase:new({_('meters'),                 'meters'}),
        feet                = Phrase:new({_('feet'),                 'feet'}),
        MSL                    = Phrase:new({_('MSL'),                 'MSL',                'eM eS eL'}),
        egress                = Phrase:new({_('Egress'),                 'Egress'}),        
        Digits                = Digits,
        Number                = Number,
        TargetDescription    = TargetDescription,
        MGRS                = MGRS,
        CompassDirection8    = CompassDirection8,
        CompassDirection4     = CompassDirection4,
        markType            = Phrases:new( {{_('No mark'),             'No mark'}, 
                                            {_('Marked by WP'),     'Marked by WP',     'Marked by Double U Pete'},
                                            {_('Marked by IR'),     'Marked by IR',     'Marked by infrared pointer'},
                                            {_('Marked by laser'),     'Marked by laser'}} )
    }
}

NineLineBriefRemarks = {
    make = function(self, _9_line_brief_remarks)
        local result = p.start()

        if _9_line_brief_remarks.laser_to_target_line then
            local ltl_azimuth_deg =    base.math.floor(u.get_azimuth(_9_line_brief_remarks.laser_to_target_line)    * u.units.deg.coeff)
            result = result + CR_ + self.sub.LTL:make() + self.sub.Digits:make(ltl_azimuth_deg, '%03d')
        end
        
        if _9_line_brief_remarks.ordnance then
            result = result + CR_ + self.sub.use:make() + ' ' + self.sub.WeaponType:make(_9_line_brief_remarks.ordnance)
        end
        
        if _9_line_brief_remarks.threats then
            result = result + CR_ + self.sub.GroupThreats:make(_9_line_brief_remarks.threats)
        end

        if _9_line_brief_remarks.final_attack_heading then
            result =     result + CR_ + self.sub.finalAttackHeading:make() + ': ' +
                        self.sub.Digits:make(u.round(_9_line_brief_remarks.final_attack_heading.min * u.units.deg.coeff, 5.0)) +
                        ' - ' +    self.sub.Digits:make(u.round(_9_line_brief_remarks.final_attack_heading.max    * u.units.deg.coeff, 5.0), '%03d')
        end
        
        if _9_line_brief_remarks.weather then
            local wind = Wind:make(_9_line_brief_remarks.weather.wind)
            if wind ~= nil then
                result = result + CR_ + wind
            end
            if _9_line_brief_remarks.weather.clouds then
                --cloudy level http://meteoweb.narod.ru/amn/spotters_guide.html
                if _9_line_brief_remarks.weather.clouds.density > 3 then
                     result = result + CR_
                    if _9_line_brief_remarks.weather.clouds.density > 9 then
                        result = result +  self.sub.overcastSky:make()
                    elseif _9_line_brief_remarks.weather.clouds.density > 7 then
                        result = result +  self.sub.cloudySky:make()
                    elseif _9_line_brief_remarks.weather.clouds.density > 3 then
                        result = result +  self.sub.partlyCloudySky:make()
                    else
                        result = result +  self.sub.clearSky:make()
                    end
                    result = result +      ', ' + self.sub.cloudBase:make() + ' ' +
                                           self.sub.Number:make(u.adv_round(_9_line_brief_remarks.weather.clouds.min_height,    1)) + ' ' +self.sub.m:make() + ' ' + self.sub.MSL:make()
                end
            end
            if     _9_line_brief_remarks.weather.fog and
                _9_line_brief_remarks.weather.fog.density > 0.1 then
                result = result + CR_ + self.sub.fog:make()
            end
            if     _9_line_brief_remarks.weather.visibility and
                _9_line_brief_remarks.weather.visibility < 10000 then
                result = result + CR_ + self.sub.visibility:make() +
                                       u.adv_round(self.sub.Number:make(_9_line_brief_remarks.weather.visibility    * u.units.nm.coeff), 1)
            end
        end
        
        if _9_line_brief_remarks.TOT then
            result = result + CR_ + self.sub.tot:make()  + p._S('(TOT)')    + self.sub.Time:make(_9_line_brief_remarks.TOT.min) + ' - ' +    self.sub.Time:make(_9_line_brief_remarks.TOT.max)
        elseif _9_line_brief_remarks.TTT then
            local minuntes = base.math.mod(_9_line_brief_remarks.TTT, 60.0)
            local seconds = _9_line_brief_remarks.TTT - minuntes * 60        
            result = result + CR_ + self.sub.ttt:make() + p._S('(TTT)') +    self.sub.Time:make(_9_line_brief_remarks.TOT.min) + ':' +    self.sub.Time:make(_9_line_brief_remarks.TOT.max) +   self.sub.hack:make()
        end
            
        return result
    end,
    sub = {    LTL                    = Phrase:new({_('Laser-to-target line: '), 'LTL' }),
            use                    = PhraseRandom:new( { {_('use'), 'use'},
                                                    {_('request'), 'request'} } ),
            finalAttackHeading    = PhraseRandom:new( {    {_('Final attack heading'),     'Final attack heading'},
                                                        {_('make your attack heading'), 'make your attack heading'} } ),
            Wind                = Wind,
            overcastSky            = Phrase:new({_('overcast sky'), 'overcast sky'}),
            cloudySky            = Phrase:new({_('cloudy sky'), 'cloudy sky'}),
            partlyCloudySky        = Phrase:new({_('partly cloudy sky'), 'partly cloudy sky'}),
            clearSky            = Phrase:new({_('clear sky'), 'clear sky'}),
            cloudBase            = Phrase:new({_('cloud base'), 'cloud base'}),
            m                    = Phrase:new({_('meters'),                 'meters'}),
            feet                = Phrase:new({_('feet'), 'feet'}),
            MSL                    = Phrase:new({_('MSL'), 'MSL', 'eM eS eL'}),
            fog                    = Phrase:new({_('fog'), 'fog'}),
            visibility            = Phrase:new({_('visibility'), 'visibility'}),
            tot                    = Phrase:new({_('Time-on-Target: '), 'TOT', 'Time-on-Target'}),
            ttt                    = Phrase:new({_('Time-to-Target: '), 'TTT', 'Time-to-Target'}),
            hack                = Phrase:new({_('READY, READY, HACK'), 'HACK', 'READY, READY, HACK'}),
            WeaponType            = WeaponType,
            TGPrequired            = Phrase:new({_('TGP'), 'TGP'}, 'Weapon'),
            GroupThreats        = {
                make = function(self, threats)
                    local result = p.start()
                    local firsTthreatInCluster  = true
                    for threatClusterIndex, threatCluster in base.pairs(threats) do
                        if not firsTthreatInCluster then
                            result = result + CR_
                        end
                        local typesQty = 0
                        local typesCounter = {}
                        for objectIndex, pThreat in base.pairs(threatCluster.objects) do
                            if pThreat:isExist() then
                                local typeName = pThreat:getTypeName()
                                if typeName ~= nil then
                                    local displayTypeId = self.displayTypeIds[typeName]
                                    if displayTypeId == nil then
                                        base.error('Warning: Index for airdefence unit \"'..typeName..'\" is missed !')
                                    end
                                    if typesCounter[displayTypeId] == nil then
                                        typesQty = typesQty + 1
                                        typesCounter[displayTypeId] = 1
                                    else
                                        typesCounter[displayTypeId] = typesCounter[displayTypeId] + 1
                                    end
                                end
                            end
                        end
                        local counter = 0
                        for displayTypeId, count in base.pairs(typesCounter) do
                            counter    = counter + 1
                            if     counter == typesQty and
                                counter > 1 then
                                result = result + ' ' + self.sub.pand:make() + ' '
                            elseif counter > 1 then
                                result = result + comma_space_
                            end
                            if count > 1 then
                                result = result + self.sub.Number:make(count) + ' x '
                            end
                            result = result + self.sub.displayTypeName:make(displayTypeId)
                        end
                        if counter > 0 then
                            result = result +     ' ' +    self.sub.CompassDirection8:make(u.get_azimuth(threatCluster.direction))   +
                                                ' ' +    self.sub.Digits:make(u.adv_round(u.get_lengthZX(threatCluster.direction)    * u.units.nm.coeff)) +
                                                ' ' + self.sub.nm:make()
                            firsTthreatInCluster = false
                        end                        
                    end
                    return result                    
                end,
                displayTypeIds = {    ['2S6 Tunguska']                = 1,
                                    ['SA-11 Buk LN 9A310M1']        = 2,
                                    ['Osa 9A33 ln']                    = 3,
                                    ['Tor 9A331']                    = 4,
                                    ['Strela-10M3']                    = 5,
                                    ['Strela-1 9P31']                = 6,
                                    ['Gepard']                        = 7,
                                    ['Vulcan']                        = 8,
                                    ['M48 Chaparral']                 = 9,
                                    ['M6 Linebacker']                 = 10,
                                    ['M1097 Avenger']                = 11,
                                    ['Kub 1S91 str']                 = 12,
                                    ['S-300PS 40B6M tr']             = 13,
                                    ['Hawk tr']                     = 14,
                                    ['Patriot str']                 = 15,
                                    ['Roland Radar']                 = 16,
                                    ['snr s-125 tr']                 = 17,
                                    ['ZSU-23-4 Shilka']             = 18,
                                    ['ZU-23 Emplacement Closed']     = 19,
                                    ['ZU-23 Emplacement']             = 19,
                                    ['ZU-23 Closed Insurgent']         = 19,
                                    ['Ural-375 ZU-23 Insurgent']     = 19,
                                    ['ZU-23 Insurgent']                = 19,
                                    ['Ural-375 ZU-23']                 = 19,
                                    ['SA-18 Igla manpad']            = 20,
                                    ['SA-18 Igla-S manpad']            = 20,
                                    ['Stinger manpad']                = 20,
                                    ['Stinger manpad dsr']            = 20,
                                },
                sub = {    Number                = Number,
                        pand                = Phrase:new({_('and'), 'and'}),
                        CompassDirection8    = CompassDirection8,
                        Digits                = Digits,
                        nm                    = Phrase:new({_('nautical'),     'nautical'}),
                        displayTypeName        = Phrases:new( {{_('SA-19'),    'SA-19'},
                                                            {_('SA-11'),    'SA-11'},
                                                            {_('SA-8'),        'SA-8'},
                                                            {_('SA-15'),    'SA-15'},
                                                            {_('SA-13'),    'SA-13'},
                                                            {_('SA-9'),        'SA-9'},
                                                            {_('Gepard'),    'Gepard'},
                                                            {_('Vulcan'),    'Vulcan'},
                                                            {_('Chaparral'),'Chaparral'},
                                                            {_('Linebacker'),'Linebacker'},
                                                            {_('Avenger'), 'Avenger'},
                                                            {_('SA-6'),        'SA-6'},
                                                            {_('SA-10'),    'SA-10'},
                                                            {_('Hawk'),        'Hawk'},
                                                            {_('Patriot'),    'Patriot'},
                                                            {_('Roland'),    'Roland'},
                                                            {_('SA-3'),        'SA-3'},
                                                            {_('Zeus'),        'Zeus'},
                                                            {_('ZU-23'),    'ZU-23'},
                                                            {_('MANPADS'),    'MANPADS'}}, 'AirDefence') }
            },
            Digits                = Digits,
            Number                = Number,
            Time                = Time,
            artillery            = Phrase:new({_('artillery'), 'artillery'}),
            GTL                    = Phrase:new({_('GTL'), 'GTL', _('gun-to-target line') }),
            stay                = Phrase:new({_('stay'), 'stay'}),
            gridLine            = Phrase:new({_('of grid line'), 'of grid line'}),
            remain                = Phrase:new({_('remain'), 'remain'}),
            above                = Phrase:new({_('above'), 'above'}),            
            below                = Phrase:new({_('below'), 'below'}),
            takingFireFrom        = Phrase:new({_('target is taking fire from our'),    'target is taking fire from our'}),
            fighting            = Phrase:new({_('target is fighting with our'),     'target is fighting with our'}),
            engagedBy            = Phrase:new({_('target is engaged by our'),         'target is engaged by our'}),
            firingOn            = Phrase:new({_('target is firing on our'),         'target is firing on our'}),            
            burningVehicle        = Phrase:new({_('of the burning vehicle'),             'of the burning vehicle'}),
            burningVehicles        = Phrase:new({_('of the burning vehicles'),         'of the burning vehicles'})
        }
}

if base._DEBUG then
    local function checkThreatNames()
        local savedDb = base.db
        base.db = nil
        base.dofile('Scripts/Database/db_main.lua')    
        for vehicleIndex, vehicleDesc in base.pairs(base.db.Units.Cars.Car) do
            if     base.findAttribute(vehicleDesc.attribute, 'AAA') or
                base.findAttribute(vehicleDesc.attribute, 'SAM') or
                base.findAttribute(vehicleDesc.attribute, 'SAM TR') then                
                local displayTypeId = NineLineBriefRemarks.sub.GroupThreats.displayTypeIds[vehicleDesc.Name]
                if displayTypeId == nil then
                    base.error('No display id for '..vehicleDesc.Name)
                end
                local phrase = NineLineBriefRemarks.sub.GroupThreats.sub.displayTypeName.phrases[displayTypeId]
                if phrase == nil then
                    base.error('No display name for '..vehicleDesc.Name)
                end
            end
        end
        base.db = savedDb
    end
    checkThreatNames()
end

toJTACHandler = {
    make = function(self, message, language)
        return self.sub.PlayerAircraftCallsign:make(message.sender,    language == 'RUS') + comma_space_ + Event:make(message.event)
    end,
    sub = { PlayerAircraftCallsign    = PlayerAircraftCallsign }
}

LeaderToJTACHandler = {
    make = function(self, message, language)
        return     self.sub.CallsignJTAC:make(message.receiver) + comma_space_ + self.sub.thisIs:make() + ' ' +
                self.sub.PlayerAircraftCallsign:make(message.sender,    language == 'RUS') + comma_space_ + Event:make(message.event)
    end,
    sub = { CallsignJTAC             = CallsignJTAC,
            thisIs                    = Phrase:new({_('this is'), 'this is'}),
            PlayerAircraftCallsign    = PlayerAircraftCallsign }
}

CAScheckInHandler = {
    make = function(self, message)    
        local result = self.sub.LeaderToJTACHandler:make(message)
        if message.parameters then
            if message.parameters.missionNumber ~= nil then
                result = result + self.sub.asFragged:make() +    comma_space_ + self.sub.missionNumber:make() + ' ' +    self.sub.PhoneticAlphabet:make(essage.parameters.missionNumber) +    comma_space_
            end
            wantLL = message.parameters.aircraft_type[4] == base.KA_50  --Доб Ка-50--
            wantRR = message.parameters.aircraft_type[4] == base.MI_8MT  --Доб Ми-8--
            result = result +    self.sub.Digits:make(message.parameters.flight_size) + ' x ' +    self.sub.aircraftType:make(message.parameters.aircraft_type[4]) + CR_
            if message.parameters.CP then
                result = result +        self.sub.Number:make(u.adv_round(u.get_lengthZX(message.parameters.dir)   *  u.units.nm.coeff, 1)) + ' ' + self.sub.nm:make() + ' ' +
                                       self.sub.CompassDirection8:make(u.get_azimuth(message.parameters.dir)) +    ' ' + self.sub.ofIP:make() + ' ' +
                                    self.sub.NamesIP:make(message.parameters.CP) + ' ' +
                                    self.sub.Altitude:make(message.parameters.alt, message.sender:getUnit():getCountry()) + CR_
            else
                base.assert(message.parameters.point ~= nil)
                result = result + self.sub.MGRS:make(message.parameters.point, 2)
                result = result + ' ' +    self.sub.Altitude:make(message.parameters.point.y,    message.sender:getUnit():getCountry()) + CR_
            end
            
            if message.parameters.weapon then
                result = result + self.sub.armed:make()    + ': '
                local first_weapon = true
                for weaponIndex, weaponData in base.pairs(message.parameters.weapon) do
                    if weaponData.type[2] ~= base.wsType_GContainer then
                        if not first_weapon then
                            result = result  + comma_space_
                        end                    
                        if     weaponData.qty > 1 and
                            weaponData.type[3] ~= base.wsType_Control_Cont then
                            if weaponData.type[2] == base.wsType_Shell then                            
                                local roundQty = 50 * base.math.floor(weaponData.qty / 50 + 0.5)                            
                                result = result + self.sub.Number:make(roundQty)  + ' x '
                            end
                            result = result + self.sub.WeaponType:make(weaponData.type)
                        else
                            result = result + self.sub.WeaponType:make(weaponData.type)
                        end
                    end
                    first_weapon = false
                end
                result = result + CR_
            end        
            
            if message.parameters.time_on_station then
                result =     result + self.sub.playTime:make() + ' ' +
                               self.sub.Number:make(base.math.floor(message.parameters.time_on_station.start    / 60)) + ' ' + self.sub.plus:make('plus') + ' ' +
                            self.sub.Number:make(base.math.floor(message.parameters.time_on_station.duration / 60))+ CR_
            end
            result = result + self.sub.ready:make()
        end
        
        return result
    end,
    sub = {
        LeaderToJTACHandler    = LeaderToJTACHandler,
        asFragged            = Phrase:new({_('checking in as fragged'), 'checking in as fragged'}),
        missionNumber        = Phrase:new({_('mission number'), 'mission number'}),
        PhoneticAlphabet    = PhoneticAlphabet,
        aircraftType        = Phrases:new( {     [base.A_10A] = {_('A-10'), 'A-10'},
                                                [base.A_10C] = {_('A-10'), 'A-10'},
                                                [base.FA_18] = { _('F/A-18'), 'FA-18' },
                                                [base.FA_18C] = { _('F/A-18'), 'FA-18' },
                                                [base.KA_50] = {_('Ka-50'), 'Ka-50'},
                                                [base.AH_64A] = {_('AH-64'), 'AH-64'},
                                                [base.AH_64D] = {_('AH-64'), 'AH-64'},
                                                [base.AH_1W] = {_('AH-1'), 'AH-1'},
                                                [base.MI_8MT] = {_('Mi-8'), 'Mi-8'},
                                                [base.MI_24W] = {_('Mi-24'), 'Mi-24'},
                                                [base.F_16A] = {_('F-16'), 'F-16'},
                                                [base.F_16] = {_('F-16'), 'F-16'},
                                                [base.P_51B] = {_('P-51'), 'P-51'},
                                                [base.P_51D] = {_('P-51'), 'P-51'} } ),
        NamesIP                = NamesIP,
        CompassDirection8    = CompassDirection8,
        nm                    = Phrase:new({_('nautical'), 'nautical'}),
        ofIP                = Phrase:new({_('of IP'), 'of IP'}),
        Digits                = Digits,
        Number                = Number,
        Altitude            = Altitude,
        armed                = PhraseRandom:new( {     {_('Armed with'), 'Armed with'},
                                                    {_('I have'), 'I have'} } ),
        WeaponType            = WeaponType,
        playTime            = PhraseRandom:new( {     {_('Play time is'), 'Play time is'},
                                                    {_('Time on station is'), 'Time on station is'} } ),
        plus                = Phrase:new( { '+', 'plus', _('plus') } ),
        ready                = Phrase:new({_('Available for tasking.    What do you have for us?'), 'Available for tasking', 'Available for    tasking. What do you have for us?'}),
        MGRS                = MGRS
    }
}

CASReadBackHandler = {
    make = function(self, message)
        local result =     self.sub.Number:make(u.adv_round(message.parameters.target_elevation, 1)) + comma_space_ +
                        self.sub.MGRS:make(message.parameters.target_location, 3)
        if message.parameters.final_attack_heading then
            result = result + comma_space_ +    self.sub.finalAttackHeading:make() + ': ' +    self.sub.Digits:make(u.round(message.parameters.final_attack_heading.min    * u.units.deg.coeff, 5.0), '%03d') + ' - ' +    self.sub.Digits:make(u.round(message.parameters.final_attack_heading.max    * u.units.deg.coeff, 5.0), '%03d')
        end
        return result
    end,
    sub = {
        Number                = Number,
        Digits                = Digits,
        MGRS                = MGRS,
        finalAttackHeading    = Phrase:new({_('final attack heading'), 'final attack heading'})
    }
}

CAScontactHandler = {
    make = function(self, message)
        return self.sub.toJTACHandler:make(message) + self.sub.TargetData:make(message.parameters.target_data)
    end,
    sub = { toJTACHandler            = toJTACHandler,
            TargetData                = TargetData}
}

INhandler = {
    make = function(self, message)
        return self.sub.toJTACHandler:make(message) + ' ' +    self.sub.FromCompassDirection8:make(u.get_azimuth(message.parameters.back_dir))
    end,
    sub = { toJTACHandler             = toJTACHandler,
            FromCompassDirection8     = FromCompassDirection8 }
}

AIRCRAFT_BDA_handler = {
    make = function(self, message)
        local result = p.start()
        --Weapon
        for weaponIndex, weapon in base.pairs(message.parameters.weapons) do
            result = result + self.sub.Number:make(weapon.qty) + ' x ' + self.sub.WeaponType:make(weapon.wsType)
            if weapon.wsType[2] == base.wsType_Bomb then
                result = result + self.sub.released:make()
            else
                result = result + self.sub.fired:make()
            end
            result = result + CR_
        end
        --Destroyed targets
        if     message.parameters.destroyedTargets ~= nil and
            #message.parameters.destroyedTargets > 0 then
            for targetIndex, target in base.pairs(message.parameters.destroyedTargets) do
                result = result + self.sub.Number:make(target.qty) + ' x ' + self.sub.TargetType:make(target.type + 1)
            end
            result = result + self.sub.destroyed:make()
        end
    end,
    sub = { Number        = Number,
            WeaponType    = WeaponType,
            TargetType    = TargetType,
            fired        = Phrase:new({_('fired'),        'fired'}),
            released    = Phrase:new({_('released'),    'released'}),
            destroyed    = Phrase:new({_('destroyed'),    'destroyed'})     }
}

UseWeaponHandler = {
    make = function(self, message)
        return p.start() + self.sub.use:make() + ' ' + self.sub.WeaponType:make(message.parameters.ordnance)
    end,
    sub = {
        use                = Phrase:new({_('use'), 'use'}),
        WeaponType        = WeaponType,
    }
}

INFLIGHTREP_handler = {
    make = function(self, message)
        local result =     self.sub.toJTACHandler:make()+ CR_ +
                        --self.thisIs:make() + ' ' + self.sub.PlayerAircraftCallsign:make(message.sender) +
                        self.sub.missionNumber:make() + ' ' +    self.sub.PhoneticAlphabet:make(message.parameters.missionNumber) + CR_ +
                        self.sub.TOT:make() + self.sub.Time:make(message.parameters.TOT) + CR_
        if     message.parameters.destroyedTargets ~= nil and
            #message.parameters.destroyedTargets > 0 then
            for targetIndex, target in base.pairs(message.parameters.destroyedTargets) do
                result = result + self.sub.Number:make(target.qty) + ' x ' + self.sub.TargetType:make(target.type + 1)
            end
            result = result + self.sub.destroyed:make() + CR_
        end
        result = result +     self.sub.TargetDescription:make(message.parameters.target) + CR_ +
                            self.sub.Time:make(message.parameters.TDME)
                
    end,
    sub = {
        toJTACHandler        = toJTACHandler,
        --thisIs                = Phrase:new({_('this is'), 'this is'}),
        PlayerAircraftCallsign    = PlayerAircraftCallsign,
        missionNumber        = Phrase:new({_('mission number'), 'mission number'}),
        TOT                    = Phrase:new({_('TOT'), 'TOT', _('Time-on-target')}),
        PhoneticAlphabet    = PhoneticAlphabet,
        Time                = Time,
        destroyed            = Phrase:new({_('destroyed'), 'destroyed'}),
        TargetDescription     = TargetDescription,
    }
}

toLeaderHandler = {
    make = function(self, message)
        return self.sub.PlayerAircraftCallsign:make(message.receiver) + comma_space_ +  Event:make(message.event)
    end,
    sub = { PlayerAircraftCallsign = PlayerAircraftCallsign     }
}

JTACToLeaderHandler = {
    make = function(self, message)
        return self.sub.PlayerAircraftCallsign:make(message.receiver) +    comma_space_ + self.sub.thisIs:make() + ' ' +    self.sub.CallsignJTAC:make(message.sender) + comma_space_ +    Event:make(message.event)
    end,
    sub = { PlayerAircraftCallsign    = PlayerAircraftCallsign,
            thisIs                    = Phrase:new({_('this is'), 'this is'}),
            CallsignJTAC             = CallsignJTAC    }
}

TargetDescriptionHandler = {
    make = function(self, message)
        return self.sub.toLeaderHandler:make(message) + ' ' + self.sub.TargetDescription:make(message.parameters)
    end,
    sub = {    toLeaderHandler        = toLeaderHandler,
            TargetDescription    = TargetDescription }
}

NoTaskClearedToDepartHandler = {
    make = function(self, message)
        return self.sub.PlayerAircraftCallsign:make(message.receiver) +    comma_space_ + Event:make(message.event) + self.sub.thanks:make() + ' '   +  self.sub.youMayDepart:make()
    end,
    sub = {
        PlayerAircraftCallsign    = PlayerAircraftCallsign,
        thanks                    = PhraseRandom:new({{_('Thanks for the support.'),     'Thanks for the support'},
                                                    {_('Good job!'),                 'good job'},
                                                    {_('Nice work!'),                 'nice work'}}),
        youMayDepart            = Phrase:new({_('You may depart'), 'You may depart'})
    }
}

NineLineBriefHandler = {
    make = function(self, message)
        return Event:make(message.event) + '\n' + self.sub.NineLineBrief:make(message.parameters)
    end,
    sub = {    NineLineBrief        = NineLineBrief }
}

NineLineBriefRemarksHandler = {
    make = function(self, message)
        return self.sub.NineLineBriefRemarks:make(message.parameters)
    end,
    sub = {    NineLineBriefRemarks = NineLineBriefRemarks }
}

TargetCorrectionHander = {
    make = function(self, message)
        return     self.sub.toLeaderHandler:make(message) + ' ' +    CompassDirection8:make(u.get_azimuth(message.parameters.direction)) + '   '  +
                self.sub.Number:make(u.adv_round(u.get_lengthZX(message.parameters.direction)))
    end,
    sub = {    toLeaderHandler        = toLeaderHandler,
            CompassDirection8     = CompassDirection8,
            Number                = Number}
}

CASfromTheMarkHandler = {
    make = function(self, message)
        return     Event:make(message.event) + ' ' +    self.sub.CompassDirection8:make(u.get_azimuth(message.parameters.direction))    + ' ' +
                self.sub.Number:make(u.adv_round(u.get_lengthZX(message.parameters.direction))) + ' ' + self.sub.m:make()
    end,
    sub = {
        Number                = Number,
        CompassDirection8    = CompassDirection8,
        m                    = Phrase:new({_('meters'), 'meters'})
    }
}

JTAC_BDA_handler = {
    make = function(self, message)
        local result = self.sub.toLeaderHandler:make(message)
        if message.parameters.destroyed_units_qty then
            if message.parameters.destroyed_units_qty > 1 then
                result =     result +    self.sub.Number:make(message.parameters.destroyed_units_qty) + ' ' +    self.sub.units:make() + ' ' +
                            self.sub.destroyed:make() + '. ' + self.sub.reAttack:make() + '.'
            elseif message.parameters.destroyed_units_qty > 0 then
                result =     result + self.sub.Number:make(1) + ' ' +    self.sub.unit:make() + ' ' + self.sub.destroyed:make() + '. ' +
                            self.sub.reAttack:make() + '.'
            end
        end
        return result
    end,
    sub = {
        toLeaderHandler        = toLeaderHandler,
        unit                = Phrase:new({_('unit'),                    'unit'}),
        units                = Phrase:new({_('units'),                    'units'}),
        destroyed            = Phrase:new({_('destroyed'),                'destroyed'}),
        reAttack            = Phrase:new({_('Re-attack is authorized'), 'Re-attack is authorized'}),
        Number                = Number
    }
}

CASabortHandler = {
    make = function(self, message)
        local result = self.sub.toLeaderHandler:make(message)
        if     message.parameters and
            message.parameters.reason and
            message.parameters.reason > 0 then
            result = result + ' ' + self.sub.abortReason:make(message.parameters.reason)
        end    
        return result
    end,
    sub = {
        toLeaderHandler         = toLeaderHandler,
        abortReason                = Phrases:new(    {    {_('You have no permission!'), 'You have no permission'},
                                                    {_('You are    attacking a wrong target!'), 'You are attacking a wrong target'},
                                                    {_('RED on RED RED on RED!'), 'RED on RED RED on RED'} } )
    }
}

SAMlaunchHandler = {
    make = function(self, message)
        return self.sub.PlayerAircraftCallsign:make(message.receiver) + '    ' +  self.sub.BearingOClock:make(u.get_azimuth(message.parameters.dir))
    end,
    sub = {    PlayerAircraftCallsign     = PlayerAircraftCallsign,
            BearingOClock            = BearingOClock    }
}    --end adds by JTAC mod

InboundAt = {
	make = function(self, message, language)
		local senderUnit = message.sender:getUnit()
		if senderUnit:hasAttribute('Helicopters') then
			local country = senderUnit:getCountry()
			local selfPos = senderUnit:getPosition().p
			local airdromePos = message.receiver:getUnit():getPosition().p
			local dir = { 	x = selfPos.x - airdromePos.x,
							y = selfPos.y - airdromePos.y,
							z = selfPos.z - airdromePos.z }
			local distanceUnit = unitSystemByCountry[country].distance
			return 	self.sub.AirbaseName:make(message.receiver, getAirdromeNameVariant(language)) +
					comma_space_ + self.sub.PlayerAircraftCallsign:make(message.sender, language == 'RUS') + comma_space_ + self.sub.range:make() + ' ' +
					self.sub.Number:make(u.round(u.get_lengthZX(dir) * distanceUnit.coeff, 1)) + ' ' + self.sub.Altitude:make(selfPos.y, country, 500)
		else
			return	self.sub.AirbaseName:make(message.receiver, getAirdromeNameVariant(language)) +
					comma_space_ + self.sub.PlayerAircraftCallsign:make(message.sender, language == 'RUS') + comma_space_ + self.sub.inbound:make()
		end
	end,
	sub = { PlayerAircraftCallsign	= PlayerAircraftCallsign,
			AirbaseName				= AirbaseName,
			Number					= Number,
			range					= Phrase:new({_('inbound range'), 	'inbound range'}),
			inbound					= Phrase:new({_('inbound'), 		'inbound'}),
			Altitude				= Altitude }
}

handlersTable = {
	--AWACS -> PLAYER
	[base.Message.wMsgLeaderInbound]				= InboundAt,
	--AWACS -> Player
	[base.Message.wMsgAWACSBanditBearingForMiles]	= AWACSbanditBearingHandler,
	[base.Message.wMsgAWACSVectorToNearestBandit]	= AWACSbanditBearingHandler,
	[base.Message.wMsgAWACSPopUpGroup]				= AWACSbanditBearingHandler,
	[base.Message.wMsgAWACSHomeBearing]				= AWACSBullVectorHandler,
	[base.Message.wMsgAWACSTankerBearing]			= AWACSBullVectorHandler,
	[base.Message.wMsgAWACSPicture]					= AWACSpictureHandler,	
}

 --Player -> JTAC    --start adds by JTAC mod
    [base.Message.wMsgLeaderCheckIn]                 = CAScheckInHandler,                              ------1------ 1
    [base.Message.wMsgLeader9LineReadback]            = CASReadBackHandler,                              -----1------ 2
    [base.Message.wMsgLeaderContact]                 = CAScontactHandler,
    [base.Message.wMsgLeader_CONTACT_the_mark]        = EventHandler,
    [base.Message.wMsgLeader_IN]                     = INhandler,
    [base.Message.wMsgLeaderBDA]                    = AIRCRAFT_BDA_handler,                            -----1------  3
    [base.Message.wMsgLeaderINFLIGHTREP]            = INFLIGHTREP_handler,
    --JTAC -> Player
    [base.Message.wMsgFACNoTaskingAvailableStandBy]    = JTACToLeaderHandler,
    [base.Message.wMsgFACType1InEffectAdviseWhenReadyFor9Line] = JTACToLeaderHandler,
    [base.Message.wMsgFACType2InEffectAdviseWhenReadyFor9Line] = JTACToLeaderHandler,
    [base.Message.wMsgFACType3InEffectAdviseWhenReadyFor9Line] = JTACToLeaderHandler,
    [base.Message.wMsgFACNoTaskingAvailableClearedToDepart] =    NoTaskClearedToDepartHandler,                                    -----0------5
    [base.Message.wMsgFACNoTaskingAvailable]        = EventHandler,        
    [base.Message.wMsgFACAdviseWhenReadyForRemarksAndFutherTalkOn] = EventHandler,
    [base.Message.wMsgFACReadBackCorrect]            = EventHandler,    
    [base.Message.wMsgFAC9lineBrief]                 =    NineLineBriefHandler,                                                      -----0------1
    [base.Message.wMsgFAC9lineBriefWP]                 =    NineLineBriefHandler,                                                  -----0------2
    [base.Message.wMsgFAC9lineBriefIRPointer]         =    NineLineBriefHandler,                                                  -----0------3
    [base.Message.wMsgFAC9lineBriefLaser]             =    NineLineBriefHandler,                                                  -----0------4
    [base.Message.wMsgFAC9lineRemarks]                = NineLineBriefRemarksHandler,                          -----2------ 5
    [base.Message.wMsgFACFromTheMark]                = CASfromTheMarkHandler,
    [base.Message.wMsgFACTargetDescription]         = TargetDescriptionHandler,
    [base.Message.wMsgFACThatIsNotYourTarget]         = TargetCorrectionHander,
    [base.Message.wMsgFACThatIsFriendly]             = TargetCorrectionHander,
    [base.Message.wMsgFACYourTarget]                 = TargetCorrectionHander,                              -----2------ 4
    [base.Message.wMsgFACTargetPartiallyDestroyed]     = JTAC_BDA_handler,                                     -----2------ 6
    [base.Message.wMsgUseWeapon]                    = UseWeaponHandler,                                      -----2------ 7
    [base.Message.wMsgFAC_ABORT_ATTACK]             = CASabortHandler,
    [base.Message.wMsgFAC_SAM_launch]                = SAMlaunchHandler,       --end adds by JTAC mod

base.setmetatable(handlersTable, common.handlersTable_mt)

rangeHandlersTable = {
	--PLAYER -> AWACS
	{
		range = { base.Message.wMsgLeaderToAWACSNull,	base.Message.wMsgLeaderToAWACSMaximum },
		handler = ClientToAWACSHandler
	},
	--AWACS -> PLAYER
	{
		range = { base.Message.wMsgAWACSNull,			base.Message.wMsgAWACSMaximum },
		handler = AWACSToClientHandler
	}
}

    --PLAYER -> JTAC    --start adds by JTAC mod
    {
        range = { base.Message.wMsgLeaderReadyToCopy,     base.Message.wMsgLeader9LineReadback },
        handler = EventHandler
    },    
    {
        range = { base.Message.wMsgLeaderToFACNull,        base.Message.wMsgLeaderToFACMaximum },
        handler = toJTACHandler
    },
    --JTAC -> PLAYER
    {
        range = { base.Message.wMsgFACReport_IP_INBOUND,base.Message.wMsgFACThatIsYourTarget },
        handler = EventHandler
    },
    {
        range = { base.Message.wMsgFACMarkOnDeck,        base.Message.wMsgFAC_NoMark },
        handler = EventHandler,
    },
    {
        range = { base.Message.wMsgFACNull,                base.Message.wMsgFACMaximum },
        handler = toLeaderHandler
    },    --end adds by JTAC mod

base.setmetatable(rangeHandlersTable, common.rangeHandlersTable_mt)

base.print('Speech.USSR module loaded')