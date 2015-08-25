ENT.Category		= "Parakeet's Pills"

ENT.Spawnable       = true
ENT.AdminSpawnable  = true

ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "Gunship"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

ENT.NextShot = 0
ENT.IsShooting = false

local Sounds = {}
Sounds.Photo = Sound("npc/scanner/scanner_photo1.wav")
Sounds.Die = Sound("ambient/explosions/explode_3.wav")
Sounds.ChargeUp = Sound("npc/attack_helicopter/aheli_charge_up.wav")
Sounds.DropBomb = Sound("npc/attack_helicopter/aheli_mine_drop1.wav")
/*Sounds.SpikesIn = Sound("npc/roller/mine/rmine_blades_in1.wav")
Sounds.Jump = Sound("npc/roller/mine/rmine_blip1.wav")
Sounds.Burrow = Sound("npc/roller/mine/rmine_reprogram.wav")
Sounds.Shock = Sound("npc/roller/mine/rmine_explode_shock1.wav")
*/

if (SERVER) then
    function ENT:Initialize()
        //Physics
        self.Entity:SetModel("models/Combine_Helicopter.mdl")
        self.Entity:PhysicsInit(SOLID_VPHYSICS)
        self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        self.Entity:SetModel("models/gunship.mdl")
        
        local phys = self.Entity:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
    
        //Make the player spectate us.
        self:GetNWEntity("PillUser"):Spectate(OBS_MODE_CHASE)
        self:GetNWEntity("PillUser"):SpectateEntity(self.Entity)
        self:GetNWEntity("PillUser"):SetMoveType(MOVETYPE_OBSERVER)
        self:GetNWEntity("PillUser"):StripWeapons()
        
        self:SetPlaybackRate(1)
    
        //Add looping Sounds
        self.Sound_Hover = CreateSound(self.Entity,"npc/combine_gunship/engine_whine_loop1.wav")
        self.Sound_Fire = CreateSound(self.Entity,"npc/combine_gunship/gunship_weapon_fire_loop6.wav")
        
        self.Sound_Hover:Play()
        
        self:ResetSequence(self:LookupSequence("prop_turn"))
        
        //Health
        self:SetNWInt("Health",1000)
    end
    
    function ENT:Think()
        //Remove in water.
        if (self:WaterLevel() > 1) then self:Remove() end
        
        //Aiming
        local Yaw,Pitch

        Yaw = math.Clamp(self:WorldToLocalAngles(self:GetNWEntity("PillUser"):EyeAngles()).y,-75,75)
        Pitch = math.Clamp(self:WorldToLocalAngles(self:GetNWEntity("PillUser"):EyeAngles()).p,-75,75)
    
        self:SetPoseParameter("flex_horz",Yaw)
        self:SetPoseParameter("flex_vert",Pitch)
        
        local Power = 9 //37.5
        
        //Shooting
        if (self:GetNWEntity("PillUser"):KeyDown(IN_ATTACK) && CurTime() >= self.NextShot) then
            //Sound
            if (!self.IsShooting) then
                self.Sound_Fire:Play()
                self.IsShooting = true
            end
                
            //Bullet
            local bullet = {}
            bullet.Src          = self:GetAttachment(self:LookupAttachment("Muzzle")).Pos
            bullet.Attacker   = self:GetNWEntity("PillUser")
            bullet.Dir          = self:GetAttachment(self:LookupAttachment("Muzzle")).Ang:Forward()
            bullet.Spread      = Vector(0.02,0.02,0)
            bullet.Num          = 1
            bullet.Damage      = 4
            bullet.Force      = 2
            bullet.Tracer      = 1
            bullet.TracerName = "HelicopterTracer"
        
            self:FireBullets(bullet)
            
            self.NextShot = CurTime() + 0.1
        elseif (!self:GetNWEntity("PillUser"):KeyDown(IN_ATTACK) && self.IsShooting) then
            self.Sound_Fire:Stop()
            self.IsShooting = false
        end
        
        //UpDown
        if (self:GetNWEntity("PillUser"):KeyDown(IN_SPEED)) then Power = Power + 6
        elseif (self:GetNWEntity("PillUser"):KeyDown(IN_DUCK)) then Power = Power - 6
        end
        
        self:GetPhysicsObject():AddVelocity(self:GetAngles():Up() * Power)
        
        //Them Angles
        local Aim = self:GetNWEntity("PillUser"):EyeAngles()
        
        if (self:GetNWEntity("PillUser"):KeyDown(IN_FORWARD)) then Aim.p = 20
        elseif (self:GetNWEntity("PillUser"):KeyDown(IN_BACK)) then Aim.p = -20
        else Aim.p = 0
        end
        
        if (self:GetNWEntity("PillUser"):KeyDown(IN_MOVERIGHT)) then Aim.r = 20
        elseif (self:GetNWEntity("PillUser"):KeyDown(IN_MOVELEFT)) then Aim.r = -20
        else Aim.r = 0
        end
        
        local LocalAim = self:WorldToLocalAngles(Aim)
        MoveAng = Vector(0,0,0)
        
        MoveAng.y = LocalAim.p*3
        MoveAng.z = LocalAim.y*3
        MoveAng.x = LocalAim.r*3
        
        self:GetPhysicsObject():AddAngleVelocity(-1 * self:GetPhysicsObject():GetAngleVelocity() + MoveAng)
        
        //Fins
        local LocalVel = WorldToLocal(self:GetVelocity(),Angle(),Vector(0,0,0),self:GetAngles())
        self:SetPoseParameter("fin_accel",LocalVel.x/200)
        self:SetPoseParameter("fin_sway",-LocalVel.y/200)
        
        self:SetPoseParameter("antenna_accel",LocalVel.x/200)
        self:SetPoseParameter("antenna_sway",-LocalVel.y/200)
        
        self:NextThink(CurTime())
        return true
    end
    
    function ENT:OnRemove( )
        //Stop looping sounds
        self.Sound_Hover:Stop()
        self.Sound_Fire:Stop()
        
        self:EmitSound(Sounds.Die,100,100)
    
        //Kill user.
        self:GetNWEntity("PillUser"):SetNWEntity("PillEnt",nil)
        if (self:GetNWEntity("PillUser"):IsValid() && self:GetNWEntity("PillUser"):Alive()) then
            self:GetNWEntity("PillUser"):KillSilent()
        end
    end
    
    function ENT:KeyIn(key)
        if (key == IN_ATTACK && self.ShotsLeft == 0) then
            self:EmitSound(Sounds.ChargeUp,100,100)
            
            self.NextShot = CurTime() + 2
            self.ShotsLeft = 40
        elseif (key == IN_RELOAD) then
            self:Remove()
        end
    end
    
    //Damage
    function ENT:OnTakeDamage(dmg)
        self:SetNWInt("Health",self:GetNWInt("Health")-dmg:GetDamage())
        if (self:GetNWInt("Health") <= 0) then
            self:Remove()
        end
    end
    
    function ENT:SpawnFunction( ply, tr )
        if (ply:GetNWEntity("PillEnt"):IsValid()) then
            ply:ChatPrint("You are already using a pill!")
            return
        end
        if (!ply:Alive()) then
            ply:ChatPrint("You must be alive to use a pill!")
            return
        end
        
        local ent = ents.Create(ClassName)
        ent:SetPos(ply:GetPos()+Vector(0,0,100))
        ent:SetNWEntity("PillUser",ply)
        ply:SetNWEntity("PillEnt",ent)
        ent:Spawn()
    
        return ent
    end
else
    ENT.ViewOffset = Vector(0,0,100)
    ENT.ViewDistance = 500
    ENT.CrosshairStart = "Muzzle"
    
    ENT.ShowHealth = true
end