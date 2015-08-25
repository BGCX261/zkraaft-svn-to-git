ENT.Category		= "Parakeet's Pills"

ENT.Spawnable       = true
ENT.AdminSpawnable  = true

ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "Portal Turret"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true


ENT.Deployed = false
ENT.Busy = false

ENT.NextShot = 0
ENT.NextPing = 0
ENT.NextCanTalk = 0

local Sounds = {}
Sounds.Shoot = Sound("npc/turret_floor/shoot1.wav")
Sounds.Deploy = Sound("npc/turret_floor/deploy.wav")
Sounds.Retract = Sound("npc/turret_floor/retract.wav")
Sounds.Die = Sound("npc/turret_floor/die.wav")
Sounds.Ping = Sound("npc/turret_floor/ping.wav")
Sounds.VoiceDeploy = {
    Sound("npc/turret_floor/turret_deploy_1.wav"),
    Sound("npc/turret_floor/turret_deploy_2.wav"),
    Sound("npc/turret_floor/turret_deploy_3.wav"),
    Sound("npc/turret_floor/turret_deploy_4.wav"),
    Sound("npc/turret_floor/turret_deploy_5.wav"),
    Sound("npc/turret_floor/turret_deploy_6.wav")
}
Sounds.VoiceRetract = {
    Sound("npc/turret_floor/turret_retire_1.wav"),
    Sound("npc/turret_floor/turret_retire_2.wav"),
    Sound("npc/turret_floor/turret_retire_3.wav"),
    Sound("npc/turret_floor/turret_retire_4.wav"),
    Sound("npc/turret_floor/turret_retire_5.wav"),
    Sound("npc/turret_floor/turret_retire_6.wav"),
    Sound("npc/turret_floor/turret_retire_7.wav")
}
Sounds.VoiceShoot = {
    Sound("npc/turret_floor/turret_active_1.wav"),
    Sound("npc/turret_floor/turret_active_2.wav"),
    Sound("npc/turret_floor/turret_active_3.wav"),
    Sound("npc/turret_floor/turret_active_4.wav"),
    Sound("npc/turret_floor/turret_active_5.wav"),
    Sound("npc/turret_floor/turret_active_6.wav"),
    Sound("npc/turret_floor/turret_active_7.wav"),
    Sound("npc/turret_floor/turret_active_8.wav")
}
Sounds.VoiceCollide = {
    Sound("npc/turret_floor/turret_collide_1.wav"),
    Sound("npc/turret_floor/turret_collide_2.wav"),
    Sound("npc/turret_floor/turret_collide_3.wav"),
    Sound("npc/turret_floor/turret_collide_4.wav"),
    Sound("npc/turret_floor/turret_collide_5.wav")
}
Sounds.VoiceShotAt = {
    Sound("npc/turret_floor/turret_shotat_1.wav"),
    Sound("npc/turret_floor/turret_shotat_2.wav"),
    Sound("npc/turret_floor/turret_shotat_3.wav")
}
Sounds.VoiceDie = {
    Sound("npc/turret_floor/turret_disabled_1.wav"),
    Sound("npc/turret_floor/turret_disabled_2.wav"),
    Sound("npc/turret_floor/turret_disabled_3.wav"),
    Sound("npc/turret_floor/turret_disabled_4.wav"),
    Sound("npc/turret_floor/turret_disabled_5.wav"),
    Sound("npc/turret_floor/turret_disabled_6.wav"),
    Sound("npc/turret_floor/turret_disabled_7.wav"),
    Sound("npc/turret_floor/turret_disabled_8.wav")
}

