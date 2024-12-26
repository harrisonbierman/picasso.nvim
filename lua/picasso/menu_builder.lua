local settings = require("picasso.settings")

local M = {}
--TODO: brake up into two funcitons and make local
--		need: find_color_schemes
--		need: format_color_options 
--				^this will be a big function that can create drop down menus

function M.find_color_schemes() -- I don't like passing the current color in here
	local scheme_list = {} --clear table
	for _, rt in ipairs(vim.api.nvim_list_runtime_paths()) do

		local files_vim = {}
		local files_lua = {}

		if settings.get().display_vim_schemes then
			files_vim = vim.fn.glob(rt .. '/colors/*.vim', false, true)
		end

		if settings.get().display_neovim_schemes then
			files_lua = vim.fn.glob(rt .. '/colors/*.lua', false, true)
		end

		local files = vim.list_extend(files_lua, files_vim)

	for _, file in ipairs(files) do
			local name = vim.fn.fnamemodify(file, ':t:r')
			table.insert(scheme_list, tostring(name))
		end
	end

	table.sort(scheme_list)
	table.insert(scheme_list, 1, "Current Scheme: " .. (settings.get().current_scheme or ""))
	return scheme_list
end



return M
