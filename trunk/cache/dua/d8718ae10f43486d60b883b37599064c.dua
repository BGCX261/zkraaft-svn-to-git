local playermodels = {}
for name, path in pairs(player_manager.AllValidModels()) do
	table.insert(playermodels, name)
end

table.sort(playermodels)

--[[ local cv_normalize = CreateClientConVar("pac_auto_normalize", 1, true)
local cv_normalize_size = CreateClientConVar("pac_normalize_size", 8, true)

function PAC.NormalizeCurrentPart()
	local tbl = PAC.ActiveEnts[LocalPlayer():UniqueID()]
	if not tbl then return end
	for key, entity in pairs(tbl) do
		if entity.name == PAC.CurrentPart.name then
			local value = PAC.GetPropertyInfo( "Scale", "NormalizeSize" ).Control:GetValue()
			local size = (value ~= 0 and value or 8) / entity:BoundingRadius()
			PAC.CurrentPart:SetSize(size)
			PAC.GetPropertyInfo( "Scale", "Scale" ).Control:SetValue(size)
			break
		end
	end
end ]]

PAC.PropertyInfo =
{
	//----------------------------- general -----------------------------
	{
		Name = "Preview",
		Type = PAC_PROPTYPE_PREVIEW,
		Properties =
		{
			{
				Name = "Sensitivity",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Sensitivity:",
				Extra = { 0, 2 },
				ConVar = "pac_preview_sensitivity"
			},
			{
				Name = "Bone",
				Type = PAC_PROPERTY_CHOICE,
				Title = "Center on:",
				ConVar = "pac_preview_bone",
				Extra = { "Player", unpack( PAC.EditorBoneNames ) }
			},
			{
				Name = "TPose",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enable T pose",
				ConVar = "pac_preview_tpose"
			},
			{
				Name = "Trace",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enable Trace Block",
				ConVar = "pac_preview_trace"
			},
			{
				Name = "AutoFocus",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enable Bone Focus",
				ConVar = "pac_preview_autofocus"
			},
			{
				Name = "AutoFocusEntity",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enable Entity Focus",
				ConVar = "pac_preview_autofocus_entity"
			},
			{
				Name = "FullBrightMode",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enable Fullbright",
				Change = function(_, bool)
					if bool then
						PAC.FullBrightMode = true
					else
						PAC.FullbrightMode = false
					end
				end,
			},
			{
				Name = "ResetEyeAngles",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset Eye Angles",
				Change = function( control ) LocalPlayer():SetEyeAngles(Angle(0,0,0)) end
			}
		}
	},
	{
		Name = "Creation",
		Type = PAC_PROPTYPE_GENERAL,
		Properties =
		{
			{
				Name = "AddPart",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Part",
				Change = function( control )
					PAC.AddNewPart( )
					PAC.GetPropertyInfo("Bones", "Reset").Change()
				end
			},
			{
				Name = "Random",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Random Part",
				Change = function( control ) PAC.AddNewPart(nil, true) end
			},
--[[ 			{
				Name = "Normalize",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Auto Normalize",
				ConVar = "pac_auto_normalize"
			}, ]]
			{
				Name = "AddBone",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Bone",
				Change = function( control ) PAC.AddNewBone( ); end
			},
			{
				Name = "Clear",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Clear",
				Change = function( control )

					LocalPlayer():SetPACConfig{}

					PAC.SetCurrentPart( nil );
					PAC.RefreshPartList( );

				end
			}
		}
	},
	{
		Name = "Player",
		Type = PAC_PROPTYPE_GENERAL,
		Properties =
		{
			{
				Name = "DrawWeapon",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Draw Weapon:",
				Change = function( control, value )

					if( !LocalPlayer( ):GetPACConfig( ) ) then return; end

					LocalPlayer( ):GetPACConfig( ):SetDrawWeapon( value );
					
					PAC.ReApplyConfig()

				end,
				Reset = function( control, data ) control:SetValue( not data and true or data:GetDrawWeapon( ) ); end
			},
			{
				Name = "Model",
				Type = PAC_PROPERTY_SORTEDCHOICE,
				Title = "Player Model:",
				Extra = playermodels,
				Change = function( control, value )

					if( not LocalPlayer():GetPACConfig() || PAC.IsBoneObject( PAC.CurrentPart ) ) then control:SetText( "" ) return; end

					LocalPlayer():GetPACConfig():SetPlayerModel(value)

				end,
				Reset = function( control, data )

					if( not LocalPlayer():GetPACConfig() || PAC.IsBoneObject( PAC.CurrentPart ) ) then control:SetText( "" ) return; end

					control:ChooseOption( LocalPlayer():GetPACConfig():GetPlayerModel() or "" );

				end
			},
		}
	},
	{
		Name = "Scale",
		Type = PAC_PROPTYPE_GENERAL,
		Properties =
		{
			{
				Name = "Scale",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Scale:",
				Extra = { 0, 5 },
				Change = function( control, value )

					local p = PAC.GetPropertyInfo( "Scale", "X", false );
					local y = PAC.GetPropertyInfo( "Scale", "Y", false );
					local r = PAC.GetPropertyInfo( "Scale", "Z", false );

					p.Control:SetValue( value );
					y.Control:SetValue( value );
					r.Control:SetValue( value );

					PAC.UpdatePlayerScale()

				end,
				// hacking my own system..
				ResetThis = function( control, data ) control:SetValue( 1 ); end
			},
			{
				Name = "X",
				Type = PAC_PROPERTY_SLIDER,
				Title = "X:",
				Extra = { 0, 5 },
				Change = function( control, value )

					if( !LocalPlayer( ):GetPACConfig( ) ) then return; end

					LocalPlayer( ):GetPACConfig( ).overall_scale.x = tonumber( value );

					PAC.UpdatePlayerScale()

				end,
				Reset = function( control, data ) control:SetValue( data and data.overall_scale.x or 0 ); end
			},
			{
				Name = "Y",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Y:",
				Extra = { 0, 5 },
				Change = function( control, value )

					if( !LocalPlayer( ):GetPACConfig( ) ) then return; end

					LocalPlayer( ):GetPACConfig( ).overall_scale.y = tonumber( value );

					PAC.UpdatePlayerScale()

				end,
				Reset = function( control, data ) control:SetValue( data and data.overall_scale.y or 0 ); end
			},
			{
				Name = "Z",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Z:",
				Extra = { 0, 5 },
				Change = function( control, value )

					if( !LocalPlayer( ):GetPACConfig( ) ) then return; end

					LocalPlayer( ):GetPACConfig( ).overall_scale.z = tonumber( value );

					PAC.UpdatePlayerScale()

				end,
				Reset = function( control, data ) control:SetValue( data and data.overall_scale.z or 0 ); end
			},
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control, value )

					local scale = PAC.GetPropertyInfo( "Scale", "Scale", false );

					scale.ResetThis( scale.Control );

					PAC.UpdatePlayerScale()

				end
			}
		}
	},
	{
		Name = "Outfit Scale",
		Type = PAC_PROPTYPE_GENERAL,
		Properties =
		{
			{
				Name = "Multiplier",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Multiplier:",
				Extra = { 0, 5 },
				Change = function( control, scale )
					PAC.GlobalOutfitScale = scale
				end,
				Reset = function( control )
					control:SetValue(1)
				end,
			},
			{
				Name = "Scale",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Scale",
				Change = function( control )

					if PAC.GlobalOutfitScale then
						local c = LocalPlayer():GetPACConfig()
						local scale = PAC.GlobalOutfitScale

						if not c then return end
						if scale == 0 then return end

						c.overall_scale = c.overall_scale * scale

						for key, value in pairs(c.parts) do
							value.scale = value.scale * scale
							value.offset = value.offset * scale
							value.clip.distance = value.clip.distance * scale
							value.sprite.x = value.sprite.x * scale
							value.sprite.y = value.sprite.y * scale
							value.text.size = value.text.size * scale
						end

						PAC.ReApplyConfig()
					end

				end
			}

		}
	},
	{
		Name = "HSV",
		Type = PAC_PROPTYPE_GENERAL,
		Properties =
		{
			{
				Name = "Hue",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Hue:",
				Extra = { 0, 360 },
				Change = function( control, value )
					for key, part in pairs(LocalPlayer():GetPACConfig().parts) do
						part:SetHue(value)
					end
				end,
				Reset = function( control, data ) control:SetValue( data.hue ) end
			},
			{
				Name = "Sat",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Saturation:",
				Extra = { 0, 5 },
				Change = function( control, value )
					for key, part in pairs(LocalPlayer():GetPACConfig().parts) do
						part:SetSaturation(value)
					end
				end,
				Reset = function( control, data ) control:SetValue( data.saturation or 1 ) end
			},
			{
				Name = "Val",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Brightness:",
				Extra = { 0, 5 },
				Change = function( control, value )
					for key, part in pairs(LocalPlayer():GetPACConfig().parts) do
						part:SetBrightness(value ^ 10)
					end
				end,
				Reset = function( control, data ) control:SetValue( data.brightness or 1 ) end
			},
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control, value )

					PAC.GetPropertyInfo( "HSV", "Hue", false ).Control:SetValue(0)
					PAC.GetPropertyInfo( "HSV", "Sat", false ).Control:SetValue(1)
					PAC.GetPropertyInfo( "HSV", "Val", false ).Control:SetValue(1)

				end
			}
		}
	},
	{
		Name = "Color",
		Type = PAC_PROPTYPE_GENERAL,
		Properties =
		{
			{
				Name = "Box",
				Type = PAC_PROPERTY_COLOR,
				Title = "Color:",
				Change = function( control, value )

					if( !LocalPlayer( ):GetPACConfig( ) ) then return; end

					LocalPlayer( ):GetPACConfig( ):SetPlayerColor( value );



				end,
				Reset = function( control, data ) control:SetColor( data and data:GetPlayerColor( ) or color_white ); end
			},
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control )

					local box = PAC.GetPropertyInfo( "Color", "Box", false );

					box.Control:SetColor( color_white );

				end
			}
		}
	},
	{
		Name = "Material",
		Type = PAC_PROPTYPE_GENERAL,
		Properties =
		{
			{
				Name = "Material",
				Type = PAC_PROPERTY_MATERIAL,
				Title = "Reset",
				Change = function( control, value )

					if( !LocalPlayer( ):GetPACConfig( ) ) then return; end

					LocalPlayer( ):GetPACConfig( ):SetPlayerMaterial( value );

					PAC.ReApplyConfig()

				end,
				Reset = function( control, data ) control:SetSelected( data and data:GetPlayerMaterial( ) or "" ); end
			},
--[[ 			{
				Name = "Box",
				Type = PAC_PROPERTY_COLOR,
				Title = "Color:",
				Change = function( control, value )

					if( !LocalPlayer( ):GetPACConfig( ) ) then return; end

					LocalPlayer( ):GetPACConfig( ):SetPlayerMaterialColor( value );



				end,
				Reset = function( control, data ) control:SetColor( data and data:GetPlayerMaterialColor( ) or color_white ); end
			},
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control )

					local box = PAC.GetPropertyInfo( "Material", "Box", false );

					box.Control:SetColor( color_white );

				end
			} ]]
		}
	},
	//----------------------------- part -----------------------------
	{
		Name = "General",
		Type = PAC_PROPTYPE_BONE,
		Properties =
		{
			{
				Name = "Name",
				Type = PAC_PROPERTY_TEXTENTRY,
				Title = "Name:",
				Change = function( control )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					local exists, part = PAC.PartNameExists( control:GetValue( ) );

					if( exists ) then

						if( part == PAC.CurrentPart ) then return; end

						PAC.Notify( "This name is taken" );

						control:SetValue( PAC.CurrentPart:GetName( ) );

						return;

					else PAC.CurrentPart:SetName( control:GetValue( ) ); end

					PAC.RefreshPartList( );

				end,
				Reset = function( control, data ) control:SetValue( data and ( data.name or PAC.GetBoneName( data ) ) or "" ); end
			},
			{
				Name = "Model",
				Type = PAC_PROPERTY_TEXTENTRY,
				Title = "Model:",
				Change = function( control )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					for key, part in pairs( LocalPlayer( ):GetPACConfig( ).parts ) do

						if( part.model == control:GetValue( ) && part == PAC.CurrentPart ) then return; end

					end

					PAC.CurrentPart:SetModel( control:GetValue( ) );

--[[ 					if cv_normalize:GetBool() then
						PAC.NormalizeCurrentPart()
					end ]]

					PAC.ReApplyConfig()

					PAC.RefreshPartList( );

					PAC.GetPropertyInfo("Bones", "Reset").Change()
				end,
				Reset = function( control, data ) control:SetValue( data and ( data.model or "" ) or "" ); end
			},
			{
				Name = "FixModelOrigin",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Fix Origin",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.originfix = value;
					
				end,
				Reset = function( control, data )

					if( !data || data.originfix == nil ) then control:SetChecked( false ); return; end

					control:SetValue( data.originfix );

				end
			},
			{
				Name = "Bone",
				Type = PAC_PROPERTY_SORTEDCHOICE,
				Title = "Attach to:",
				Extra = PAC.EditorBoneNames,
				Change = function( control, value )

					if( !PAC.CurrentPart ) then control:SetText( "" ); return; end

					if( PAC.IsBoneObject( PAC.CurrentPart ) ) then

						local config = LocalPlayer( ):GetPACConfig( );
						if( !config ) then return; end

						if( config.bones[ value ] ) then

							if( config.bones[ value ] == PAC.CurrentPart ) then return; end

							PAC.Notify( "This bone is taken" );

							control:SetText( value );

							return;

						else

							config.bones[ PAC.GetBoneName( PAC.CurrentPart ) ] = nil;
							config.bones[ value ] = PAC.CurrentPart;

						end

					else

						if( PAC.CurrentPart.bone == value ) then return; end

						PAC.CurrentPart:SetBone( value );

					end


					PAC.RefreshPartList( );

				end,
				Reset = function( control, data )

					if( !data ) then control:SetText( "" ); return; end

					local bonename = data.bone or PAC.GetBoneName( data );

					control:SetText(bonename)

				end
			},
			{
				Name = "WeaponClass",
				Type = PAC_PROPERTY_TEXTENTRY,
				Title = "Weapon Class:",
				Change = function( control )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then control:SetText( "" ) return; end

					PAC.CurrentPart:SetWeaponClass(control:GetValue())
					
					PAC.ReApplyConfig()
				end,
				Reset = function( control, data )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then control:SetText( "" ) return; end

					control:SetText( data.weaponclass or "" );

				end
			},
			{
				Name = "HideWeaponClass",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Hide Weapon Class",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.hideweaponclass = value;
									
					PAC.ReApplyConfig()
					
				end,
				Reset = function( control, data )
					control:SetValue( data and type(data.hideweaponclass) == "boolean" and data.hideweaponclass == true or nil )
				end
			},
			{
				Name = "Parent",
				Type = PAC_PROPERTY_SORTEDCHOICE,
				Title = "Parent to:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then control:SetText( "" ) return; end

					if value == PAC.CurrentPart.name then
						PAC.Notify( "Cannot parent to self" )
						timer.Simple(0.1, function() PAC.GetPropertyInfo("General", "UnParent").Control:DoClick() end) -- uh
						return
					end

					PAC.CurrentPart:SetParent(value)

					PAC.ReApplyConfig()

				end,
				Reset = function( control, data )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then control:SetText( "" ) return; end

					control:SetText( data.parent or "" );

				end
			},
			{
				Name = "UnParent",
				Type = PAC_PROPERTY_BUTTON,
				Title = "UnParent",
				Change = function( control, value )

					if( not PAC.CurrentPart ) then return; end

					PAC.CurrentPart:SetParent()

					PAC.ReApplyConfig()

					PAC.GetPropertyInfo( "General", "Parent" ).Control:SetText("")

				end,
			},
		}
	},
	{
		Name = "Offset",
		Type = PAC_PROPTYPE_BONE,
		Properties =
		{
			{
				Name = "X",
				Type = PAC_PROPERTY_SLIDER,
				Title = "X:",
				Extra = { -250, 250 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.offset.x = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.offset.x or 0 ); end
			},
			{
				Name = "Y",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Y:",
				Extra = { -250, 250 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.offset.y = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.offset.y or 0 ); end
			},
			{
				Name = "Z",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Z:",
				Extra = { -250, 250 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.offset.z = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.offset.z or 0 ); end
			},
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control, value )

					local x = PAC.GetPropertyInfo( "Offset", "X" );
					local y = PAC.GetPropertyInfo( "Offset", "Y" );
					local z = PAC.GetPropertyInfo( "Offset", "Z" );

					x.Control:SetValue( 0 );
					y.Control:SetValue( 0 );
					z.Control:SetValue( 0 );

				end
			}
		}
	},
	{
		Name = "Angle",
		Type = PAC_PROPTYPE_BONE,
		Properties =
		{
			{
				Name = "P",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Pitch:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.angles.p = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.angles.p or 0 ); end
			},
			{
				Name = "Y",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Yaw:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.angles.y = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.angles.y or 0 ); end
			},
			{
				Name = "R",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Roll:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.angles.r = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.angles.r or 0 ); end
			},
