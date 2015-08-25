mctrl = {}
mctrl.AXIS_X = 1
mctrl.AXIS_Y = 2
mctrl.AXIS_Z = 3
mctrl.AXIS_VIEW = 4
mctrl.MODE_MOVE = 1
mctrl.MODE_ROTATE = 2

mctrl.target = nil

local AXIS_X, AXIS_Y, AXIS_Z, AXIS_VIEW = mctrl.AXIS_X, mctrl.AXIS_Y, mctrl.AXIS_Z, mctrl.AXIS_VIEW
local MODE_MOVE, MODE_ROTATE = mctrl.MODE_MOVE, mctrl.MODE_ROTATE

--
-- Math functions
--
function mctrl.dot(x1, y1, x2, y2)
	return (x1 * x2 + y1 * y2);
end

function mctrl.linePlaneIntersection(p, n, lp, ln)
	local d = p:Dot(n)
	local t = d - lp:Dot(n) / ln:Dot(n)
	if t < 0 then return; end
	return lp + ln * t;
end


--
-- Script functions
--

-- functions added for PAC's local bone positions + angles
function mctrl.PACGetBonePos()
	local target = mctrl.getTarget()
	local bone = LocalPlayer():LookupBone(PAC.TranslateBoneToUnfriendly(target.bone or "") or "")
	local position, angles = LocalPlayer():GetBonePosition(bone)
	
	local parent = PAC.CurrentEntity and PAC.CurrentEntity.parent
	if parent then
		local modelbones = parent.modelbones
		if modelbones and modelbones.redirectparent then
			position, angles = parent:GetBonePosition(parent:LookupBone(modelbones.redirectparent))
		else
			position = parent:GetPos()
			angles = parent:GetAngles()
		end
	end

	return position, angles;
end
function mctrl.targetPos()
	local target = mctrl.getTarget()
	if not target then return; end
	
	local position, angles = mctrl.PACGetBonePos()
	
	return LocalToWorld( target.offset, target.angles, position, angles )
end
function mctrl.targetLocal(pos, ang)
	local position, angles = mctrl.PACGetBonePos()
	return WorldToLocal(pos, ang, position, angles);
end



-- Mctrl functions
function mctrl.lpi(pos, normal, cursorx, cursory)
	return mctrl.linePlaneIntersection(
		Vector(0, 0, 0), normal,
		gamemode.Call("CalcView", LocalPlayer(), LocalPlayer():EyePos(), LocalPlayer():EyeAngles(), LocalPlayer():GetFOV()).origin - pos,
		gui.ScreenToVector(cursorx, cursory));
end

function mctrl.pointToAxis(pos, axis, x, y)
	local origin = pos:ToScreen()
	local point = (pos + axis * 10):ToScreen()
	
	local a = math.atan2(point.y - origin.y, point.x - origin.x)
	local d = mctrl.dot(math.cos(a), math.sin(a), point.x - x, point.y - y)
	
	return point.x + math.cos(a) * -d,
		point.y + math.sin(a) * -d;
end

function mctrl.calculateMovement(axis, x, y, offset)
	local target = mctrl.getTarget()
	if not target then return; end
	
	local pos, angs = mctrl.targetPos()
	local forward, right, up = mctrl.getAxes(angs)
	
	if axis == AXIS_X then
		local x, y = mctrl.pointToAxis(pos, forward, x, y)
		local localpos = mctrl.lpi(pos, right, x, y)
		if not localpos then return; end
		
		return (mctrl.targetLocal(pos + localpos:Dot(forward)*forward - forward*offset, angs));
	elseif axis == AXIS_Y then
		local x, y = mctrl.pointToAxis(pos, right, x, y)
		local localpos = mctrl.lpi(pos, forward, x, y)
		if not localpos then return; end
		
		return (mctrl.targetLocal(pos + localpos:Dot(right)*right - right*offset, angs));
	elseif axis == AXIS_Z then
		local x, y = mctrl.pointToAxis(pos, up, x, y)
		
		local localpos = mctrl.lpi(pos, forward, x, y)
		if not localpos then
			localpos = mctrl.lpi(pos, right, x, y)
		end
		if not localpos then return; end
		
		return (mctrl.targetLocal(pos + localpos:Dot(up)*up - up*offset, angs));
	elseif axis == AXIS_VIEW then
		local camnormal = gamemode.Call("CalcView", LocalPlayer(), LocalPlayer():EyePos(), LocalPlayer():EyeAngles(), LocalPlayer():GetFOV()).angles:Forward()
		return (mctrl.targetLocal(pos + mctrl.lpi(pos, camnormal, x, y), angs));
	end
