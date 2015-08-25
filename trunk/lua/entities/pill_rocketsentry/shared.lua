ENT.Category		= "Parakeet's Pills"

ENT.Spawnable       = true
ENT.AdminSpawnable  = true

ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "Rocket Sentry"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

ENT.Busy = true //Default Busy

ENT.NextShot = 0
ENT.NextRocket = 0

ENT.Rockets = {}

ENT.BusyPitch = 0
ENT.BusyYaw = 180

local Sounds = {}
Sounds.RocketBoom = Sound("weapons/explode1.wav")
Sounds.RocketFire = Sound("weapons/rocket/rocket_fire1.wav")
Sounds.Locking1 = Sound("weapons/rocket/rocket_locking_beep1.wav")
Sounds.Locking2 = Sound("weapons/rocket/rocket_locked_beep1.wav")
Sounds.Die = Sound("npc/turret_floor/die.wav")

if (SERVER) then
    function ENT:Initialize()
        //Physics
        self.Entity:SetModel("models/props_bts/rocket_sentry.mdl")
        self.Entity:PhysicsInit(SOLID_VPHYSICS )
        self.Entity:SetMoveType(MOVETYPE_NONE)
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
        //self:SetSequence(self:LookupSequence("inactive"))
        
        //OPEN
        
        self:SetSequence(self:LookupSequence("open"))
        
        timer.Simple(3,self.FinishAction,self)
    end
    
    function ENT:Think()
        //Aiming
        local Yaw,Pitch
        if (!self.Busy) then
            Yaw = -self:WorldToLocalAngles(self:GetNWEntity("PillUser"):EyeAngles()).y-90
            Pitch = math.Clamp(self:WorldToLocalAngles(self:GetNWEntity("PillUser"):EyeAngles()).p,-50,50)
        else
            Yaw = self.BusyYaw
            Pitch = self.BusyPitch
        end
        
        self:SetPoseParameter("aim_yaw",Yaw)
        self:SetPoseParameter("aim_pitch",Pitch)
        
        //RAWKITS!
        for k,rocket in pairs(self.Rockets) do
            rocket:SetPos(rocket:GetPos() + rocket:GetAngles():Forward() * 20)
            if (util.QuickTrace(rocket:GetPos(),rocket:GetAngles():Forward() * 30,{self,rocket}).Hit) then
                
                local explode = ents.Create("env_explosion")
                explode:SetPos(rocket:GetPos())
                explode:SetOwner(self.User)
                explode:Spawn()
                explode:SetKeyValue("iMagnitude","100")
                explode:Fire("Explode",0,0)
                
                rocket.Sound_RocketLoop:Stop()
                
                rocket:Remove()
                table.remove(self.Rockets,k)
            end
        end
    
        self:NextThink(CurTime())
        return true
    end
    
    function ENT:KeyIn(key)
        if (key == IN_ATTACK && CurTime() >= self.NextRocket && !self.Busy) then
            
            self.Busy = true
            self.BusyYaw = self:GetPoseParameter("aim_yaw")
            self.BusyPitch = self:GetPoseParameter("aim_pitch")
            
            self:EmitSound(Sounds.Locking1,100,100)
            self:EmitSound(Sounds.Locking2,100,100)
            
            self:ResetSequence(self:LookupSequence("load"))
            self:SetSkin(1)
            
            timer.Simple(1,function(self)
                    
                    local rocket = ents.Create("prop_dynamic")
                    local spawn = self:GetAttachment(self:LookupAttachment("barrel"))
            
                    table.insert(self.Rockets,rocket)
                    rocket:SetModel("models/props_bts/rocket.mdl")
                    rocket:SetPos(spawn.Pos)
                    rocket:SetAngles(spawn.Ang)
                    rocket:Spawn()
            
                    self:EmitSound(Sounds.RocketFire,100,100)
                        
                    rocket.Sound_RocketLoop = CreateSound(rocket,"weapons/rocket/rocket_fly_loop1.wav")
                    rocket.Sound_RocketLoop:Play()
                    
                    self:SetSkin(2)
                    
                    timer.Simple(1,self.SetSkin,self,0)
                    
                    util.SpriteTrail(rocket,0,Color(50,50,50),false,1,30,1,1/(1+30)*0.5,"trails/smoke.vmt")
            
                    self.NextRocket = CurTime() + 3
                    self.Busy = false
            end,self)
            
       
        elseif (key == IN_RELOAD) then
            self:Remove()
        end
    end
    
    function ENT:OnRemove()
        self:EmitSound(Sounds.Die,100,100)
        
        self:GetNWEntity("PillUser"):SetNWEntity("PillEnt",nil)
        if (self:GetNWEntity("PillUser"):IsValid() && self:GetNWEntity("PillUser"):Alive()) then
            self:GetNWEntity("PillUser"):KillSilent()
        end
    end
    //Say something when shot
    //function ENT:OnTakeDamage(dmg)
    //    self:TakePhysicsDamage(dmg)
    //end
    
    //Sets busy to false
    function ENT:FinishAction()
        self.Busy = false
    end
    
    function ENT:SpawnFunction(ply,tr)
        if (ply:GetNWEntity("PillEnt"):IsValid()) then
            ply:ChatPrint("You are already using a pill!")
            return
        end
        if (!ply:Alive()) then
            ply:ChatPrint("You must be alive to use a pill!")
            return
        end
        
        local trace = util.QuickTrace(ply:GetPos(),Vector(0,0,1) * -20,ply)
        if (!trace.Hit) then
            ply:ChatPrint("You can't spawn as this pill in midair!")
            return
        end
        
        local ent = ents.Create(ClassName)
        ent:SetPos(ply:GetPos()+Vector(0,0,0))
        ent:SetAngles(ply:GetAngles())
        ent:SetNWEntity("PillUser",ply)
        ply:SetNWEntity("PillEnt",ent)
        ent:Spawn()
    
        return ent
    end
else
    ENT.ViewOffset = Vector(0,0,60)
    ENT.ViewDistance = 100
    
    ENT.CrosshairStart = "barrel"
end