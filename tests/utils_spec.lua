describe("Is table Subset", function()
	before_each(ReloadRequire("picasso.utils"))
	it("can be required", function()
		require("picasso.utils")
	end)

	it("can find if sub_table fits in super_table with same type", function()
		local super_table = { "orange", "red", "blue", "green" }
		local sub_table = { "orange", "green" }
		assert.equal(true, require("picasso.utils").is_table_subset(super_table, sub_table))
	end)

	it("can find if sub_table fits in super_table with mixed types", function()
		local super_table = { "orange", "red", "blue", 504}
		local sub_table = { "orange", 504}
		assert.equal(true, require("picasso.utils").is_table_subset(super_table, sub_table))
	end)

	it("can find if super_table does not fit in sub_table", function()
		local super_table = { "orange", "red", "blue", "green" }
		local sub_table = { "orange", "green" }
		assert.equal(false, require("picasso.utils").is_table_subset(sub_table, super_table))
	end)

	it("can find if sub_table fits in super_table with nested tables", function()
		local super_table = { "orange", "red", "blue", { "potato", "banana" } }
		local sub_table = { "orange", { "potato", "banana" } }
		assert.equal(true, require("picasso.utils").is_table_subset(sub_table, super_table))
	end)

end)
