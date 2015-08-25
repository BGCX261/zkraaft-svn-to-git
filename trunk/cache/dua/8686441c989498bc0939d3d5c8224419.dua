require("datastream")
require("glon")

PAC = PAC or {}

local eye_ang = Angle(0)
local eye_pos = Vector(0)

hook.Add("RenderScene", "PAC.GetEyeAngles", function(pos, ang) 
	eye_ang = ang 
	eye_pos = pos 
end)

PAC.CV_Enable = CreateClientConVar("pac_cl_enable", 1, true, true)
PAC.CV_DrawDistance = CreateClientConVar("pac_cl_draw_distance", 7000, true, true)

local CV_Enable = PAC.CV_Enable
local CV_DrawDistance = PAC.CV_DrawDistance
local ActiveEnts = PAC.ActiveEnts
local LocalPlayer = LocalPlayer
local Vector = Vector

local distance

function CheckDistance(ply)
	if ply == LocalPlayer() then
		return ply:ShouldDrawLocalPlayer()
	end
	distance = CV_DrawDistance:GetInt()
	return distance == 0 or eye_pos:Distance(ply:GetShootPos()) < distance or LocalPlayer():GetEyeTrace().Entity == ply
end

PAC.CheckDistance = CheckDistance

local EyePos = EyePos
local EyeAngles = EyeAngles
local SetMaterial = render.SetMaterial
local DrawSprite = render.DrawSprite
local Clamp = function(number, min, max)
	return math.max(math.min(number,max),min)
end

local function DrawSprites(position, material, x, y, color)
	SetMaterial( material )
	DrawSprite( position, Clamp(x,-128,128), Clamp(y,-128,128), color)
end

local insert = table.insert
local remove = table.remove
local StartBeam = render.StartBeam
local AddBeam = render.AddBeam
local EndBeam = render.EndBeam
local pairs = pairs
local width

