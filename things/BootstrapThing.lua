local BootstrapThing = {}
            
function BootstrapThing:doThings(tbt)
    package.loaded.BootstrapThing = nil

    local function indexMeta(t, k)
        local status, ret = pcall(function()
                file.close()
                print("[L] - Finding:"..t.thing..":"..k..":"..node.heap())
                local ef = loadfile("meta"..k..".lua")
                if ef == nil then
                    ef = loadfile(t.thing..k..".lua")
                    if ef == nil then
                        for i,v in ipairs(things) do    
                            if v.thing == k then return v end
                        end
                        --print("[L] - No files ["..t.thing..k..".lua"..":meta"..k..".lua]")
                    else
                        return ef
                    end
                else
                    return ef
                end
            end)
            if status ~= true then
                print("[L] - Error Finding ["..t.thing..":"..k.."]["..ret.."]")
            end
            return ret
    end       

    for i, t in ipairs(tbt) do
        local sn = string.gsub(string.lower(t.thing),"thing","")
        local t = setmetatable(t,{ __index = indexMeta})
        t.thing = sn
        t[1] = i
    end
    return tbt
end

return BootstrapThing
