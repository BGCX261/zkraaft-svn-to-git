PAC.InPreview = false;

local PANEL = vgui.Register( "PACDragPanel", { } );

AccessorFunc( PANEL, "m_CamAng", "CameraAngle" );
AccessorFunc( PANEL, "m_CamDist", "CameraDist" );

PANEL.Sensitivity = CreateClientConVar( "pac_preview_sensitivity", "0.85", true, false );
PANEL.ViewBone = CreateClientConVar( "pac_preview_bone", "Player", false, false );
PANEL.TPose = CreateClientConVar( "pac_preview_tpose", "0", false, false );
PANEL.Trace = CreateClientConVar( "pac_preview_trace", "1", false, false );
PANEL.AutoFocus	= CreateClientConVar( "pac_preview_autofocus", "1", false, false );
PANEL.AutoFocusEntity = CreateClientConVar( "pac_preview_autofocus_entity", "0", false, false );

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Init( )
	
	self.MouseHeld, self.MousePosition = -1, Vector( );
	
	self:SetCursor( "sizeall" );
	
	self:SetCameraAngle( Angle( 0, 20, 0 ) );
	self:SetCameraDist( 75 );
	
	self:SetAlpha(255)
	
	self:Enable(true)
end

function PANEL:Paint()
	return true
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:OnMousePressed( mcode )
	
	if mctrl.GUIMousePressed( mcode ) then self:SetCursor("user") return end
	
	if( mcode != MOUSE_LEFT && mcode != MOUSE_RIGHT ) then return; end
	
	self.MouseHeld = mcode;
	
	self.MousePosition.x, self.MousePosition.y = self:CursorPos( );
	
	self.HeldAngle		= self:GetCameraAngle( );
	self.HeldDistance	= self:GetCameraDist( );
	
	self:MouseCapture( true );
	self:SetCursor( "none" );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:OnMouseReleased( mcode )
	
	mctrl.GUIMouseReleased( mcode )

	self.MouseHeld = -1;
	
	self:MouseCapture( false );
	self:SetCursor( "sizeall" );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:OnCursorMoved( x, y )
	
	if( !self.HeldAngle || !self.HeldDistance ) then return; end
	
	if( self.MouseHeld == MOUSE_LEFT ) then
		
		local delta = ( self.MousePosition - Vector( x, y, 0 ) ) * self.Sensitivity:GetFloat( );
		
		local angle = Angle( self.HeldAngle.p - delta.y, self.HeldAngle.y + delta.x, self.HeldAngle.r );
		
		self:SetCameraAngle( angle );
		
	elseif( self.MouseHeld == MOUSE_RIGHT ) then
		
		self:SetCameraDist( math.Clamp( self.HeldDistance + ( y - self.MousePosition.y ) * self.Sensitivity:GetFloat( ), 0, 450 ) );
		
	end
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:GetViewPosition( )

	local center, i, pl, bone = vector_origin, 0, LocalPlayer( ), self.AutoFocus:GetBool() and PAC.CurrentPart and PAC.CurrentPart.bone or self.ViewBone:GetString( );
	
	if( bone != "" && bone != "Player" ) then
		local bonepos = pl:GetBonePosition( pl:LookupBone( PAC.BoneList[ bone ] ) )
		
		if self.AutoFocusEntity:GetBool() then
			return IsValid(PAC.CurrentEntity) and PAC.CurrentEntity:GetPos() ~= vector_origin and PAC.CurrentEntity:GetPos() or pl:GetShootPos()
		end
		if self.AutoFocus:GetBool() then
			return bonepos
		end
		return bonepos
	end
	
	for nice, name in pairs( PAC.BoneList ) do
		
		center, i = center + pl:GetBonePosition( pl:LookupBone( name ) ), i + 1;
		
	end
	
	return center / i;
	
end

local function SafeRemoveHook(name, unique)
	if hook.GetTable()[name] and hook.GetTable()[name][unique] then
		hook.Remove(name, unique)
	end	
end

function PANEL:Enable(enable)
	if enable then
		hook.Add( "UpdateAnimation", "PAC.TPose", function( pl )
			
			if not PAC.InPreview then return end
			if( pl != LocalPlayer( ) ) then return; end
			
			pl:SetPoseParameter("breathing", 0)
			
			if( !self.TPose:GetBool( ) ) then return; end
			
			pl:ResetSequence( pl:LookupSequence( "ragdoll" ) );
		
		end)
		
		hook.Add("CalcView", "PAC.CalcView", function(ply, _, _, fov)
			local angles = self:GetCameraAngle( )
			local trace, origin
			if self.Trace:GetBool() then 
				trace = util.QuickTrace( self:GetViewPosition( ), angles:Forward( ) * -self.m_CamDist, LocalPlayer( ) )
				origin = trace.HitPos + trace.HitNormal * trace.Fraction * 2.5
			else
				origin = self:GetViewPosition() + angles:Forward() * -self.m_CamDist
			end
			return GAMEMODE:CalcView(ply,origin,angles,fov)
		end)
		
		hook.Add("GetMotionBlurValues", "PAC.GetMotionBlurValues", function()
			return 0, 0, 0, 0
		end)
	
	else
		SafeRemoveHook( "UpdateAnimation", "PAC.TPose")
		SafeRemoveHook("CalcView","PAC.CalcView")
		SafeRemoveHook("GetMotionBlurValues","PAC.GetMotionBlurValues")
	end
end