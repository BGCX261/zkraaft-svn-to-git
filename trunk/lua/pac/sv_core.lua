require("datastream")
require("glon")

PAC = PAC  or {}

PAC.EffectsBlackList = {
	"frozen_steam",
	"portal_rift_01",
	"explosion_silo",
	"citadel_shockwave_06",
	"citadel_shockwave",
	"choreo_launch_rocket_start",
	"choreo_launch_rocket_jet",
}

local servertags = GetConVarString("sv_tags") --Thanks PHX!

if servertags == nil then
	RunConsoleCommand("sv_tags", "PAC2")
elseif not string.find(servertags, "PAC2") then
	RunConsoleCommand("sv_tags", "PAC2," .. servertags)
end

function PAC.SpawnPart(ply, model)
	if ply:GetNWBool("in pac editor") then
		SendUserMessage("PAC.SpawnPart", ply, model)
		return false
	end
end

hook.Add( "PlayerSpawnProp", "PAC.PlayerSpawnProp", PAC.SpawnPart)
hook.Add( "PlayerSpawnRagdoll", "PAC.PlayerSpawnRagdoll", PAC.SpawnPart)
hook.Add( "PlayerSpawnEffect", "PAC.PlayerSpawnEffect", PAC.SpawnPart)

hook.Add("PlayerSpawn", "PAC.SetPlayerModel", function(ply)
	local config = ply:GetPACConfig()
	if config and config.playermodel and ply:GetInfoNum("pac_cl_player_model") < 1 then
		ply:SetModel(player_manager.TranslatePlayerModel(config.playermodel))
	end
end)

--[[ hook.Add("AcceptStream", "PAC.AcceptStream", function(ply, handler)
	if handler == "PACSubmission" then
		ply.pac_streaming_outfit
	end
end)

hook.Add("CompletedIncomingStream", "PAC.CompletedIncomingStream", function(ply, handler)
	
end) ]]

concommand.Add("pac_sync", function(ply)
	if ply.pac_synced then return end
	ply.pac_synced = true
	PAC.Sync(ply) 
	local config = PAC.GetSpawnConfig(ply)
	local allowed, issue = hook.Call("PrePACConfigApply", nil, ply, config)
	if allowed ~= false then
		ply:SetPACConfig(config)
	end
end)

concommand.Add("pac_load_config_sv", function(ply, command, arguments)
	PAC.WearConfigFromFile(ply, arguments[1], arguments[2])
end)

concommand.Add("pac_rename_config_sv", function(ply, command, arguments)
	if ply:IsAdmin() or ply:UniqueID() == arguments[1] then
		PAC.RenameConfig(arguments[1], arguments[2], arguments[3])
	end
end)

concommand.Add("pac_delete_config_sv", function(ply, command, arguments)
	if ply:IsAdmin() or ply:UniqueID() == arguments[1] then
		PAC.DeleteConfig(arguments[1], arguments[2])
	end
end)

concommand.Add("in_pac_editor", function(ply, command, arguments)
	if tonumber(arguments[1]) >= 1 then
		ply:SetNWBool("in pac editor", true)
	else
		ply:SetNWBool("in pac editor", false)
	end
end)

local enable = CreateConVar("pac_server_outfits", "1", FCVAR_ARCHIVE)

concommand.Add("pac_get_server_outfits", function(ply)
	if not enable:GetBool() then return end
	if (ply.LastPACSubmission or 0) < CurTime() then
		local tbl = {}
		local done = 0
		file.TFind("data/pac2_outfits/*", function(path, folders)
			if not IsValid(ply) then return end
			for key, value in pairs(folders) do
				local owner = (file.Read("pac2_outfits/"..value.."/__owner.txt") or file.Read("pac2_outfits/"..value.."/owner.txt") or "unknown name") .. "|" .. value
				tbl[owner] = {}
				done = #folders
				file.TFind("data/pac2_outfits/"..value.."/*", function(path, outfits, files)
					if not IsValid(ply) then return end
					done = done - 1
					for key, outfit in pairs(outfits) do
						local path = "pac2_outfits/"..value.."/"..outfit
						if file.Exists(path.."/outfit.txt") then
							tbl[owner][outfit] = {
								name = file.Read(path.."/name.txt"), 
								time = file.Time(path.."/outfit.txt"),
								size = file.Size(path.."/outfit.txt")
							}
						end
					end
					local index = ply:EntIndex()
					timer.Create("PAC:ServerOutfitsDone"..index, 0, 0, function()
						if not IsValid(ply) then timer.Destroy("PAC:ServerOutfitsDone"..index) return end
						if done <= 0 then
							timer.Destroy("PAC:ServerOutfitsDone"..index)
							if IsValid(ply) then 
								datastream.StreamToClients(ply, "PAC Server Outfits", tbl)
							end
						end
					end)
				end)
			end
		end)
		ply.LastPACSubmission = CurTime() + 8
	else
		umsg.Start("PACSubmissionAcknowledged", ply)
			umsg.Bool(false)
			umsg.String("You cannot refresh the server list that often!")
		umsg.End()
	end
end)

