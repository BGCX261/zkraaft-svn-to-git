PAC.Spacing = 2;

//----------------------------------------------------------------------------------------
//	Purpose: changes a convar
//----------------------------------------------------------------------------------------
function PAC.ChangeConVar( name, value )
	
	if( !ConVarExists( name ) ) then return; end
	
	RunConsoleCommand( name, tostring( value ) );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.Notify( message, title )
	
	Derma_Message( message, title or "Notification", "Okay" );
	
end

//----------------------------------------------------------------------------------------
//	Purpose: gets the editor instance or creates it if it doesn't exist
//----------------------------------------------------------------------------------------
function PAC.GetEditorInstance( )
	
	if PAC.Editor then return PAC.Editor end
	
	PAC.Editor = vgui.Create( "PACEditor" )
	PAC.Editor:SetVisible(false)

	return PAC.Editor
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.RefreshPartList( )
	
	local editor=PAC.GetEditorInstance( )
	
	editor.Parts:Refresh( );
	
	PAC.Editor.Parts:SetCurrentPart( PAC.CurrentPart, true );
		
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.SetCurrentPart( part )
	
	PAC.CurrentPart = part;
	
	PAC.ResetProperties( part );
	
	local editor=PAC.GetEditorInstance( )
	editor.Parts:SetCurrentPart( part, true );
	editor.Properties:Refresh( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.AddNewPart( existing, random, skipnorm, model )
	
	local config = LocalPlayer( ):GetPACConfig( );
	if( !config ) then return; end
	
	local name, part = PAC.GetNewUniqueName( );
	
	if( existing ) then
		
		part = config:AddPart( name, existing );
		
	else part = config:AddPart( name, nil, "head" ); end
	
	local names = {}
	
	for friendly, unfriendly in pairs(PAC.BoneList) do
		table.insert(names, friendly)
	end
	
	if random then
		part:SetBone(table.Random(names))
		part:SetModel(table.Random(table.Random(spawnmenu.GetPropTable())))
	end
	
	if model then
		part:SetModel(model)
	end
	PAC.ApplyConfig( LocalPlayer( ), config );
	
	PAC.RefreshPartList( );
	
	if( !existing ) then PAC.SetCurrentPart( part ); end
	
	--if not skipnorm and GetConVar("pac_auto_normalize"):GetBool() then PAC.NormalizeCurrentPart() end
	
	return part
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.AddNewBone( )
	
	local config = LocalPlayer( ):GetPACConfig( );
	if( !config ) then return; end
	
	local bonename;
	
	for nice, name in pairs( PAC.BoneList ) do
		
		if( !config.bones[ nice ] ) then
			
			bonename = nice;
			
			break;
			
		end
		
	end
	
	if( !bonename ) then PAC.Notify( "Cannot create bone" ); return; end
	
	PAC.SetCurrentPart( config:SetBone( bonename, nil, nil, nil ) );
	
	PAC.ApplyConfig( LocalPlayer( ), config );
	
	PAC.RefreshPartList( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.RemovePart( to )
	
	local config, removed, index = LocalPlayer( ):GetPACConfig( );
	
	local contents = PAC.IsBoneObject( to ) and config.bones or config.parts;
	
	for i, data in pairs( contents ) do
		
		if( contents == config.bones ) then
			
			if( data == to ) then
				
				config.bones[ i ] = nil;
				
				removed = true;
				
			elseif( removed ) then
				
				PAC.SetCurrentPart( data );
				
				break;
				
			end
			
		else
			
			if( data == to ) then
				
				table.remove( contents, i );
				
				if( to == PAC.CurrentPart ) then
					
					PAC.SetCurrentPart( contents[ i ] or contents[ i - 1 ] );
					
				end
				
			end
			
		end
		
	end
	
	PAC.ApplyConfig( LocalPlayer( ), config );
	
	PAC.RefreshPartList( );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.ReApplyConfig( )
	
	PAC.ApplyConfig( LocalPlayer( ), LocalPlayer( ):GetPACConfig( ) );
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.GetBoneName( bone )
	
	local config = LocalPlayer( ):GetPACConfig( );
	if( !config ) then return; end
	
	for name, data in pairs( config.bones ) do
		
		if( data == bone ) then return name; end
		
	end
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.PartNameExists( name )
	
	local config = LocalPlayer( ):GetPACConfig( );
	if( !config ) then return; end
	
	if( config.bones[ name ] ) then return true, config.bones[ name ]; end
	
	for i, part in pairs( config.parts ) do
		
		if( part.name == name ) then return true, part; end
		
	end
	
	return false;
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PAC.GetNewUniqueName( part )
	
	if( part && PAC.IsBoneObject( part ) ) then return PAC.GetBoneName( part ); end
	
	local config = LocalPlayer( ):GetPACConfig( );
	if( !config ) then return "ERROR"; end
	
	local count	= math.max( #config.parts + #config.bones, 1 );
	local name	= "Part "..count;
	
	while( PAC.PartNameExists( name ) ) do
		
		count = count + 1;
		name = "Part "..count;
		
	end
	
	return name;
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//	Notes: stolen from garry
//----------------------------------------------------------------------------------------
function HighlightedButtonPaint( self )

	surface.SetDrawColor( 255, 200, 0, 255 );
	
	for i = 2, 3 do
		
		surface.DrawOutlinedRect( i, i, self:GetWide( ) - i * 2, self:GetTall( ) - i * 2 );
		
	end

end


//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
local function InitPostEntity( )
	
	PAC.ResetProperties( );
	
end
hook.Add( "InitPostEntity", "PAC.ResetProperties", InitPostEntity );

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
local function PACConfigApplied( pl, config )
	
	if( pl != LocalPlayer( ) ) then return; end
	
	local lastpart = PAC.LastPartSelected 
	if lastpart then
		for key, part in pairs(config.parts) do
			if lastpart == part.name then
				PAC.SetCurrentPart(part)
				PAC.LastPartSelected = nil
				break
			end
		end
	else	
		PAC.SetCurrentPart( );
	end
	PAC.RefreshPartList( );
	
	
	
end
hook.Add( "PACConfigApplied", "PAC.RefreshEditor", PACConfigApplied );