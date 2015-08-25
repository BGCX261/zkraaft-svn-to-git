ENT.Category		= "Parakeet's Pills"

ENT.Spawnable       = true
ENT.AdminSpawnable  = true

ENT.Type   = "anim"
ENT.Base                = "base_anim"
ENT.PrintName           = "Rollermine"
ENT.RenderGroup         = RENDERGROUP_TRANSLUCENT

local Sounds = {}
Sounds.SpikesOut = Sound("npc/roller/mine/rmine_blades_out1.wav")
Sounds.SpikesIn = Sound("npc/roller/mine/rmine_blades_in1.wav")
Sounds.Jump = Sound("npc/roller/mine/rmine_blip1.wav")
Sounds.Burrow = Sound("npc/roller/mine/rmine_reprogram.wav")
Sounds.Shock = Sound("npc/roller/mine/rmine_explode_shock1.wav")

if (SERVER) then
    function ENT:Initialize()
        //Physics
        self.Entity:SetModel("models/Roller.mdl")
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
    
        //Add looping Sounds
        self.Sound_Move = CreateSound(self.Entity,"npc/roller/mine/rmine_moveslow_loop1.wav")
        self.Sound_Charged = CreateSound(self.Entity,"npc/roller/mine/rmine_seek_loop2.wav")
    end
    
    function ENT:Think()
        //Go boom if underwater.
        if (self:WaterLevel() > 1) then self:Remove() end
    
        //Only do the rest if we arnt in the ground.
        if (self.Burrowed) then return end
    
        //Movement
        local AimYaw = Angle(0,self:GetNWEntity("PillUser"):EyeAngles().y,0)
        local MoveDir = vector_origin
        if (self:GetNWEntity("PillUser"):KeyDown(IN_FORWARD)) then
            MoveDir = MoveDir + AimYaw:Forward()
        end
        if (self:GetNWEntity("PillUser"):KeyDown(IN_BACK)) then
            MoveDir = MoveDir - AimYaw:Forward()
        end
        if (self:GetNWEntity("PillUser"):KeyDown(IN_MOVERIGHT)) then
        MoveDir = MoveDir + AimYaw:Right()
        end
        if (self:GetNWEntity("PillUser"):KeyDown(IN_MOVELEFT)) then
            MoveDir = MoveDir - AimYaw:Right()
        end
    
        local Center = self:LocalToWorld(self:GetPhysicsObject():GetMassCenter())
        self:GetPhysicsObject():ApplyForceOffset(MoveDir:Normalize() * 22000,Center + Vector(0,0,5))
        self:GetPhysicsObject():ApplyForceOffset(MoveDir:Normalize() * -22000,Center + Vector(0,0,-5))
            
        //Movement Sound
        local MineSpeed = self:GetVelocity():Length()
        if (self.PlayingMoveSound) then
            if (MoveDir == vector_origin) then
            self.Sound_Move:FadeOut(0.5)
                self.PlayingMoveSound = false
            else
                self.Sound_Move:ChangePitch(math.Clamp(MineSpeed/2,100,150))
            end
        else
            if (MoveDir != vector_origin) then
                self.Sound_Move:Play()
                self.PlayingMoveSound = true
            end
        end
    end
    
    //Zap things we bounce off of.
    function ENT:StartTouch(TouchEnt)
        if (self:GetModel() == "models/roller_spikes.mdl" && (
                    TouchEnt:GetClass() == "player" ||
                    string.sub(TouchEnt:GetClass(),1,3) == "npc" ||
                    TouchEnt:GetNWEntity("PillUser") != NULL))
        then
            local Force = (self:GetPos() - TouchEnt:GetPos()):Normalize()
        
            //GTFO
            self:GetPhysicsObject():ApplyForceCenter(Force * 30000)
        
            //Give Damage
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(10)
            dmginfo:SetAttacker(self:GetNWEntity("PillUser"))
            dmginfo:SetDamageForce(Force * -10000)
            TouchEnt:TakeDamageInfo(dmginfo)
        
            self:EmitSound(Sounds.Shock)
        end
    end
    
    function ENT:OnRemove( )
        //Explode
        local explode = ents.Create("env_explosion")
        explode:SetPos(self:GetPos())
        explode:SetOwner(self.User)
        explode:Spawn()
        explode:SetKeyValue("iMagnitude","100")
        explode:Fire("Explode",0,0)
    
        //Stop looping sounds
        self.Sound_Charged:Stop()
        self.Sound_Move:Stop()
    
        //Kill user.
        self:GetNWEntity("PillUser"):SetNWEntity("PillEnt",nil)
        if (self:GetNWEntity("PillUser"):IsValid() && self:GetNWEntity("PillUser"):Alive()) then
            self:GetNWEntity("PillUser"):KillSilent()
        end
    end
    
    function ENT:KeyIn(key)
        //Toggle Spikes
        if (key == IN_ATTACK && !self.Burrowed) then
            if (self:GetModel() == "models/roller.mdl") then
                self:SetModel("models/Roller_Spikes.mdl")
            
                self:EmitSound(Sounds.SpikesOut,100,100)
                self.Sound_Charged:Play()
            else
                self:SetModel("models/Roller.mdl")
                
                self:EmitSound(Sounds.SpikesIn,100,100)
                self.Sound_Charged:Stop()
            end
        //Explode on M2
        elseif (key == IN_ATTACK2) then
            self:Remove()
        //Jump
        elseif (key == IN_JUMP) then
            local ShouldJump = false
            //If burrowed, unburrow
            if (self.Burrowed) then
                self:SetMoveType(MOVETYPE_VPHYSICS)
                self:SetPos(self:GetPos() + Vector(0,0,8))
                self.Burrowed = false
            
                self:DrawShadow(true)
            
                ShouldJump = true
                //If not, check if we can jump.
            else
                local trace = util.QuickTrace(self:GetPos(),Vector(0,0,-20),self)
                if (trace.Hit) then ShouldJump = true end
            end
            //If we should jump, do it!
            if (ShouldJump) then
                self:GetPhysicsObject():ApplyForceCenter(Vector(0,0,15000))
                self:EmitSound(Sounds.Jump)
            end
        //Burrowing
        elseif (key == IN_DUCK && !self.Burrowed) then
            local trace = util.QuickTrace(self:GetPos(),Vector(0,0,-20),self)
            if (trace.MatType == (MAT_DIRT || MAT_SAND)) then
                self:SetPos(trace.HitPos + Vector(0,0,-6))
                self:SetModel("models/Roller.mdl")
                self:SetMoveType(MOVETYPE_NONE)
                self.Burrowed = true
            
                self.Sound_Charged:Stop()
                self.Sound_Move:Stop()
                self:StopParticles()
                self:EmitSound(Sounds.Burrow)
                self:DrawShadow(false)
            end
        end
    end
    //Explode if we take explosive damage.
    function ENT:OnTakeDamage(dmg)
        if (dmg:GetDamageType() == DMG_BLAST) then
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
        ent:SetPos(ply:GetPos()+Vector(0,0,20))
        ent:SetNWEntity("PillUser",ply)
        ply:SetNWEntity("PillEnt",ent)
        ent:Spawn()
    
        return ent
    end
end