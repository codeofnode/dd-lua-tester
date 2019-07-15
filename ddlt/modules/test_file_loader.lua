return function(ddlt, loaders)
  local path = require 'pl.path'
  local dir = require 'pl.dir'
  local tablex = require 'pl.tablex'
  local fileLoaders = {}

  for _, v in pairs(loaders) do
    local loader = require('ddlt.modules.files.'..v)
    fileLoaders[#fileLoaders+1] = loader
  end

  local getTestFiles = function(rootFile, patterns, options)
    local fileList

    if path.isfile(rootFile) then
      fileList = { rootFile }
    elseif path.isdir(rootFile) then
      local getfiles = options.recursive and dir.getallfiles or dir.getfiles
      fileList = getfiles(rootFile)

      fileList = tablex.filter(fileList, function(filename)
        local basename = path.basename(filename)
        for _, patt in ipairs(options.excludes) do
          if patt ~= '' and basename:find(patt) then
            return nil
          end
        end
        for _, patt in ipairs(patterns) do
          if basename:find(patt) then
            return true
          end
        end
        return #patterns == 0
      end)

      fileList = tablex.filter(fileList, function(filename)
        if path.is_windows then
          return not filename:find('%\\%.%w+.%w+', #rootFile)
        else
          return not filename:find('/%.%w+.%w+', #rootFile)
        end
      end)
    else
      ddlt.publish({ 'error' }, {}, nil, 'output.file_not_found:'..rootFile, {})
      fileList = {}
    end

    table.sort(fileList)
    return fileList
  end

  local getAllTestFiles = function(rootFiles, patterns, options)
    local fileList = {}
    for _, root in ipairs(rootFiles) do
      tablex.insertvalues(fileList, getTestFiles(root, patterns, options))
    end
    return fileList
  end

  -- runs a testfile, loading its tests
  local loadTestFile = function(ddlt, filename)
    for _, v in pairs(fileLoaders) do
      if v.match(ddlt, filename) then
        return v.load(ddlt, filename)
      end
    end
  end

  local loadTestFiles = function(rootFiles, patterns, options)
    return getAllTestFiles(rootFiles, patterns, options)
  end

  return loadTestFiles, loadTestFile, getAllTestFiles
end
