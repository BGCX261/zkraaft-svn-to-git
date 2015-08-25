AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   
	self.Entity:PhysicsInit( SOLID_VPHYSICS )  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )      

	self.Outputs = Wire_CreateOutputs( self.Entity, { "Health", "Total Health" })
	
	self.pewpew = {}
	self.Props = {}
	self.PropHealth = {}
	self.pewpew.CoreHealth = 1
	self.pewpew.CoreMaxHealth = 1
	self.Entity.Core = self
	
	WireLib.TriggerOutput( self.Entity, "Health", self.pewpew.CoreHealth or 0 )
	WireLib.TriggerOutput( self.Entity, "Total Health", self.pewpew.CoreMaxHealth or 0 )
	
	self.Entity:NextThink( CurTime() + 1 )
	return true
end

function ENT:SetOptions( ply )
	self.Owner = ply
end

function ENT:ClearProp( Entity )
	for key, ent in pairs( self.Props ) do
		if (Entity == ent) then
			table.remove( self.Props, key )
			self.Prophealth[ent:EntIndex()] = nil
		end
	end
end

function ENT:Think()
	-- Get all constrained props
	self.Props = constraint.GetAllConstrainedEntities( self.Entity )
	
	-- Loop through all props
	local hp = self.pewpew.CoreHealth
	local maxhp = 1
	for _, ent in pairs( self.Props ) do
		if (!ent.pewpew) then ent.pewpew = {} end
		if (ent and pewpew:CheckValid( ent ) and pewpew:CheckAllowed( ent )) then
			if (!ent.pewpewHealth or !ent.pewpewMaxMass) then pewpew:SetHealth( ent ) end
			local entcore = ent.pewpew.Core
			local health = self.PropHealth[ent:EntIndex()] or 0
			local enthealth = pewpew:GetHealth( ent )
			if (!entcore or !entcore:IsValid()) then -- if the entity has no core
				ent.pewpew.Core = self.Entity
				self.PropHealth[ent:EntIndex()] = enthealth
				hp = hp + enthealth
			elseif (entcore and entcore == self.Entity and enthealth != health) then -- if the entity's health has changed
				hp = hp - health -- subtract the old health
				hp = hp + enthealth -- add the new health
				self.PropHealth[ent:EntIndex()] = enthealth
			elseif (entcore and entcore != self.Entity) then -- if the entity already has a core
				self.Owner:ChatPrint("You cannot have several cores in the same contraption. Core self-destructing.")
					local effectdata = EffectData()
					effectdata:SetOrigin( self.Entity:GetPos() )
					effectdata:SetScale( (self.Entity:OBBMaxs() - self.Entity:OBBMins()):Length() )
					util.Effect( "pewpew_deatheffect", effectdata )
				self:Remove()
				return
			end
			maxhp = maxhp + enthealth
		end
	end
	-- Set health
	self.pewpew.CoreHealth = hp
	self.pewpew.CoreMaxHealth = maxhp
	
	if (self.pewpew.CoreHealth > self.pewpew.CoreMaxHealth) then self.pewpew.CoreHealth = self.pewpew.CoreMaxHealth end
	
	
	-- Set NW ints
	hp = self.Entity:GetNWInt("pewpewMaxHealth")
	if (!hp or hp != self.pewpew.CoreMaxHealth) then
		self.Entity:SetNWInt("pewpewMaxHealth", self.pewpew.CoreMaxHealth)
	end
	hp = self.Entity:GetNWInt("pewpewHealth")
	if (!hp or hp != self.pewpew.CoreHealth) then
		self.Entity:SetNWInt("pewpewHealth", self.pewpew.CoreHealth)
	end
	
	-- Wire Output
	WireLib.TriggerOutput( self.Entity, "Health", self.pewpew.CoreHealth or 0 )
	WireLib.TriggerOutput( self.Entity, "Total Health", self.pewpew.CoreMaxHealth or 0 )
	
	-- Run again in 5 seconds
	self.Entity:NextThink( CurTime() + 5 )
	return true
end

function ENT:RemoveAllProps()
	for _, ent in pairs( self.Props ) do
		local effectdata = EffectData()
		effectdata:SetOrigin( ent:GetPos() )
		effectdata:SetScale( (ent:OBBMaxs() - ent:OBBMins()):Length() )
		util.Effect( "pewpew_deatheffect", effectdata )
		ent:Remove()
	end
	self:Remove()
end

function ENT:BuildDupeInfo()
	local info = self.BaseClass.BuildDupeInfo(self) or {}
	return info
end

function ENT:ApplyDupeInfo( ply, ent, info, GetEntByID )
	self.BaseClass.ApplyDupeInfo( self, ply, ent, info, GetEntByID )
end