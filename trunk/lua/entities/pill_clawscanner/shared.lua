ENT.Category		= "Parakeet's Pills"

ENT.Spawnable       = true
ENT.AdminSpawnable  = true

ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "Claw Scanner"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

ENT.CLModel = nil

local Sounds = {}
Sounds.Photo = Sound("npc/scanner/scanner_photo1.wav")
Sounds.Die = Sound("npc/scanner/scanner_explode_crash2.wav")

if (SERVER) then
    function ENT:Initialize()
        //Physics
        self.Entity:SetModel("models/Shield_Scanner.mdl")
        self.Entity:PhysicsInit(SOLID_VPHYSICS )
        self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        
        local phys = self.Entity:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
        
        self:GetPhysicsObject():EnableGravity(false)
        self:GetPhysicsObject():SetMass(10)
    
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
        
        self:ResetSequence(self:LookupSequence("HoverClosed"))
        
        //Health
        self:SetNWInt("Health",30)
    end
    
    function ENT:Think()
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
        elseif (key == IN_ATTACK && self:GetSequence() == self:LookupSequence("HoverClosed")) then
            self.DroppingMine = true
            self:ResetSequence(self:LookupSequence("OpenUp"))
            
            timer.Simple(0.5,function(self)
                    self:SetNWBool("DrawMine",true)
            end,self)
            
            timer.Simple(2.25,function(self)
                    self:ResetSequence(self:LookupSequence("CloseUp"))
                    self:SetNWBool("DrawMine",false)
                            
                    //Drop a mine
                    local mine = ents.Create("combine_mine")
                    local pos,ang = self:GetBonePosition(self:LookupBone("Bone08_T"))
                    mine:SetPos(pos)
                    mine:SetAngles(ang)
                    mine:Spawn()
                    mine:GetPhysicsObject():AddVelocity(self:GetVelocity())
                    
                    timer.Simple(2,function(self)                 
                            self:ResetSequence(self:LookupSequence("HoverClosed"))
                    end,self)
            end,self)
            
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

    function ENT:Initialize()
        self.CLModel = ClientsideModel("models/props_combine/combine_mine01.mdl",RENDERGROUP_OPAQUE)
        self.CLModel:SetPos(self:GetPos())
        self.CLModel:SetParent(self)
    end
    function ENT:Think()
        if self:GetNWBool("DrawMine") then
            self.CLModel:SetNoDraw(false)
            
            local pos, ang = self:GetBonePosition(self:LookupBone("Bone08_T"))
            self.CLModel:SetRenderOrigin(pos)
            self.CLModel:SetRenderAngles(ang)
        else
            self.CLModel:SetNoDraw(true)
        end
        
        self:NextThink(CurTime())
        return true
    end
    function ENT:OnRemove()
        self.CLModel:Remove()
    end
end