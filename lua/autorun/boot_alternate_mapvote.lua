local function includeFile(filePath)
	assert(type(filePath) == "string", "bad argument #1 to 'IncludeLua' (string expected, got " .. type(filePath) .. ")")
	local isShared = string.find(filePath, "sh_")
	local isClient = string.find(filePath, "cl_")
	local isServer = string.find(filePath, "sv_")
	if (isShared or isClient) then
		AddCSLuaFile(filePath)
	end
	if (isServer and CLIENT) then return end
	if (isClient and SERVER) then return end
	print("Including lua file: " .. filePath)
	include(filePath)
end

local function includeDir(folder)
	assert(type(folder) == "string", "bad argument #1 to 'IncludeFolder' (string expected, got " .. type(folder) .. ")")
	if (string.sub(folder, -1) != "/") then
		folder = folder .. "/"
	end
	local pattern = folder .. "*.lua"
	local files, directories = file.Find(pattern, "LUA")
	for _, name in pairs(files) do
		includeFile(folder .. name)
	end
end

amapvote = {
	NetString = "amapvote",
	ShowWinnerString = "amapvote_result",
}

includeDir("amapvote")
includeDir("amapvote/ui")