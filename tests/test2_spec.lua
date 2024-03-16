local function write_to_file(filename, content)
  local file, err = io.open(filename, "w")
  if file == nil then
    print("Couldn't open file: " .. err)
  else
    file:write(content)
    file:close()
  end
end

describe("Function write_to_file", function()
  it("should write contents to file correctly", function()
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

  it("given a separate file, should also write to it correctly", function()
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
