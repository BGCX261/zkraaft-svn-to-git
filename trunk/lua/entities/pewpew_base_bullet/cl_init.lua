include('shared.lua')

function ENT:Initialize()
	self.Bullet = pewpew:GetBullet(self.Entity:GetNWString("BulletName"))
	if (self.Bullet) then
		if (self.Bullet.CLInitializeOverride) then
			self.Bullet.CLInitializeFunc(self)
		end
	end
end

function ENT:Draw()
	if (self.Bullet and self.Bullet.CLDrawOverride) then
		self.Bullet.CLDrawFunc(self)
	else
		self.Entity:DrawModel()
	end
end
 
function ENT:Think()
	if (self.Bullet) then
		if (self.Bullet.CLThinkOverride) then
			return self.Bullet.CLThinkFunc(self)
		end
		
		if (self.Bullet.Reloadtime < 0.5) then
			-- Run more often!
			self.Entity:NextThink(CurTime())
			return true
		end
	end
end