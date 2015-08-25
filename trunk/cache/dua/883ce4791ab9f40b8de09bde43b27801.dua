require("datastream")
require("glon")

PAC = PAC or {}

PAC.ServerFileList = {}
PAC.KnownPrecachedEffects = {}
PAC.ActiveEnts = {}

PAC.CV_Enable = CreateClientConVar("pac_cl_enable", 1, true, true)
PAC.CV_PlayerModel = CreateClientConVar("pac_cl_player_model", 0, true, true)

table.Merge( list.GetForEdit( "TrailMaterials" ),{
	"trails/plasma",
	"trails/tube",
	"trails/electric",
	"trails/smoke",
	"trails/laser",
	"trails/physbeam",
	"trails/love",
	"trails/lol"
} );

table.Merge( list.GetForEdit( "SpriteMaterials" ),{
	"sprites/glow04_noz",
	"sprites/grip",
	"sprites/key_0",
	"sprites/key_1",
	"sprites/key_10",
	"sprites/key_11",
	"sprites/key_12",
	"sprites/key_13",
	"sprites/key_14",
	"sprites/key_15",
	"sprites/key_2",
	"sprites/key_3",
	"sprites/key_4",
	"sprites/key_5",
	"sprites/key_6",
	"sprites/key_7",
	"sprites/key_8",
	"sprites/key_9",
	"sprites/light_ignorez",
	"sprites/muzzleflash4",
	"sprites/orangecore1",
	"sprites/orangecore2",
	"sprites/orangeflare1",
	"sprites/orangelight1",
	"sprites/orangelight1_noz",
	"sprites/physbeam",
	"sprites/physbeama",
	"sprites/physg_glow1",
	"sprites/physg_glow2",
	"sprites/physgbeamb",
	"sprites/redglow1",
	"sprites/640_logo",
	"sprites/640_pain",
	"sprites/640_train",
	"sprites/640hud1",
	"sprites/640hud2",
	"sprites/640hud3",
	"sprites/640hud4",
	"sprites/640hud5",
	"sprites/640hud6",
	"sprites/640hud7",
	"sprites/640hud8",
	"sprites/640hud9",
	"sprites/a_icons1",
	"sprites/animglow01",
	"sprites/animglow02",
	"sprites/ar2_muzzle1",
	"sprites/ar2_muzzle1b",
	"sprites/ar2_muzzle2b",
	"sprites/ar2_muzzle3",
	"sprites/ar2_muzzle3b",
	"sprites/ar2_muzzle4",
	"sprites/ar2_muzzle4b",
	"sprites/arrow",
	"sprites/autoaim_1a",
	"sprites/autoaim_1b",
	"sprites/bigspit",
	"sprites/blackbeam",
	"sprites/blood",
	"sprites/bloodspray",
	"sprites/blueflare1",
	"sprites/blueflare1_noz",
	"sprites/blueglow1",
	"sprites/blueglow2",
	"sprites/bluelaser1",
	"sprites/bluelight1",
	"sprites/blueshaft1",
	"sprites/bubble",
	"sprites/combineball_glow_black_1",
	"sprites/combineball_glow_blue_1",
	"sprites/combineball_glow_red_1",
	"sprites/combineball_trail_black_1",
	"sprites/combineball_trail_blue_1",
	"sprites/combineball_trail_red_1",
	"sprites/crosshair_h",
	"sprites/crosshair_v",
	"sprites/crosshairs",
	"sprites/crosshairs_tluc",
	"sprites/crystal_beam1",
	"sprites/d_icons",
	"sprites/dot",
	"sprites/fire",
	"sprites/fire1",
	"sprites/fire2",
	"sprites/fire_floor",
	"sprites/fire_floor_subrect",
	"sprites/fireburst",
	"sprites/flame01",
	"sprites/flame03",
	"sprites/flame04",
	"sprites/flamefromabove",
	"sprites/flamelet1",
	"sprites/flamelet2",
	"sprites/flamelet3",
	"sprites/flamelet4",
	"sprites/flamelet5",
	"sprites/flare1",
	"sprites/flatflame",
	"sprites/floorfire4_",
	"sprites/FloorFlame",
	"sprites/floorflame2",
	"sprites/FlyingEmber",
	"sprites/glow01",
	"sprites/glow02",
	"sprites/glow03",
	"sprites/glow04",
	"sprites/glow05",
	"sprites/glow06",
	"sprites/glow07",
	"sprites/glow08",
	"sprites/glow1",
	"sprites/glow1_noz",
	"sprites/glow_test01",
	"sprites/glow_test01b",
	"sprites/glow_test02",
	"sprites/greenglow1",
	"sprites/greenspit1",
	"sprites/gunsmoke",
	"sprites/halo01",
	"sprites/heatwave",
	"sprites/heatwavedx70",
	"sprites/hud1",
	"sprites/hydragutbeam",
	"sprites/hydragutbeamcap",
	"sprites/hydraspinalcord",
	"sprites/lamphalo",
	"sprites/lamphalo1",
	"sprites/laser",
	"sprites/laserbeam",
	"sprites/laserdot",
	"sprites/lgtning",
	"sprites/lgtning_noz",
	"sprites/light_glow01",
	"sprites/light_glow02",
	"sprites/light_glow02_add",
	"sprites/light_glow02_add_noz",
	"sprites/light_glow02_noz",
	"sprites/light_glow03",
	"sprites/muzzleflash1",
	"sprites/muzzleflash2",
	"sprites/muzzleflash3",
	"sprites/obsolete",
	"sprites/old_Aexplo",
	"sprites/old_Cexplo",
	"sprites/old_richo2",
	"sprites/old_XFire",
	"sprites/orangeglow1",
	"sprites/physcannon_bluecore1",
	"sprites/physcannon_bluecore1b",
	"sprites/physcannon_bluecore2",
	"sprites/physcannon_bluecore2b",
	"sprites/physcannon_blueflare1",
	"sprites/physcannon_blueglow",
	"sprites/physcannon_bluelight1",
	"sprites/physcannon_bluelight1b",
	"sprites/physcannon_bluelight2",
	"sprites/physring1",
	"sprites/plasma",
	"sprites/plasma1",
	"sprites/plasmabeam",
	"sprites/plasmaember",
	"sprites/plasmahalo",
	"sprites/predator",
	"sprites/purpleglow1",
	"sprites/purplelaser1",
	"sprites/qi_center",
	"sprites/redglow2",
	"sprites/redglow3",
	"sprites/redglow4",
	"sprites/reticle",
	"sprites/reticle1",
	"sprites/reticle2",
	"sprites/richo1",
	"sprites/rico1",
	"sprites/rico1_noz",
	"sprites/rollermine_shock",
	"sprites/scanner",
	"sprites/scanner_bottom",
	"sprites/scanner_dots1",
	"sprites/scanner_dots2",
	"sprites/shellchrome",
	"sprites/smoke",
	"sprites/splodesprite",
	"sprites/spotlight",
	"sprites/sprite_fire01",
	"sprites/steam1",
	"sprites/strider_blackball",
	"sprites/strider_bluebeam",
	"sprites/tp_beam001",
	"sprites/vortring1",
	"sprites/w_icons1",
	"sprites/w_icons1b",
	"sprites/w_icons2",
	"sprites/w_icons2b",
	"sprites/w_icons3",
	"sprites/w_icons3b",
	"sprites/white",
	"sprites/WXplo1",
	"sprites/XBeam2",
	"sprites/yellowflare",
	"sprites/yellowglow1",
	"sprites/zerogxplode",
	"sprites/grubflare1",
	"sprites/bucket_bat_blue",
	"sprites/bucket_bat_red",
	"sprites/bucket_bonesaw",
	"sprites/bucket_bottle_blue",
	"sprites/bucket_bottle_red",
	"sprites/bucket_fireaxe",
	"sprites/bucket_fists_blue",
	"sprites/bucket_fists_red",
	"sprites/bucket_flamethrower_blue",
	"sprites/bucket_flamethrower_red",
	"sprites/bucket_grenlaunch",
	"sprites/bucket_knife",
	"sprites/bucket_machete",
	"sprites/bucket_medigun_blue",
	"sprites/bucket_medigun_red",
	"sprites/bucket_minigun",
	"sprites/bucket_nailgun",
	"sprites/bucket_pda",
	"sprites/bucket_pda_build",
	"sprites/bucket_pda_destroy",
	"sprites/bucket_pipelaunch",
	"sprites/bucket_pistol",
	"sprites/bucket_revolver",
	"sprites/bucket_rl",
	"sprites/bucket_sapper",
	"sprites/bucket_scatgun",
	"sprites/bucket_shotgun",
	"sprites/bucket_shovel",
	"sprites/bucket_smg",
	"sprites/bucket_sniper",
	"sprites/bucket_syrgun_blue",
	"sprites/bucket_syrgun_red",
	"sprites/bucket_tranq",
	"sprites/bucket_wrench",
	"sprites/healbeam",
	"sprites/healbeam_blue",
	"sprites/healbeam_red",
	"sprites/640_pain_down",
	"sprites/640_pain_left",
	"sprites/640_pain_right",
	"sprites/640_pain_up",
	"sprites/bomb_carried",
	"sprites/bomb_carried_ring",
	"sprites/bomb_carried_ring_offscreen",
	"sprites/bomb_dropped",
	"sprites/bomb_dropped_ring",
	"sprites/bomb_planted",
	"sprites/bomb_planted_ring",
	"sprites/c4",
	"sprites/cbbl_smoke",
	"sprites/defuser",
	"sprites/glow",
	"sprites/halo",
	"sprites/hostage_following",
	"sprites/hostage_following_offscreen",
	"sprites/hostage_rescue",
	"sprites/ledglow",
	"sprites/numbers",
	"sprites/objective_rescue",
	"sprites/objective_site_a",
	"sprites/objective_site_b",
	"sprites/player_blue_dead",
	"sprites/player_blue_dead_offscreen",
	"sprites/player_blue_offscreen",
	"sprites/player_blue_self",
	"sprites/player_blue_small",
	"sprites/player_hostage_dead",
	"sprites/player_hostage_dead_offscreen",
	"sprites/player_hostage_offscreen",
	"sprites/player_hostage_small",
	"sprites/player_radio_ring",
	"sprites/player_radio_ring_offscreen",
	"sprites/player_red_dead",
	"sprites/player_red_dead_offscreen",
	"sprites/player_red_offscreen",
	"sprites/player_red_self",
	"sprites/player_red_small",
	"sprites/player_tick",
	"sprites/radar",
	"sprites/radar_trans",
	"sprites/radio",
	"sprites/scope_arc",
	"sprites/shopping_cart",
	"sprites/spectator_3rdcam",
	"sprites/spectator_eye",
	"sprites/spectator_freecam",
	"sprites/water_drop",
	"sprites/wpn_select1",
	"sprites/wpn_select2",
	"sprites/wpn_select3",
	"sprites/wpn_select4",
	"sprites/wpn_select5",
	"sprites/wpn_select6",
	"sprites/wpn_select7",
	"sprites/xfireball3",
	"sprites/yelflare1",
	"sprites/yelflare2",
	"sprites/frostbreath",
	"sprites/cloudglow1_nofog",
	"sprites/core_beam1",
	"sprites/rollermine_shock_yellow",
	"sprites/yellowlaser1",
	"sprites/bluelight",
	"sprites/grav_beam",
	"sprites/grav_beam_noz",
	"sprites/grav_flare",
	"sprites/grav_light",
	"sprites/orangelight",
	"sprites/portalgun_effects",
	"sprites/redlaserglow",
	"sprites/sphere_silhouette",
	"sprites/track_beam",
	"sprites/redglow_mp1",
	"sprites/sent_ball",
	"sprites/magic",
	"sprites/soul",
	"particle/bendibeam",
	"particle/bendibeam_cheap",
	"particle/blood_core",
	"particle/fire",
	"particle/particle_cloud",
	"particle/particle_composite",
	"particle/Particle_Crescent",
	"particle/Particle_Crescent_Additive",
	"particle/Particle_Debris_01",
	"particle/Particle_Debris_02",
	"particle/Particle_Glow_01",
	"particle/Particle_Glow_01_Add_NoFog",
	"particle/Particle_Glow_01_Additive",
	"particle/Particle_Glow_02",
	"particle/Particle_Glow_02_Additive",
	"particle/Particle_Glow_03",
	"particle/Particle_Glow_03_Additive",
	"particle/Particle_Glow_04",
	"particle/Particle_Glow_04_Additive",
	"particle/Particle_Glow_05",
	"particle/Particle_Glow_05_Add_15OB_MinSize",
	"particle/Particle_Glow_05_Add_15OB_MinSizeBig",
	"particle/Particle_Glow_05_Add_15OB_NoZ",
	"particle/Particle_Glow_05_Additive",
	"particle/Particle_Glow_05_AddNoFog",
	"particle/Particle_Glow_06",
	"particle/Particle_Glow_07",
	"particle/Particle_Glow_07_15OB",
	"particle/Particle_Glow_08",
	"particle/Particle_Glow_09",
	"particle/particle_glow_10",
	"particle/particle_glow_11",
	"particle/particle_noisesphere",
	"particle/Particle_Ring_Blur",
	"particle/Particle_Ring_Blur_Add_15_OverBright",
	"particle/Particle_Ring_Blur_Additive",
	"particle/particle_ring_refract_01",
	"particle/Particle_Ring_Sharp",
	"particle/Particle_Ring_Sharp_Additive",
	"particle/Particle_Ring_Wave",
	"particle/Particle_Ring_Wave_10",
	"particle/Particle_Ring_Wave_2",
	"particle/Particle_Ring_Wave_2_Add",
	"particle/Particle_Ring_Wave_2_Add_15OB",
	"particle/Particle_Ring_Wave_3",
	"particle/Particle_Ring_Wave_3_Add",
	"particle/Particle_Ring_Wave_3_Add_15OB",
	"particle/Particle_Ring_Wave_4",
	"particle/Particle_Ring_Wave_4_Add",
	"particle/Particle_Ring_Wave_4_Add_15OB",
	"particle/Particle_Ring_Wave_4_NoFog",
	"particle/Particle_Ring_Wave_5",
	"particle/Particle_Ring_Wave_5_Add",
	"particle/Particle_Ring_Wave_5_Add_15OB",
	"particle/Particle_Ring_Wave_6",
	"particle/Particle_Ring_Wave_6_Add",
	"particle/Particle_Ring_Wave_6_Add_15OB",
	"particle/Particle_Ring_Wave_7",
	"particle/Particle_Ring_Wave_7_Add",
	"particle/Particle_Ring_Wave_7_Add_15OB",
	"particle/Particle_Ring_Wave_8",
	"particle/Particle_Ring_Wave_8_15OB_NoFog",
	"particle/Particle_Ring_Wave_9",
	"particle/Particle_Ring_Wave_Additive",
	"particle/Particle_Ring_Wave_AddNoFog",
	"particle/particle_smokegrenade",
	"particle/particle_smokegrenade1",
	"particle/particle_sphere",
	"particle/Particle_Sphere_Additive_15OB",
	"particle/Particle_Sphere_Additive_NoZ_15OB",
	"particle/Particle_Square_Gradient",
	"particle/Particle_Square_Gradient_NoFog",
	"particle/Particle_Swirl_03",
	"particle/Particle_Swirl_04",
	"particle/rain",
	"particle/screenspace_fog",
	"particle/smokesprites_0001",
	"particle/smokesprites_0002",
	"particle/smokesprites_0003",
	"particle/smokesprites_0004",
	"particle/smokesprites_0005",
	"particle/smokesprites_0006",
	"particle/smokesprites_0007",
	"particle/smokesprites_0008",
	"particle/smokesprites_0009",
	"particle/smokesprites_0010",
	"particle/smokesprites_0011",
	"particle/smokesprites_0012",
	"particle/smokesprites_0013",
	"particle/smokesprites_0014",
	"particle/smokesprites_0015",
	"particle/smokesprites_0016",
	"particle/SmokeStack",
	"particle/snow",
	"particle/sparkles",
	"particle/warp1_dx8",
	"particle/warp1_warp",
	"particle/warp2_warp",
	"particle/warp3_warp_NoZ",
	"particle/warp4_dx8",
	"particle/warp4_warp",
	"particle/warp4_warp_NoZ",
	"particle/warp5_warp",
	"particle/warp_ripple",
	"particle/animglow02",
	"particle/beam_smoke_01",
	"particle/beam_smoke_02",
	"particle/bendibeam_nofog",
	"particle/glow_haze_nofog",
	"particle/particle_cloud2",
	"particle/particle_electrical_arc",
	"particle/particle_vortring1",
	"particle/smoke_black_smokestack000",
	"particle/smoke_black_smokestack001",
	"particle/smoke_black_smokestack_all",
	"particle/smokestack_nofog",
	"particle/particle_rockettrail1",
	"particle/particle_rockettrail2",
	"particle/Particle_Sphere_Additive_15OB_nodepth",
	"particle/Particle_Swirl_04_nodepth",
	"particle/Particle_Glow_05_Add_15OB",
	"particles/balloon_bit",
	"particles/fire1",
	"particles/fire_glow",
	"particles/flamelet1",
	"particles/flamelet2",
	"particles/flamelet3",
	"particles/flamelet4",
	"particles/flamelet5",
	"particles/smokey",
	"particles/Smoke01_L",

} );

