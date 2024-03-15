describe("Basic math:", function()
  it("test five plus five is ten", function()
    assert.are.equal(5 + 5, 10)
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

describe("Basic IO:", function()
  it("test write_to_file writes content to file", function()
    local filename = "test.txt"
    local content = "Hello, World!"

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
