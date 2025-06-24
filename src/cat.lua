local cat = {}
string.split = string.split or function(str, sep)
    local result = {}
    for match in (str .. sep):gmatch("(.-)" .. sep) do
        table.insert(result, match)
    end
    return result
end

cat.global = {}
cat.globalIds = {}

local Type = {
    UNDEFINED = 0,
    STRING = 1,
    LINK = 2,
    NUMBER = 3,
    ARRAY = 4,
    FUNCTION = 5
}

cat.load = function(code)
    local lines = string.split(code, "\n")
    local state = {}
    local memory = {}
    local lengths = {}
    local length = nil
    -- .str
    local strings = string.split(lines[Type.STRING], " ")
    for i = 1, #strings do
        strings[i] = strings[i]:gsub('\\\\', '\\'):gsub('\\n"', '\n'):gsub('\\c', ' ')
        table.insert(memory, i)
    end
    length = #strings
    table.insert(lengths, length)
    state.str = strings
    -- .lin
    local links = string.split(lines[Type.LINK], " ")
    for i = 1, #links do
        local globalId = cat.globalIds[links[i]]
        links[i] = globalId
        table.insert(memory, globalId)
    end
    state.lin = links
    length = length + #links
    table.insert(lengths, length)
    -- .num
    local numbers = string.split(lines[Type.NUMBER], " ")
    for i = 1, #numbers do
        local number = tonumber(numbers[i])
        numbers[i] = number
        table.insert(memory, number)
    end
    state.num = numbers
    length = length + #numbers
    table.insert(lengths, length)
    -- .arr
    local arrays = string.split(lines[Type.ARRAY], " ")
    for i = 1, #arrays do
        arrays[i] = string.split(arrays[i], ",")
        for j = 1, #arrays[i] do
            arrays[i][j] = tonumber(arrays[i][j])
        end
        table.insert(memory, i)
    end
    state.arr = arrays
    length = length + #arrays
    table.insert(lengths, length)
    -- .fun
    local functions = {}
    for i = Type.FUNCTION, #lines do
        functions[i - Type.FUNCTION] = string.split(lines[i], " ")
        table.insert(memory, i)
    end
    length = length + #functions
    table.insert(lengths, length)
    state.fun = functions
    state.mem = memory
    state.len = lengths
    return state
end

cat.type = function(state, addr)
    for i = 1, #state.len do
        if addr <= state.len[i] then
            return i
        end
    end
    return Type.UNDEFINED
end

cat.get = function(state, addr)
    return state.mem[addr]
end

cat.set = function(state, addr, value)
    state.mem[addr] = value
end
