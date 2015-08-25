local PANEL = vgui.Register( "PACColorBox", { }, "DPanel" );

AccessorFunc( PANEL, "m_Color", "Color" );
AccessorFunc( PANEL, "m_ChAlpha", "ChangeAlpha" );

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
local function PaintPreview( self )
	
	local color = self:GetParent( ).m_Color;
	
	draw.SimpleText(
		"Transparent",
		"ChatFont",
		self:GetWide( ) * 0.5,
		self:GetTall( ) * 0.5,
		color_white,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER
	);
	
	surface.SetDrawColor( 50, 50, 50, 255 );
	self:DrawOutlinedRect( );
	
	surface.SetDrawColor( color.r, color.g, color.b, color.a );
	self:DrawFilledRect( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Init( )
	
	self.InSetColor = false;
	
	self.Preview = vgui.Create( "DPanel", self );
	self.Preview.Paint = PaintPreview;
	
	local function AddNumberWang( callback )
		
		local wang = vgui.Create( "DNumberWang", self );
		wang:SetMinMax( 0, 255 );
		wang:SetDecimals( 0 );
		wang.ChangeCallback = callback;
		
		wang.OnValueChanged = function( wang, value )
			
			wang:ChangeCallback( value );
			
			if( !self.InSetColor ) then self:ColorChanged( self.m_Color ); end
			
		end;
		
		// hacks, incompleteness, etc. is what derma is all about..
		wang.TextEntry.OnEnter = function( entry ) entry:GetParent( ):SetValue( entry:GetValue( ) ); end
		
		return wang;
		
	end
	
	self.RW = AddNumberWang( function( wang, value ) self.m_Color.r = tonumber( value ); end );
	self.GW = AddNumberWang( function( wang, value ) self.m_Color.g = tonumber( value ); end );
	self.BW = AddNumberWang( function( wang, value ) self.m_Color.b = tonumber( value ); end );
	self.AW = AddNumberWang( function( wang, value ) self.m_Color.a = tonumber( value ); end );
	
	self:SetTall( self.RW:GetTall( ) * 4 + PAC.Spacing * 5 );
	
	self:SetChangeAlpha( true );
	self:SetColor( color_white );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:PerformLayout( )
	
	self.Preview:SetWide( self:GetTall( ) - PAC.Spacing * 2 );
	self.Preview:SetTall( self.Preview:GetWide( ) );
	self.Preview:SetPos( PAC.Spacing, PAC.Spacing );
	
	self.RW:SetWide( 40 );
	self.RW:AlignTop( PAC.Spacing );
	self.RW:AlignRight( PAC.Spacing );
	
	self.GW:CopyBounds( self.RW );
	self.GW:MoveBelow( self.RW, PAC.Spacing );
	
	self.BW:CopyBounds( self.RW );
	self.BW:MoveBelow( self.GW, PAC.Spacing );
	
	self.AW:CopyBounds( self.RW );
	self.AW:MoveBelow( self.BW, PAC.Spacing );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:SetChangeAlpha( bool )
	
	self.m_ChAlpha = bool;
	
	self.AW:SetVisible( bool );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:SetColor( color )
	
	self.m_Color = table.Copy( color );
	
	self.InSetColor = true;
		
		self.RW:SetValue( color.r );
		self.GW:SetValue( color.g );
		self.BW:SetValue( color.b );
		self.AW:SetValue( color.a );
		
	self.InSetColor = false;
	
	self:ColorChanged( self.m_Color );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:ColorChanged( color )
end