hook.Add( "ShouldDrawLocalPlayer", "PAC.ShouldDrawLocalPlayer",  function()
	if( PAC.InPreview ) then return true; end
end)

hook.Add("PopulateToolMenu", "PAC.PopulateToolMenu:AddOptions", function()
	spawnmenu.AddToolMenuOption("Options", "PAC",  "PAC Client", "PAC Client", "", "",
		PAC.ClientOptionsMenu,  { SwitchConVar = "pac_cl_enable" }
	)
end)

hook.Add("PACEffectPrecached", "PAC.EffectCache", function(name)
	PAC.KnownPrecachedEffects[name] = true
end)

hook.Add("EntityRemoved", "PAC.EntityRemoved", function(ply)
	if ply:IsPlayer() then
		for key, entity in pairs(PAC.ActiveEnts[ply:UniqueID()] or {}) do
			if( type( entity ) == "CSEnt" && IsValid( entity ) ) then entity:Remove( ); end
		end
	end
end)

hook.Add("InitPostEntity", "PAC.Sync", function()
	RunConsoleCommand("pac_sync")
	RunConsoleCommand("pac_get_server_outfits")
	PAC.GetEditorInstance( )
	LocalPlayer():SetPACConfig({}, true)
end)

concommand.Add("pac_save_config_cl", function(ply, command, arguments)
	PAC.SaveConfig(arguments[1], ply:GetPACConfig())
end)

