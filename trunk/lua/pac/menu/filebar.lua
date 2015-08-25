local PANEL = vgui.Register( "PACFileBar", { }, "DPanel" );

//----------------------------------------------------------------------------------------
//	Purpose: creates the topbar's contents
//----------------------------------------------------------------------------------------

PAC.ScreenClicker = false

function PANEL:Init( )
	
	self:SetTall( 16 + PAC.Spacing * 2 );
	
	self.Anchor = vgui.Create( "DImageButton", self );
	self.Anchor:SetImage( "gui/silkicons/anchor" );
	self.Anchor:SetToolTip( "Toggle Focus" );
	self.Anchor:SizeToContents( );
	self.Anchor.DoClick = function( ) 
		if PAC.ScreenClicker or PAC.Editor.hasfocus then
			gui.EnableScreenClicker(false)
			PAC.ScreenClicker = false
			PAC.Editor:SetFocus(false)
		else
			gui.EnableScreenClicker(true) 
			PAC.ScreenClicker = true
			PAC.Editor:SetFocus(true)
		end
	end
		
	self.NameInput = vgui.Create( "DTextEntry", self );
	self.NameInput:SetWide( 280 );
	
	self.SaveClient = vgui.Create( "DImageButton", self );
	self.SaveClient:SetImage("gui/silkicons/page")
	self.SaveClient:SetToolTip( "Save the outfit to client" );
	self.SaveClient:SizeToContents();
	self.SaveClient.DoClick = function( ) self:SaveToClient( ); end
	
	self.SaveServer = vgui.Create( "DImageButton", self );
	self.SaveServer:SetImage("gui/silkicons/world")
	self.SaveServer:SetToolTip( "Save the outfit to server" );
	self.SaveServer:SizeToContents();
	self.SaveServer.DoClick = function( ) self:SaveToServer() end
	
	self.Wear = vgui.Create( "DImageButton", self );
	self.Wear:SetImage("gui/silkicons/arrow_refresh")
	self.Wear:SetToolTip( "Wear your outfit" );
	self.Wear:SizeToContents();
	self.Wear.DoClick = function( ) LocalPlayer():SetPACConfig(LocalPlayer():GetPACConfig()) end
	
end

//----------------------------------------------------------------------------------------
//	Purpose: positions the contents as needed
//----------------------------------------------------------------------------------------
function PANEL:PerformLayout( )
	
	self.Anchor:AlignRight( PAC.Spacing );
	self.Anchor:CenterVertical( );
	
	self.SaveClient:MoveLeftOf( self.Anchor, PAC.Spacing );
	self.SaveClient:CenterVertical( );

	self.SaveServer:MoveLeftOf( self.SaveClient, PAC.Spacing );
	self.SaveServer:CenterVertical( );
	
	self.Wear:MoveLeftOf( self.SaveServer, PAC.Spacing );
	self.Wear:CenterVertical( );

	self.NameInput:AlignLeft( PAC.Spacing );
	self.NameInput:StretchRightTo( self.Wear, PAC.Spacing );
	self.NameInput:CenterVertical( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:GetFileName( )

	local name = self.NameInput:GetValue( )
	
	if name == "" then name = "noname" end
	
	local filename = name:gsub( "^pac2_outfits/", "" );
	
	if( !filename:find( "%.txt$" ) ) then filename = filename..".txt"; end
	
	return filename;
	
end

function PANEL:SetFileName(name)
	self.NameInput:SetValue(name)
end

function PANEL:SaveToServer()
	
	PAC.SaveToServer(self:GetFileName( ):sub(0,-5), LocalPlayer( ):GetPACConfig( ))
	surface.PlaySound("buttons/button9.wav")
end

//----------------------------------------------------------------------------------------
//	Purpose: saves all of the parts to the client
//----------------------------------------------------------------------------------------
function PANEL:SaveToClient( )
	
	PAC.SaveConfig( self:GetFileName( ):sub(0,-5), LocalPlayer( ):GetPACConfig( ) );
	surface.PlaySound("buttons/button9.wav")
	
end