local utils = require("picasso.utils")

local item_database = {}
item_database._items = {}

--- Returns table of items in item_database that matches given tags
--- @param tags table table of string to query for
--- @return table items in database
function item_database.query(tags)
	local queried_items = {}
	for _, _item in pairs(item_database._items) do
		if utils.is_table_subset(_item.tags, tags) then
			table.insert(queried_items, _item)
		end
	end
	return queried_items
end

--- Adds table of items to item_database
--- @param items table table of items
function item_database.add_items(items)
	assert(type(items) == "table", "bad argument, pass in a table of items")
	for _, item in pairs(items) do
		assert(type(item) == "table", "bad argument, item is not type table, check if table of items was passed into add_items()")
		table.insert(item_database._items, item)
	end
end

--- Removes table of itesm from item_database
--- Best to use item_database.query(tags) as argument
--- @param items table table of items
function item_database.remove_by_items(items)
	assert(type(items) == "table", "bad argument, pass in table of items")
	for _, item in pairs(items) do
		assert(type(item) == "table", "bad argument, check if table of items was passed in")
		--this will first find the index of the item in the table so it can be removed
		--get_table_index(table_of_items, item)
		
		--the second argument in remove should be an index not an item lua is too stupid to have
		--its own recursive comparsion
		table.remove(item_database._items, item)
	end
end

function item_database.remove_by_tags(tags)
	assert(type(tags) == "table", "bad argument, pass in table of tags")
	for tag in pairs(tags) do
		assert(type(tag) == "string", "bad argument, table must only contain strings")
	end
end

return item_database


