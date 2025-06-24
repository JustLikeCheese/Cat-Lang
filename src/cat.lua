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
    -- .str
    local strings = string.split(lines[Type.STRING], " ")
    for i = 1, #strings do
        strings[i] = strings[i]:gsub('\\\\', '\\'):gsub('\\n"', '\n'):gsub('\\c', ' ')
    end
    state.str = strings
    -- .lin
    local links = string.split(lines[Type.LINK], " ")
    for i = 1, #links do
        links[i] = cat.globalIds[links[i]]
    end
    state.lin = links
    -- .num
    local numbers = string.split(lines[Type.NUMBER], " ")
    for i = 1, #numbers do
        numbers[i] = tonumber(numbers[i])
    end
    state.num = numbers
    -- .arr
    local arrays = string.split(lines[Type.ARRAY], " ")
    for i = 1, #arrays do
        arrays[i] = string.split(arrays[i], ",")
        for j = 1, #arrays[i] do
            arrays[i][j] = tonumber(arrays[i][j])
        end
    end
    state.arr = arrays
    -- .fun
    local functions = {}
    for i = Type.FUNCTION, #lines do
        functions[i - Type.FUNCTION] = string.split(lines[i], " ")
    end
    state.fun = functions
    return state
end