concommand.Add("pac_load_config_cl", function(ply, command, arguments)
	PAC.WearConfigFromFile(arguments[1])
end)

concommand.Add("pac_convert_legacy_outfits", function()
	debug.sethook()
	local path = "pac2_outfits/"..tostring(LocalPlayer():UniqueID()).."/"
	for key, value in pairs(file.Find(path.."*.txt")) do
		local fil = path..value
		if not file.IsDir(fil) and value ~= "__owner.txt" and value ~= "owner.txt" then
			PAC.SaveConfig(value:sub(0,-5), glon.decode(file.Read(fil)))
			file.Delete(fil)
		end
	end
end)

usermessage.Hook("PAC.SpawnPart", function(umr)
	PAC.AddNewPart( nil, nil, nil, umr:ReadString() )
end)

usermessage.Hook("PAC Effect Precached", function(umr) 
	hook.Call("PACEffectPrecached", gmod.GetGamemode(), umr:ReadString())
end)

usermessage.Hook("PACSubmissionAcknowledged", function(umr)
	if umr:ReadBool() then
		chat.AddText(Color(255,255,0), "[PAC2] ", Color(0,255,0), "Your config has been applied.")
	else
		chat.AddText(Color(255,255,0), "[PAC2] ", Color(255,0,0), umr:ReadString())
	end
end)