if (SERVER) then
    function ENT:Initialize()
        //Physics
        self.Entity:SetModel("models/props/turret_01.mdl")
        self.Entity:PhysicsInit(SOLID_VPHYSICS )
        self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        
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
    end
    
    function ENT:Think()
        //Aiming
        local Yaw,Pitch
        if (self.Deployed && !self.Busy) then
            Yaw = math.Clamp(self:WorldToLocalAngles(self:GetNWEntity("PillUser"):EyeAngles()).y,-60,60)
            Pitch = math.Clamp(self:WorldToLocalAngles(self:GetNWEntity("PillUser"):EyeAngles()).p,-15,15)
        else
            Yaw = 0
            Pitch = 0
        end
    
        self:SetPoseParameter("aim_yaw",Yaw)
        self:SetPoseParameter("aim_pitch",Pitch/2)
        //Shooting
        if (self:GetNWEntity("PillUser"):KeyDown(IN_ATTACK) && CurTime() >= self.NextShot && self.Deployed && !self.Busy) then
            //Bullet
            local bullet = {}
            bullet.Src          = self:GetAttachment(self:LookupAttachment("RT_Gun2_Muzzle")).Pos
            bullet.Attacker   = self:GetNWEntity("PillUser")
            bullet.Dir          = self:GetAttachment(self:LookupAttachment("eyes")).Ang:Forward()
            bullet.Spread      = Vector(0.05,0.05,0)
            bullet.Num          = 1
            bullet.Damage      = 4
            bullet.Force      = 2
            bullet.Tracer      = 1
            bullet.TracerName = "AR2Tracer"
        
            self:FireBullets(bullet)
            
            bullet.Src          = self:GetAttachment(self:LookupAttachment("LFT_Gun2_Muzzle")).Pos
            self:FireBullets(bullet)
        
            //Animation
            self:ResetSequence(self:LookupSequence("fire"))
            
            //Sound
            self:EmitSound(Sounds.Shoot,100,100)
            
            if (CurTime() >= self.NextShot + 0.15 && CurTime() >= self.NextCanTalk) then
                self:EmitSound(Sounds.VoiceShoot[math.random(1,8)],100,100)
                self.NextCanTalk = CurTime() + 2
            end
        
            self.NextShot = CurTime() + 0.1
            
            //Delay pings
            self.NextPing = CurTime() + 0.1
        end
        
        //Pingage
        if (CurTime() >= self.NextPing && self.Deployed && !self.AlarmOn && !self.Busy) then
            self:EmitSound(Sounds.Ping,100,100)
            self.NextPing = CurTime() + 1
        end
            
        self:NextThink(CurTime())
        return true
    end
    
    function ENT:KeyIn(key)
    //Deploy
        if (key == IN_ATTACK2) then
            if (!self.Busy) then
                if (!self.Deployed) then
                    self.Deployed = true
                    self.Busy = true
                    self:SetSequence(self:LookupSequence("deploy"))
                    self:EmitSound(Sounds.Deploy,100,100)
                    if (CurTime() >= self.NextCanTalk) then
                        self:EmitSound(Sounds.VoiceDeploy[math.random(1,6)],100,100)
                        self.NextCanTalk = CurTime() + 2
                    end
                    timer.Simple(1/3,self.FinishAction,self)
                else
                    self.Deployed = false
                    self.Busy = true
                    self:SetSequence(self:LookupSequence("retract"))
                    self:EmitSound(Sounds.Retract,100,100)
                    if (CurTime() >= self.NextCanTalk) then
                        self:EmitSound(Sounds.VoiceRetract[math.random(1,7)],100,100)
                        self.NextCanTalk = CurTime() + 2
                    end
                    timer.Simple(1/3,self.FinishAction,self)
                end
            end
        elseif (key == IN_RELOAD) then
            self:Remove()
        end
    end
    
    function ENT:OnRemove()
        self:EmitSound(Sounds.Die,100,100)
        if (CurTime() >= self.NextCanTalk) then
            self:EmitSound(Sounds.VoiceDie[math.random(1,8)],100,100)
            self.NextCanTalk = CurTime() + 2
        end
        
        self:GetNWEntity("PillUser"):SetNWEntity("PillEnt",nil)
        if (self:GetNWEntity("PillUser"):IsValid() && self:GetNWEntity("PillUser"):Alive()) then
            self:GetNWEntity("PillUser"):KillSilent()
        end
    end
    //Say something when we collide with something
    function ENT:StartTouch( ent )
        if (CurTime() >= self.NextCanTalk) then
            self:EmitSound(Sounds.VoiceCollide[math.random(1,5)],100,100)
            self.NextCanTalk = CurTime() + 2
        end
    end
    //Say something when shot
    function ENT:OnTakeDamage(dmg)
        self:TakePhysicsDamage(dmg)
        if (dmg:GetDamageType() == DMG_BULLET && CurTime() >= self.NextCanTalk) then
            self:EmitSound(Sounds.VoiceShotAt[math.random(1,3)],100,100)
            self.NextCanTalk = CurTime() + 2
        end
    end
    
    //Sets busy to false, used when animations are done.
    function ENT:FinishAction()
        self.Busy = false
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
        ent:SetPos(ply:GetPos()+Vector(0,0,5))
        ent:SetAngles(ply:GetAngles())
        ent:SetNWEntity("PillUser",ply)
        ply:SetNWEntity("PillEnt",ent)
        ent:Spawn()
    
        return ent
    end
else
    ENT.ViewOffset = Vector(0,0,65)
    ENT.ViewDistance = 100
    ENT.CrosshairStart = "eyes"
end