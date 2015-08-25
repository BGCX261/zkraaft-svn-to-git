local PANEL = vgui.Register( "PACMatSelect", { }, "DPanel" );

AccessorFunc( PANEL, "m_MatList", "MaterialList" );

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Init( )
	
	self.ImageButton = vgui.Create( "DImageButton", self );
	self.ImageButton:SetSize( 128, 128 );
	self.ImageButton:SetPos( 0, PAC.Spacing );
	self.ImageButton.DoClick = function( ) self:OpenBrowser( ); end
	
	self.ResetButton = vgui.Create( "DButton", self );
	self.ResetButton:SetText( "Reset" );
	self.ResetButton:SetWide( self.ImageButton:GetWide( ) );
	self.ResetButton.DoClick = function( ) self:ResetMaterial( ); end
	
	self.Browser = nil;
	
	self:SetMaterialList( "OverrideMaterials" );
	
	self:SetTall( self.ImageButton:GetTall( ) + self.ResetButton:GetTall( ) + PAC.Spacing * 3 );
	
	self.ResetButton:MoveBelow( self.ImageButton, PAC.Spacing );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:PerformLayout( )
	
	self.ImageButton:CenterHorizontal( );
	self.ResetButton:CenterHorizontal( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:OpenBrowser( )
	
	self.Browser = self.Browser or vgui.Create( "PACMatBrowser" );
	self.Browser:SetMaterialList( self:GetMaterialList( ) );
	self.Browser:SetSelected( self.ImageButton:GetImage( ) );
	self.Browser:SetVisible( true );
	self.Browser:MakePopup( );
	
	self.Browser.MaterialSelected = function(_, value)
				
		self:SetSelected( value or "" );
		
		self:MaterialChanged( value or "" );
		
	end
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:ResetMaterial( )
	
	self.ImageButton.m_Image.Paint = function( ) end
	
	self:MaterialChanged( "" );
	
	if self.Browser then
	
		self.Browser.Entry:SetText("")
	
	end
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:SetSelected( value )
	
	if( value == "" ) then self:ResetMaterial( ); return; end
	
	self.ImageButton.m_Image.Paint = DImage.Paint;
	self.ImageButton:SetImage( value );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:GetSelected( )
	
	return self.ImageButton:GetImage( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:MaterialChanged( value )
end