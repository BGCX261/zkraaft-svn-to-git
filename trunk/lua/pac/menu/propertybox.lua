local PANEL = vgui.Register( "PACPropertyBox", { }, "DCollapsibleCategory" );

PAC_PROPERTY_SLIDER			= 1;
PAC_PROPERTY_BUTTON			= 2;
PAC_PROPERTY_CHECKBOX		= 3;
PAC_PROPERTY_TEXTENTRY		= 4;
PAC_PROPERTY_CHOICE			= 5;
PAC_PROPERTY_SORTEDCHOICE 	= 6
PAC_PROPERTY_COLOR			= 7;
PAC_PROPERTY_MATERIAL		= 8;

//----------------------------------------------------------------------------------------
//	Purpose: initializes the propertybox
//----------------------------------------------------------------------------------------
function PANEL:Init( )
	
	self.Contents = vgui.Create( "DPanelList" );
	self.Contents:SetSpacing( PAC.Spacing );
	self.Contents:SetPadding( PAC.Spacing );
	self.Contents:SetAutoSize( true );
	
	self:SetContents( self.Contents );
	
end

//----------------------------------------------------------------------------------------
//	Purpose: adds a property to the box
//----------------------------------------------------------------------------------------
function PANEL:AddProperty( property, title, change, extra, convar, decimals )
	
	local control;
	
	if( property == PAC_PROPERTY_SLIDER ) then
		
		control = vgui.Create( "PACSlider" );
		control:SetText( title );
		
		control:SetDecimals( decimals or control:GetDecimals() )
		
		control.SetValueReal = control.SetValue;
		control.SetValue = function( control, value )
			
			control:SetValueReal( value );
			
			control:InvalidateLayout( );
			
		end
		
		if( change ) then
			
			control.OnValueChanged = change;
			
			control.Wang.TextEntry.OnEnter = function( entry )
				
				control:OnValueChanged( control:GetValue( ) );
				
				control:InvalidateLayout( );
				
			end
			
		end
		
		if( #extra > 0 ) then control:SetMinMax( unpack( extra ) ); end
		
		if( convar ) then control:SetConVar( convar ); end
		
		self.Contents:AddItem( control );
		
	elseif( property == PAC_PROPERTY_BUTTON ) then
		
		control = vgui.Create( "DButton" );
		control:SetText( title );
		
		control.DoClick = change;
		
		self.Contents:AddItem( control );
		
	elseif( property == PAC_PROPERTY_CHECKBOX ) then
		
		control = vgui.Create( "DCheckBoxLabel" );
		control:SetText( title );
		
		if( change ) then control.OnChange = change; end
		if( convar ) then control:SetConVar( convar ); end
		
		self.Contents:AddItem( control );
		
	elseif( property == PAC_PROPERTY_TEXTENTRY ) then
		
		local label = vgui.Create( "DLabel" );
		label:SetText( title );
		label:SizeToContents( );
		
		control = vgui.Create( "DTextEntry" );
		control.TitleLabel = label;
		
		control.OnEnter = change;
		
		self.Contents:AddItem( control.TitleLabel );
		self.Contents:AddItem( control );
		
	elseif( property == PAC_PROPERTY_CHOICE ) then
		
		local label = vgui.Create( "DLabel" );
		label:SetText( title );
		label:SizeToContents( );
		
		control = vgui.Create( "DMultiChoice" );
		control.TitleLabel = label;
		
		if( change ) then control.OnSelect = change; end
		
		if( convar ) then control:SetConVar( convar ); end
		
		if( #extra > 0 ) then
			
			for i, choice in pairs( extra ) do control:AddChoice( choice ); end
			
		end
		
		self.Contents:AddItem( control.TitleLabel );
		self.Contents:AddItem( control );
	
	elseif( property == PAC_PROPERTY_SORTEDCHOICE ) then
		
		local label = vgui.Create( "DLabel" );
		label:SetText( title );
		label:SizeToContents( );
		
		control = vgui.Create( "PACChoice" );
		control.TitleLabel = label;
		
		if( change ) then control.OnSelect = change; end
		
		if( convar ) then control:SetConVar( convar ); end
		
		if( #extra > 0 ) then
			
			for i, choice in pairs( extra ) do control:AddChoice( choice ); end
			
		end
		
		self.Contents:AddItem( control.TitleLabel );
		self.Contents:AddItem( control );
		
	elseif( property == PAC_PROPERTY_COLOR ) then
		
		local label = vgui.Create( "DLabel" );
		label:SetText( title );
		label:SizeToContents( );
		
		control = vgui.Create( "PACColorBox" );
		control.TitleLabel = label;
		
		control.ColorChanged = change;
		
		if( #extra > 0 ) then control:SetColor( extra[ 1 ] ); end
		if( #extra > 1 ) then control:SetChangeAlpha( extra[ 2 ] ); end
		
		self.Contents:AddItem( control.TitleLabel );
		self.Contents:AddItem( control );
		
	elseif( property == PAC_PROPERTY_MATERIAL ) then
		
		control = vgui.Create( "PACMatSelect" );
		control:SetText( title );
		control.MaterialChanged = change;
		
		if( #extra > 0 ) then control:SetMaterialList( extra[ 1 ] ); end
		
		self.Contents:AddItem( control );
		
		
	end
	
	return control;
	
end