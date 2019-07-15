local loaded = false
local bustedRunner = require "busted.runner"

return function(options)
  if loaded then return function() end else loaded = true end
  bustedRunner(options.bustedArgs)
end