local function RenderTrail(entity, material, color, length, startsize)
	entity.traildata = entity.traildata or {}
	entity.traildata.points = entity.traildata.points or {}

	insert(entity.traildata.points,entity:GetPos())
	if #entity.traildata.points > length then remove(entity.traildata.points, #entity.traildata.points - length) end

	SetMaterial(material)
	StartBeam(#entity.traildata.points)
		for k,v in pairs(entity.traildata.points) do
			width = k / (length / startsize)
			AddBeam(v,width,width,color)
		end
	EndBeam()
end

local Start3D2D = cam.Start3D2D
local End3D2D = cam.End3D2D
local IsValid = IsValid
local SimpleTextOutlined = draw.SimpleTextOutlined
local CullMode = render.CullMode

local angles

local function DrawText(entity, tbl)
	angles = entity:GetAngles()
	
	Start3D2D(entity:GetPos(), angles, tbl.size)
		SimpleTextOutlined(tbl.text, tbl.font, 0,0, tbl.color, 0,0, tbl.outline, tbl.outlinecolor)
		CullMode(1) -- MATERIAL_CULLMODE_CW
			SimpleTextOutlined(tbl.text, tbl.font, 0,0, tbl.color, 0,0, tbl.outline, tbl.outlinecolor)
		CullMode(0) -- MATERIAL_CULLMODE_CCW
	End3D2D()
	
end

local type = type
local ParticleEffectAttach = ParticleEffectAttach
local CurTime = CurTime
local Max = math.max
local TranslateBoneToUnfriendly = PAC.TranslateBoneToUnfriendly
local LocalToWorld = LocalToWorld
local abs = math.abs
local Round = math.Round

local EnableClipping = render.EnableClipping
local PushCustomClipPlane = render.PushCustomClipPlane
local SetMaterialOverride = SetMaterialOverride
local SetColorModulation = render.SetColorModulation
local SetBlend = render.SetBlend
local SuppressEngineLighting = render.SuppressEngineLighting
local PopCustomClipPlane = render.PopCustomClipPlane
local DynamicLight = DynamicLight
local CRC = util.CRC
local Min = math.min
local KnownPrecachedEffects = PAC.KnownPrecachedEffects
local draw_model = true

local bone
local position, angles
local parent
local modelbones
local velocity
local worldangles
local clip
local bone
local clipangles
local normal
local sprite
local trail
local text
local light, dlight 
local sequence
local rate
local frame
local min
local max
local hue, sat
local color
local offset
local weaponclass
local weapon
local hide_weapon
local new_position, new_angles

local function HideWeapon(ply, allowed)
	weapon = ply:GetActiveWeapon( )
	if weapon:IsWeapon() then
		if allowed then
			weapon:SetNoDraw( true )
			weapon:SetColor(255,255,255,0)
			weapon.pac_hide_weapon = true
		else
			weapon:SetNoDraw( false )
			weapon:SetColor(255,255,255,255)
			weapon.pac_hide_weapon = false
		end
	end
end

-- lol
-- sunbeams nostalgia
local entity
local vec2
local mult
hook.Add("RenderScreenspaceEffects", "PAC.RenderScreenspaceEffects", function()
	for key, ply in pairs(player.GetAll()) do
		if not ply.pac_draw then continue end
		config = ply.CurrentPACConfig
		if config then			
			uniqueid = ply:UniqueID()
			if ActiveEnts[uniqueid] then	
				for id, part in pairs(ply.CurrentPACConfig.parts) do
					if IsValid(part.entity) then
						entity = part.entity
						if part.sunbeams.Enabled then
				 			vec2 = entity:GetPos():ToScreen()
							mult = Clamp((-ply:GetShootPos():Distance(eye_pos) / PAC.CV_DrawDistance:GetFloat()) + 1, 0, 1)
							if mult > 0 and vec2.x < ScrW() and vec2.x > 0 and vec2.y < ScrH() and vec2.y > 0 then
								DrawSunbeams(
									Clamp(part.sunbeams.darken, 0, 1), 
									Clamp((part.sunbeams.multiply * mult) * 0.4, -1, 1), 
									part.sunbeams.size * 0.5, 
									vec2.x / ScrW(), 
									vec2.y / ScrH()
								)
							end
						end
					end
				end
			end
		end
	end
end)

local bclip = false

local function RenderPart(ply, entity, part, time, uniqueid, hitpos, id, total)

	entity.nodraw = false

	if ply.CurrentPACConfig and ply.CurrentPACConfig.drawwep == true then
		weaponclass = part.weaponclass or entity.parent and entity.parent.part and entity.parent.part.weaponclass
	
		if weaponclass and weaponclass ~= "" then
							
			if ply.pac_weapon_class ~= ply.pac_previous_weapon_class then
				if ply.pac_weapon_class:find(weaponclass) then 
					entity.hide_weapon_matched = true
				else
					entity.hide_weapon_matched = false
				end
				if id == total then ply.pac_previous_weapon_class = ply.pac_weapon_class end
			end
			
			if entity.hide_weapon_matched then
				if part.hideweaponclass then
					HideWeapon(ply, true)
					--("hiding weapon", CurTime())
				else
					HideWeapon(ply, false)
				end
			else 
				HideWeapon(ply, false)
			return end
		end
	else
		ply.pac_hide_weapon_matched = false
	end
		
	if entity.nodraw then return end
	
	hitpos = hitpos or Vector(0)
	if not draw_model then return end
	
	if -- Particle
		part.effect and 
		part.effect.Enabled and
		type(part.effect.effect) == "string" and 
		part.effect.effect ~= "" and
		KnownPrecachedEffects[part.effect.effect] and
		(entity.last_effect_time or 0) < time and
		(not entity.effect_active or part.effect.loop) 
	then
		entity:StopParticles()
		ParticleEffectAttach(part.effect.effect, 1, entity, 0) -- PATTACH_ABSORIGIN_FOLLOW
		entity.effect_active = true
		entity.last_effect_time = time + Max(part.effect.rate,0.1)
	end
	
	bone = ply:LookupBone(TranslateBoneToUnfriendly(part.bone) or "")
	parent = entity.parent
	
	if parent or bone then
					
		if parent then
			modelbones = parent.part.modelbones
			if modelbones.Enabled and modelbones and modelbones.redirectparent then
				position, angles = parent:GetBonePosition(parent:LookupBone(modelbones.redirectparent))				
			else
				position = parent:GetPos() --or vector_origin
				angles = parent:GetAngles() --or Angle(0)
			end
		else
			position, angles = ply:GetBonePosition(bone)
		end
		
		position, angles = LocalToWorld( part.offset, part.angles, position, angles )
		
					
		if part.eyeangles then 
			angles = part.angles + (hitpos - entity:GetPos()):Angle()
		end
		
		--do --Set
			velocity = part.anglevelocity
			if velocity then
				if velocity.p ~= 0 then angles:RotateAroundAxis(angles:Right(), time*velocity.p*30) end
				if velocity.y ~= 0 then angles:RotateAroundAxis(angles:Forward(), time*velocity.y*30) end
				if velocity.r ~= 0 then angles:RotateAroundAxis(angles:Up(), time*velocity.r*30) end
			end
			
			if part.originfix then				
				entity:SetRenderOrigin(position)
				entity:SetRenderAngles(angles)
				new_position, new_angles = LocalToWorld(entity.center*-1 * part.scale * part.size, vector_origin, entity:GetRenderOrigin() or vector_origin, entity:GetRenderAngles() or vector_origin)
				entity:SetRenderOrigin(new_position)
				entity:SetRenderAngles(new_angles)
				entity:SetupBones()

			else
				entity:SetRenderOrigin(position)
				entity:SetRenderAngles(angles)
				entity:SetupBones()
			end
			
			
			if PAC.InPreview and ply == LocalPlayer() then
				entity:SetModelScale(part.scale*part.size)
				if part.skin ~= 0 then entity:SetSkin(part.skin) end
				if part.bodygroup ~= 0 and part.bodygroup_state ~= 0 then entity:SetBodygroup(part.bodygroup, part.bodygroup_state) end
				if part.rendermode ~= 0 then entity:SetRenderMode(part.rendermode) end
				if part.renderfx ~= 0 then entity:SetRenderFX(part.renderfx) end
			end
		--end
		
 		--do --Draw
			if part.color.a ~= 0 and part.size ~= 0 and part.scale ~= vector_origin then
				clip = part.clip
				if clip and clip.Enabled then
					bone = clip.bone
					local position, angles = position, angles
					if bone and bone ~= "" then
						position, angles = LocalToWorld( part.offset, part.angles, entity:GetBonePosition(entity:LookupBone(bone)) )
					end
					clipangles = clip.angles
					if clipangles.p ~= 0 then angles:RotateAroundAxis(entity:GetAngles():Right(), clipangles.p) end
					if clipangles.y ~= 0 then angles:RotateAroundAxis(entity:GetAngles():Up(), clipangles.y) end
					normal = angles:Forward()
					bclip = EnableClipping(true)
					PushCustomClipPlane(normal, normal:Dot(position+normal*clip.distance))
				end
				
				color = part.color
				
				--if part.hue ~= 0 or part.saturation ~= 0 or part.brightness ~= 0 then	
					hue, sat, value = ColorToHSV(part.color)
					color = HSVToColor(hue + part.hue, math.min(sat * part.saturation, 1), value)
					
					color.r = color.r * part.brightness
					color.g = color.g * part.brightness
					color.b = color.b * part.brightness
				--end
								
				SetMaterialOverride(entity.imaterial or 0)
					SetColorModulation(color.r/255, color.g/255, color.b/255)
						SetBlend(part.color.a/255)
							if part.mirrored then CullMode(1) end
								if part.fullbright then SuppressEngineLighting(true) end
									if part.modelbones.merge then draw_model = false end
										entity:DrawModel()
									if part.modelbones.merge then draw_model = true end
								if part.fullbright then SuppressEngineLighting(false) end
							if part.mirrored then CullMode(0) end
						SetBlend(1)
					SetColorModulation(1,1,1)
				SetMaterialOverride(0)
				if part.clip and part.clip.Enabled then
					PopCustomClipPlane()
					EnableClipping(bclip)
				end
			end
		--end --Draw
		
		modelbones = part.modelbones
		if modelbones.Enabled and modelbones and modelbones.redirectparent then
			position, angles = entity:GetBonePosition(entity:LookupBone(modelbones.redirectparent))				
		end
		
 		--do --Extra			
			sprite = part.sprite
			if sprite and sprite.Enabled and entity.sprite.material ~= "" and sprite.Enabled and type(entity.sprite_material) == "IMaterial" then
				DrawSprites(position, entity.sprite_material, sprite.x, sprite.y, sprite.color)
			end
			
			trail = part.trail
			if trail and trail.Enabled and entity.trail_material and trail.startsize > 0 and trail.length > 0 then
				RenderTrail(entity, entity.trail_material, trail.color, trail.length, trail.startsize)
			end
			
			text = part.text
			if text and text.Enabled and text.text and text.text ~= "" and text.font and text.font ~= "" and text.size > 0 then
				DrawText(entity, text)
			end
					
			if part.light.Enabled then
				light, dlight = part.light, DynamicLight(uniqueid..part.name)
				if dlight then
					dlight.Pos = position
					dlight.r = light.r
					dlight.g = light.g
					dlight.b = light.b
					dlight.Brightness = Min(light.Brightness, 10)
					dlight.Size = light.Size
					dlight.Decay = 0
					dlight.DieTime = time + 0.1
				end
			end
			
			if part.animation.Enabled then
				sequence = entity:LookupSequence(part.animation.name)
				if sequence ~= -1 then
					entity:ResetSequence(sequence)
				else
					entity:ResetSequence(part.animation.sequence)
				end
				rate = part.animation.rate
				if rate > 0 then
					frame = (time+part.animation.offset)*rate
					min = part.animation.min
					max = part.animation.max
					if part.animation.loopmode then
						entity:SetCycle(min + abs(Round(frame*0.5) - frame*0.5)*2 * (max - min))
					else
						entity:SetCycle(min + frame%1 * (max - min))
					end
				else
					entity:SetCycle(part.animation.offset)
				end
			end
			
		--end
	end
	entity:SetNoDraw(true)
end

local config

hook.Add("PrePlayerDraw", "PAC.PrePlayerDraw:SetAlpha", function(ply)
	if PAC.CV_Enable:GetBool() and ply.pac_draw then
		
		config = ply.CurrentPACConfig
		if config then
			SetColorModulation((config.player_color.r or 255)/255, (config.player_color.g or 255)/255, (config.player_color.b or 255)/255)
			SetBlend((config.player_color.a or 255)/255)
			-- seems to work better than destroying the shadow..
			local c = config.player_color
			ply:SetColor(c.r,c.g,c.b,Max(c.a,1)) 
			if config.player_color.a == 0 then
				weapon = ply:GetActiveWeapon()
				if weapon:IsWeapon() then weapon:DestroyShadow() end
				if not ply.pac_alpha_0 then
					ply:SetMaterial("models/wireframe")
					ply.pac_alpha_0 = true
				end
			elseif ply.pac_alpha_0 then
				ply:SetMaterial(config.player_material)
				ply.pac_alpha_0 = false
			end
			
			for key, wep in pairs(ply:GetWeapons()) do
				wep.pac_hide_weapon = nil
			end
		end
	end
end)

local TimerCreate = timer.Create
local ErrorNoHalt
local tostring = tostring
local GetAll = player.GetAll
local QuickTrace = util.QuickTrace

local entity
local time
local config
local tbl
local eye = false

local function Reset(ply, cmp, to)
	if ply.pac_reset == cmp then
		ply:SetMaterial("")
		ply:SetModelScale(Vector())
		ply:SetColor(255,255,255,255)
		ply.pac_reset = to
	end
end

-- If you call traces in a render hooks, odd things will happen. So we'll this in tick instead.
hook.Add("Tick", "PAC.HitPos", function()
	if not PAC.ActiveEnts then return end
	for key, ply in pairs(GetAll()) do
	
		if ply.pac_reset == nil then
			ply.pac_reset = "not_drawn"
		end
		
		if PAC.CV_Enable:GetBool() then
			
			ply.pac_draw = CheckDistance(ply)
			
			if ply.pac_draw then 
				config = ply.CurrentPACConfig
				if config then			
					if ply.pac_reset == "not_drawn" or ply.pac_reset == "pac_off" then
						
						ply:SetMaterial(config.player_material)
						ply:SetModelScale(config.overall_scale)
						--local c = config.player_color
						--ply:SetColor(c.r, c.g, c.b, 255)
						
						ply.pac_reset = "drawn"
					end
				
					ply.pac_weapon_class = ply:GetActiveWeapon():IsWeapon() and ply:GetActiveWeapon():GetClass() or ""
					tbl = PAC.ActiveEnts[ply:UniqueID()]
					eye = false
					if tbl then
						for key, entity in pairs(tbl) do
							if not entity:IsValid() then continue end
							if not entity.part then continue end
							if eye ~= nil and entity.part.eyeangles then
								eye = true
							end
							if entity.part.modelbones.merge then
								if not entity:IsEffectActive(EF_BONEMERGE) then 
									entity:AddEffects(EF_BONEMERGE) 
								end
							else
								entity:RemoveEffects(EF_BONEMERGE) 
							end
							if entity:GetParent() ~= ply then entity:SetParent(ply) end
						end
					end
					if eye then ply.PAC_HitPos = QuickTrace(ply:GetShootPos(), ply:GetAimVector()*1000, ply).HitPos end
				end
			else
				Reset(ply, "drawn", "not_drawn")
			end
		else
			Reset(ply, "drawn", "pac_off")
		end
	end
end)

local uniqueid

hook.Add("PostPlayerDraw", "PAC.PostPlayerDraw:DrawParts", function(ply)
	if PAC.CV_Enable:GetBool() and ply.pac_draw then
	
		SetColorModulation(1,1,1)
		SetBlend(1)
	
		if IsValid(ply) and ply:Alive() then
			ply.pac_is_visible = CurTime()
		end
		
		config = ply.CurrentPACConfig
		if config then			
			uniqueid = ply:UniqueID()
			if ActiveEnts[uniqueid] then	
					
				time = CurTime()
								
				for id, part in pairs(ply.CurrentPACConfig.parts) do
					if IsValid(part.entity) then
						RenderPart(ply, part.entity, part, time, uniqueid, ply.PAC_HitPos, id, #ply.CurrentPACConfig.parts)
					end
				end

				if config.drawwep == false then
					weapon = ply:GetActiveWeapon( )
					if IsValid( weapon ) then
						weapon:SetNoDraw( weapon.pac_hide_weapon or not config.drawwep )
					end
				end
				
				if config.player_color.a == 0 then
					ply:DestroyShadow()
				end
			end
		end
	end
end)

local index, matrix
local velocity

local function BuildBonePositions(ply, body)
	if PAC.CV_Enable:GetBool() and ply.CurrentPACConfig and ply.pac_draw then
		body = body and body:IsValid() and body or ply
		for name, bone in pairs(ply.CurrentPACConfig.bones) do
			index = body:LookupBone(PAC.TranslateBoneToUnfriendly(name))
			matrix = body:GetBoneMatrix(index)
			if matrix then
				matrix:Scale(bone.scale*(ply ~= body and ply.CurrentPACConfig.overall_scale or 1) * bone.size)
				matrix:Translate(bone.offset)
				
				velocity = CopyAngle(bone.angles)
				
				velocity:RotateAroundAxis(bone.angles:Right(), CurTime()*bone.anglevelocity.p*30)
				velocity:RotateAroundAxis(bone.angles:Forward(), CurTime()*bone.anglevelocity.y*30)
				velocity:RotateAroundAxis(bone.angles:Up(), CurTime()*bone.anglevelocity.r*30)
				
				matrix:Rotate(bone.angles+velocity)
				body:SetBoneMatrix(index, matrix)
			end
		end
	end 
end

local ragdoll

hook.Add("PostDrawOpaqueRenderables", "PAC.PostDrawOpaqueRenderables:DrawBones", function()
	if PAC.CV_Enable:GetBool() then
		for key, ply in pairs(player.GetAll()) do
			if ply.pac_draw then
				if ply.CurrentPACConfig and ActiveEnts[ply:UniqueID()] then
					if (ply.pac_is_visible or math.huge) < CurTime()-0.1 then
						for id, part in pairs(ply.CurrentPACConfig.parts) do
							entity = ActiveEnts[ply:UniqueID()][id]
							if entity and entity:IsValid() then
								entity:StopParticles()
								entity.effect_active = false
							end
						end
					end			
					if ply:GetRagdollEntity() then
						ragdoll = ply:GetRagdollEntity()
						if ValidEntity(ragdoll) then
							if ragdoll.PACOverriden_BuildBonePositions and ragdoll.BuildBonePositions ~= ragdoll.PACOverriden_BuildBonePositions
							or not ragdoll.PACOverriden_BuildBonePositions and ragdoll.BuildBonePositions ~= BuildBonePositions then
								if ragdoll.BuildBonePositions then
									local old_BuildBonePositions = ragdoll.BuildBonePositions
									function ragdoll:BuildBonePositions(...)
										BuildBonePositions(ply, self)
										old_BuildBonePositions(self, ...)
									end
									ragdoll.PACOverriden_BuildBonePositions = ragdoll.BuildBonePositions
								else
									function ragdoll:BuildBonePositions()
										BuildBonePositions(ply, self)
									end
									ragdoll.PACOverriden_BuildBonePositions = ragdoll.BuildBonePositions
								end
							end
							ragdoll:SetMaterial(ply.CurrentPACConfig.player_material)
							ragdoll:SetColor(
								ply.CurrentPACConfig.player_color.r, ply.CurrentPACConfig.player_color.g,
								ply.CurrentPACConfig.player_color.b, Max(ply.CurrentPACConfig.player_color.a, 1)
							)
							for id, part in pairs(ply.CurrentPACConfig.parts) do
								entity = ActiveEnts[ply:UniqueID()][id]
								if entity and entity:IsValid() then
									RenderPart(ragdoll, entity, part, CurTime(), ply:UniqueID(), ply.PAC_HitPos)
								end
							end
						end
					else
						if ply.PACOverriden_BuildBonePositions and ply.BuildBonePositions ~= ply.PACOverriden_BuildBonePositions
						or not ply.PACOverriden_BuildBonePositions and ply.BuildBonePositions ~= BuildBonePositions then
							if ply.BuildBonePositions then
								local old_BuildBonePositions = ply.BuildBonePositions
								function ply:BuildBonePositions(...)
									BuildBonePositions(self)
									old_BuildBonePositions(self, ...)
								end
								ply.PACOverriden_BuildBonePositions = ply.BuildBonePositions
							else 
								function ply:BuildBonePositions()
									BuildBonePositions(self)
								end
								ply.PACOverriden_BuildBonePositions = ply.BuildBonePositions
							end
						end
					end
				end
			end
		end
	end
end)

local last_inpreview = false

local RunConsoleCommand = RunConsoleCommand
local GetAllPlayers = player.GetAll
local Color = Color
local DrawText = draw.DrawText

local position_3D
local position

hook.Add("HUDPaint", "PAC.HUDPaint:DrawNotice", function()
	if PAC.InPreview and PAC.InPreview ~= last_inpreview then
		RunConsoleCommand("in_pac_editor", 1)
		last_inpreview = PAC.InPreview
		if ctp and ctp.Disable then
			ctp:Disable()
		end
	elseif not PAC.InPreview and PAC.InPreview ~= last_inpreview then
		RunConsoleCommand("in_pac_editor", 0)
		last_inpreview = PAC.InPreview
	end
	for key, ply in pairs(GetAllPlayers()) do
		if ply ~= LocalPlayer() and ply:GetNWBool("in pac editor") then
			position_3D = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1"))
			position = (position_3D + Vector(0,0,10)):ToScreen()
			DrawText("In PAC Editor", "ChatFont", position.x, position.y, Color(255,255,255,Clamp((position_3D + Vector(0,0,10)):Distance(EyePos()) * -1 + 500, 0, 500)/500*255),1)
		end
	end
end)
