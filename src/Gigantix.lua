local Gigantix = {}

-- Updated notation table using standard short scale abbreviations
local NOTATION = {
	'',    -- 10^0 (1)
	'K',   -- 10^3 (Thousand)
	'M',   -- 10^6 (Million)
	'B',   -- 10^9 (Billion)
	'T',   -- 10^12 (Trillion)
	'Qa',  -- 10^15 (Quadrillion)
	'Qi',  -- 10^18 (Quintillion)
	'Sx',  -- 10^21 (Sextillion)
	'Sp',  -- 10^24 (Septillion)
	'Oc',  -- 10^27 (Octillion)
	'No',  -- 10^30 (Nonillion)
	'Dc',  -- 10^33 (Decillion)
	'UD',  -- 10^36 (Undecillion)
	'DD',  -- 10^39 (Duodecillion)
	'TD',  -- 10^42 (Tredecillion)
	'QaD', -- 10^45 (Quattuordecillion)
	'QiD', -- 10^48 (Quindecillion)
	'SxD', -- 10^51 (Sedecillion)
	'SpD', -- 10^54 (Septendecillion)
	'OcD', -- 10^57 (Octodecillion)
	'NoD', -- 10^60 (Novendecillion)
	'Vg',  -- 10^63 (Vigintillion)
	'UVg', -- 10^66 (Unvigintillion)
	'DVg', -- 10^69 (Duovigintillion)
	'TVg', -- 10^72 (Tresvigintillion)
	'QaVg',-- 10^75 (Quattuorvigintillion)
	'QiVg',-- 10^78 (Quinvigintillion)
	'SxVg',-- 10^81 (Sesvigintillion)
	'SpVg',-- 10^84 (Septemvigintillion)
	'OcVg',-- 10^87 (Octovigintillion)
	'NoVg',-- 10^90 (Novemvigintillion)
	'Tg',  -- 10^93 (Trigintillion)
	'UTg', -- 10^96 (Untrigintillion)
	'DTg', -- 10^99 (Duotrigintillion)
	'TTg', -- 10^102 (Trestrigintillion)
	'QaTg',-- 10^105 (Quattuortrigintillion)
	'QiTg',-- 10^108 (Quintrigintillion)
	'SxTg',-- 10^111 (Sestrigintillion)
	'SpTg',-- 10^114 (Septentrigintillion)
	'OcTg',-- 10^117 (Octotrigintillion)
	'NoTg',-- 10^120 (Noventrigintillion)
	'Qag', -- 10^123 (Quadragintillion)
	'Qig', -- 10^153 (Quinquagintillion)
	'Sxg', -- 10^183 (Sexagintillion)
	'Spg', -- 10^213 (Septuagintillion)
	'Ocg', -- 10^243 (Octogintillion)
	'Nog', -- 10^273 (Nonagintillion)
	'Ce',  -- 10^303 (Centillion)
	'UCe', -- 10^306 (Uncentillion)
	'DCe', -- 10^309 (Duocentillion)
	'TCe', -- 10^312 (Trecentillion)
	'QaCe',-- 10^315 (Quattuorcentillion)
	'QiCe',-- 10^318 (Quincentillion)
	'SxCe',-- 10^321 (Sexcentillion)
	'SpCe',-- 10^324 (Septencentillion)
	'OcCe',-- 10^327 (Octocentillion)
	'NoCe',-- 10^330 (Novemcentillion)
	'∞'    -- Infinity (for numbers beyond 10^330)
}

-- Lookup table for suffix multipliers (automatically generated)
local suffixLookup = {}
for i = 1, #NOTATION do
	local v = NOTATION[i]
	suffixLookup[v:lower()] = (i - 1) * 3
end


-- Caching global functions for performance optimization
local math_floor = math.floor
local string_rep = string.rep
local string_format = string.format
local table_concat = table.concat
local table_create = table.create

-- Precompute power values to avoid repeated calculations
local powerCache = {}
for i = 1, #NOTATION do
	powerCache[i] = 10 ^ (i * 3)
end

--[[ 
    Convert notation like "15K" to "15000"
    Example:
    local result = Gigantix.convertNotationToNumber("15K")
    print(result) -- Output: "15000"
]]
function Gigantix.convertNotationToNumber(notation: string): string
	-- Remove commas or periods used as thousand separators
	notation = notation:gsub("[,.]", "")

	-- Extract numeric and suffix parts
	local number = notation:match("[%d%.]+")
	local suffix = notation:match("%a+")

	if suffix then
		suffix = suffix:lower()
		local zerosCount = suffixLookup[suffix]
		if zerosCount then
			number = number .. string_rep("0", zerosCount)
		end
	end

	return number
end

