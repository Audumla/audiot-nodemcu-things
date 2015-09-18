local BootstrapThing = {}
            
function BootstrapThing:doThings(tbt)
    package.loaded.BootstrapThing = nil

    local function indexMeta(t, k)
--                    print("[L] - Finding:"..t.thing..":"..k.." - "..node.heap())
            local ext = loadfile("meta"..k..".lua")
            if ext == nil then
                ext = loadfile(t.thing..k..".lua")
                if ext == nil then
                    for i,v in ipairs(things) do    
                        if v.thing == k then return v end
                    end
                end
            end
            return ext
        end       

    for i, t in pairs(tbt) do
        local sn = string.gsub(string.lower(t.thing),"thing","")
        local t = setmetatable(t,{ __index = indexMeta})
        t.thing = sn
        t[1] = i
    end
    return tbt
end

return BootstrapThing
