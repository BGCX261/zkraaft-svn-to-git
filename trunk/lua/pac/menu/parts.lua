local PANEL = vgui.Register( "PACParts", { }, "DPanelList" );

AccessorFunc( PANEL, "m_Selected", "Selected" );

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Init( )
	
	self:SetTall( 66 );
	
	self:EnableHorizontal( true );
	self:EnableVerticalScrollbar( true );
	self:SetPadding( 1 );
	self:SetSpacing( 1 );
	local material = Material("models/debug/debugwhite")
	local ring = Material("particle/particle_Ring_Sharp")
	hook.Add("PostDrawTranslucentRenderables", "PAC.Highlight", function()
		local entity = self.highlight
		if IsValid(entity) then	
			entity:SetNoDraw(true)
			cam.IgnoreZ(true)
				render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(true)
						SetMaterialOverride(material)
							local frame = CurTime()*10
							render.SetBlend(math.abs(math.Round(frame*0.5) - frame*0.5)*2/5)
								entity:DrawModel()
							render.SetBlend(0)
						SetMaterialOverride(0)
					render.SuppressEngineLighting(false)
				render.SetColorModulation(1,1,1)
				
				
				if entity:GetModelScale():Length() < 0.2 then
					render.SetMaterial(ring)
					render.DrawSprite(entity:GetPos(), 8,8,color_white)
				end
				
			cam.IgnoreZ(false)
		end
	end)
	
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:Refresh( )
	
	self:Clear( true );
	
	local config = LocalPlayer( ):GetPACConfig( );
	if( !config ) then return; end
	
	// TODO: add the new icons, remove the old ones and change the existing instead of recreating everything
	
	local function AddIcon( data, isbone )
		
		local tooltip;
		
		if( PAC.IsBoneObject( data ) ) then
			
			tooltip = "Bone: "..PAC.GetBoneName( data );
			
		else tooltip = "Name: "..data.name.."\nModel: "..data.model.."\nBone: "..data.bone end
		
		local icon = vgui.Create( "SpawnIcon" );
		icon:SetModel( isbone and "models/Gibs/HGIBS_spine.mdl" or (data.model and file.Exists("../"..data.model)) and data.model or "models/error.mdl" );
		icon:SetIconSize( 64 );
		icon:InvalidateLayout( true );
		icon:SetToolTip( tooltip );
		icon.Data = data;
				
		icon.OnCursorEntered = function() 
			local tbl = PAC.ActiveEnts[LocalPlayer():UniqueID()]
			if not tbl then return end
			for key, entity in pairs(tbl) do
				if entity.name == data.name then
					self.highlight = entity
				end
			end
		end
		
		icon.OnCursorExited = function()
			self.highlight = nil
		end
		
		icon.DoClick = function( icon ) PAC.SetCurrentPart( icon.Data ); end
		
		icon.OpenMenu = function( icon )
			
			local menu = DermaMenu();
			
			if( PAC.IsPartObject( icon.Data ) ) then
				
				menu:AddOption( "Clone", function( ) PAC.SetCurrentPart(PAC.AddNewPart( icon.Data, nil, true )) end );
				
				menu:AddSpacer( );
				
			end
			
			menu:AddOption( "Remove", function( ) PAC.RemovePart( icon.Data ); end );
			
			menu:Open( );
			
		end
		
		self:AddItem( icon );
		
	end
	
	local property = PAC.GetPropertyInfo( "General", "Parent" )
		
	property.Control:Clear()
		
	for i, part in pairs( config.parts ) do 
		AddIcon( part )
		--if PAC.CurrentPart and part.name ~= PAC.CurrentPart.name then
			property.Control:AddChoice(part.name)
		--end
	end
	
	for i, bone in pairs( config.bones ) do AddIcon( bone, true ); end
	
	self:PerformLayout()
end

//----------------------------------------------------------------------------------------
//	Purpose:
//----------------------------------------------------------------------------------------
function PANEL:SetCurrentPart( data, refresh )
	
	self:SetSelected( data );
	
	if( !refresh ) then return; end
	
	for i, panel in pairs( self:GetItems( ) ) do
		
		if( IsValid( panel ) ) then
			
			panel.PaintOver = panel.Data == data and HighlightedButtonPaint or nil;
			
		end
		
	end
	
	self:PerformLayout()
end