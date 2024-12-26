local item_database = require("picasso.item_database")
local menu_item = {}

--- @param tags table Identifier to query for menu_item from item_database
function menu_item:new(tags)
	local instance = {}
	setmetatable(instance, self)
	self.__index = self

	for _, tag in pairs(tags) do
		assert(type(tag) ~= "nil", "the tag argument for the menu_item was not assigned")
		assert(type(tag) == "string", "menu_item tag must be of type \'string\'")
	end

	instance.tags = tags
	instance:add_tags({"menu_item"})
	item_database.add_items({instance})

	return instance
end

function menu_item:get_tags()
	assert(self.tags ~= nil, "This menu item does not have a tag")
	return self.tags
end

function menu_item:add_tags(tags)
	for _, tag in pairs(tags) do
		table.insert(self.tags, tag)
	end
end

function menu_item:remove_tags(tags)
	for _, tag in pairs(tags) do
		table.remove(self.tags, tag)
	end
end
return menu_item
