local mnemonics = {
    HLT = 0, -- stop
    ADD = 1, -- add contents of x to accumulator
    SUB = 2, -- subtract contents of x from accumulator

    STA = 3, -- store accumulator val in mem x
    STO = 3,

    LDA = 5, -- store contents of x in accumulator
    -- BRA = 6, -- branching is not implemented for now
    -- BRZ = 7,
    -- BRP = 8,

    INP = 9.01,
    OUT = 9.02,
    OTC = 9.22,
}

local fs = require("fs")
require("string-extensions")

local fmt = string.format
local function pf(...) p(fmt(...)) end

local src = fs.readFileSync("main.fmc")
src = string.split(src:gsub("\r\n", "\n"), "\n")

local function zero(x)
    return x or 0
end

local instructions = {}
for _, line in pairs(src) do
    local a = string.split(line, " ")
    local mnemonic = a[1]
    local operand = a[2]

    if operand and not tonumber(operand) then error(fmt("Operand on line %s should be a number", _)) end

    table.insert(instructions, {
        literal = mnemonic,
        opcode = (mnemonics[mnemonic] * 100),
        operand = zero(tonumber(operand))
    })
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

local function step()
    pcounter = pcounter + 1
    local i = mem[pcounter]
    if i == 00 or not i then
        print()
        print()
        printSnapshot("HALT")
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
            -- TODO
            local random = math.random(1, 60)
            p("UNIMPLEMENTED opcode 901: generated random input", random)
            accumulator = random
        elseif address == 2 then
            printSnapshot("output accumulator as num")
            print("OUTPUT:", accumulator)
        elseif address == 22 then
            printSnapshot("output accumulator as ascii char")
            print("OUTPUT:", string.char(accumulator))
        end
    end

    step()
end

step()
