describe("Basic math - part 2:", function()
  it("test five multiplied by two is ten", function()
    assert.are.equal(5 * 2, 10)
  end)
end)

local function write_to_file(filename, content)
  local file, err = io.open(filename, "w")
  if file == nil then
    print("Couldn't open file: " .. err)
  else
    file:write(content)
    file:close()
  end
end

describe("Basic IO - part 2:", function()
  it("test write_to_file writes content to file", function()
    local filename = "test2.txt"
    local content = "Hello, Stephen!"

    write_to_file(filename, content)

    local file, err = io.open(filename, "r")
    if file == nil then
      print("Couldn't open file: " .. err)
    else
      local fileContent = file:read("*a")
      file:close()

      os.remove(filename)

      assert.are.same(content, fileContent)
    end
  end)
end)