datastream.Hook("PAC Server Outfits", function(handler, id, encoded, decoded)
	hook.Call("RefreshPACFileList", {}, decoded)
	PAC.ServerFileList = decoded
end)

datastream.Hook("ReceivePACList", function(handler, id, encoded, decoded)
	for path, status in pairs(decoded.edit) do
		PAC.PermissionListExceptions[decoded.list][path] = status
	end
	for k, path in pairs(decoded.delete) do
		PAC.PermissionListExceptions[decoded.list][path] = nil
	end
	PAC.RefreshExceptionList(decoded.list)
end)

datastream.Hook("PACSetConfig", function(handler, id, encoded, t)
	PAC.ApplyConfig(t.ply, t.config)
	hook.Call( "PACConfigApplied", GAMEMODE, t.ply, t.config );
end)

function PAC.SaveToServer(name, config)
	config.name = name
	datastream.StreamToServer("PACSaveToServer", config)
end

function PAC.GetConfigFromFile(name)
	return glon.decode(file.Read("pac2_outfits/"..tostring(LocalPlayer():UniqueID()).."/"..name.."/outfit.txt"))
end

function PAC.WearConfigFromFile(name)
	LocalPlayer():SetPACConfig(PAC.GetConfigFromFile(name))
end

function PAC.RenameConfig(a,b)
	local old = PAC.GetConfigFromFile(a)
	file.Delete("pac2_outfits/"..tostring(LocalPlayer():UniqueID()).."/"..a.."/outfit.txt")
	PAC.SaveConfig(b, old)
