PAC_PROPTYPE_BONE		= 1;
PAC_PROPTYPE_PART		= 3;
PAC_PROPTYPE_GENERAL	= 4;
PAC_PROPTYPE_PREVIEW	= 8;

local PANEL = vgui.Register( "PACPropertyContainer", { }, "DPanel" );

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Init( )
	
	self.Title = vgui.Create( "DLabel", self );
	self.Title:SetTextColor( color_white );
	self.Title:SetFont( "ChatFont" );
	
	self.Contents = vgui.Create( "DPanelList", self );
	self.Contents:SetSpacing( 1 );
	self.Contents:SetPadding( 0 );
	self.Contents:EnableVerticalScrollbar( true );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:PerformLayout( )
	
	self.Title:SetPos( PAC.Spacing, PAC.Spacing );
	
	self.Contents:StretchToParent( 0, self.Title:GetTall( ) + PAC.Spacing * 2, 0, 0 );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:SetTitle( text )
	
	self.Title:SetText( text );
	self.Title:SizeToContents( );
	
	self:InvalidateLayout( true );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:AddBox( item )
	
	self.Contents:AddItem( item );
	
	item.Toggle = function( item )
		
		DCollapsibleCategory.Toggle( item );
		
		if( item:GetExpanded( ) ) then
			
			for i, category in pairs( self.Contents:GetItems( ) ) do
				
				if( category:GetExpanded( ) && category != item ) then DCollapsibleCategory.Toggle( category ); end
				
			end
			
		end
		
	end
	
end

local PANEL = vgui.Register( "PACProperties", { }, "DVerticalDivider" );

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Init( )
	
	self:SetWidth( 220 );
	
	self.GeneralProperties = vgui.Create( "PACPropertyContainer" );
	self.GeneralProperties:SetTitle( "General:" );
	self:SetTop( self.GeneralProperties );
	
	self.PartProperties = vgui.Create( "PACPropertyContainer" );
	self.PartProperties:SetTitle( "Part:" );
	self:SetBottom( self.PartProperties );
	
	self:SetDividerHeight( PAC.Spacing );
	self:SetCookieName( "PAC.PropertySep" );
	
	self:AddProperties( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:GetContents( part )
	
	return part and self.PartProperties or self.GeneralProperties;
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:AddPropertyBox( title, part )
	
	local box = vgui.Create( "PACPropertyBox" );
	box:SetLabel( title );
	
	self:GetContents( part ):AddBox( box );
	
	box:SetCookieName( "PAC.PB."..title );
	
	return box;
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:AddProperties( )
	
	for i, info in pairs( PAC.PropertyInfo ) do
		
		info.Type = info.Type or PAC_PROPTYPE_PART;
		info.Box = self:AddPropertyBox(
			info.Name,
			info.Type == PAC_PROPTYPE_PREVIEW and false or info.Type & PAC_PROPTYPE_BONE == PAC_PROPTYPE_BONE
		);
		
		if( IsValid( info.Box ) && info.Properties ) then
			
			for i, property in pairs( info.Properties ) do
				
				property.RealReset = property.Reset;
				
				property.Reset = function( control, data )
					
					if( !IsValid( control ) ) then return; end
					if( !property.RealReset ) then return; end
					
					return property.RealReset( control, data );
					
				end
				
				property.Control = info.Box:AddProperty(
					property.Type,
					property.Title,
					property.Change,
					property.Extra or { },
					property.ConVar,
					property.Decimals
				);
				
			end
			
		end
		
	end
	
	self:Refresh( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Refresh( )
	
	local pl = LocalPlayer( );
	
	for i, info in ipairs( PAC.PropertyInfo ) do
		
		info.Box:SetVisible(
			info.Type == PAC_PROPTYPE_PREVIEW ||
			( !PAC.CurrentPart && IsValid( pl ) && pl:GetPACConfig( ) && info.Type == PAC_PROPTYPE_GENERAL ) ||
			PAC.CurrentPart && ( PAC.IsPartObject( PAC.CurrentPart ) ||
			( PAC.IsBoneObject( PAC.CurrentPart ) && info.Type != PAC_PROPTYPE_PART ) )
		);
		
	end
	
	self.PartProperties.Contents:Rebuild( );
	self.GeneralProperties.Contents:Rebuild( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.GetPropertyInfo( name, pname, part )
	
	local target = ( part == nil and true or part ) and PAC_PROPTYPE_BONE or PAC_PROPTYPE_GENERAL;
	
	for i, info in pairs( PAC.PropertyInfo ) do
		
		if( info.Name == name && info.Type & target == target ) then
			
			if( pname ) then
				
				for i, property in pairs( info.Properties ) do
					
					if( property.Name == pname ) then return property, info; end
					
				end
				
			end
			
			return info;
			
		end
		
	end
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.ResetProperties( data )
	
	for i, info in ipairs( PAC.PropertyInfo ) do
		
		if( info.Type == PAC_PROPTYPE_GENERAL || PAC.IsPartObject( data ) ||
			( info.Type == PAC_PROPTYPE_BONE && PAC.IsBoneObject( data ) ) ) then
			
			for i, property in pairs( info.Properties ) do
				
				if property.Reset and property.Control then
					property.Reset(
						property.Control,
						info.Type == PAC_PROPTYPE_GENERAL and LocalPlayer( ):GetPACConfig( ) or data
					);
				end
			end
			
		end
		
	end
	
end