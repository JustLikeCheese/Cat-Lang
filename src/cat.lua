local cat = {}
string.split = string.split or function(str, sep)
    local result = {}
    for match in (str .. sep):gmatch("(.-)" .. sep) do
        table.insert(result, match)
    end
    return result
end

local tonumbers = function(t)
    for i, v in ipairs(t) do
        t[i] = tonumber(v)
    end
    return t
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
    local types = {}
    local length = nil
    -- .str
    local strings = string.split(lines[Type.STRING], " ")
    for i = 1, #strings do
        strings[i] = strings[i]:gsub('\\\\', '\\'):gsub('\\n"', '\n'):gsub('\\c', ' ')
        table.insert(memory, i)
        table.insert(types, Type.STRING)
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
        table.insert(types, Type.LINK)
    end
    length = length + #links
    table.insert(lengths, length)
    state.lin = links
    -- .num
    local numbers = string.split(lines[Type.NUMBER], " ")
    for i = 1, #numbers do
        local number = tonumber(numbers[i])
        numbers[i] = number
        table.insert(memory, number)
        table.insert(types, Type.NUMBER)
    end
    length = length + #numbers
    table.insert(lengths, length)
    state.num = numbers
    -- .arr
    local arrays = {}
    local _arrayTokens = string.split(lines[Type.ARRAY], " ")
    local _arrayLength = 0
    local _array = nil
    for i = 1, #_arrayTokens do
        local _arrayToken = tonumber(_arrayTokens[i]) or 0 -- use 'or 0' to skip lua warnings
        if _array == nil then
            _arrayLength = _arrayToken
        elseif _arrayLength == 0 then
            _arrayLength = _arrayToken
            table.insert(arrays, _array)
            table.insert(memory, #arrays)
            table.insert(types, Type.ARRAY)
            _array = {}
        else
            table.insert(_array, _arrayToken)
            _arrayLength = _arrayLength - 1
        end
    end
    length = length + #arrays
    table.insert(lengths, length)
    state.arr = arrays
    -- .fun
    local functions = {}
    local functionArgs = {}
    local functionArgTypes = {}
    local functionReturns = {}
    local functionReturnTypes = {}
    for i = Type.FUNCTION, #lines do
        local _funcTokens = string.split(lines[i], " ")
        local _functionArgLength = _funcTokens[1]
        local _functionReturnLength = _funcTokens[2]
        local _functionArgs = {}
        local _functionArgTypes = {}
        local _functionReturns = {}
        local _functionReturnTypes = {}
        local _newFuncTokens = {}
        for j = 3, #_funcTokens do
            local _funcToken = tonumber(_funcTokens[j])
            if _functionArgLength > 0 then
                table.insert(_functionArgs, _funcToken)
                table.insert(_functionArgTypes, types(_funcToken))
                _functionArgLength = _functionArgLength - 1
            elseif _functionReturnLength > 0 then
                table.insert(_functionReturns, _funcToken)
                table.insert(_functionReturnTypes, types(_funcToken))
                _functionReturnLength = _functionReturnLength - 1
            else
                table.insert(_newFuncTokens, _funcToken)
            end
        end
        table.insert(functions, _newFuncTokens)
        table.insert(functionArgs, _functionArgs)
        table.insert(functionArgTypes, _functionArgTypes)
        table.insert(functionReturns, _functionReturns)
        table.insert(functionReturnTypes, _functionReturnTypes)
        table.insert(memory, #functions)
        table.insert(types, Type.FUNCTION)
    end
    length = length + #functions
    table.insert(lengths, length)
    state.fun = functions
    state.fun_args = functionArgs
    state.fun_arg_types = functionArgTypes
    state.fun_rets = functionReturns
    state.fun_ret_types = functionReturnTypes
    -- state
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

return cat
