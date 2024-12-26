-- Put all Development function in here.

local M = {}

-- Paths
local data_path = vim.fn.stdpath("data")
local picasso_data_dir = data_path .. "/picasso"
local picasso_settings_file = picasso_data_dir .. "/settings.json"

local function clear_module_cache(mod_name)
	package.loaded[mod_name] = nil
	if package.loaded[mod_name] == nil then
		print("Module unloaded: " .. mod_name)
	else
		print("Error unloading module: " .. mod_name)
	end
end

local function reload_module(mod_name)
	local ok, result = pcall(require, mod_name)
	if ok then
		print("Module reloaded: " .. mod_name)
	else
		print("Error reloading module: " .. mod_name .. "\n" .. result)
	end
	return result
end

local function remove_path(path)
	local result, error_message = os.remove(path)
	if result then
		print("Directory removed successfuly:" .. path)
	else
		print("Error removing file" .. error_message)
	end
end

-- remove paths
remove_path(picasso_settings_file)
remove_path(picasso_data_dir)

-- Reload modules here.

local modules = {
  "picasso",
  "picasso.init",
  "picasso.settings",
  "picasso.menu_builder",
  "picasso.item_database",
  "picasso.menu_item",
  "picasso.utils"
}

for _, mod_name in ipairs(modules) do
  clear_module_cache(mod_name)
end

for _, mod_name in ipairs(modules) do
  reload_module(mod_name)
end

print("Development Tools Loaded!")

return M

