local utils = require("picasso.utils")
local error_message = require("picasso.error_message")


local M = {}

M._settings = {} -- The reason for exporting is so tests will run correctly

local data_path = vim.fn.stdpath("data")
local picasso_data_dir = data_path .. "/picasso"
local picasso_settings_file = picasso_data_dir .. "/settings.json"

local function ensure_dir_exists(dir)
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
end

-- settings that will override the settings.json file
local function save()
	ensure_dir_exists(picasso_data_dir)
	local file = io.open(picasso_settings_file, "w")
	if file then
		local settings = vim.json.encode(M._settings)
		file:write(settings)
		file:close()
	end
end


-- call this function every time buffer changes to check for language specific color scheme
local function load()
	-- locate current color scheme settings
	ensure_dir_exists(picasso_data_dir)
	local file = io.open(picasso_settings_file, "r")
		if file then
			local settings = file:read()
			file:close()
			if settings ~= nil then
				M._settings = vim.json.decode(settings)
			end
		end
	-- find out what kind of file the buffer is (this is for language specific themes)
end

-- make this a match statement
function M.apply(setting)
	if setting == "current_scheme" then
		vim.cmd.colorscheme(M._settings.current_scheme)
	end

	if setting == "buffer_scheme" then
		vim.cmd.colorscheme(M._settings.buffer_scheme)
	end
end

-- User or default settings.
function M.setup(user_settings)

	load() -- Loads in last knows settings from file.

	-- Makes sure automatic settings were not set by user.
	assert(
		user_settings.current_scheme == nil ,
		error_message.settings.unauthorized_initalization("current_scheme", user_settings.current_scheme)
	)
	assert(
		user_settings.buffer_scheme == nil,
		error_message.settings.unauthorized_initalization("buffer_scheme", user_settings.buffer_scheme)
	)

	-- overrides loaded settings with user_settings or default
	-- The "or" operator takes the first truthy value 
	M._settings = {
		current_scheme         = M._settings.current_scheme           or "habamax",
		buffer_scheme          = M._settings.buffer_scheme            or "habamax",
		display_neovim_schemes = user_settings.display_neovim_schemes or false,
		display_vim_schemes    = user_settings.display_vim_schemes    or false,
		border                 = user_settings.border                 or "normal",
	}

	-- Makes sure settings are not misspelled.
	for user_key, user_value in pairs(user_settings) do
		local user_key_exists = false
		for settings_key, _ in pairs(M._settings) do
			if user_key == settings_key then
				user_key_exists = true
				break
			else
				user_key_exists = false
			end
		end
		if not user_key_exists then
			error(error_message.settings.unauthorized_initalization(user_key, user_value))
		end
	end

	-- Makes sure menu loads with at least one type of scheme.
	assert(
		M._settings.display_neovim_schemes == true or
		M._settings.display_vim_schemes == true,
		error_message.settings.no_schemes_displayed()
	)
	save()
	M.apply("current_scheme")
end

--- @return table immutable clone.
function M.get()
	if type(M._settings) ~= "table" then
        error("Expected M._settings to be a table, got " .. type(M._settings))
    end
	return utils.make_tbl_readonly(M._settings)
end


function M.set(key, value)
	assert(type(key) == "string", "Error: argument must be of type 'string' but found: '" .. type(key) .. "'")
	assert(type(M._settings[key]) ~= "nil", "Key: '" .. key .. "' was not found")
	M._settings[key] = value
	save()
end



return M