end

function PAC.DeleteConfig(name)
	file.Delete("pac2_outfits/"..tostring(LocalPlayer():UniqueID()).."/"..name.."/outfit.txt")
	file.Delete("pac2_outfits/"..tostring(LocalPlayer():UniqueID()).."/"..name.."/name.txt")
end

local bonemerge = {
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_Spine1",
	"ValveBiped.Bip01_R_Foot",
	"ValveBiped.Bip01_Spine",
	"ValveBiped.Bip01_Head1",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_R_Thigh",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_Spine4",
	"ValveBiped.Bip01_R_Calf",
	"ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_Spine2",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_Pelvis",
	"ValveBiped.Bip01_L_Foot",
	"ValveBiped.Bip01_L_Thigh",
}

function PAC.UpdatePlayerScale()
	LocalPlayer():SetModelScale(LocalPlayer().CurrentPACConfig.overall_scale or Vector())
end

function PAC.ChangeHSV(color)
	local a = color.a
	local hue, saturation, brightness = ColorToHSV(color)

	saturation = math.Clamp(saturation + (PAC.OutfitSaturation or 0), 0, 1)
	hue = hue + (PAC.OutfitHue or 0)

	local return_color = HSVToColor(hue, saturation, 1)
	
	return_color.r = return_color.r * math.max((PAC.OutfitBrightness or 1), 0.1)
	return_color.g = return_color.g * math.max((PAC.OutfitBrightness or 1), 0.1)
	return_color.b = return_color.b * math.max((PAC.OutfitBrightness or 1), 0.1)
	return_color.a = a
	
	return return_color
