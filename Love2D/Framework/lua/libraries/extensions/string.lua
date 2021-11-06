local pattern_escape_replacements = {
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z"
}

function string.PatternSafe( str )
	return ( str:gsub( ".", pattern_escape_replacements ) )
end

function string.StripExtension( path )
	local i = path:match( ".+()%.%w+$" )
	if ( i ) then return path:sub( 1, i - 1 ) end
	return path
end

function string.TrimLeft( s, char )
	if ( char ) then char = char:PatternSafe() else char = "%s" end
	return string.match( s, "^" .. char .. "*(.+)$" ) or s
end

function string.GetExtensionFromFilename( path )
	return path:match( "%.([^%.]+)$" )
end

function string.GetPathFromFilename( path )
	return path:match( "^(.*[/\\])[^/\\]-$" ) or ""
end

function string.GetFileFromFilename( path )
	if ( not path:find( "\\" ) and not path:find( "/" ) ) then return path end
	return path:match( "[\\/]([^/\\]+)$" ) or ""
end

function string.Explode(separator, str, withpattern)
	if ( withpattern == nil ) then withpattern = false end

	local ret = {}
	local current_pos = 1

	for i = 1, string.len( str ) do
		local start_pos, end_pos = string.find( str, separator, current_pos, not withpattern )
		if ( not start_pos ) then break end
		ret[ i ] = string.sub( str, current_pos, start_pos - 1 )
		current_pos = end_pos + 1
	end

	ret[ #ret + 1 ] = string.sub( str, current_pos )

	return ret
end