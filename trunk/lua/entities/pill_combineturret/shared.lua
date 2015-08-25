ENT.Category		= "Parakeet's Pills"

ENT.Spawnable       = true
ENT.AdminSpawnable  = true

ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "Combine Turret"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true


ENT.Deployed = false
ENT.Busy = false

ENT.NextShot = 0
ENT.NextPing = 0

local Sounds = {}
Sounds.Shoot = Sound("npc/turret_floor/shoot1.wav")
Sounds.Deploy = Sound("npc/turret_floor/deploy.wav")
Sounds.Retract = Sound("npc/turret_floor/retract.wav")
Sounds.Die = Sound("npc/turret_floor/die.wav")
Sounds.Ping = Sound("npc/turret_floor/ping.wav")

if (SERVER) then
    function ENT:Initialize()
        //Physics
        self.Entity:SetModel("models/Combine_turrets/Floor_turret.mdl")
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
        
        self.Sound_Alarm = CreateSound(self.Entity,"npc/turret_floor/alarm.wav")
        
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
        self:SetPoseParameter("aim_pitch",Pitch)
        //Shooting
        if (self:GetNWEntity("PillUser"):KeyDown(IN_ATTACK) && CurTime() >= self.NextShot && self.Deployed && !self.Busy) then
            //Bullet
            local bullet = {}
            bullet.Src          = self:GetAttachment(self:LookupAttachment("eyes")).Pos
            bullet.Attacker   = self:GetNWEntity("PillUser")
            bullet.Dir          = self:GetAttachment(self:LookupAttachment("eyes")).Ang:Forward()
            bullet.Spread      = Vector(0.05,0.05,0)
            bullet.Num          = 1
            bullet.Damage      = 4
            bullet.Force      = 2
            bullet.Tracer      = 1
            bullet.TracerName = "AR2Tracer"
        
            self:FireBullets(bullet)
        
            //Animation
            self:ResetSequence(self:LookupSequence("fire"))
            
            //Sound
            self:EmitSound(Sounds.Shoot,100,100)
        
            self.NextShot = CurTime() + 0.1
            
            //This should stop pings from going off.
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
                    
                    self.Sound_Alarm:Play()
                    timer.Simple(1,self.Sound_Alarm.FadeOut,self.Sound_Alarm,0.1)
                    
                    timer.Simple(1/3,self.FinishAction,self)
                else
                    self.Deployed = false
                    self.Busy = true
                    self:SetSequence(self:LookupSequence("retract"))
                    self:EmitSound(Sounds.Retract,100,100)
                    timer.Simple(1/3,self.FinishAction,self)
                end
            end
        elseif (key == IN_RELOAD) then
            self:Remove()
        end
    end
    
    function ENT:OnRemove()
        self.Sound_Alarm:Stop()
        
        self:EmitSound(Sounds.Die,100,100)
        
        self:GetNWEntity("PillUser"):SetNWEntity("PillEnt",nil)
        if (self:GetNWEntity("PillUser"):IsValid() && self:GetNWEntity("PillUser"):Alive()) then
            self:GetNWEntity("PillUser"):KillSilent()
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