end

function PAC.ApplyConfig(ply, config)	
	
	if PAC.LastApply == CurTime() then return end

	if not ply:IsValid() then return end
	config = PAC.ValidateConfig(config)
			
	if file.Exists("materials/" .. config.player_material .. ".vmt" , true) then
		ply.player_imaterial = Material(config.player_material)
	end
									
	for key, entity in ipairs(PAC.ActiveEnts[ply:UniqueID()] or {}) do
		if IsValid(entity) then
			entity:Remove()
		end
	end
	
	PAC.ActiveEnts[ply:UniqueID()] = {}
	
	ply:SetMaterial(config.player_material)
	ply:SetModelScale(config.overall_scale or Vector())
	
	for key, wep in pairs(ply:GetWeapons()) do
		if wep:IsWeapon() then
			 wep:SetNoDraw(false)
		end
	end
	
	ply.pac_hide_weapon_matched = false
	ply.pac_previous_weapon_class = nil
	
	for id, part in ipairs(config.parts) do
		if part.effect and type(part.effect.effect) == "string" and part.effect.effect ~= "" then
			RunConsoleCommand("pac_precache_effect", part.effect.effect)
		end
		if part.name and part.model then
			local entity = ClientsideModel(part.model)
			--entity:SetModel(part.model)
			--entity:Spawn()

			if not IsValid(entity) then return end
			
			local bone_count = entity:GetBoneCount()
	
			if bone_count then
				for i=0, bone_count do
					local bones = part.modelbones.bones[i]
					if bones then
						bones[i] = {
							size = bones.size or 1, 
							scale = CopyVector(bones.scale) or Vector(), 
							offset = CopyVector(bones.offset) or Vector(0), 
							angles = CopyAngle(bones.angles) or Vector(0)
						}
					else
						if not part.modelbones.bones then part.modelbones.bones = {} end
						part.modelbones.bones[i] = {
							size = 1, 
							scale = Vector(), 
							offset = Vector(0), 
							angles = Vector(0)
						}
					end
				end
			end

           -- entity:SetParent(ply)
			
			entity.part = part
			part.entity = entity
					
			if PAC.CurrentPart and PAC.CurrentPart.name == part.name then PAC.CurrentEntity = entity end
			
			entity:SetNoDraw(true)
			
			if part.material ~= "" and file.Exists("materials/" .. part.material .. ".vmt" , true) then
				entity.imaterial = Material(part.material)
			end
						
			entity.effect_active = false
			entity.name = part.name
			
			--entity.error_scale = not file.Exists("../"..part.model) and 0.1 or 1
			
			PAC.ActiveEnts[ply:UniqueID()][id] = entity
						
			entity.sprite = part.sprite
			if entity.sprite.Enabled then
				entity.sprite_material = Material(part.sprite.material)
				if entity.sprite_material:IsError() then
					entity.sprite_material = nil
				end
			end
			
			entity.trail = part.trail
			if entity.trail.Enabled then
				entity.trail_material = Material(part.trail.material)
				if entity.trail_material:IsError() then
					entity.trail_material = nil
				end
			end
									
			--if part.modelbones.merge then entity:AddEffects(EF_BONEMERGE) entity.pac_bonemerged = true end
			
			entity.BuildBonePositions = function(self)
				if part.modelbones.Enabled then
					for i=0,#part.modelbones.bones do
						local data = part.modelbones.bones[i]
						if data then
							local matrix = entity:GetBoneMatrix(i)
							if matrix then
								matrix:Scale(data.scale*data.size*part.modelbones.overallsize)
								matrix:Translate(data.offset)
								matrix:Rotate(data.angles)
								
								if part.modelbones.fixfingers and entity:GetBoneName(i):find("Finger") then
									local position, angles 
										
									if entity:GetBoneName(i):find("_R_") then
										position, angles = ply:GetBonePosition(entity:LookupBone("ValveBiped.Bip01_R_Hand"))
									else
										position, angles = ply:GetBonePosition(entity:LookupBone("ValveBiped.Bip01_L_Hand"))
									end
									
									matrix:SetTranslation(position)
									matrix:Rotate(angles)
									matrix:Scale(Vector(0))
								end
								
								entity:SetBoneMatrix(i, matrix)
							end
						end
					end
				end
			end
			
			entity:SetModelScale(part.scale*part.size)
			
			local min, max = entity:GetRenderBounds()
			
			entity.center = (min + max) * 0.5

			entity:SetRenderBounds(vector_up*-100, vector_up*100)
			
			if part.skin ~= 0 then entity:SetSkin(part.skin) end
			if part.bodygroup ~= 0 and part.bodygroup_state ~= 0 then entity:SetBodygroup(part.bodygroup, part.bodygroup_state) end
			if part.rendermode ~= 0 then entity:SetRenderMode(part.rendermode) end
			if part.renderfx ~= 0 then entity:SetRenderFX(part.renderfx) end
		end
	end
	
	for id, part in pairs(config.parts) do
		if part.parent then
			for key, entity in pairs(PAC.ActiveEnts[ply:UniqueID()]) do
				if entity.name == part.parent then
					part.entity.parent = entity
				end
			end
		end
	end
	
	if ply == LocalPlayer() then
		ply.PACConfigContainsLights = false
		for id, part in ipairs(config.parts) do
			if part.light.Enabled then
				ply.PACConfigContainsLights = true
			break end
		end
	end

	ply.CurrentPACConfig = config
	
	if PAC.Editor and PAC.Editor.Parts then
		PAC.Editor.Parts:Refresh()
		PAC.GetPropertyInfo("Bones", "Bone").Reset(PAC.GetPropertyInfo("Bones", "Bone").Control)
		PAC.GetPropertyInfo("Bones", "Select").Reset(PAC.GetPropertyInfo("Bones", "Select").Control, PAC.CurrentPart)
		PAC.GetPropertyInfo("Bones", "ParentBone").Reset(PAC.GetPropertyInfo("Bones", "ParentBone").Control, PAC.CurrentPart)
	end
	
	PAC.LastApply = CurTime()
