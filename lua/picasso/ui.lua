local settings      = require("picasso.settings")
local menu_builder  = require("picasso.menu_builder")
local utils         = require('picasso.utils')
local popup         = require('plenary.popup')
local init          = require('picasso.init')

local M = {}

local cursor_move_cmd_id = nil
local cursor_saved_pos = {} -- (x, y)
local Picasso_win_id = nil

local function close_menu()
	settings.apply("current_scheme")

	if cursor_move_cmd_id then
		vim.api.nvim_del_autocmd(cursor_move_cmd_id)
		cursor_move_cmd_id = nil
	end

	if vim.api.nvim_win_is_valid(Picasso_win_id) then
		cursor_saved_pos = vim.api.nvim_win_get_cursor(Picasso_win_id)
		vim.api.nvim_win_close(Picasso_win_id, true)
	end
end

--TODO: Too many things are happening in this one function
local function create_window(opts, cb)
	local width = utils.longest_string_length(opts)
	local height = 10

	--TODO: find a nicer looking way to pattern match.
	local borderchars

	local settings_state_border = settings.get().border

	if settings_state_border == "fun" then
		borderchars = { "─", "│", "─", "►", "✎", "✐", "✎", "✐" }
	elseif settings_state_border == "cryptic" then
		borderchars = { "ΓöÇ", "Γöé", "ΓöÇ", "Γöé", "Γò¡", "Γò«", "Γò»", "Γò░" }
	elseif settings_state_border == "normal" then
	    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	else
		error("Error: Failed to open picasso menu. Value for 'border' was set to <\"" .. settings.get().border .. "\"> in require('picasso').setup() function either does not exist or was spelled wrong")
	end

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

	local buffer_number = vim.api.nvim_win_get_buf(Picasso_win_id)
	vim.api.nvim_buf_set_option(buffer_number, "readonly", true)
	vim.api.nvim_buf_set_option(buffer_number, "modifiable", false)

	-- if next() second argument is nil, returns first index
	if next(cursor_saved_pos) ~= nil then
		vim.api.nvim_win_set_cursor(0, cursor_saved_pos)
	end

	-- tracks cursor movement for hot-swap fun
	cursor_move_cmd_id = vim.api.nvim_create_autocmd({"CursorMoved"}, {
		callback = function()
			if vim.api.nvim_win_is_valid(Picasso_win_id) then
				local cursor_pos = vim.api.nvim_win_get_cursor(Picasso_win_id)
				local row = cursor_pos[1]
				local option = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

				local is_current_scheme = string.find(option, "Current Scheme: ")

				-- This if statment could be a funciton used multiple times in code
				-- also the hard coded string should be a constant
				if is_current_scheme then
					option = string.match(option, "Current Scheme: (.*)")
				end

				settings.set("buffer_scheme", option)
				settings.apply("buffer_scheme")
			end
		end,
		group = init.harrison_bierman_picasso
	})
end

local function open_menu()
	local opts = menu_builder.find_color_schemes()
	-- this call-back is called when selecting menu item (on "return" key)
	local cb = function(_, selection)

		-- this is checking if the user is selecting the top options
		-- that is the current color and will regex out the name of the scheme
		local is_current_scheme = string.find(selection, "Current Scheme: ")
		if is_current_scheme then
			selection = string.match(selection, "Current Scheme: (.*)")
		end

		settings.set("current_scheme", selection)
		settings.apply("current_scheme")

		if vim.api.nvim_win_is_valid(Picasso_win_id) then
			cursor_saved_pos = vim.api.nvim_win_get_cursor(Picasso_win_id)
		end

		open_menu() -- reopens menu after selection is made
	end
	create_window(opts, cb)
end

function M.toggle_menu()
	-- guard clause if menu has been initiated or is open
	if Picasso_win_id ~= nil then
		if vim.api.nvim_win_is_valid(Picasso_win_id) then
			close_menu()
		else
			open_menu()
		end
	else
		open_menu()
	end
end

return M

