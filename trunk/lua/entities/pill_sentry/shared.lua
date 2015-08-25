ENT.Category		= "Parakeet's Pills"

ENT.Spawnable       = true
ENT.AdminSpawnable  = true

ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "Sentry Gun"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true


ENT.Level = 0
ENT.Busy = false

ENT.NextShot = 0
ENT.NextPing = 0
ENT.NextCanTalk = 0

ENT.NextRocket = 0

ENT.ActiveBarrel = true

ENT.Rockets = {}

local Sounds = {}
Sounds.Shoot1 = Sound("weapons/sentry_shoot.wav")
Sounds.Shoot2 = Sound("weapons/sentry_shoot2.wav")
Sounds.Shoot3 = Sound("weapons/sentry_shoot3.wav")
Sounds.ShootMini = Sound("weapons/sentry_shoot_mini.wav")
Sounds.Die = Sound("weapons/sentry_explode.wav")
Sounds.Ping1 = Sound("weapons/sentry_scan.wav")
Sounds.Ping2 = Sound("weapons/sentry_scan2.wav")
Sounds.Ping3 = Sound("weapons/sentry_scan3.wav")
Sounds.RocketBoom = Sound("weapons/explode1.wav")
Sounds.RocketFire = Sound("weapons/sentry_rocket.wav")

util.PrecacheModel("models/buildables/sentry1_heavy.mdl")
util.PrecacheModel("models/buildables/sentry1.mdl")

util.PrecacheModel("models/buildables/sentry2_heavy.mdl")
util.PrecacheModel("models/buildables/sentry2.mdl")

util.PrecacheModel("models/buildables/sentry3_heavy.mdl")
util.PrecacheModel("models/buildables/sentry3.mdl")


