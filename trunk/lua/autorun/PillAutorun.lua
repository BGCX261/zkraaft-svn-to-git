if (SERVER) then
	AddCSLuaFile("PillAutorun.lua")
	
	hook.Add("KeyPress","pill_keypress",function(ply,key)
            if (ply:GetNWEntity("PillEnt"):IsValid()) then
                ply:GetNWEntity("PillEnt"):KeyIn(key)
            end
    end)
        
    hook.Add("PlayerDeath","pill_playerdeath",function(ply)
            if (ply:GetNWEntity("PillEnt"):IsValid()) then
                ply:GetNWEntity("PillEnt"):Remove()
            end
    end)
else
    hook.Add("CalcView","pill_view",function(ply, pos, angles, fov)
        if (ply:GetNWEntity("PillEnt") && ply:GetNWEntity("PillEnt").ViewOffset) then
            local View = {}
            View.origin = util.QuickTrace(
                ply:GetNWEntity("PillEnt"):LocalToWorld(ply:GetNWEntity("PillEnt").ViewOffset),
                angles:Forward() * -ply:GetNWEntity("PillEnt").ViewDistance,
                ply:GetNWEntity("PillEnt")
            ).HitPos + angles:Forward() * 5
            View.angles = angles
            View.fov = fov
            return View
        end
    end)
    hook.Add("HUDPaint","pill_hud",function()
        if (LocalPlayer():GetNWEntity("PillEnt")) then
            local PillEnt = LocalPlayer():GetNWEntity("PillEnt")
            if (PillEnt.CrosshairStart and PillEnt:LookupAttachment(PillEnt.CrosshairStart) != 0) then
                local BarrelAngPos = PillEnt:GetAttachment(PillEnt:LookupAttachment(PillEnt.CrosshairStart))
                local pos = util.QuickTrace(BarrelAngPos.Pos,BarrelAngPos.Ang:Forward()*10000,PillEnt).HitPos:ToScreen()
                surface.SetDrawColor(0,255,0,255)
                
                surface.DrawLine(pos.x+15,pos.y+15,pos.x-15,pos.y-15)
                surface.DrawLine(pos.x+15,pos.y-15,pos.x-15,pos.y+15)
            end
            
            if (PillEnt.ShowHealth) then
                draw.SimpleText("Health: "..PillEnt:GetNWInt("Health"),"HUDNumber5",200,200,Color (255,0,0,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
            end
        end
        for _,p in pairs(player.GetAll()) do
                if (ValidEntity(p:GetNWEntity("PillEnt")) && p != LocalPlayer()) then
                    local PillEnt = p:GetNWEntity("PillEnt")
                    local Pos2D = (p:GetPos() + Vector(0,0,100)):ToScreen()
                    if (Pos2D.visible) then
                        draw.SimpleText(p:GetName(),"HUDNumber5",Pos2D.x,Pos2D.y,Color (0,0,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                    end
                end
        end
    end)
end