concommand.Add("pac_precache_effect", function(ply, command, arguments)
	local effect = tostring(arguments[1])
	if table.HasValue(PAC.EffectsBlackList, effect) then return end
	PrecacheParticleSystem(effect)
	umsg.Start("PAC Effect Precached")
		umsg.String(effect)
	umsg.End()
end)

datastream.Hook("PACSaveToServer", function(ply, handler, id, encoded, decoded)
	PAC.SaveConfig(ply, decoded.name, decoded)
end)

datastream.Hook("PACSubmission", function(ply, handler, id, encoded, decoded)
	local config = PAC.ValidateConfig(decoded)

	local allowed, issue = true, ""
	if CurTime() < (ply.LastPACSubmission or 0)+0.3 then
		allowed, issue = false, "You must wait 1 second between submissions."
	end
	
	if PAC.IsBanned(ply) then
		allowed, issue = false, "You are banned from using PAC on this server! No one but you will see you wearing this outfit."
	end
		
	local args = {hook.Call("PrePACConfigApply", nil, ply, decoded)}
		
	if args[1] == false then
		allowed, issue = false, args[2]
	elseif args[1] == nil then
		local count = 0
		for k,v in pairs(config.parts) do
			if v.sunbeams and v.sunbeams.Enabled then
				count = count + 1
			end
		end
		
		if count > 1 then 
			allowed, issue = false, "Only 1 part can have sunbeams. You have " .. count .. " parts with sunbeams."
		end
	end

	if allowed then
		ply:SetPACConfig(config)
		ply.LastPACSubmission = CurTime()
		umsg.Start("PACSubmissionAcknowledged", ply)
			umsg.Bool(allowed)
			umsg.String("")
		umsg.End()
	else
		--ply:SetPACConfig({})
		-- so people can save their outfit
		umsg.Start("PACSubmissionAcknowledged", ply)
			umsg.Bool(allowed)
			umsg.String(issue or "")
		umsg.End()
	end
end)

local function GetPlayer(target)
	for key, ply in pairs(player.GetAll()) do
		if ply:SteamID() == target or ply:UniqueID() == target or ply:Nick():lower():find(target:lower()) then
			return ply
		end
	end		
end

function PAC.Ban(ply)

	ply:SetPACConfig{}

	umsg.Start("PACSubmissionAcknowledged", ply)
		umsg.Bool(false)
		umsg.String("You have been banned from using PAC!")
	umsg.End()
	
	local fil = file.Read("pac_bans.txt")
	
	local bans = {}
	if fil and fil ~= "" then
		bans = KeyValuesToTable(fil)
	end
		
	for name, steamid in pairs(bans) do
		if ply:SteamID() == steamid then
			bans[name] = nil
		end
	end

	bans[ply:Nick():lower():gsub("%A", "")] = ply:SteamID()
	
	file.Write("pac_bans.txt", TableToKeyValues(bans))
	
end

concommand.Add("pac_ban", function(ply, cmd, arguments)
	local target = GetPlayer(arguments[1])
	if (not IsValid(ply) or ply:IsAdmin()) and target then
		PAC.Ban(target)
	end
end)

function PAC.Unban(ply)

	ply:SendLua[[LocalPlayer():SetPACConfig(LocalPlayer():GetPACConfig())]]
	
	umsg.Start("PACSubmissionAcknowledged", ply)
		umsg.Bool(false)
		umsg.String("You are now permitted to use PAC!")
	umsg.End()
		
	local fil = file.Read("pac_bans.txt")
	
	local bans = {}
	if fil and fil ~= "" then
		bans = KeyValuesToTable(fil)
	end
		
	for name, steamid in pairs(bans) do
		if ply:SteamID() == steamid then
			bans[name] = nil
		end
	end
	
	file.Write("pac_bans.txt", TableToKeyValues(bans))
	
