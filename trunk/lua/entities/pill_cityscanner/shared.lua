ENT.Category		= "Parakeet's Pills"

ENT.Spawnable       = true
ENT.AdminSpawnable  = true

ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "City Scanner"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

local Sounds = {}
Sounds.Photo = Sound("npc/scanner/scanner_photo1.wav")
Sounds.Die = Sound("npc/scanner/scanner_explode_crash2.wav")
/*Sounds.SpikesIn = Sound("npc/roller/mine/rmine_blades_in1.wav")
Sounds.Jump = Sound("npc/roller/mine/rmine_blip1.wav")
Sounds.Burrow = Sound("npc/roller/mine/rmine_reprogram.wav")
Sounds.Shock = Sound("npc/roller/mine/rmine_explode_shock1.wav")
*/

if (SERVER) then
    function ENT:Initialize()
        //Physics
        self.Entity:SetModel("models/Combine_Scanner.mdl")
        self.Entity:PhysicsInit(SOLID_VPHYSICS )
        self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        
        local phys = self.Entity:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
        
        self:GetPhysicsObject():EnableGravity(false)
        //self:GetPhysicsObject():OutputDebugInfo( )
    
        //Make the player spectate us.
        self:GetNWEntity("PillUser"):Spectate(OBS_MODE_CHASE)
        self:GetNWEntity("PillUser"):SpectateEntity(self.Entity)
        self:GetNWEntity("PillUser"):SetMoveType(MOVETYPE_OBSERVER)
        self:GetNWEntity("PillUser"):StripWeapons()
        
        self:SetPlaybackRate(1)
    
        //Add looping Sounds
        self.Sound_Hover = CreateSound(self.Entity,"npc/scanner/cbot_fly_loop.wav")
        //self.Sound_Charged = CreateSound(self.Entity,"npc/roller/mine/rmine_seek_loop2.wav")
        
        self.Sound_Hover:Play()
        
        self:ResetSequence(self:LookupSequence("idle"))
        
        //Health
        self:SetNWInt("Health",30)
    end
    
    function ENT:Think()
        //Remove in water.
        if (self:WaterLevel() > 1) then self:Remove() end
        
        //Lateral Movement
        local Move = Vector(0,0,0)
        
        if (self:GetNWEntity("PillUser"):KeyDown(IN_FORWARD)) then Move = self:GetAngles():Forward()*2 end
        if (self:GetNWEntity("PillUser"):KeyDown(IN_BACK)) then Move = Move + self:GetAngles():Forward()*-2 end
        if (self:GetNWEntity("PillUser"):KeyDown(IN_MOVERIGHT)) then Move = Move + self:GetAngles():Right()*2 end
        if (self:GetNWEntity("PillUser"):KeyDown(IN_MOVELEFT)) then Move = Move + self:GetAngles():Right()*-2 end
        
        //Move = self:GetAngles():Forward()*self.FwdVel
        
        
        //UpDown
        if (self:GetNWEntity("PillUser"):KeyDown(IN_SPEED)) then Move = Move + Vector(0,0,2)
        elseif (self:GetNWEntity("PillUser"):KeyDown(IN_DUCK)) then Move = Move + Vector(0,0,-2)
        end
        
        self:GetPhysicsObject():AddVelocity(Move)
        
        //Them Angles
        local Aim = self:GetNWEntity("PillUser"):EyeAngles()
        Aim.p = math.Clamp(Aim.p,-30,30)
        
        local LocalAim = self:WorldToLocalAngles(Aim)
        MoveAng = Vector(0,0,0)
        
        MoveAng.y = LocalAim.p*3
        MoveAng.z = LocalAim.y*3
        MoveAng.x = LocalAim.r*3
        
        self:GetPhysicsObject():AddAngleVelocity(-1 * self:GetPhysicsObject():GetAngleVelocity() + MoveAng)
        
        //Move Head to face turning direction
        self:SetPoseParameter("flex_vert",LocalAim.p)
        self:SetPoseParameter("flex_horz",LocalAim.y)
        
        //Move tail based on vertical velocity
        self:SetPoseParameter("tail_control",self:GetPhysicsObject():GetVelocity().z/4)
        
        //Spinny wheel
        self:SetPoseParameter("dynamo_wheel",self:GetPoseParameter("dynamo_wheel")+10)
        
        self:NextThink(CurTime())
        return true
    end
    
    function ENT:OnRemove( )
        //Stop looping sounds
        self.Sound_Hover:Stop()
        //self.Sound_Move:Stop()
        
        self:EmitSound(Sounds.Die,100,100)
    
        //Kill user.
        self:GetNWEntity("PillUser"):SetNWEntity("PillEnt",nil)
        if (self:GetNWEntity("PillUser"):IsValid() && self:GetNWEntity("PillUser"):Alive()) then
            self:GetNWEntity("PillUser"):KillSilent()
        end
    end
    
    function ENT:KeyIn(key)
        if (key == IN_ATTACK2) then
            self:EmitSound(Sounds.Photo,100,100)
        elseif (key == IN_RELOAD) then
            self:Remove()
        end
    end
    
    //Damage
    function ENT:OnTakeDamage(dmg)
        self:SetNWInt("Health",self:GetNWInt("Health")-dmg:GetDamage())
        print(self:GetNWInt("Health"))
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