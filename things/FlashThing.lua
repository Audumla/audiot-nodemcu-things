local FlashThing = {}

function FlashThing:flashAll(config,clean,debug,cb)
    package.loaded.FlashThing = nil
    if clean == true then
        for i,t in ipairs(config) do
            local thbak = t.thing..".bak"
            local thlua = t.thing..".lua"
            if self.fileList[thlua] == nil and self.fileList[thbak] ~= nil then
                file.rename(thbak,thlua) 
            end
        end
        if self.fileList["MetaThing.lua"] == nil and self.fileList["MetaThing.bak"] ~= nil then
            file.rename("MetaThing.bak","MetaThing.lua")
        end
    end
    local i, t
    local flfnc
    flfnc = function()
        i,t = next(config,i)
        if i ~= nil then
            local thlua = t.thing..".lua"
            if file.open(thlua) == true then
                 self:flash(t.thing,debug)
            end
            return tmr.alarm(0,100,0,flfnc)
        else
            if file.open("MetaThing.lua") == true then
                self:flash("MetaThing",debug)
            end
            tmr.alarm(0,100,0,cb)
        end
    end
    tmr.alarm(0,100,0,flfnc)
end

function FlashThing:flash(thingName,debug)
    print("[L] - Flashing:"..thingName..":"..node.heap().."")            
    if debug ~= true then
        node.compile(thingName..".lua")
    else
        file.remove(thingName..".lc")
    end
    collectgarbage()
    local realThing = require(thingName)
    local sn = string.gsub(string.lower(thingName),"thing","")
    for i,v in pairs(realThing) do
        collectgarbage()
        if type(v) == "function" then
            local fn = sn..i..".lua"
            file.remove(sn..i..".lc")
            file.remove(sn.."_"..i..".lc")
--            safefnc = loadstring("return loadstring("..string.dump(v)..")")
            file.open(fn, "w+")
            file.write(string.dump(v))
            file.close()
        end
        realThing[i] = nil
        
    end
    realThing = nil
--    local thbak = thingName..".bak"
--    if self.fileList[thbak] ~= nil then     
--        file.remove(thbak)
--    end
--    file.rename(thlua,thbak)
    package.loaded[thingName] = nil
end

return FlashThing
