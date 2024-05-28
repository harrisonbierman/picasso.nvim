--TODO: Make all of the global functions local and split
--		into their respective modules
--		refactor like hell
local popup = require('plenary.popup')
local utils = require('picasso.utils')

local M = {}
local curr_color 
local cursor_move_cmd_id = nil
local cursor_saved_pos = {}
local Picasso_win_id

M.colors = {}

--TODO: brake up into two funcitons and make local
--		need: find_color_schemes
--		need: format_color_options 
--				^this will be a big function that can create drop down menus
function FindColorSchemes(is_vim_allowed)
	M.colors = {} --clear table
	for _, rt in ipairs(vim.api.nvim_list_runtime_paths()) do

		local files

		if is_vim_allowed then
			local files_lua = vim.fn.glob(rt .. '/colors/*.lua', false, true)
			local files_vim = vim.fn.glob(rt .. '/colors/*.vim', false, true)
			files = vim.list_extend(files_lua, files_vim)
		else
			files = vim.fn.glob(rt .. '/colors/*.lua', false, true)
		end

	for _, file in ipairs(files) do
			local name = vim.fn.fnamemodify(file, ':t:r')
			table.insert(M.colors, tostring(name))
		end 
	end

	table.sort(M.colors)
	table.insert(M.colors, 1, "Current Scheme: " .. (curr_color or ""))
	return M.colors
end


local harrison_bierman_picasso = vim.api.nvim_create_augroup(
	"HARRISON_BIERMAN_PICASSO",
	{ clear = true }
)

--TODO: I'm not even sure this is deleting the autocommand when it closes
function CloseMenu()
	if cursor_move_cmd_id then
		vim.api.nvim_del_autocmd(cursor_move_cmd_id)
		cursor_move_cmd_id = nil
	end
	if vim.api.nvim_win_is_valid(Picasso_win_id) then
		cursor_saved_pos = vim.api.nvim_win_get_cursor(Picasso_win_id)
		P("new saved pos is: " .. tostring(cursor_saved_pos))
		vim.api.nvim_win_close(Picasso_win_id, true)
	end
end

vim.api.nvim_set_keymap("n", "<leader>pi", "<cmd>lua MyMenu()<CR>", {})

--this funciton dooes not work yet but want to add this in the future
--[[
vim.api.nvim_create_autocmd("VimResized", {
	callback = function(ev)
		if vim.api.nvim_win_is_valid(Picasso_win_id) then
			CloseMenu()
			MyMenu()
		end
	end,
	group = harrison_bierman_picasso
})
--]]

--TODO: Move this to utils
function LongestStringLength(opts)
	local ls = ""
	for _, s in ipairs(opts) do
		if #s > #ls then
			ls = s
		end
	end
	return #ls
end

--TODO: Too many things are happening in this one fucntion
function CreateMenu(opts, cb)
	local width = LongestStringLength(opts)
	local height = 10 
	-- local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	local borderchars = { "─", "│", "─", "►", "✎", "✐", "✎", "✐" }

	Picasso_win_id = popup.create(opts, {
		title = "Picasso",
		highlight = "PicassoWindow",
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width)),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
		callback = cb,
		cursorline = true,
	})
	local bufnr = vim.api.nvim_win_get_buf(Picasso_win_id)
	
	-- This feels like a bad solution
	vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>lua CloseMenu()<CR><cmd>lua ChooseCurrentColor()<CR>", { silent = false })
	if next(cursor_saved_pos) ~= nil then
		vim.api.nvim_win_set_cursor(0, cursor_saved_pos)
	end
	
	vim.api.nvim_buf_set_option(bufnr, "readonly", true)
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

	-- This entire autocommand should be pulled out
	cursor_move_cmd_id = vim.api.nvim_create_autocmd({"CursorMoved"}, {
		callback = function()
			if vim.api.nvim_win_is_valid(Picasso_win_id) then
				local cursor_pos = vim.api.nvim_win_get_cursor(Picasso_win_id)
				local row = cursor_pos[1]
				local option = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

				local is_curr_color = string.find(option, "Current Scheme: ")

				-- This if statment could be a funciton used multiple times in code
				-- also the hard coded string should be a constant
				if is_curr_color then
					option = string.match(option, "Current Scheme: (.*)")
				end
				
				vim.cmd("colorscheme " .. option)
			end
		end,
		group = harrison_bierman_picasso
	})
end

--TODO: Change the name of function to something more fitting
function MyMenu()
	curr_color = curr_color or ""
	local opts = FindColorSchemes(false)
	local cb = function(_, selection)
		local is_curr_color = string.find(selection, "Current Scheme: ")
		
		-- this is the other if statment that is used a second time
		if is_curr_color then
			selection = string.match(selection, "Current Scheme: (.*)")
		end

		vim.cmd("colorscheme " .. selection)
		curr_color = selection

		if vim.api.nvim_win_is_valid(Picasso_win_id) then
			cursor_saved_pos = vim.api.nvim_win_get_cursor(Picasso_win_id)
		end
		--TODO: find a better solution to keeping the menu opened on 'Enter'
		--		than just calling the menu function again
		--		it makes the whole screen flash and looks bad
		MyMenu()

	end
	CreateMenu(opts, cb)
end

-- the only reason this exist is to switch back to
-- the current color when user quits menu
function ChooseCurrentColor()
	vim.cmd("colorscheme " .. curr_color)
end