if (SERVER) then
    function ENT:Initialize()
        //Physics
        self.Entity:SetModel("models/weapons/w_models/w_toolbox.mdl")
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
        
        self:SetNWFloat("size",1)
        
         //Health
        self:SetNWInt("Health",50)
    end
    
    function ENT:Think()
        //Aiming
        local Yaw,Pitch
        if (!self.Busy && self.Level != 0) then
            Yaw = self:WorldToLocalAngles(self:GetNWEntity("PillUser"):EyeAngles()).y
            Pitch = math.Clamp(self:WorldToLocalAngles(self:GetNWEntity("PillUser"):EyeAngles()).p,-50,50)
        else
            Yaw = 0
            Pitch = 0
        end
    
        self:SetPoseParameter("aim_yaw",-Yaw)
        self:SetPoseParameter("aim_pitch",-Pitch)
        
        //Shooting
        if (self:GetNWEntity("PillUser"):KeyDown(IN_ATTACK) && CurTime() >= self.NextShot && !self.Busy && self.Level != 0) then
            //Bullet
            local bullet = {}
            bullet.Attacker   = self:GetNWEntity("PillUser")
            bullet.Dir          = self:GetAttachment(self:LookupAttachment("build_point_0")).Ang:Forward()
            bullet.Spread      = Vector(0.01,0.01,0)
            bullet.Num          = 1
            bullet.Force      = 2
            bullet.Damage = 16
            bullet.Tracer      = 1
            bullet.TracerName = "Tracer"
            bullet.Callback = function(attacker,trace,dmg)
                if (self.Level == 1 && trace.Entity:GetModel() == "models/props_junk/watermelon01.mdl") then
                    self.Level = -1
                    self:SetNWFloat("size",0.75)
                    self:SetSkin(2)
                    self:SetBodygroup(2,1)
                    
                    self:SetNWInt("Health",100)
                    
                    self:GetNWEntity("PillUser"):PrintMessage(HUD_PRINTCENTER,"YOU FOUND MINISENTRY MODE")
                end
            end
            
            if (self.Level == 1) then
                bullet.Src = self:GetAttachment(self:LookupAttachment("muzzle")).Pos
                self:FireBullets(bullet)
                self:EmitSound(Sounds.Shoot1,100,100)
                
                ParticleEffect("muzzle_sentry",bullet.Src,bullet.Dir:Angle(),self)
                
                self.NextShot = CurTime() + 0.25
                self.NextPing = CurTime() + 0.25
            elseif (self.Level > 1) then
                if (self.ActiveBarrel) then
                    bullet.Src = self:GetAttachment(self:LookupAttachment("muzzle_l")).Pos
                    if (self.Level == 2) then
                        self:EmitSound(Sounds.Shoot2,100,100)
                    else
                        self:EmitSound(Sounds.Shoot3,100,100)
                    end
                else
                    bullet.Src = self:GetAttachment(self:LookupAttachment("muzzle_r")).Pos
                end
                self.ActiveBarrel = !self.ActiveBarrel
                
                self:FireBullets(bullet)
                
                ParticleEffect("muzzle_sentry2",bullet.Src,bullet.Dir:Angle(),self)
                
                self.NextShot = CurTime() + 0.125
                self.NextPing = CurTime() + 0.125
            elseif (self.Level == -1) then
                bullet.Src = (self:GetAttachment(self:LookupAttachment("muzzle")).Pos - self:GetPos())*0.75 + self:GetPos()
                bullet.Damage = 8
                self:FireBullets(bullet)
                self:EmitSound(Sounds.ShootMini,100,100)
                
                ParticleEffect("muzzle_sentry",bullet.Src,bullet.Dir:Angle(),self)
                
                self.NextShot = CurTime() + 1/6
                self.NextPing = CurTime() + 1/6
            end
        end
        
        
        //Pingage
        if (CurTime() >= self.NextPing && !self.Busy && self.Level != 0) then
            if (self.Level == 1 || self.Level == -1) then self:EmitSound(Sounds.Ping1,100,100)
            elseif (self.Level == 2) then self:EmitSound(Sounds.Ping2,100,100)
            elseif (self.Level == 3) then self:EmitSound(Sounds.Ping3,100,100)
            end
            
            self.NextPing = CurTime() + 3
        end
        
        //RAWKITS!
        for k,rocket in pairs(self.Rockets) do
            rocket:SetPos(rocket:GetPos() + rocket:GetAngles():Forward() * 20)
            if (util.QuickTrace(rocket:GetPos(),rocket:GetAngles():Forward() * 30,{self,rocket}).Hit) then
                util.BlastDamage(self,self:GetNWEntity("PillUser"),rocket:GetPos(),100,100)
                
                ParticleEffect("explosioncore_midair",rocket:GetPos(),Angle(0,0,0),nil)
                rocket:EmitSound(Sounds.RocketBoom,100,100)
                
                rocket:Remove()
                table.remove(self.Rockets,k)
            end
        end
    
        self:NextThink(CurTime())
        return true
    end
    
    function ENT:KeyIn(key)
        //Upgrade
        if (key == IN_SPEED && !self.Busy) then
            if (self.Level == 0) then
                local trace = util.QuickTrace(self:GetPos(),self:GetAngles():Up() * -20,self)
                if (trace.Hit) then
                    local ang = self:GetAngles()
                    self:SetModel("models/buildables/sentry1_heavy.mdl")
                    self:PhysicsInitBox(Vector(-24.5,-24.5,0), Vector(24.5,24.5,87))
                    self:SetAngles(ang)
                    
                    constraint.Weld(self,trace.Entity,0,trace.PhysicsBone,0,true)
                    
                    self:ResetSequence(self:LookupSequence("build"))
                    
                    self.Busy = true
                    self.Level = 1
                    
                    timer.Simple(5,self.FinishAction,self,"models/buildables/sentry1.mdl",3)
                else
                    self:GetNWEntity("PillUser"):ChatPrint("You can't build here.")
                end
            elseif (self.Level == 1) then

                self:SetModel("models/buildables/sentry2_heavy.mdl")
                
                self:ResetSequence(self:LookupSequence("upgrade"))
                

                
                
                self.Busy = true
                self.Level = 2
                
                timer.Simple(1,self.FinishAction,self,"models/buildables/sentry2.mdl",1.2)
            elseif (self.Level == 2) then
                self:SetModel("models/buildables/sentry3_heavy.mdl")
                
                self:ResetSequence(self:LookupSequence("upgrade"))
                
                
                self.Busy = true
                self.Level = 3
                
                timer.Simple(1,self.FinishAction,self,"models/buildables/sentry3.mdl",1.2)
            end
                
        elseif (key == IN_RELOAD) then
            self:Remove()
        elseif (key == IN_ATTACK2 && self.Level == 3 && CurTime() >= self.NextRocket && !self.Busy) then
            local rocket = ents.Create("prop_dynamic")
            local spawn = self:GetAttachment(self:LookupAttachment("rocket"))
            
            table.insert(self.Rockets,rocket)
            
            rocket:SetModel("models/buildables/sentry3_rockets.mdl")
            rocket:SetPos(spawn.Pos)
            rocket:SetAngles(spawn.Ang)
            rocket:Spawn()
            
            self:EmitSound(Sounds.RocketFire,100,100)
            
            self.NextRocket = CurTime() + 3
        end
    end
    
    function ENT:OnRemove()
        self:EmitSound(Sounds.Die,100,100)
        
        self:GetNWEntity("PillUser"):SetNWEntity("PillEnt",nil)
        if (self:GetNWEntity("PillUser"):IsValid() && self:GetNWEntity("PillUser"):Alive()) then
            self:GetNWEntity("PillUser"):KillSilent()
        end
    end
    
    //Damage
    function ENT:OnTakeDamage(dmg)
        self:SetNWInt("Health",self:GetNWInt("Health")-dmg:GetDamage())
        if (self:GetNWInt("Health") <= 0) then
            self:Remove()
        end
    end
    
    //Sets busy to false, sets model
    function ENT:FinishAction(mdl,hmult)
        self:SetModel(mdl)
        self.Busy = false
        
        self:SetNWInt("Health",self:GetNWInt("Health")*hmult)
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
    ENT.ViewOffset = Vector(0,0,60)
    ENT.ViewDistance = 100
    ENT.CrosshairStart = "build_point_0"
   
    ENT.ShowHealth = true
    
    function ENT:Draw()
        local size = self:GetNWFloat("size")
        self:SetModelScale(Vector(size,size,size))
        self:DrawModel()
    end
end