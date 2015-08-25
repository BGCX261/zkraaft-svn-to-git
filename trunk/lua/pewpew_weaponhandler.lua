-- PewPew Weapon Handler
-- Takes care of adding and managing all the available bullets

-- Load all the bullet files
function pewpew:LoadBullets()
	self.bullets = {}
	self.Categories = {}
	
	self:LoadDirectory( "PewPewBullets" )
end

-- Reloads all weapons on the map (useful if you've just updated several weapons and done pewpew:LoadBullets())
function pewpew:ReloadWeapons()
	local weps = ents.FindByClass("pewpew_base_cannon")
	for k,v in ipairs( weps ) do
		if (v:IsValid()) then
			local name = v.Bullet.Name
			v.Bullet = table.Copy( pewpew:GetBullet( name ) )
			print( "[PewPew] Reloaded weapon: " .. tostring(v) .. " with bullet: " .. name )
		end
	end
end

local CurrentCategory = ""

function pewpew:LoadDirectory( Dir ) -- Thanks to Jcw87 for fixing this function
	-- Get the category
	if (string.find(Dir, "/")) then
		CurrentCategory = string.Right( Dir, string.find( string.reverse( Dir ), "/", 1, true ) - 1 )
		CurrentCategory = string.gsub( CurrentCategory, "_", " " )
	else
		CurrentCategory = "Other"
	end
	
	local entries = file.FindInLua( Dir .. "/*")
	for _, entry in ipairs ( entries ) do
		-- If entry is a file
		if (string.find(entry, "%.")) then
			-- If entry is a lua file
			if (string.sub(entry, -4) == ".lua") then
				if (SERVER) then 
					AddCSLuaFile( Dir .. "/" .. entry )
				end
				include( Dir .. "/" .. entry )
			end
		-- If entry is a directory
		else 
			self:LoadDirectory( Dir .. "/" .. entry )
		end
	end
end


-- Add the bullets to the bullet list
function pewpew:AddBullet( bullet )
	if (SERVER) then print("[PewPew] Added Bullet: " .. bullet.Name) end
	table.insert( self.bullets, bullet )
	if (!self.Categories[CurrentCategory]) then
		self.Categories[CurrentCategory] = {}
	end
	bullet.Category = CurrentCategory
	table.insert( self.Categories[CurrentCategory], bullet.Name )
end

-- Allows you to find a bullet
function pewpew:GetBullet( BulletName )
	for _, blt in pairs( self.bullets ) do
		if (string.lower(blt.Name) == string.lower(BulletName)) then
			return blt
		end
	end
	return nil
end

------------------------------------------------------------------------------------------------------------

-- Development number (this function doesn't quite work correctly yet)
function pewpew:DevNum( BulletName )
	local bullet = self:GetBullet( BulletName )
	if (bullet) then
		-- Basics
		local dmg = bullet.Damage or 0
		local rld = bullet.Reloadtime or 1
		if (rld == 0) then rld = 1 end
		local ammo = bullet.Ammo or 0
		local rldammo = bullet.AmmoReloadtime or 1
		if (rldammo == 0) then rldammo = 1 end
		local ret = (dmg * (1/rld)) - (ammo * (1/rldammo)) * 15
		
		-- Special
		local special = 0
		special = special - (bullet.Spread or 0) * 10
		special = special - (bullet.Gravity or 0) * 20
		special = special + (bullet.Speed or 0)
		if (bullet.Lifetime) then
			special = special - (((bullet.Lifetime[1] or 0)+(bullet.Lifetime[2] or 0))/2) * 10
			if (bullet.ExplodeAfterDeath) then special = special + 25 end
		end
		
		
		-- Damage Types
		if (bullet.DamageType == "BlastDamage") then
			special = special + dmg * (bullet.RangeDamageMul or 0) / 5
			special = special + (bullet.Radius or 0) / 6
		elseif (bullet.DamageType == "SliceDamage") then
			special = special + (bullet.NumberOfSlices or 1) * 35
		elseif (bullet.DamageType == "EMPDamage") then
			special = special + (bullet.Duration or 0) * 25
			special = special + (bullet.Radius or 0) / 8
		end
			
		ret = ret + special
		return ret
	end
	return 0
end

------------------------------------------------------------------------------------------------------------

