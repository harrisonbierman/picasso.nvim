local M = require('picasso.settings')  -- Replace 'your_module_name' with the actual module name

describe('M.set', function()
  local settings_backup

  -- Backup and restore _settings before each test
  before_each(function()
    settings_backup = { key1 = "value1", key2 = "value2" }
    M._settings = vim.deepcopy(settings_backup)  -- Update the module's _settings reference
  end)

  it('should set a valid key with a new value', function()
    M.set('key1', 'new_value')
    assert.equals(M._settings.key1, 'new_value')
  end)

  it('should raise an error for a non-string key', function()
    assert.has_error(function() M.set(123, 'value') end, "Error: argument must be of type 'string' but found: 'number'")
  end)

  it('should raise an error if the key is not found', function()
    assert.has_error(function() M.set('invalid_key', 'value') end, "Key: 'invalid_key' was not found")
  end)

  it('should not alter other keys', function()
    M.set('key1', 'new_value')
    assert.equals(M._settings.key1, 'new_value')
    assert.equals(M._settings.key2, 'value2')
  end)
end)

