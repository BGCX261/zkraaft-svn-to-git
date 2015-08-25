-- Pewpew Safe Zones
-- These functions add safe zones
------------------------------------------------------------------------------------------------------------

-- Damage Blocked Table
pewpew.SafeZones = {}

-- Add a Safe Zone. If you want to parent the safe zone to an entity, make sure the position is local.
function pewpew:AddSafeZone( Position, Radius, ParentEntity )
	if (!Position or !Radius) then 
		return 
	end
	table.insert( self.SafeZones, { Position, Radius, ParentEntity } )
end

-- Remove a Safe Zone. In can be a vector, number, or entity (if entity, it must be the entity the safe zone is "parented" to)
function pewpew:RemoveSafeZone( In )
	-- If the type is a vector
	if (type(In) == "vector") then
		-- Find the safe zone
		local bool, index = self:FindSafeZone( In )
		-- Found it?
		if (bool) then
			-- Remove it
			table.remove( self.SafeZones, index )
		else
			-- Notify
		end
	-- If the type is a number
	elseif (type(In) == "number") then
		-- Remove the safe zone
		if (self.SafeZones[In]) then
			table.remove( self.SafeZones, In )
		end
	elseif (type(In) == "Entity") then
		for index,tbl in pairs( self.SafeZones ) do
			if (tbl[3]) then
				if (tbl[3]:IsValid()) then
					if (tbl[3] == In) then
						table.remove( self.SafeZones, index )
					end
				else
					self:RemoveSafeZone( index )
					return
				end
			end
		end
	end
end

-- Modify an already existing Safe Zone
function pewpew:ModifySafeZone( In, Position, Radius, ParentEntity )
	if (!Position or !Radius) then return end
	if (type(In) == "vector") then
		local bool, index = self:FindSafeZone( In )
		if (bool) then
			self.SafeZones[index] = { Position, Radius, ParentEntity }
		end
	elseif (type(In) == "number") then
		self.SafeZones[In] = { Position, Radius, ParentEntity }
	elseif (type(In) == "Entity") then
		for index,tbl in pairs( self.SafeZones ) do
			if (tbl[3]) then
				if (tbl[3]:IsValid()) then
					if (tbl[3] == In) then
						self.SafeZones[index] = { Position, Radius, ParentEntity }
						return
					end
				else
					self:RemoveSafeZone( index )
					return
				end
			end
		end
	end
end

-- Check if a position is inside a Safe Zone
function pewpew:FindSafeZone( Position )
	for index,tbl in pairs( self.SafeZones ) do
		CheckPosition = tbl[1]
		-- Parented?
		if (tbl[3]) then
			-- Valid entity?
			if (tbl[3]:IsValid()) then
				CheckPosition = tbl[3]:LocalToWorld(CheckPosition)
			else
				self:RemoveSafeZone( index )
				return false, index
			end
		end
		-- Check distance
		if (Position:Distance(CheckPosition) <= tbl[2]) then
			return true, index
		end
	end
	return false, 0
end