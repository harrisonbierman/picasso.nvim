local M = {}

--- return length of the longest string in a table
--- @param table table
--- @return integer
function M.longest_string_length(table)
	local ls = ""
	for _, s in ipairs(table) do
		assert("string", type(s), "all table types must be a string")
		if #s > #ls then
			ls = s
		end
	end
	return #ls
end

--- returns true if sub_table is a subset of super_table
--- @param super_table table
--- @param sub_table table
--- @return boolean
function M.is_table_subset(super_table, sub_table)
	for _, sub_object in pairs(sub_table) do
		local is_subset = false
		for _, super_object in pairs(super_table) do
			if sub_object == super_object then
				is_subset = true
				break
			end
		end
		if not is_subset then
			return false
		end
	end
	return true
end

function M.are_tables_same(table1, table2)
	assert(type(table1) == "table", "bad argument, pass in table")
	assert(type(table2) == "table", "bad argument, pass in table")
	return assert(table1, table2)
end

function M.make_tbl_readonly(table)
	local data = table or {}
	local meta_table = {
		__index = data,
		__newindex = function(_, key, _)
			error("Attempt to modifty Key: " .. key..  ", in read-only table", 2)
		end,
		__metatable = false
	}

	return setmetatable({}, meta_table)
end

return M