end

function mctrl.calculateRotation(axis, x, y)
	local target = mctrl.getTarget()
	if not target then return; end
	
	local pos, angs = mctrl.targetPos()
	local forward, right, up = mctrl.getAxes(angs)
	
	if axis == AXIS_X then
		local localpos = mctrl.lpi(pos, right, x, y)
		if not localpos then return; end
		
		local diffang = (pos - (localpos + pos)):Angle()
		diffang:RotateAroundAxis(right, 180)
		
		local _, localang = WorldToLocal(vector_origin, diffang, vector_origin, angs)
		local _, newang = LocalToWorld(vector_origin, Angle(math.NormalizeAngle(localang.p + localang.y), 0, 0), vector_origin, angs)
		
		return select(2, mctrl.targetLocal(vector_origin, newang));
		
	elseif axis == AXIS_Y then
		local localpos = mctrl.lpi(pos, up, x, y)
		if not localpos then return; end
		
		local diffang = (pos - (localpos + pos)):Angle()
		diffang:RotateAroundAxis(up, 90)
		
		local _, localang = WorldToLocal(vector_origin, diffang, vector_origin, angs)
		local _, newang = LocalToWorld(vector_origin, Angle(0, math.NormalizeAngle(localang.p + localang.y), 0), vector_origin, angs)
		
		return select(2, mctrl.targetLocal(vector_origin, newang));
	elseif axis == AXIS_Z then
		local localpos = mctrl.lpi(pos, forward, x, y)
		if not localpos then return; end
		
		local diffang = (pos - (localpos + pos)):Angle()
		diffang:RotateAroundAxis(forward, -90)
		
		local _, localang = WorldToLocal(vector_origin, diffang, vector_origin, angs)
		local _, newang = LocalToWorld(vector_origin, Angle(0, 0, math.NormalizeAngle(localang.p)), vector_origin, angs)
		
		return select(2, mctrl.targetLocal(vector_origin, newang));
	end
end


--
-- Public functions
--
--[[ not needed for PAC
function mctrl.setTarget(ent)
	mctrl.target = ent
end]]
function mctrl.getTarget()
	return PAC.CurrentPart;
end

function mctrl.getAxes(angs)
	if not mctrl.getTarget() then return; end
	
	return angs:Forward(),
		angs:Right() *-1,
		angs:Up();
end

function mctrl.move(axis, x, y, offset)
	local target = mctrl.getTarget()
	if not target then return; end
	local vNewPos = mctrl.calculateMovement(axis, x, y, offset)
	if not vNewPos then return; end
	
	-- Update the PAC editor's slider values
	local prop = (PAC.GetPropertyInfo("Offset", "X"))
	prop.Control:SetValue(vNewPos.x)
	local prop = (PAC.GetPropertyInfo("Offset", "Y"))
	prop.Control:SetValue(vNewPos.y)
	local prop = (PAC.GetPropertyInfo("Offset", "Z"))
	prop.Control:SetValue(vNewPos.z)
	
	target.offset = vNewPos
	return vNewPos;
end

function mctrl.rotate(axis, x, y)
	local target = mctrl.getTarget()
	if not target then return; end
	local aRotation = mctrl.calculateRotation(axis, x, y)
	if not aRotation then return; end
	
	local prop = (PAC.GetPropertyInfo("Angle", "P"))
	prop.Control:SetValue(aRotation.p)
	local prop = (PAC.GetPropertyInfo("Angle", "Y"))
	prop.Control:SetValue(aRotation.y)
	local prop = (PAC.GetPropertyInfo("Angle", "R"))
	prop.Control:SetValue(aRotation.r)
	
	target.angles = aRotation
	return aRotation;
end


--
-- Display & interface to script functions
--
mctrl.radiusScale = 1.1
mctrl.grabDist = 15

mctrl.grab = {mode = nil, axis=nil}

function mctrl.GetCalculatedScale()

	if PAC.Editor and PAC.Editor.dragframe and PAC.CurrentPart then
		return math.max(PAC.CurrentPart.size*(PAC.Editor.dragframe.m_CamDist*0.1), 4)
	end
	
	return 0
end