end

concommand.Add("pac_unban", function(ply, cmd, arguments)
	local target = GetPlayer(arguments[1])
	if (not IsValid(ply) or ply:IsAdmin()) and target then
		PAC.Unban(target)
	end
end)

function PAC.IsBanned(ply)

	local fil = file.Read("pac_bans.txt")
	
	local bans = {}
	if fil and fil ~= "" then
		bans = KeyValuesToTable(fil)
	end

	return table.HasValue(bans, ply:SteamID())
	
end

function PAC.SaveConfig(ply, name, config)
	local path = "pac2_outfits/"..tostring(ply:UniqueID()).."/"..string.gsub(name, "%W", "")
	file.Write(path.."/outfit.txt", glon.encode(config))
	file.Write(path.."/name.txt", name)
	if not file.Exists("pac2_outfits/"..tostring(ply:UniqueID()).."/__owner.txt") then
		file.Write("pac2_outfits/"..tostring(ply:UniqueID()).."/__owner.txt", string.gsub(ply:Nick(), "%W", ""))
	end
end

function PAC.GetConfigFromFile(ply, name, uniqueid)
	return glon.decode(file.Read("pac2_outfits/".. (uniqueid or ply:UniqueID()) .."/"..name.."/outfit.txt"))
end

function PAC.WearConfigFromFile(ply, name, uniqueid)
	ply:SetPACConfig(PAC.GetConfigFromFile(ply, name, uniqueid))
end

function PAC.SetSpawnConfig(ply, config)
	file.Write("pac2_outfits/"..ply:UniqueID().."/__spawn.txt", glon.encode(config))
end

function PAC.DeleteSpawnConfig(ply)
	local path = "pac2_outfits/"..ply:UniqueID().."/__spawn.txt"
	if not file.Exists(path) then return end
	file.Delete(path)
end

function PAC.GetSpawnConfig(ply)
	local path = "pac2_outfits/"..ply:UniqueID().."/__spawn.txt"
	if not file.Exists(path) then return end
	return glon.decode(file.Read(path))
end

function PAC.RenameConfig(uniqueid,a,b)
	local old = glon.decode(file.Read("pac2_outfits/".. uniqueid .."/"..a.."/outfit.txt"))
	file.Delete("pac2_outfits/"..uniqueid.."/"..a.."/outfit.txt")
	
	local path = "pac2_outfits/"..uniqueid.."/"..string.gsub(b, "%W", "")
	file.Write(path.."/outfit.txt", glon.encode(old))
	file.Write(path.."/name.txt", b)
end

function PAC.DeleteConfig(uniqueid, name)
	file.Delete("pac2_outfits/"..uniqueid.."/"..name.."/outfit.txt")
	file.Delete("pac2_outfits/"..uniqueid.."/"..name.."/name.txt")
end

function PAC.SendPlayerConfig(to, ply, config)
	datastream.StreamToClients(to, "PACSetConfig", {ply = ply, config = config or ply.CurrentPACConfig})
end

function PAC.SetPlayerConfig(ply, config)	
	ply.CurrentPACConfig = config
	
	if config.playermodel and ply:GetInfoNum("pac_cl_player_model") < 1 then
		ply:SetModel(player_manager.TranslatePlayerModel(config.playermodel))
	end
	
	if config.parts then
		for id, part in pairs(config.parts) do
			if part.effect and type(part.effect.effect) == "string" and part.effect.effect ~= "" then
				PrecacheParticleSystem(part.effect.effect)
			end
		end
	end
	
	PAC.SendPlayerConfig(player.GetAll(), ply)
	
	if PAC.IsEmptyConfig(config) then
		PAC.DeleteSpawnConfig(ply)
	else
		PAC.SetSpawnConfig(ply, config)
	end
end

function PAC.Sync(to)
	for id, ply in pairs(player.GetAll()) do
		if ply.CurrentPACConfig then
			PAC.SendPlayerConfig(to, ply)
		end
	end
end
	
function _R.Player:SetPACConfig(config, dont_validate)
	PAC.SetPlayerConfig(self, dont_validate and (IsEntity(config) and config:GetPACConfig() or config) or PAC.ValidateConfig(config))
end