
//
// Experimental
// 
// 21st March 2011
//

PANEL = {}

function PANEL:Init()

	self.HTML = vgui.Create( "LuaHTML", self )
	self.HTML:Dock( FILL );
	self.HTML.PageTitleChanged = function( html, title ) self:PageTitleChanged( title ) end

end

function PANEL:GetCode()

	local code = string.Replace( self.HTML.PageTitle, "*/*new*line*/*", "\n\r" )
	
	return code

end

function PANEL:SetCode( code )

	// The page is loading.. keep trying until it works!
	if ( self.HTML:IsLoading() ) then	
		local this = self
		return timer.Simple( 0.1, function() if ( IsValid( this ) ) then this:SetCode( code ) end end )
	end
	// TODO.. there's probably more cleaning to be done here.
	
	code = string.Replace( code, "\n\r", "\\n" )
	code = string.Replace( code, "\r\n", "\\n" )
	code = string.Replace( code, "\n", "\\n" )
	code = string.Replace( code, "\"", "\\\"" )
	
	//MsgN( "UpdateCode( \""..code.."\" );" )
	
	self.HTML:RunJavascript( "UpdateCode( \""..code.."\" );" )

end

function PANEL:PageTitleChanged( new )

	if ( !self.OnCodeChanged ) then return end
	
	self:OnCodeChanged( self:GetCode() )

end

derma.DefineControl( "DLuaEditor", "", PANEL, "Panel" )