end


function PAC.SaveConfig(name, config)
	local path = "pac2_outfits/"..tostring(LocalPlayer():UniqueID()).."/"..string.gsub(name, "%W", "")
	file.Write(path.."/outfit.txt", glon.encode(config))
	file.Write(path.."/name.txt", name)
	if not file.Exists("pac2_outfits/"..tostring(LocalPlayer():UniqueID()).."/__owner.txt") then
		file.Write("pac2_outfits/"..tostring(LocalPlayer():UniqueID()).."/__owner.txt", string.gsub(LocalPlayer():Nick(), "%W", ""))
	end
end

function PAC.GetServerFileList()
	RunConsoleCommand("pac_get_server_outfits")
end

function PAC.SubmitConfig(config)
	datastream.StreamToServer("PACSubmission", config)
end

function PAC.ClientOptionsMenu(panel)
	panel:AddControl("Button", {
		Label = "Show Editor",
		Command = "pac_show_editor",
	})
	local browser = panel:AddControl("PACBrowser", {})
	browser:SetSize(400,700)
	panel:AddControl("Button", {
		Label = "Refresh",
		Command = "pac_refresh_files",
	})	
	panel:AddControl("CheckBox", {
		Label = "Enable PAC",
		Command = "pac_cl_enable",
	})
	panel:AddControl("Slider", {
		Label = "Draw Distance",
		Command = "pac_cl_draw_distance",
		min = 0,
		max = 20000,
	})
	panel:AddControl("CheckBox", {
		Label = "Ignore Outfit Player Model",
		Command = "pac_cl_player_model",
	})
end

function _R.Player:SetPACConfig(config, dont_send)
	config = type(config) == "Player" and config:GetPACConfig() or config

	self.CurrentPACConfig = PAC.ValidateConfig(config)
	if not dont_send and self == LocalPlayer() then
		PAC.SubmitConfig(self.CurrentPACConfig)
	end
end