--[[ 			{
				Name = "WP",
				Type = PAC_PROPERTY_SLIDER,
				Title = "WPitch:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart or PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.worldangles.r = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.worldangles and data.worldangles.r or 0 ); end
			},
			{
				Name = "WY",
				Type = PAC_PROPERTY_SLIDER,
				Title = "WYaw:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart or PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.worldangles.y = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.worldangles and data.worldangles.y or 0 ); end
			},
			{
				Name = "WR",
				Type = PAC_PROPERTY_SLIDER,
				Title = "WRoll:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart or PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.worldangles.r = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.worldangles and data.worldangles.r or 0 ); end
			}, ]]
			{
				Name = "PVelocity",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Pitch Velocity:",
				Extra = { -100, 100 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.anglevelocity.p = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.anglevelocity and data.anglevelocity.p or 0 ); end
			},
			{
				Name = "YVelocity",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Yaw Velocity:",
				Extra = { -100, 100 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.anglevelocity.y = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.anglevelocity and data.anglevelocity.y or 0 ); end
			},
			{
				Name = "RVelocity",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Roll Velocity:",
				Extra = { -100, 100 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.anglevelocity.r = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.anglevelocity and data.anglevelocity.r or 0 ); end
			},
			{
				Name = "EyeAngles",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Follow EyeAngles:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:FollowEyeAngles(tobool(value))

				end,
				Reset = function( control, data ) control:SetValue( not data and false or PAC.CurrentPart.eyeangles ); end
			},
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control, value )

					local p = PAC.GetPropertyInfo( "Angle", "P" );
					local y = PAC.GetPropertyInfo( "Angle", "Y" );
					local r = PAC.GetPropertyInfo( "Angle", "R" );

