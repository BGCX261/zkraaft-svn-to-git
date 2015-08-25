-- Player Appearance Customiser 2
-- Copyright 2009 Elias Hogstvedt (CapsAdmin)
-- Licensed under Creative Commons Attribution-Noncommercial-Share Alike 2.5
-- Thanks to the following for their assistance:
--	Declan White (Deco Da Man)
--	Brian (Nevec)
--	Tomy (TomyLobo)
--	Zé (ZpankR)

--[[ Todo:
	- Create some data validation for the client so they can't crash any hooks (IMPORTANT)
		-- {Done}
	- Add error handling to the hooks (if the solution to the above precaution is questionable)
		-- {Done}
	- Clamp some part data, such as light intensity, scale, size
		-- So, should I limit the brightness to 1, or 255?
		-- 1 is the multiplayer limit, 255 is the single player (and engine) limit
		-- {Done}
	- Create whitelist/blacklist system
		- Could integrate with the editor
	- Create editor
		(- Nevec should be working on this)
		- Make sure that you can 'click' the parts in the 3D view
		- Add support for skins
		- Fix precaching in the editor for particle effects
		- When using the editor, the local player needs to be drawn only when rendering the preview
			- Now it's drawing the effects and stuff two times - for the preview and the world
			- We need to fix that somehow
		
	- Implement a hooking system so gamemodes can integrate (maybe)
		- Would allow people to 'buy' things in gamemodes
	- Provide a more friendly version of data (maybe.. probably not)
		- GLON is good for storage.. but these configs are going to be a community thing, so the config needs to be readable
		- Perhaps JSON
	- Implement a better system for converting descriptive bone names into unfriendly bone names (maybe)
		- Certain models may have special bones (I know you want to use this with a furry model)
		- Certain gamemodes may use custom player models and custom animation hooks
			- Could we 'hack' into the bone animation hooks and grab the names of the bones?
	- Think of more things to do	
	- Optimization 
		- Make use of DrawModel for parts and set the parts to NoDraw on init. I mean, draw the models when needed in PostPlayerDraw
	
Temp todo:
	- Make sure pac_enable is obeyed
	- (Client-side has become pac_cl_enable (and CV_CLEnable))
	- Get trails working (clamping, rendering)
		- Should fading be by distance or time?
			- Should it be a choice?
		- Garbage collection man is scary, be wary of him :(
	- Endurance test sunbeams, sprites and trails (for bugs)
]]

if CLIENT and PAC then -- for reloading during development
	for uniqueid, ents in ipairs(PAC.ActiveEnts or {}) do
		for id, entity in ipairs(ents) do
			entity:Remove()
		end
	end
end

PAC = PAC or {}


PAC.BoneList, PAC.EditorBoneNames = {
	["pelvis"			] = "ValveBiped.Bip01_Pelvis"		,
	["spine 1"			] = "ValveBiped.Bip01_Spine"		,
	["spine 2"			] = "ValveBiped.Bip01_Spine1"		,
	["spine 3"			] = "ValveBiped.Bip01_Spine2"		,
	["spine 4"			] = "ValveBiped.Bip01_Spine4"		,
	["neck"				] = "ValveBiped.Bip01_Neck1"		,
	["head"				] = "ValveBiped.Bip01_Head1"		,
	["right clavicle"	] = "ValveBiped.Bip01_R_Clavicle"	,
	["right upper arm"	] = "ValveBiped.Bip01_R_UpperArm"	,
	["right forearm"	] = "ValveBiped.Bip01_R_Forearm"	,
	["right hand"		] = "ValveBiped.Bip01_R_Hand"		,
	["left clavicle"	] = "ValveBiped.Bip01_L_Clavicle"	,
	["left upper arm"	] = "ValveBiped.Bip01_L_UpperArm"	,
	["left forearm"		] = "ValveBiped.Bip01_L_Forearm"	,
	["left hand"		] = "ValveBiped.Bip01_L_Hand"		,
	["right thigh"		] = "ValveBiped.Bip01_R_Thigh"		,
	["right calf"		] = "ValveBiped.Bip01_R_Calf"		,
	["right foot"		] = "ValveBiped.Bip01_R_Foot"		,
	["right toe"		] = "ValveBiped.Bip01_R_Toe0"		,
	["left thigh"		] = "ValveBiped.Bip01_L_Thigh"		,
	["left calf"		] = "ValveBiped.Bip01_L_Calf"		,
	["left foot"		] = "ValveBiped.Bip01_L_Foot"		,
	["left toe"			] = "ValveBiped.Bip01_L_Toe0"		,
}, { };

for nice, name in pairs( PAC.BoneList ) do table.insert( PAC.EditorBoneNames, nice ); end

function PAC.RemoveClutterFromBoneName(name)
	if not name then return "" end
	
	if name:find("ValveBiped.Bip01_") then
		name = name:Right(-18)
	elseif name:find("bip_") then
		name = name:Right(-5)
	else
		local right = string.Explode(".", name)[2]
		if right then
			name = right
		end
	end
	return name
end

table.sort(PAC.EditorBoneNames)


function PAC.TranslateBoneToUnfriendly(bone)
	if type(bone) == "table" then PrintTable(bone) debug.Trace() end
	return PAC.BoneList[string.lower(bone)] or bone
end

function PAC.TranslateBoneToFriendly(bone)
	for bone, unfriendly in pairs(PAC.BoneList) do
		if string.lower(unfriendly) == string.lower(bone) then
			return unfriendly
		end
	end
	return bone
end

function _R.Player:GetPACConfig()
	return self.CurrentPACConfig
end

/* function PAC.OptimizeConfig(config)
	for key, value in pairs(config)
end */

function PAC.ValidateConfig(tbl)
	if( PAC.IsConfigObject( tbl ) ) then return tbl; end
	
	local config = PAC.Config:New()
	tbl = type(tbl) == "table" and tbl or {}
	config:SetPlayerColor(tbl.player_color)
	config:SetPlayerMaterial(tbl.player_material)
	config:SetPlayerMaterialColor(tbl.player_mat_color or Color(255,255,255,255))
	config:SetOverallBoneScale(tbl.overall_scale)
	config:SetPlayerModel(tbl.playermodel)
	config:SetDrawWeapon(tbl.drawwep == false and tbl.drawwep or tbl.drawwep == true and tbl.drawwep or tbl.drawwep == nil)
	for id, part in ipairs(type(tbl.parts) == "table" and tbl.parts or {}) do
		config:AddPart(part.name, type(part) == "table" and part or {})
	end
	for name, bone in pairs(type(tbl.bones) == "table" and tbl.bones or {}) do
		bone = type(bone) == "table" and bone or {}
		config:SetBone(tostring(name), bone.scale, bone.offset, bone.angles, bone.size, bone.anglevelocity)
	end
	return config
end

function PAC.IsEmptyConfig(config)
	if not config then return true end

	local scale = config.overall_scale
	local mat_color = config.player_mat_color
	local color = config.player_color

	return 
		#config.bones == 0 and
		config.drawwep == true and
		scale.x == 1 and scale.y == 1 and scale.z == 1 and
		mat_color.r == 255 and mat_color.g == 255 and mat_color.b == 255 and mat_color.a == 255 and
		color.r == 255 and color.g == 255 and color.b == 255 and color.a == 255 and
		#config.parts == 0 and
		config.player_material == ""
end

function IsAngle( angle )
	
	return type( angle ) == "Angle";
	
end

function CopyVector( vector )
	
	return IsVector( vector ) and Vector( vector.x, vector.y, vector.z ) or vector;
	
end

function CopyAngle( angle )
	
	return IsAngle( angle ) and Angle( angle.p, angle.y, angle.r ) or angle;
	
end

do -- classes
	local function New(metatable, ...)
		local tbl = {}
		setmetatable(tbl, metatable)
		local init = metatable.Initialize
		if init then init(tbl, ...) end
		return tbl
	end
	
	local function NewClass(classname)
		local meta = { New = New }
		meta.__index = meta
		PAC[classname] = meta
		PAC["Is"..classname.."Object"] = function(object)
			return getmetatable(object) == meta
		end
		return meta
	end
	
	do -- class part
		local part = NewClass("Part")
		
		function part:Initialize(...)
			self:Modify(...)
		end
		
		function part:SetName(name)
			self.name = type(name) == "string" and name or "noname"
		end
		
		function part:SetModel(model)
			self.model = type(model) == "string" and model or "models/props_c17/doll01.mdl"
		end
		
		function part:SetBone(bone)
			self.bone = type(bone) == "string" and bone or "head"
		end
		
		function part:SetOffset(offset)
			self.offset = type(offset) == "Vector" and offset or Vector(0,0,0)
		end
		
		function part:SetAngles(angles)
			self.angles = type(angles) == "Angle" and angles or Angle(0,0,0)
		end
		
		function part:SetWorldAngles(angles)
			self.worldangles = type(angles) == "Angle" and angles or Angle(0,0,0)
		end
		function part:SetScale(scale)
			self.scale = type(scale) == "Vector" and scale or tonumber(scale) and Vector(1,1,1)*scale or Vector(1,1,1)
		end
		
		function part:SetSize(size)
			self.size = tonumber(size) or 1
		end
		
		function part:SetColor(color)
			self.color = type(color) == "table" and color.r and color.g and color.b and (color.a and color or Color(color.r, color.g, color.b, 255)) or Color(255, 255, 255, 255)
		end
		
		function part:SetHue(value)
			self.hue = math.Clamp(tonumber(value) or 0, 0, 360)
		end
		
		function part:SetSaturation(value)
			self.saturation = tonumber(value) or 1
		end
		
		function part:SetBrightness(value)
			self.brightness = tonumber(value) or 1
		end
		
		function part:SetMaterial(material)
			self.material = type(material) == "string" and material or ""
		end
		
		function part:SetSkin(skin)
			self.skin = math.Round(tonumber(skin or 0))
		end
		
		function part:SetEffect(t)
			local nt = type(t) == "table" and t or {}
			nt.Enabled = type(t) == "table" and (table.Count(t) > 0 and t.Enabled ~= false or t.Enabled)
			nt.effect = type(nt.effect) == "string" and nt.effect or ""
			nt.loop = tobool(nt.loop)
			nt.rate = tonumber(nt.rate) or 1
			self.effect = nt
		end
			
		function part:SetBodygroup(bodygroup)
			self.bodygroup = math.Round(tonumber(bodygroup  or 0))
		end
		
		function part:SetBodygroupState(state)
			self.bodygroup_state = math.Round(tonumber(state  or 0))
		end
	
		function part:SetLightParams(t)
			local nt = type(t) == "table" and t or {}
			nt.Enabled = type(t) == "table" and (table.Count(t) > 0 and t.Enabled ~= false or t.Enabled)
			nt.r = tonumber(nt.r) or self.color.r
			nt.g = tonumber(nt.g) or self.color.g
			nt.b = tonumber(nt.b) or self.color.b
			nt.Brightness = tonumber(nt.Brightness) or 1
			nt.Size = tonumber(nt.Size) or 256*self.size
			nt.Decay = tonumber(nt.Decay) or nt.Size*5
			self.light = nt
		end
				
		function part:SetSprite(t)
			local nt = type(t) == "table" and t or {}
			nt.Enabled = type(t) == "table" and (table.Count(t) > 0 and t.Enabled ~= false or t.Enabled)
			nt.material = type(nt.material) == "string" and nt.material or ""
			nt.x = tonumber(nt.x) or self.size
			nt.y = tonumber(nt.y) or self.size
			nt.color = table.Copy( nt.color or self.color )
			self.sprite = nt
		end

		function part:SetTrail(t)
			local nt = type(t) == "table" and t or {}
			nt.Enabled = type(t) == "table" and (table.Count(t) > 0 and t.Enabled ~= false or t.Enabled)
			nt.length = tonumber(nt.length) or 1
			nt.startsize = tonumber(nt.startsize) or 16
			nt.material = tostring(nt.material) or ""
			nt.color = table.Copy( nt.color or self.color )
			self.trail = nt
		end

		function part:SetAnimation(t)
			local nt = type(t) == "table" and t or {}
			nt.Enabled = type(t) == "table" and (table.Count(t) > 0 and t.Enabled ~= false or t.Enabled)
			nt.sequence = math.Round(tonumber(nt.sequence or 1)) 
			nt.rate = tonumber(nt.rate) or 1
			nt.loopmode = tobool(nt.loopmode) or false
			nt.offset = tonumber(nt.offset) or 0
			nt.name = tostring(nt.name) or ""
			nt.min = tonumber(nt.min) or 0
			nt.max = tonumber(nt.max) or 1
			self.animation = nt			
		end
		
		function part:SetText(t)
			local nt = type(t) == "table" and t or {}
			nt.Enabled = type(t) == "table" and (table.Count(t) > 0 and t.Enabled ~= false or t.Enabled)
			nt.text = tostring(nt.text or "")
			nt.size = tonumber(nt.size or 1)
			nt.font = tostring(nt.font or "default")
			nt.color = table.Copy( nt.color or self.color )
			nt.outline = tonumber(nt.outline or 0)
			nt.outlinecolor = table.Copy( nt.outlinecolor or self.color )
			self.text = nt	
		end
		
		function part:SetMirrored(bool)
			self.mirrored = bool
		end
		
		function part:FollowEyeAngles(bool)
			self.eyeangles = bool
		end
		
		function part:ClampEyeAngles(bool)
			self.eyeanglesclamp = bool
		end
        
		function part:SetClipPlane(t)
			local nt = type(t) == "table" and t or {}
			nt.Enabled = type(t) == "table" and (table.Count(t) > 0 and t.Enabled ~= false or t.Enabled)
			nt.distance = tonumber(nt.distance) or 0
			nt.angles = type(nt.angles) == "Angle" and CopyAngle(nt.angles) or Angle(0)
			nt.bone = type(nt.bone) == "string" and nt.bone or ""
			self.clip = nt	
		end   
		
		function part:SetSunbeams(t)
			local nt = type(t) == "table" and t or {}
			nt.Enabled = type(t) == "table" and (table.Count(t) > 0 and t.Enabled ~= false or t.Enabled)
			nt.darken = tonumber(nt.darken) or 0
			nt.multiply = tonumber(nt.multiply) or 0
			nt.size = tonumber(nt.size) or 0
			self.sunbeams = nt	
		end
		
		function part:SetAngleVelocity(velocity)
			self.anglevelocity = type(velocity) == "Angle" and CopyAngle(velocity) or Angle( 0, 0, 0 )
		end
		
		function part:SetRenderFX(enum)
			self.renderfx = math.Round(tonumber(enum or 0))
		end
		
		function part:SetRenderMode(enum)
			self.rendermode = math.Round(tonumber(enum or 0))
		end
		
		function part:SetParent(parent)
			self.parent = parent
		end
		
		function part:SetFullBright(bool)
			self.fullbright = bool
		end
		
		function part:SetModelBones(t)
			local nt = type(t) == "table" and t or {}
			nt.Enabled = type(t) == "table" and (table.Count(t) > 0 and t.Enabled ~= false or t.Enabled)
			nt.bones = nt.bones or {}
			nt.overallsize = nt.overallsize or 1
			nt.merge = nt.merge
			nt.fixfingers = nt.fixfingers
			self.modelbones = nt
		end
	
		function part:SetOriginFix(var)
			self.originfix = var
		end
		
	
		function part:SetWeaponClass(var)
			self.weaponclass = var
		end	
		
		function part:SetHideWeaponClass(var)
			self.hideweaponclass = var
		end
		
		function part:GetParent()
			return self.parent
		end
		
		function part:GetName()
			return self.name
		end
		
		function part:GetModel()
			return self.model
		end
		
		function part:GetBone()
			return self.bone
		end
		
		function part:GetOffset()
			return self.offset
		end
		
		function part:GetAngles()
			return self.angles
		end
		
		function part:GetScale()
			return self.scale
		end
		
		function part:GetSize()
			return self.size
		end
		
		function part:GetColor()
			return self.color
		end		
		
		function part:GetHue()
			return self.hue
		end		
		
		function part:GetSaturation()
			return self.saturation
		end		
		
		function part:GetBrightness()
			return self.brightness
		end
		
		function part:GetMaterial()
			return self.material
		end
		
		function part:GetSkin()
			return self.skin
		end
		
		function part:GetEffect()
			return self.effect
		end
		
		function part:GetLightParams()
			return self.light
		end
		
		function part:GetSunbeams()
			return self.sunbeams
		end

		function part:GetSprite()
			return self.sprite
		end

		function part:GetTrail()
			return self.trail
		end
		
		function part:GetBodygroup()
			return self.bodygroup
		end
		
		function part:GetBodygroupState()
			return self.bodygroup_state
		end
		
		function part:GetAnimation()
			return self.animation
		end
		
		function part:GetOriginFix()
			return self.originfix
		end
					
		function part:Modify(
			name, 
			model, 
			bone, 
			offset, 
			angles, 
			worldangles, 
			size, 
			scale, 
			color, 
			hue, 
			saturation, 
			brightness, 
			material, 
			skin, 
			effect, 
			light, 
			sprite, 
			trail,
			bodygroup,
			bodygroup_state,
			animation,
			mirrored,
			text,
			clip,
			anglevelocity,
			fx,
			rendermode,
			parent,
			fullbright,
			modelbones,
			eyeangles,
			eyeanglesclamp,
			originfix,
			weaponclass,
			hideweaponclass,
			sunbeams
		)
			if type(name) == "table" then
				return self:Modify(
					name.name, 
					name.model, 
					name.bone, 
					name.offset, 
					name.angles, 
					name.worldangles,
					name.size, 
					name.scale, 
					name.color, 
					name.hue, 
					name.saturation, 
					name.brightness, 
					name.material, 
					name.skin, 
					name.effect, 
					name.light, 
					name.sprite, 
					name.trail,
					name.bodygroup,
					name.bodygroup_state,
					name.animation,
					name.mirrored,
					name.text,
					name.clip,
					name.anglevelocity,
					name.fx,
					name.rendermode,
					name.parent,
					name.fullbright,
					name.modelbones,
					name.eyeangles,
					name.eyeanglesclamp,
					name.originfix,
					name.weaponclass,
					name.hideweaponclass,
					name.sunbeams
				)
			end
			
			if type(model) == "table" then
				return self:Modify(
					name or model.name, 
					model.model, 
					model.bone, 
					model.offset, 
					model.angles, 
					model.worldangles, 
					model.size, 
					model.scale, 
					model.color, 
					model.hue, 
					model.saturation, 
					model.brightness, 
					model.material, 
					model.skin, 
					model.effect, 
					model.light, 
					model.sprite, 
					model.trail,
					model.bodygroup,
					model.bodygroup_state,
					model.animation,
					model.mirrored,
					model.text,
					model.clip,
					model.anglevelocity,
					model.fx,
					model.rendermode,
					model.parent,
					model.fullbright,
					model.modelbones,
					model.eyeangles,
					model.eyeanglesclamp,
					model.originfix,
					model.weaponclass,
					model.hideweaponclass,		
					model.sunbeams					
				)
			end
			
			self:SetName(name)
			self:SetModel(model)
			self:SetBone(bone)
			// the editor modifies these directly
			// any copies you make need to be copied completely
			// or the editor will modify all of them
			self:SetOffset(CopyVector( offset ))
			self:SetAngles(CopyAngle( angles ))
			self:SetWorldAngles(CopyAngle( worldangles ))
			self:SetSize(size)
			self:SetScale(CopyVector( scale ))
			self:SetColor(table.Copy( color ))
			self:SetHue(hue)
			self:SetSaturation(saturation)
			self:SetBrightness(brightness)
			self:SetMaterial(material)
			self:SetSkin(skin)
			self:SetEffect(table.Copy(effect))
			self:SetLightParams(table.Copy( light ))
			self:SetSprite(table.Copy( sprite ))
			self:SetTrail(table.Copy( trail ))
			self:SetBodygroup(bodygroup)
			self:SetBodygroupState(bodygroup_state)
			self:SetAnimation(table.Copy(animation))
			self:SetMirrored(mirrored)
			self:SetText(table.Copy(text))
			self:SetClipPlane(table.Copy(clip))
			self:SetAngleVelocity(CopyAngle(anglevelocity))
			self:SetRenderFX(fx)
			self:SetRenderMode(rendermode)
			self:SetParent(parent)
			self:SetFullBright(fullbright)
			self:SetModelBones(table.Copy(modelbones))
			self:FollowEyeAngles(eyeangles)
			self:ClampEyeAngles(eyeanglesclamp)
			self:SetOriginFix(originfix)
			self:SetWeaponClass(weaponclass)
			self:SetHideWeaponClass(hideweaponclass)
			self:SetSunbeams(table.Copy(sunbeams))
		end
	end -- class part
	
	do -- class bone
		local bone = NewClass("Bone")
		
		AccessorFunc( bone, "size", "Size" );
		
		function bone:Initialize(scale, offset, angles, size, velocity)
			self:SetScale(scale)
			self:SetOffset(offset)
			self:SetAngles(angles)
			self:SetSize( size );
			self:SetAngleVelocity(velocity)
		end
		
		function bone:SetScale(scale)
			self.scale = type(scale) == "Vector" and scale or tonumber(scale) and Vector(1,1,1)*scale or Vector(1,1,1)
		end
		
		function bone:SetOffset(offset)
			self.offset = type(offset) == "Vector" and offset or Vector( 0, 0, 0 )
		end
		
		function bone:SetAngles(angles)
			self.angles = type(angles) == "Angle" and angles or Angle( 0, 0, 0 )
		end
		
		function bone:SetAngleVelocity(velocity)
			self.anglevelocity = type(velocity) == "Angle" and velocity or Angle( 0, 0, 0 )
		end
		
		function bone:SetSize( size )
			self.size = tonumber( size ) or 1;
		end
		
		function bone:GetScale(bone)
			return self.scale
		end
		
		function bone:GetOffset(bone)
			return self.offset
		end
		
		function bone:GetAngles(bone)
			return self.angles
		end
		
	end -- class bones
		
	do -- class config
		local config = NewClass("Config")
				
		function config:Initialize()
			self.drawwep = true;
			self.player_color = Color(255,255,255,255)
			self.player_material = ""
			self.parts = {}
			self.bones = {}
		end
		
		function config:AddPart(...)
			local part = PAC.Part:New(...)
			table.insert(self.parts, part)
			return part
		end
		
		function config:SetBone(bone, scale, offset, angles, size, velocity)
			self.bones[bone] = PAC.Bone:New(scale, offset, angles, size, velocity)
			return self.bones[ bone ];
		end
		
		function config:SetPlayerColor(color)
			self.player_color = type(color) == "table" and color.r and color.g and color.b and (color.a and color or Color(color.r, color.g, color.b, 255)) or Color(255, 255, 255, 255)
		end
	
		function config:SetPlayerMaterialColor(color)
			self.player_mat_color = type(color) == "table" and color.r and color.g and color.b and (color.a and color or Color(color.r, color.g, color.b, 255)) or Color(255, 255, 255, 255)
		end
		
		function config:SetPlayerMaterial(material)
			self.player_material = type(material) == "string" and material or ""
		end
		
		function config:SetOverallBoneScale(scale)
			self.overall_scale = type(scale) == "Vector" and scale
			or tonumber(scale) and Vector(1,1,1)*scale
			or Vector(1,1,1)
		end
		
		function config:SetPlayerModel(model)
			self.playermodel = model
		end
		
		function config:GetPlayerModel()
			return self.playermodel or CLIENT and GetConVarString("cl_playermodel") or nil
		end
		
		config.SetModelScale = config.SetOverallBoneScale
		
		function config:SetDrawWeapon( bool )
			self.drawwep = bool
		end
				
		function config:GetDrawWeapon( )
			return self.drawwep
		end
				
		function config:GetParts()
			return self.parts
		end
		
		function config:GetBones()
			return self.bones
		end
		
		function config:GetBone(bone)
			return self.bones[bone]
		end
		
		function config:GetPlayerColor()
			return self.player_color
		end
		
		
		function config:GetPlayerMaterial()
			return self.player_material
		end
		
		function config:GetPlayerMaterialColor()
			return self.player_mat_color
		end
		
		function config:GetOverallBoneScale()
			return self.overall_scale
		end
		
	end -- class config
end -- classes

PAC.MenuFiles =
{
	"pacmenu",
	
	"propertybox",
	"matselect",
	"colorbox",
	"slider",
	"dragpanel",
	"choice",
	
	"editor",
	"browser",
	
	"filebar",
	"properties",
	"property_setup",
	"parts",
	"matbrowser"
};

for i, filename in pairs( PAC.MenuFiles ) do IncludeClientFile( "pac/menu/"..filename..".lua" ); end