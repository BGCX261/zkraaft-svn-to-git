
local State = "idle"

local texFSB = render.GetSuperFPTex()
local matFSB = Material( "pp/motionblur" )
local LastPixelX = 0
local LastPixelY = 0

local Function = "";

local FunctionCompiled = nil

PANEL = 
{

	Init = function( self )

		self:SetSizable( true )
		self:SetTitle( "Pixel Render 2011" )
		self:SetRenderInScreenshots( false )
		/*
		local btn = vgui.Create( "DButton", self )
			btn.DoClick = function()
				State = "capture"
			end
		btn:Dock( BOTTOM )
		*/

		self.Error = vgui.Create( "DTextEntry", self )		
			self.Error:SetTextColor( Color( 255, 0, 0, 255 ) )
			self.Error:Dock( BOTTOM )
			self.Error:SetVisible( false )
		
		local ctrl = vgui.Create( "DLuaEditor", self )
			ctrl:SetVerticalScrollbarEnabled( true )
			ctrl.OnCodeChanged = function( self )

				if ( self:GetCode() == "" ) then return end
				
				Function = self:GetCode()
							
				FunctionCompiled = CompileString( Function, "Line", false )
				if ( type( FunctionCompiled ) == "string" ) then 
					PixelRenderWindow:SetError( FunctionCompiled )
					FunctionCompiled = nil
					return
				end
			
				PixelRenderWindow:SetError( nil )
				
				LastPixelX = 0
				LastPixelY = 0
					
				if ( State == "idle" ) then State = "capture" end
				if ( State == "display" ) then State = "render" end
				
			end
		ctrl:Dock( FILL )
		
		self.CodeEdit = ctrl
			
			
		self:SetSize( 700, 400 )
			
	end,

	SetError = function( self, err )
	
		if ( err ) then
		
			if ( !self.Error:IsVisible() ) then
			
				self.Error:SetVisible( true )
				self:InvalidateLayout()
				
			end
			
			self.Error:SetText( err )
			
		else
		
			if ( self.Error:IsVisible() ) then
			
				self.Error:SetVisible( false )
				self:InvalidateLayout()
				
			end
		
		end
	

				
	end
}

local pnlPixelRender = vgui.RegisterTable( PANEL, "DFrame" )


local function CapturePixels()

	render.CapturePixels()
	
	local OldRT = render.GetRenderTarget()
	
	render.SetRenderTarget( texFSB )
		render.Clear( 50, 200, 255 )
	render.SetRenderTarget( OldRT )
	
	State = "render"
	
	LastPixelX = 0
	LastPixelY = 0
	
	return false

end

local function RenderPixel( _x, _y )

	if ( !FunctionCompiled ) then return end
	
	x = _x
	y = _y
	
	local b, e = pcall( FunctionCompiled )
	
	if ( !b ) then
	
		PixelRenderWindow:SetError( "Runtime Error: " .. e )
		FunctionCompiled = nil
		
	end
	
	x = nil
	y = nil

end

local function RenderPixels()

	local TimeEnd = SysTime() + ( 1 / 60 )
	if ( !FunctionCompiled ) then return end
		
	while ( true ) do
	
		RenderPixel( LastPixelX, LastPixelY )
		
		LastPixelX = LastPixelX + 1
		
		if ( LastPixelX >= ScrW() ) then
			LastPixelX = 0
			LastPixelY = LastPixelY + 1
		end
		
		if ( LastPixelY >= ScrH() ) then
			LastPixelX = 0
			LastPixelY = 0
			State = "display"
			return
		end
		
		if ( TimeEnd < SysTime() ) then
			return
		end
	end

end

local function RenderDisplay()

	matFSB:SetMaterialFloat( "$alpha", 1 )
	matFSB:SetMaterialTexture( "$basetexture", texFSB )
				
	render.SetMaterial( matFSB )
	render.DrawScreenQuad()
	
	return true

end

local function RenderProcess()

	if ( !FunctionCompiled ) then return RenderDisplay() end
	
	render.SetRenderTarget( texFSB )
		cam.Start2D()
			RenderPixels()
		cam.End2D()
	render.SetRenderTarget( nil )
	
	RenderDisplay()	
	return true

end



local function RenderSceneHook( ViewOrigin, ViewAngles )

	if ( !ValidPanel( PixelRenderWindow ) ) then return end
	
	
	if ( State == "idle" ) then return end
	if ( State == "render" ) then return RenderProcess() end
	if ( State == "display" ) then return RenderDisplay() end

	return false;

end

hook.Add( "RenderScene", "RenderPixelRender", RenderSceneHook )

local function CaptureSceneHook( bShadowDepth, bInSkyBox )

	if ( bShadowDepth ) then return end
	if ( !ValidPanel( PixelRenderWindow ) ) then return end
	if ( !FunctionCompiled ) then return end
	
	if ( State == "capture" ) then return CapturePixels() end

end

hook.Add( "PreDrawHUD", "RenderPixelCapture", CaptureSceneHook )

local function OpenWindow()

	if ( ValidPanel( PixelRenderWindow ) ) then
		PixelRenderWindow:Remove()
	end
	
	PixelRenderWindow = vgui.CreateFromTable( pnlPixelRender )
	PixelRenderWindow:InvalidateLayout( true )
	PixelRenderWindow:MakePopup()
	PixelRenderWindow:AlignBottom( 50 )
	PixelRenderWindow:CenterHorizontal()
	PixelRenderWindow:SetKeyboardInputEnabled( true )
	PixelRenderWindow.CodeEdit:SetCode( "// Read the pixel at x, y \
local r, g, b = render.ReadPixel( x, y )\
\
// Draw the exact pixel back to the screen - with twice as much red!\
surface.SetDrawColor( r*2, g, b, 255 )\
surface.DrawRect( x, y, 1, 1 )\
" )

end

concommand.Add( "pp_PixelRender", OpenWindow )


local function BuildControlPanel( CPanel )

	CPanel:Help( "Click the button below to open the window" )
	CPanel:Button( "Open Pixel Render Window", "pp_PixelRender" )
	
end

hook.Add( "PopulateToolMenu", "AddPostProcessMenu_PixelRender", function() spawnmenu.AddToolMenuOption( "PostProcessing", "PPShader", "PixelRender", "#Pixel Render", "", "", BuildControlPanel ) end )