function mctrl.GUIMousePressed(mc)
	if mc ~= MOUSE_LEFT then return; end
	local target = mctrl.getTarget()
	if not target then return; end
	local x, y = gui.MousePos()
	
	local pos, angs = mctrl.targetPos()
	local forward, right, up = mctrl.getAxes(angs)
	local r = mctrl.GetCalculatedScale()
	
	
	-- Movement
	local axis
	local dist = mctrl.grabDist
	for i, v in pairs{[AXIS_X] = (pos + forward * r):ToScreen(),
		[AXIS_Y] = (pos + right * r):ToScreen(),
		[AXIS_Z] = (pos + up * r):ToScreen(),
		[AXIS_VIEW] = pos:ToScreen()} do
		
		local d = math.sqrt((v.x - x)^2 + (v.y - y)^2)
		if d <= dist then
			axis = i
			dist = d
		end
	end
	if axis then
		mctrl.grab.mode = MODE_MOVE
		mctrl.grab.axis = axis
		return true;
	end
	-- Rotation
	local axis
	local dist = mctrl.grabDist
	for i, v in pairs{[AXIS_X] = (pos + forward * r/2):ToScreen(),
		[AXIS_Y] = (pos + right * r/2):ToScreen(),
		[AXIS_Z] = (pos + up * r/2):ToScreen()} do
		
		local d = math.sqrt((v.x - x)^2 + (v.y - y)^2)
		if d <= dist then
			axis = i
			dist = d
		end
	end
	if axis then
		mctrl.grab.mode = MODE_ROTATE
		mctrl.grab.axis = axis
		return true;
	end
end

function mctrl.GUIMouseReleased(mc)
	if mc ~= MOUSE_LEFT then return; end
	mctrl.grab.mode = nil
	mctrl.grab.axis = nil
end

function mctrl.lineToBox(origin, point)
	surface.DrawLine(origin.x, origin.y, point.x, point.y)
	surface.DrawOutlinedRect(point.x - 3, point.y - 3, 6, 6)
end

function mctrl.rotationLines(pos, dir, dir2, r)
	local pr = (pos + dir * r/2):ToScreen()
	local pra = (pos + dir * r*.48 + dir2*r*0.08):ToScreen()
	local prb = (pos + dir * r*.48 + dir2*r*-0.08):ToScreen()
	surface.DrawLine(pr.x, pr.y, pra.x, pra.y)
	surface.DrawLine(pr.x, pr.y, prb.x, prb.y)
end

function mctrl.HUDPaint()
	local target = mctrl.getTarget()
	if not target then return; end
	
	local pos, angs = mctrl.targetPos()
	local forward, right, up = mctrl.getAxes(angs)
	
	local r = mctrl.GetCalculatedScale()
	local o = pos:ToScreen()
	
	if mctrl.grab.axis == AXIS_X or mctrl.grab.axis == AXIS_VIEW then
		surface.SetDrawColor(255, 200, 0, 255) else
		surface.SetDrawColor(255, 80, 80, 255) end
	mctrl.lineToBox(o, (pos + forward * r):ToScreen())
	mctrl.rotationLines(pos, forward, up, r)
	
	
	if mctrl.grab.axis == AXIS_Y or mctrl.grab.axis == AXIS_VIEW then
		surface.SetDrawColor(255, 200, 0, 255) else
		surface.SetDrawColor(80, 255, 80, 255) end
	mctrl.lineToBox(o, (pos + right * r):ToScreen())
	mctrl.rotationLines(pos, right, forward, r)


	if mctrl.grab.axis == AXIS_Z or mctrl.grab.axis == AXIS_VIEW then
		surface.SetDrawColor(255, 200, 0, 255) else
		surface.SetDrawColor(80, 80, 255, 255) end
	
	mctrl.lineToBox(o, (pos + up * r):ToScreen())
	mctrl.rotationLines(pos, up, right, r)
	
	surface.SetDrawColor(255, 200, 0, 255)
	surface.DrawOutlinedRect(o.x - 3, o.y - 3, 6, 6)
end

function mctrl.Think()
	local x, y = gui.MousePos()
	if mctrl.grab.axis and mctrl.grab.mode == MODE_MOVE then
		mctrl.move(mctrl.grab.axis, x, y, mctrl.GetCalculatedScale())
	elseif mctrl.grab.axis and mctrl.grab.mode == MODE_ROTATE then
		mctrl.rotate(mctrl.grab.axis, x, y)
	end
end

hook.Add("HUDPaint", "mctrl.HUDPaint", mctrl.HUDPaint)
hook.Add("Think", "mctrl.Think", mctrl.Think)