--[[ 
    Convert a string number to an array of numbers
    Example:
    local total = Gigantix.convertStringToArrayNumber("15000")
    print(total) -- Output: {15, 0, 0}
]]
function Gigantix.convertStringToArrayNumber(num: string): {number}
	local len = #num
	local blocksCount = math.ceil(len / 3)
	local arr = table_create(blocksCount)
	local index = 1

	for i = len, 1, -3 do
		local start = math.max(1, i - 2)
		arr[index] = tonumber(num:sub(start, i))
		index = index + 1
	end

	return arr
end

--[[ 
    Get short notation for a large number
    Example:
    local total = Gigantix.convertStringToArrayNumber("15000")
    local result = Gigantix.getShortNotation(total)
    print(result) -- Output: "15K"
]]
function Gigantix.getShortNotation(total: {number}): string
	local numString = Gigantix.getLongNotation(total)
	local num = tonumber(numString) or 0
	local suffixIndex = math_floor((#numString - 1) / 3) + 1

	-- Handle infinity case
	if suffixIndex > #NOTATION then
		return "∞"
	end

	local divisor = powerCache[suffixIndex - 1] or 1
	local shortNum = num / divisor
	local rounded = math_floor(shortNum * 100 + 0.5) / 100
	local integerPart = math_floor(rounded)
	local fraction = rounded - integerPart

	if fraction == 0 then
		return tostring(integerPart) .. NOTATION[suffixIndex]
	else
		local firstDecimal = math_floor(fraction * 10)
		return tostring(integerPart) .. "." .. tostring(firstDecimal) .. NOTATION[suffixIndex]
	end
end

--[[ 
    Get long notation for a large number
    Example:
    local total = Gigantix.convertStringToArrayNumber("15000")
    local result = Gigantix.getLongNotation(total)
    print(result) -- Output: "15000"
]]
function Gigantix.getLongNotation(total: {number}): string
	local n = #total
	local parts = table_create(n)

	for i = 1, n do
		local block = total[n - i + 1]
		parts[i] = (i == 1) and tostring(block) or string_format("%03d", block)
	end

	return table_concat(parts)
end

--[[ 
    Add two large numbers represented as arrays
    Example:
    local total = Gigantix.convertStringToArrayNumber("15000")
    local num = Gigantix.convertStringToArrayNumber("5000")
    local resultCalc = Gigantix.addLargeNumbers(total, num)
    local result = Gigantix.getLongNotation(resultCalc)
    print(result) -- Output: "20000"
]]
function Gigantix.addLargeNumbers(total: {number}, num: {number}): {number}
	local maxLength = math.max(#total, #num)
	local result = table_create(maxLength + 1)
	local carry = 0

	for i = 1, maxLength do
		local a = total[i] or 0
		local b = num[i] or 0
		local sum = a + b + carry
		result[i] = sum % 1000
		carry = math_floor(sum / 1000)
	end

	if carry > 0 then
		result[maxLength + 1] = carry
	end

	return result
end

--[[ 
    Subtract one large number from another represented as arrays
    Example:
    local total = Gigantix.convertStringToArrayNumber("15000")
    local num = Gigantix.convertStringToArrayNumber("5000")
    local resultCalc = Gigantix.subtractLargeNumbers(total, num)
    local result = Gigantix.getLongNotation(resultCalc)
    print(result) -- Output: "10000"
]]
function Gigantix.subtractLargeNumbers(total: {number}, num: {number}): {number}
	local maxLength = math.max(#total, #num)
	local result = table_create(maxLength)
	local borrow = 0

	for i = 1, maxLength do
		local a = total[i] or 0
		local b = num[i] or 0
		local diff = a - b - borrow

		if diff < 0 then
			diff = diff + 1000
			borrow = 1
		else
			borrow = 0
		end

		result[i] = diff
	end

	while #result > 1 and result[#result] == 0 do
		result[#result] = nil
	end

	return result
end


--[[
	Check if a is greather than or equal to b
	Example:
	local total = Gigantix.convertStringToArrayNumber("15000")
	local num = Gigantix.convertStringToArrayNumber("10000")
	local isGreaterOrEqual = Gigantix.isGreaterOrEqual(total, num)
	print(isGreaterOrEqual) -- Output: true
]]
function Gigantix.isGreaterOrEqual(a: {number}, b: {number}): boolean
	-- Compare the lengths of the arrays
	if #a > #b then
		return true
	elseif #a < #b then
		return false
	end

	-- Compare each block from the highest to the lowest
	for i = #a, 1, -1 do
		if a[i] > b[i] then
			return true
		elseif a[i] < b[i] then
			return false
		end
	end

	-- If all blocks are equal, return true
	return true
end

return Gigantix
