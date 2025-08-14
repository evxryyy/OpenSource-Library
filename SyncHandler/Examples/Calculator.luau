-- Script 1: Setting up the handler
local SyncHandler = require(path.to.SyncHandler)

-- Create a handler for calculator operations
local calculatorHandler = SyncHandler.new("Calculator")

-- Register a handler that performs calculations
local disconnect = calculatorHandler:OnInvoke(function(operation, a, b)
	print("Handler received:", operation, a, b)

	if operation == "add" then
		return a + b
	elseif operation == "multiply" then
		return a * b
	elseif operation == "divide" then
		if b == 0 then
			return nil, "Cannot divide by zero"
		end
		return a / b
	else
		return nil, "Unknown operation"
	end
end)

-- The handler is now ready to receive invocations
-- Invoke some calculations
local result1 = calculatorHandler:Invoke("add", 5, 3)
print("5 + 3 =", result1) -- Output: 5 + 3 = 8

local result2 = calculatorHandler:Invoke("multiply", 4, 7)
print("4 * 7 =", result2) -- Output: 4 * 7 = 28

local result3, error = calculatorHandler:Invoke("divide", 10, 2)
print("10 / 2 =", result3) -- Output: 10 / 2 = 5

-- Try dividing by zero
local result4, error = calculatorHandler:Invoke("divide", 10, 0)
if error then
	print("Error:", error) -- Output: Error: Cannot divide by zero
end
