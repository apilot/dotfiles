-- Тестовый файл для проверки автодополнения

local function test_completion()
  -- Проверка LSP автодополнения
  local str = "Hello, World!"
  print(str)

  -- Проверка автодополнения из buffer
  local another_string = "This should appear in buffer completion"
  local buffer_test = "Buffer completion test"

  -- Проверка path автодополнения
  local file_path = "/home/user/"

  -- Проверка snippet автодополнения
  if true then
    print("Condition test")
  end
end

-- Emoji completion test 🎉
print("Emoji test: 🚀")