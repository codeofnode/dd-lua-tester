local path = require 'pl.path'
local json = require 'json'

function readAll(file)
  local f = assert(io.open(file, "r"))
  local content = f:read("*all")
  f:close()
  return content
end

local ret = {}

local getTrace = function(filename, info)
  local index = info.traceback:find('\n%s*%[C]')
  info.traceback = info.traceback:sub(1, index)
  return info
end

ret.match = function(ddlt, filename)
  return path.extension(filename) == '.json'
end

ret.load = function(ddlt, filename)
  local file, err = readAll(filename)
  if not file then
    ddlt.publish(ddlt.appName, ':FILE_NOT_LOADED_WARNING - ', filename, ' - ', err)
  end
  return file, getTrace
end

return ret
