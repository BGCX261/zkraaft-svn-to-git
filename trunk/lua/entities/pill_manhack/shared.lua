ENT.Category		= "Parakeet's Pills"

ENT.Spawnable       = true
ENT.AdminSpawnable  = true

ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "Manhack"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

ENT.Open = false

local Sounds = {}
Sounds.Die = Sound("npc/manhack/gib.wav")
Sounds.Cut = Sound("npc/manhack/grind1.wav")
Sounds.CutFlesh = Sound("npc/manhack/grind_flesh1.wav")

Sounds.OpenPanels = Sound("npc/roller/mine/rmine_blades_out1.wav")
Sounds.ClosePanels = Sound("npc/roller/mine/rmine_blades_in1.wav")

if (SERVER) then
    function ENT:Initialize()
        //Physics
        self.Entity:SetModel("models/manhack.mdl")
        self.Entity:PhysicsInit(SOLID_VPHYSICS )
        self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        
        local phys = self.Entity:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
        
        //self:GetPhysicsObject():EnableGravity(false)
        //self:GetPhysicsObject():SetMass(10)
    
        //Make the player spectate us.
        self:GetNWEntity("PillUser"):Spectate(OBS_MODE_CHASE)
        self:GetNWEntity("PillUser"):SpectateEntity(self.Entity)
        self:GetNWEntity("PillUser"):SetMoveType(MOVETYPE_OBSERVER)
        self:GetNWEntity("PillUser"):StripWeapons()
        
        self:SetPlaybackRate(1)
    
        //Add looping Sounds
        self.Sound_Hover1 = CreateSound(self.Entity,"npc/manhack/mh_engine_loop1.wav")
        self.Sound_Hover2 = CreateSound(self.Entity,"npc/manhack/mh_blade_loop1.wav")
        
        self:ResetSequence(self:LookupSequence("Deploy"))
        
        
        timer.Simple(2,function(self)
                self.Sound_Hover1:Play()
                //self.Sound_Hover2:Play()
                
                self:SetBodygroup(1,1)
                self:SetBodygroup(2,1)
                self:ResetSequence(self:LookupSequence("fly"))
        end,self)
        
        //Launch
        self:GetPhysicsObject():AddVelocity(Vector(0,0,1000))
        
        //Health
        self:SetNWInt("Health",25)
    end
    
    function ENT:Think()
        //Remove in water.
        if (self:WaterLevel() > 1) then self:Remove() end
            
        if self:GetSequence() == self:LookupSequence("fly") then
            local Power = 9
            
            //UpDown
            if (self:GetNWEntity("PillUser"):KeyDown(IN_SPEED)) then Power = Power + 3
            elseif (self:GetNWEntity("PillUser"):KeyDown(IN_DUCK)) then Power = Power - 3
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
            
            //Open/Close Panels
            local OpenAmount = self:GetPoseParameter("Panel1")
            if self.Open && OpenAmount < 90 then
                self:SetPoseParameter("Panel1",OpenAmount+10)
                self:SetPoseParameter("Panel2",OpenAmount+10)
                self:SetPoseParameter("Panel3",OpenAmount+10)
                self:SetPoseParameter("Panel4",OpenAmount+10)
            elseif !self.Open && OpenAmount > 0 then
                self:SetPoseParameter("Panel1",OpenAmount-10)
                self:SetPoseParameter("Panel2",OpenAmount-10)
                self:SetPoseParameter("Panel3",OpenAmount-10)
                self:SetPoseParameter("Panel4",OpenAmount-10)
            end
            
            self:NextThink(CurTime())
            return true
        end
    end
    
    //Code from rollermine, lol
    function ENT:PhysicsCollide(CD,Phys)
        if self.Open && CD.HitNormal.z < 0.5 && CD.HitNormal.z > -0.5 then
            local Force = -CD.HitNormal
        
            //GTFO
            self:GetPhysicsObject():ApplyForceCenter(Force * 800)
        
            //Give Damage
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(10)
            dmginfo:SetAttacker(self:GetNWEntity("PillUser"))
            dmginfo:SetDamageForce(Force * -10000)
            CD.HitEntity:TakeDamageInfo(dmginfo)
        
            if (
                    CD.HitEntity:GetClass() == "player" ||
                    string.sub(CD.HitEntity:GetClass(),1,3) == "npc" ||
                    CD.HitEntity:GetNWEntity("PillUser") != NULL) then
                self:EmitSound(Sounds.CutFlesh)
            else
                self:EmitSound(Sounds.Cut)
            end
        end
    end
    
    function ENT:OnRemove( )
        //Stop looping sounds
        self.Sound_Hover1:Stop()
        self.Sound_Hover2:Stop()
        //self.Sound_Move:Stop()
        
        self:EmitSound(Sounds.Die,100,100)
    
        //Kill user.
        self:GetNWEntity("PillUser"):SetNWEntity("PillEnt",nil)
        if (self:GetNWEntity("PillUser"):IsValid() && self:GetNWEntity("PillUser"):Alive()) then
            self:GetNWEntity("PillUser"):KillSilent()
        end
    end
    
    function ENT:KeyIn(key)
        if (key == IN_ATTACK) then
            if self.Open then
                self:EmitSound(Sounds.ClosePanels)
                self.Sound_Hover2:Stop()
                self.Open = false
            elseif !self.Open then
                self:EmitSound(Sounds.OpenPanels)
                self.Sound_Hover2:Play()
                self.Open = true
            end
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
    ENT.ShowHealth = true
end