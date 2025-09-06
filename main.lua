local mnemonics = {
    HLT = 000, -- stop
    ADD = 100, -- add contents of x to accumulator
    SUB = 200, -- subtract contents of x from accumulator

    STA = 300, -- store accumulator val in mem x
    STO = 300,

    LDA = 500, -- store contents of x in accumulator
    -- BRA = 600, -- branching is not implemented for now
    -- BRZ = 700,
    -- BRP = 800,

    INP = 901, -- request input into accumulator
    OUT = 902, -- output accumulator value as number
    OTC = 922, -- output accumulator value as ascii character
}

local fs = require("fs")
require("string-extensions")

local fmt = string.format
local function pf(...) p(fmt(...)) end

local src = fs.readFileSync("main.lmc")
if not src then error("main.lmc file not found") end

src = string.split(src:gsub("\r\n", "\n"), "\n")

local function zero(x)
    return x or 0
end

local instructions = {}
for _, line in pairs(src) do
    if string.startswith(line, "//") then goto continue end

    local a = string.split(line, " ")
    local shorthand = a[1]
    local operand = a[2]

    if operand and not tonumber(operand) then error(fmt("Operand on line %s should be a number", _)) end

    table.insert(instructions, {
        literal = shorthand,
        opcode = mnemonics[shorthand],
        operand = zero(tonumber(operand))
    })

    ::continue::
end

p(instructions)

local mem = {}
for i = 1, 100 do
    mem[i] = 0
end

for pos, instruction in pairs(instructions) do
    mem[pos] = instruction.opcode + zero(instruction.operand)
end

p(mem)

local pcounter = 0
local accumulator = 0

local opcode = 0
local address = 0

local function printSnapshot(...)
    print(fmt("PC: %s ; ACCUMULATOR: %s ; INSTRUCTION: %s", pcounter, accumulator, fmt(...)))
end

-- synchronous wrapper for io input because luvit is weird with input
local function input(prompt)
    local co = coroutine.running()

    process.stdout:write(prompt or "")
    process.stdin:resume()
    process.stdin:once("data", function(line)
        process.stdin:pause()
        local n = tonumber(line) or 0
        coroutine.resume(co, n % 1000)
    end)

    return coroutine.yield()
end

local function step()
    pcounter = pcounter + 1
    local i = mem[pcounter]
    if i == 00 or not i then
        print()
        print()
        printSnapshot("HALT")
        p(pcounter, accumulator, mem)
        os.exit(0)
    end

    opcode = math.floor(i / 100)
    address = i % 100

    if opcode == 1 then
        printSnapshot("accumulator + M%s", mem[address])
        accumulator = accumulator + mem[address]
    elseif opcode == 2 then
        printSnapshot("accumulator - M%s", mem[address])
        accumulator = accumulator - mem[address]
    elseif opcode == 3 then
        printSnapshot("M%s = accumulator", address)
        mem[address] = accumulator
    elseif opcode == 5 then
        printSnapshot("accumulator = M%s", address)
        accumulator = mem[address]
    elseif opcode == 9 then
        if address == 1 then
            printSnapshot("accumulator = requested input")
            accumulator = input("[INP] enter 0..999: ")
        elseif address == 2 then
            printSnapshot("output accumulator as num")
            p(accumulator)
        elseif address == 22 then
            printSnapshot("output accumulator as ascii char")
            p(string.char(accumulator))
        end
    end

    step()
end

step()
