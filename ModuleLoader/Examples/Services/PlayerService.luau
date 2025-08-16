local module = {}
module.Name = script.Name
module.IsStarted = false

function module:Init()
	print(self.Name,"init")
end

function module:Start()
	self.IsStarted = true
	print(self.Name,"Start")
end

function module:Cleaning()
	print(self.Name,"Cleaning")
end

return module
