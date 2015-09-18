local BootstrapThing = {}

            
function BootstrapThing:doThings(things)
    package.loaded.BootstrapThing = nil

    local indexMeta = function(t, key)
            if filelist["meta_"..key..".lc"] ~= nil then
                return loadfile("meta_"..key..".lc")
            elseif filelist[t.thing.."_"..key..".lc"] ~= nil then
                return loadfile(t.thing.."_"..key..".lc")
            else
                for i,v in ipairs(things) do    
                    if v.thing == key then return v end
                end
            end
        end       

    filelist = file.list()
    for i, t in pairs(things) do
        local name = string.gsub(string.lower(t.thing),"thing","")
        local t = setmetatable(t,{ __index = indexMeta})
        t.thing = name
        t[1] = i
    end
    return things
end

return BootstrapThing
