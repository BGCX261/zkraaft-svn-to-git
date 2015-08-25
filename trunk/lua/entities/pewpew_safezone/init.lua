AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()   
	self.Entity:PhysicsInit( SOLID_VPHYSICS )  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	self.Inputs = WireLib.CreateInputs( self.Entity, { "On", "Radius" } )
	self.Outputs = WireLib.CreateOutputs( self.Entity, { "IsOn", "CurrentRadius" } )
	
	pewpew:AddSafeZone( Vector(0,0,0), 1000, self.Entity )
	self.On = true
	WireLib.TriggerOutput( self.Entity, "IsOn", 1 )
	self.Radius = 1000
	WireLib.TriggerOutput( self.Entity, "CurrentRadius", 1000 )
	self.ChangeDelay = 0
end

function ENT:TriggerInput( name, value )

	-- Do not allow changes too often
	if (self.ChangeDelay > CurTime()) then return end
	
	if (name == "On") then
		if (value != 0) then -- If value is not 0
			if (!self.On) then -- If currently off
				-- Turn on
				pewpew:AddSafeZone( Vector(0,0,0), self.Radius, self.Entity )
				self.On = true
				WireLib.TriggerOutput( self.Entity, "IsOn", 1 )
				self.ChangeDelay = CurTime() + 2
			end
		else -- If value is 0
			if (self.On) then -- If currently on
				-- Turn off
				pewpew:RemoveSafeZone( self.Entity )
				self.On = false
				WireLib.TriggerOutput( self.Entity, "IsOn", 0 )
				self.ChangeDelay = CurTime() + 2
			end
		end
	elseif (name == "Radius") then
		value = math.Clamp(value,50,2000)
		if (self.Radius != value) then -- If radius is not already equal to value
			self.Radius = value
			pewpew:ModifySafeZone( self.Entity, Vector(0,0,0), self.Radius, self.Entity )
			WireLib.TriggerOutput( self.Entity, "CurrentRadius", self.Radius )
			self.ChangeDelay = CurTime() + 2
		end
	end
		
end

function ENT:OnRemove() pewpew:RemoveSafeZone( self.Entity ) end