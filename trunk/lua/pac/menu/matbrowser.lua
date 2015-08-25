local PANEL = vgui.Register( "PACMatBrowser", { }, "DFrame" );

AccessorFunc( PANEL, "m_Selected", "Selected" );

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Init( )
	
	self:SetTitle( "Material browser" );
		
	self.MatList = vgui.Create( "DPanelList", self );
	self.MatList:SetPadding( 2 );
	self.MatList:SetSpacing( 2 );
	self.MatList:EnableVerticalScrollbar( true );
	self.MatList:EnableHorizontal( true );
		
	self.Entry = vgui.Create( "DTextEntry", self );
	
	self.Entry.OnEnter = function() self:SetSelected(self.Entry:GetValue()) end
	
	self:SetDeleteOnClose( false );
	self:SetDrawOnTop( true );
	
	self:SetSize( PAC.Spacing * 3 + 256 + 24, PAC.Spacing * 2 + 279 );
	
	self:Center( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:PerformLayout( )

	self.BaseClass.PerformLayout( self )
			
	self.Entry:SetTall(20)
	self.Entry:StretchRightTo(self, PAC.Spacing)
	self.Entry:AlignLeft(PAC.Spacing)
	self.Entry:AlignBottom(PAC.Spacing)
	
	self.MatList:AlignTop(PAC.Spacing)
	self.MatList:StretchToParent(PAC.Spacing,PAC.Spacing+20,PAC.Spacing,PAC.Spacing+20)	
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:SetSelected( value )
	
	self.Entry:SetText(value or "")
	
	self.m_Selected = value;
		
	for i, image in pairs( self.MatList:GetItems( ) ) do
		
		image.PaintOver = image.Value == value and HighlightedButtonPaint or nil;
		
	end
	
	self:MaterialSelected(value)
	
end

function PANEL:MaterialSelected(value)
	--print("NOT SET!", value)
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:SetMaterialList( listname )
	
	self:SetSelected( );
	
	self.MaterialList = list.Get( listname );
	
	self.MatList:Clear( true );
	
	for i, material in ipairs( self.MaterialList ) do
		
		local image = vgui.Create( "DImageButton" );
		image:SetOnViewMaterial( material, material );
		image:SetSize( 64, 64 );
		image.Value = material;
		
		self.MatList:AddItem( image );
		
		image.DoClick = function( image ) self:SetSelected( image.Value ); end
		
		if( !self:GetSelected( ) ) then
			
			image.PaintOver = HighlightedButtonPaint;
			
			self:SetSelected( material );
			
		end
		
	end
	
	self:InvalidateLayout( true );
	
end