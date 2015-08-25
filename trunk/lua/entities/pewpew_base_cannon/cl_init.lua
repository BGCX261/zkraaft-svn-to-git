include('shared.lua')

function ENT:Initialize()
	self.Bullet = pewpew:GetBullet(self.Entity:GetNWString("BulletName"))
	if (self.Bullet) then
		if (self.Bullet.CLCannonInitializeOverride) then
			self.Bullet.CLCannonInitializeFunc(self)
		end
	end
end

function ENT:Draw()
	if (self.Bullet and self.Bullet.CLCannonDrawOverride) then
		self.Bullet.CLCannonDrawFunc(self)
	else
		self.Entity:DrawModel()
		Wire_Render(self.Entity)
	end
end
 
function ENT:Think()
	if (self.Bullet) then
		if (self.Bullet.CLCannonThinkOverride) then
			return self.Bullet.CLCannonThinkFunc(self)
		end
		
		if (self.Bullet.Reloadtime and self.Bullet.Reloadtime < 0.5) then
			-- Run more often!
			self.Entity:NextThink(CurTime())
			return true
		end
	end
end