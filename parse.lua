#!/usr/bin/env th

open = io.open

function read_file(path)
    local file = open(path, "r") -- r read mode and b binary mode
    local lines = {}

    for line in io.lines(path) do
        local corpus,
        label,
        id,
        quotetext,
        responsetext = line:match("([^,]*),([^,]*),([^,]*),([^,]*)([^,]*)")
        lines[#lines+1] = { corpus = corpus, label = label, label = label, quotetext = quotetext, responsetext = responsetext }

    end

    file:close()

    return lines
end

lines = read_file("sarcasm_v2.csv")
for _, line in ipairs(lines) do
	print(("corpus: %s, id: %s, quotetext: %s"):format(line.corpus, line.id, line.quotetext))
end

return 0;
