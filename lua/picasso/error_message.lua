local M = { settings = {} }

local function settings_fix(attempted_key)
	if attempted_key == "current_scheme" then return 
[[
Fix: Delete current_scheme from setup function. To change the current 
scheme, please do so with the Picasso user interface.
To open interface, set a keybind with the toggle function below

local ui = require('picasso.ui')
vim.keymap.set('n', '<your_key_bind_here>', function() ui.toggle_menu() end, { noremap = true })
]]
	end

	if attempted_key == "buffer_scheme" then return 
[[
Fix: Delete buffer_scheme from setup function. The buffer will change
automatically as you preview schemes.
]]
	end

	-- catch all
	if type(attempted_key) == "string" then return
[[
Fix: Check for spelling or refer to the github page at www.github.com/harrisonbierman/picasso.nvim 
for a list of avaliable settings
]]
	end

end


--- @param attempted_key string type of setting that not allowed to be set
--- @param value any value of the attempted setting
function M.settings.unauthorized_initalization(attempted_key, value) return [[ 

Error: picasso.nvim failed to launch. You attempted to initalizes setting: <]]..attempted_key..[[> 

require('picasso.settings').setup({
	-- Other settings
	
  ]]..attempted_key..[[ = ]]..tostring(value)..[[ <---| NOT ALLOWED TO INITALIZE SETTING

	-- Other settings
})

]]..settings_fix(attempted_key)
end

function M.settings.no_schemes_displayed() return [[

Error: picasso.nvim failed to launch. You did not initalize any color schemes to be displayed

require('picasso.settings').setup({
	-- Other settings
	
	display_neovim_schemes = false <---| AT LEAST ONE NEEDS
	display_vim_schemes = false <------| TO BE TRUE 

	-- Other settings
})

FIX: All settings default to false if not specified, either check if at least one 
setting is specified and at least one is set to true
]]
end

function M.settings.non_existent_scheme_name(attempted_scheme) return [[
Non-Critical Error: picasso.nvim tried to load setting "]]..attempted_scheme..[[" but scheme name was not found.
picasso.nvim has switched your scheme to "habamax" for the time being.

Fix: Check if scheme was properly installed. Check if scheme name as changed due to scheme update.

]]
end
return M
