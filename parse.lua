local module = {}

function module.read_file(path)
  local open = io.open
  local file = open(path, "r") -- r read mode and b binary mode
  local lines = {}

  for line in io.lines(path) do
      local corpus,
      label,
      id,
      quotetext,
      responsetext = line:match("([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)")
      local quottable = {}
      local resptable = {}
      if quotetext then
          local quottable = string.lower(quotetext):gsub(".",function(x) table.insert(quottable, string.byte(x)) end)
      end
      if responsetext then
          local resptable = string.lower(responsetext):gsub(".",function(x) table.insert(resptable, string.byte(x)) end)
      end
      lines[#lines+1] = { corpus = corpus,
                          label = label,
                          id = id,
                          quottable = quottable,
                          responsetable = resptable
                        }

  end
  file:close()
  return lines
end

return module

-- lines = read_file("sarcasm_v2.csv")
-- print (lines[20])

--return 0;