--[[ 					local wp = PAC.GetPropertyInfo( "Angle", "WP" );
					local wy = PAC.GetPropertyInfo( "Angle", "WY" );
					local wr = PAC.GetPropertyInfo( "Angle", "WR" ); ]]

					local pv = PAC.GetPropertyInfo( "Angle", "PVelocity" );
					local yv = PAC.GetPropertyInfo( "Angle", "YVelocity" );
					local rv = PAC.GetPropertyInfo( "Angle", "RVelocity" );

					p.Control:SetValue( 0 );
					y.Control:SetValue( 0 );
					r.Control:SetValue( 0 );

--[[ 					wp.Control:SetValue( 0 );
					wy.Control:SetValue( 0 );
					wr.Control:SetValue( 0 ); ]]

					pv.Control:SetValue( 0 );
					yv.Control:SetValue( 0 );
					rv.Control:SetValue( 0 );

				end
			}
		}
	},
	{
		Name = "Scale",
		Type = PAC_PROPTYPE_BONE,
		Properties =
		{
			{
				Name = "Scale",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Scale:",
				Extra = { 0, 10 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart:SetSize( tonumber( value ) );

				end,
				Reset = function( control, data ) control:SetValue( data and data:GetSize( ) or 1 ); end
			},
			{
				Name = "X",
				Type = PAC_PROPERTY_SLIDER,
				Title = "X:",
				Extra = { -10, 10 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.scale.x = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.scale.x or 1 ); end
			},
			{
				Name = "Y",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Y:",
				Extra = { -10, 10 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.scale.y = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.scale.y or 1 ); end
			},
			{
				Name = "Z",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Z:",
				Extra = { -10, 10 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.scale.z = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.scale.z or 1 ); end
			},
--[[ 			{
				Name = "NormalizeSize",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Norm Size:",
				Extra = { -50, 50 },
				ConVar = "pac_normalize_size"
			}, ]]
--[[ 			{
				Name = "Normalize",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Normalize",
				Change = function( control, value )
					PAC.NormalizeCurrentPart()
				end
			}, ]]
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control )

					local scale = PAC.GetPropertyInfo( "Scale", "Scale" );
					local x = PAC.GetPropertyInfo( "Scale", "X" );
					local y = PAC.GetPropertyInfo( "Scale", "Y" );
					local z = PAC.GetPropertyInfo( "Scale", "Z" );

					scale.Control:SetValue( 1 );
					x.Control:SetValue( 1 );
					y.Control:SetValue( 1 );
					z.Control:SetValue( 1 );

				end
			}
		}
	},
	{
		Name = "Bones",
		Properties =
		{
			{
				Name = "Enabled",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enabled",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.modelbones.Enabled = value;

					PAC.ReApplyConfig( )

				end,
				Reset = function( control, data )

					if( !data || !data.modelbones ) then control:SetChecked( false ); return; end

					control:SetValue( data.modelbones.Enabled );

				end
			},
			{
				Name = "Bone",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Bone:",
				Extra = { 0, 30 },
				Decimals = 0,
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					value = math.Round(value)
					PAC.CurrentModelBoneIndex = value

					if not PAC.CurrentPart.modelbones.bones[value] then return end

					control:SetMinMax(0, #PAC.CurrentPart.modelbones.bones)

					local scale = PAC.CurrentPart.modelbones.bones[value].scale
					PAC.GetPropertyInfo("Bones", "SX").Control:SetValue(scale.x)
					PAC.GetPropertyInfo("Bones", "SY").Control:SetValue(scale.y)
					PAC.GetPropertyInfo("Bones", "SZ").Control:SetValue(scale.z)

					local offset = PAC.CurrentPart.modelbones.bones[value].offset
					PAC.GetPropertyInfo("Bones", "X").Control:SetValue(offset.x)
					PAC.GetPropertyInfo("Bones", "Y").Control:SetValue(offset.y)
					PAC.GetPropertyInfo("Bones", "Z").Control:SetValue(offset.z)

					local angles = PAC.CurrentPart.modelbones.bones[value].angles
					PAC.GetPropertyInfo("Bones", "Pitch").Control:SetValue(angles.p)
					PAC.GetPropertyInfo("Bones", "Yaw").Control:SetValue(angles.y)
					PAC.GetPropertyInfo("Bones", "Roll").Control:SetValue(angles.r)

					PAC.GetPropertyInfo("Bones", "Size").Control:SetValue(PAC.CurrentPart.modelbones.bones[value].size)

					local entity = PAC.CurrentEntity

					if IsValid(entity) then
						PAC.GetPropertyInfo("Bones", "Select").Control:SetText(entity:GetBoneName(value))
					end

				end,
				Reset = function(control)
					local entity = PAC.CurrentEntity
					if IsValid(entity) and PAC.CurrentPart and PAC.CurrentPart.modelbones then
						control:SetMinMax(0, #PAC.CurrentPart.modelbones.bones)
					end
				end,
			},
			{
				Name = "Select",
				Type = PAC_PROPERTY_SORTEDCHOICE,
				Title = "Select:",
				Extra = PAC.EditorBoneNames,
				Change = function( control, value )

					local entity = PAC.CurrentEntity
					if IsValid(entity) then
						PAC.GetPropertyInfo("Bones", "Bone").Control:SetValue(entity:LookupBone(value))
					end

				end,
				Reset = function( control, data )

					control:Clear()

					if PAC.IsBoneObject( PAC.CurrentPart ) then return end
					
					local entity = PAC.CurrentEntity
					if not IsValid(entity) or not data then return end

					for index=0, #data.modelbones.bones do
						local name = entity:GetBoneName(index)
						if name ~= "__INVALIDBONE__" then
							control:AddChoice( name )
						end
					end

					control:SetText( entity:GetBoneName(PAC.CurrentModelBoneIndex) )

				end
			},
			{
				Name = "ParentBone",
				Type = PAC_PROPERTY_SORTEDCHOICE,
				Title = "Redirect Parent:",
				Extra = PAC.EditorBoneNames,
				Change = function( control, value )

					if not PAC.CurrentPart then return end

					PAC.CurrentPart.modelbones.redirectparent = value ~= "none" and value

				end,
				Reset = function( control, part )

					control:Clear()

					local entity = PAC.CurrentEntity

					if not IsValid(entity) or not part then return end

					for index=0, #part.modelbones.bones do
						local name = entity:GetBoneName(index)
						if name ~= "__INVALIDBONE__" then
							control:AddChoice( name )
						end
					end

					control:SetText(part.modelbones.redirectparent)

					control:AddChoice( "none" )

				end
			},
            {
				Name = "BoneMerge",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Bone Merge:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.modelbones.merge = value

                    PAC.ReApplyConfig()

				end,
				Reset = function( control, data ) control:SetValue( not data and false or PAC.CurrentPart.modelbones.merge ); end
			},
            {
				Name = "BoneMergeFix",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Fix Fingers:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.modelbones.fixfingers = value

                    PAC.ReApplyConfig()

				end,
				Reset = function( control, data ) control:SetValue( not data and false or PAC.CurrentPart.modelbones.fixfingers ); end
			},
			{
				Name = "OverallSize",
				Type = PAC_PROPERTY_SLIDER,
				Title = "OSize:",
				Extra = { 0, 4 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.overallsize = value

				end,
			},
			{
				Name = "Size",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Size:",
				Extra = { 0, 10 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].size = value

				end,
			},
			{
				Name = "SX",
				Type = PAC_PROPERTY_SLIDER,
				Title = "SX:",
				Extra = { 0, 10 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].scale.x = value

				end,
			},
			{
				Name = "SY",
				Type = PAC_PROPERTY_SLIDER,
				Title = "SY:",
				Extra = { 0, 10 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].scale.y = value

				end,
			},
			{
				Name = "SZ",
				Type = PAC_PROPERTY_SLIDER,
				Title = "SZ:",
				Extra = { 0, 10 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].scale.z = value

				end,
			},
			{
				Name = "X",
				Type = PAC_PROPERTY_SLIDER,
				Title = "X:",
				Extra = { -250, 250 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].offset.x = value

				end,
			},
			{
				Name = "Y",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Y:",
				Extra = { -250, 250 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].offset.y = value

				end,
			},
			{
				Name = "Z",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Z:",
				Extra = { -250, 250 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].offset.z = value

				end,
			},
			{
				Name = "Pitch",
				Type = PAC_PROPERTY_SLIDER,
				Title = "P:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].angles.p = value

				end,
			},
			{
				Name = "Yaw",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Y:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].angles.y = value

				end,
			},
			{
				Name = "Roll",
				Type = PAC_PROPERTY_SLIDER,
				Title = "R:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart ) then return; end

					PAC.CurrentPart.modelbones.bones[PAC.CurrentModelBoneIndex].angles.r = value

				end,
			},
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control, value )

					if PAC.CurrentPart then
						PAC.CurrentPart:SetModelBones{}
						PAC.ReApplyConfig()
					end
					PAC.GetPropertyInfo("Bones", "Bone").Control:SetValue(1)
					PAC.GetPropertyInfo("Bones", "Enabled").Control:SetValue(false)
					PAC.GetPropertyInfo("Bones", "OverallSize").Control:SetValue(1)
				end
			},
		}
	},
	{
		Name = "Clipping",
		Properties =
		{
			{
				Name = "Enabled",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enabled",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.clip.Enabled = value;



				end,
				Reset = function( control, data )

					if( !data || !data.clip ) then control:SetChecked( false ); return; end

					control:SetValue( data.clip.Enabled );

				end
			},
			{
				Name = "Bone",
				Type = PAC_PROPERTY_SORTEDCHOICE,
				Title = "Bone:",
				Extra = PAC.EditorBoneNames,
				Change = function( control, value )

					if not PAC.CurrentPart then return end

					PAC.CurrentPart.clip.bone = value ~= "none" and value

				end,
				Reset = function( control, part )

					local entity = PAC.CurrentEntity

					if not IsValid(entity) or not part then return end

					control:Clear()

					for index=0, #part.modelbones.bones do
						local name = entity:GetBoneName(index)
						if name ~= "__INVALIDBONE__" then
							control:AddChoice( name )
						end

					end

					control:SetText(part.clip.bone)

					control:AddChoice( "none" )

				end
			},
			{
				Name = "Distance",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Distance:",
				Extra = { -500, 500 },
				Change = function( control, value )

					if( !PAC.CurrentPart or not PAC.CurrentPart.clip ) then return; end

					PAC.CurrentPart.clip.distance = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.clip and data.clip.distance or 1 ); end
			},
			{
				Name = "P",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Pitch:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart or not PAC.CurrentPart.clip ) then return; end

					PAC.CurrentPart.clip.angles.p = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.clip and data.clip.angles.p or 0 ); end
			},
			{
				Name = "Y",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Yaw:",
				Extra = { -180, 180 },
				Change = function( control, value )

					if( !PAC.CurrentPart or not PAC.CurrentPart.clip ) then return; end

					PAC.CurrentPart.clip.angles.y = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.clip and data.clip.angles.y or 0 ); end
			},
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control, value )

					local d = PAC.GetPropertyInfo( "Clipping", "Distance" );
					local p = PAC.GetPropertyInfo( "Clipping", "P" );
					local y = PAC.GetPropertyInfo( "Clipping", "Y" );

					d.Control:SetValue( 0 );
					p.Control:SetValue( 0 );
					y.Control:SetValue( 0 );

				end
			}
		}
	},
	{
		Name = "Color",
		Properties =
		{
			{
				Name = "Box",
				Type = PAC_PROPERTY_COLOR,
				Title = "Color:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:SetColor( value );

				end,
				Reset = function( control, data ) control:SetColor( data and data:GetColor( ) or color_white ); end
			},
			{
				Name = "Reset",
				Type = PAC_PROPERTY_BUTTON,
				Title = "Reset",
				Change = function( control )

					local box = PAC.GetPropertyInfo( "Color", "Box" );

					box.Control:SetColor( color_white );

				end
			},
--[[ 			{
				Name = "H",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Hue:",
				Extra = { -360, 360 },
				Change = function( control, value )
				
					local p = PAC.CurrentPart
					
					if p then
						p.hue = value
					end

				end,
				Reset = function( control, part ) control:SetValue( part.hue ) end
			},
			{
				Name = "S",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Saturation:",
				Extra = { -10, 10 },
				Change = function( control, value )

					local p = PAC.CurrentPart
					
					if p then
						p.saturation = value
					end

				end,
				Reset = function( control, part ) control:SetValue( part.saturation ) end
			},
			{
				Name = "V",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Brightness:",
				Extra = { 0, 1000 },
				Change = function( control, value )

					local p = PAC.CurrentPart
					
					if p then
						p.brightness = value
					end

				end,
				Reset = function( control, part ) control:SetValue( part.brightness ) end
			}, ]]
			{
				Name = "RenderFX",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Render FX:",
				Extra = {0, 24},
				Decimals = 0,
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:SetRenderFX(tonumber( value ));

				end,
				Reset = function( control, data ) control:SetValue( data and data.renderfx or 0 ); end
			},
			{
				Name = "RenderMode",
				Type = PAC_PROPERTY_SLIDER,
				Title = "State:",
				Extra = {0, 10},
				Decimals = 0,
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:SetRenderMode(tonumber( value ));

				end,
				Reset = function( control, data ) control:SetValue( data and data.rendermode or 0 ); end
			},
		}
	},
	{
		Name = "Material",
		Properties =
		{
			{
				Name = "Material",
				Type = PAC_PROPERTY_MATERIAL,
				Title = "Reset",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:SetMaterial( value );

					PAC.ReApplyConfig( )

				end,
				Reset = function( control, data ) control:SetSelected( data and data:GetMaterial( ) or "" ); end
			}
		}
	},
	{
		Name = "Light",
		Properties =
		{
			{
				Name = "Enabled",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enabled",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.light.Enabled = value;



				end,
				Reset = function( control, data )

					if( !data || !data.light ) then control:SetChecked( false ); return; end

					control:SetValue( data.light.Enabled );

				end
			},
			{
				Name = "Color",
				Type = PAC_PROPERTY_COLOR,
				Title = "Color:",
				Extra = { color_white, false },
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.light.r = value.r;
					PAC.CurrentPart.light.g = value.g;
					PAC.CurrentPart.light.b = value.b;

				end,
				Reset = function( control, data )

					if( !data || !data.light ) then control:SetColor( color_white ); return; end

					control:SetColor( Color( data.light.r, data.light.g, data.light.b ) );

				end
			},
			{
				Name = "Brightness",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Brightness:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.light.Brightness = value;

				end,
				Reset = function( control, data ) control:SetValue( ( data && data.light ) and data.light.Brightness or 0 ); end
			},
			{
				Name = "Size",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Size:",
				Extra = {0, 130},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.light.Size = value;

				end,
				Reset = function( control, data ) control:SetValue( ( data && data.light ) and data.light.Size or 0 ); end
			},
--[[ 			{
				Name = "Decay",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Decay:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.light.Decay = value;

				end,
				Reset = function( control, data ) control:SetValue( ( data && data.light ) and data.light.Decay or 0 ); end
			} ]]
		}
	},
	{
		Name = "Effect",
		Properties =
		{
			{
				Name = "Enabled",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enabled",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.effect.Enabled = value;

					PAC.ReApplyConfig( )

				end,
				Reset = function( control, data )

					if( !data || !data.effect ) then control:SetChecked( false ); return; end

					control:SetValue( data.effect.Enabled );

				end
			},
			{
				Name = "Enter",
				Type = PAC_PROPERTY_TEXTENTRY,
				Title = "Enter:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.effect.effect = control:GetValue( );

					PAC.ReApplyConfig( )

				end,
				Reset = function( control, data ) control:SetValue( data and data.effect.effect or "" ); end
			},
			{
				Name = "Loop",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Loop:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.effect.loop = value;

				end,
				Reset = function( control, data )

					if( !data || !data.effect ) then control:SetChecked( false ); return; end

					control:SetValue( data.effect.loop );

				end
			},
			{
				Name = "Rate",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Rate:",
				Extra = {0, 2},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.effect.rate = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.effect.rate or 1 ); end
			},
		}
	},
	{
		Name = "Sprite",
		Properties =
		{
			{
				Name = "Enabled",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enabled",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.sprite.Enabled = value;

					PAC.ReApplyConfig( )

				end,
				Reset = function( control, data )

					if( !data || !data.sprite ) then control:SetChecked( false ); return; end

					control:SetValue( data.sprite.Enabled );

				end
			},
			{
				Name = "Size",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Size:",
				Change = function( control, value )

					local x = PAC.GetPropertyInfo( "Sprite", "X" );
					local y = PAC.GetPropertyInfo( "Sprite", "Y" );

					x.Control:SetValue( value );
					y.Control:SetValue( value );

				end
			},
			{
				Name = "X",
				Type = PAC_PROPERTY_SLIDER,
				Title = "X:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.sprite.x = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.sprite.x or 0 ); end
			},
			{
				Name = "Y",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Y:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.sprite.y = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.sprite.y or 0 ); end

			},
			{
				Name = "Material",
				Type = PAC_PROPERTY_MATERIAL,
				Title = "Reset",
				Extra = { "SpriteMaterials" },
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.sprite.material = value;

					PAC.ReApplyConfig( )

				end,
				Reset = function( control, data ) control:SetSelected( data and data.sprite.material or "" ); end
			},
			{
				Name = "Color",
				Type = PAC_PROPERTY_COLOR,
				Title = "Color:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.sprite.color = value;

				end,
				Reset = function( control, data ) control:SetColor( data and data.sprite.color or color_white ); end
			}
		}
	},
	{
		Name = "Trail",
		Properties =
		{
			{
				Name = "Enabled",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enabled",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.trail.Enabled = value;



				end,
				Reset = function( control, data )

					if( !data || !data.trail ) then control:SetChecked( false ); return; end

					control:SetValue( data.trail.Enabled );

				end
			},
			{
				Name = "Length",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Length:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.trail.length = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.trail.length or 0 ); end
			},
			{
				Name = "StartSize",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Size:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.trail.startsize = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.trail.startsize or 0 ); end
			},
			{
				Name = "Material",
				Type = PAC_PROPERTY_MATERIAL,
				Title = "Reset",
				Extra = { "TrailMaterials" },
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.trail.material = value;

					PAC.ReApplyConfig( )

				end,
				Reset = function( control, data ) control:SetSelected( data and data.trail.material or "" ); end
			},
			{
				Name = "Color",
				Type = PAC_PROPERTY_COLOR,
				Title = "Color:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.trail.color = value;

				end,
				Reset = function( control, data ) control:SetColor( data and data.trail.color or color_white ); end
			}
		}
	},
	{
		Name = "Text",
		Properties =
		{
			{
				Name = "Enabled",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enabled",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end



					PAC.CurrentPart.text.Enabled = value; --FIX HERE


				end,
				Reset = function( control, data )

					if( !data || !data.text ) then control:SetChecked( false ); return; end

					control:SetValue( data.text.Enabled );

				end
			},
			{
				Name = "Text",
				Type = PAC_PROPERTY_TEXTENTRY,
				Title = "Text:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.text.text = control:GetValue()

				end,
				Reset = function( control, data ) control:SetValue( data and data.text.text or "" ); end
			},
			{
				Name = "Size",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Size:",
				Extra = {0, 3},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.text.size = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.text.size or 1 ); end
			},
			{
				Name = "Font",
				Type = PAC_PROPERTY_TEXTENTRY,
				Title = "Font:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.text.font = control:GetValue();

				end,
				Reset = function( control, data ) control:SetValue( data and data.text.font or "default" ); end
			},
			{
				Name = "Color",
				Type = PAC_PROPERTY_COLOR,
				Title = "Color:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.text.color = value;

				end,
				Reset = function( control, data ) control:SetColor( data and data.text.color or color_white ); end
			},
			{
				Name = "Outline",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Outline:",
				Extra = {0, 3},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.text.outline = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.text.outline or 1 ); end
			},
			{
				Name = "OutlineColor",
				Type = PAC_PROPERTY_COLOR,
				Title = "Outline Color:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.text.outlinecolor = value;

				end,
				Reset = function( control, data ) control:SetColor( data and data.text.outlinecolor or color_white ); end
			},
		}
	},
	{
		Name = "Animation",
		Properties =
		{
			{
				Name = "Enabled",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Enabled",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.animation.Enabled = value;



				end,
				Reset = function( control, data )

					if( !data || !data.animation ) then control:SetChecked( false ); return; end

					control:SetValue( data.animation.Enabled );

				end
			},
			{
				Name = "Loopmode",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Loopmode:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.animation.loopmode = tobool(value);

				end,
				Reset = function( control, data ) control:SetValue( not data and true or PAC.CurrentPart.animation.loopmode ); end
			},
			{
				Name = "Sequence",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Sequence:",
				Extra = {-1, 100},
				Decimals = 0,
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.animation.sequence = math.Round(tonumber( value ));

				end,
				Reset = function( control, data ) control:SetValue( data and data.animation.sequence or 1 ); end
			},
			{
				Name = "Name",
				Type = PAC_PROPERTY_TEXTENTRY,
				Title = "Name:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.animation.name = control:GetValue( ) ;

				end,
				Reset = function( control, data ) control:SetValue( data and data.animation.name or "" ); end
			},
			{
				Name = "Rate",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Rate:",
				Extra = {0, 3},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.animation.rate = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.animation.rate or 1 ); end
			},
			{
				Name = "Offset",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Offset:",
				Extra = {0, 1},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.animation.offset = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.animation.offset or 0 ); end
			},
			{
				Name = "Min",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Min:",
				Extra = {0, 1},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.animation.min = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.animation.min or 0 ); end
			},
			{
				Name = "Max",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Max:",
				Extra = {0, 1},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.animation.max = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.animation.max or 1 ); end
			}
		}
	},
	{
		Name = "Misc",
		Properties =
		{
 			{
				Name = "FullBright",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "FullBright:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:SetFullBright(tobool(value))

				end,
				Reset = function( control, data ) control:SetValue( not data and false or PAC.CurrentPart.fullbright ); end
			},
			{
				Name = "Mirrored",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Mirrored:",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:SetMirrored(tobool(value))

				end,
				Reset = function( control, data ) control:SetValue( not data and false or PAC.CurrentPart.mirrored ); end
			},
			{
				Name = "Skin",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Skin:",
				Extra = {0, 10},
				Decimals = 0,
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:SetSkin(tonumber( value ));

				end,
				Reset = function( control, data ) control:SetValue( data and data.skin or 0 ); end
			},
			{
				Name = "Bodygroup",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Bodygroup:",
				Extra = {0, 10},
				Decimals = 0,
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:SetBodygroup(tonumber( value ));

				end,
				Reset = function( control, data ) control:SetValue( data and data.bodygroup or 0 ); end
			},
			{
				Name = "BodygroupState",
				Type = PAC_PROPERTY_SLIDER,
				Title = "State:",
				Extra = {0, 10},
				Decimals = 0,
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart:SetBodygroupState(tonumber( value ));

				end,
				Reset = function( control, data ) control:SetValue( data and data.bodygroup_state or 0 ); end
			},
		}
	},
	{
		Name = "Sunbeams",
		Properties =
		{
			{
				Name = "Enabled",
				Type = PAC_PROPERTY_CHECKBOX,
				Title = "Sunbeam",
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.sunbeams.Enabled = value;

					PAC.ReApplyConfig( )

				end,
				Reset = function( control, data )

					if( !data || !data.sunbeams ) then control:SetChecked( false ); return; end

					control:SetValue( data.sunbeams.Enabled );

				end
			},
			{
				Name = "Darken",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Darken:",
				Extra = {0, 1},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.sunbeams.darken = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.sunbeams.darken or 1 ); end
			},
			{
				Name = "Multiply",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Multiply:",
				Extra = {0, 1},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.sunbeams.multiply = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.sunbeams.multiply or 1 ); end
			},
			{
				Name = "Size",
				Type = PAC_PROPERTY_SLIDER,
				Title = "Size:",
				Extra = {0, 1},
				Change = function( control, value )

					if( !PAC.CurrentPart || PAC.IsBoneObject( PAC.CurrentPart ) ) then return; end

					PAC.CurrentPart.sunbeams.size = tonumber( value );

				end,
				Reset = function( control, data ) control:SetValue( data and data.sunbeams.size or 1 ); end
			},
		},
	},
}