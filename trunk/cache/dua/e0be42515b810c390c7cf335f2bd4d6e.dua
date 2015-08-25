local PANEL = vgui.Register( "PACSlider", { }, "DNumSlider" );

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Init( )
	
	self:SetTall( self.Wang:GetTall( ) );
	
	self.Slider:SetTall( 13 );
	self.Slider.Knob:NoClipping( false );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:PerformLayout( )
	
	self.Label:SetPos( 0, 0 );
	self.Label:CenterVertical( );
	
	self.Wang:SizeToContents( );
	self.Wang:SetPos( 0, 0 );
	self.Wang:AlignRight( 0 );
	
	self.Slider:CenterVertical( );
	self.Slider:MoveRightOf( self.Label, PAC.Spacing );
	self.Slider:StretchRightTo( self.Wang, PAC.Spacing );
	self.Slider:SetSlideX( self.Wang:GetFraction( ) );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:SetText( str )
	
	DNumSlider.SetText( self, str );
	
	self.Label:SizeToContents( );
	self:InvalidateLayout( );
	
end