local FlashThing = {}

function FlashThing:flashAll(config,clean,debug,cb)
    package.loaded.FlashThing = nil
    self.fileList = file.list()
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
        self.fileList = file.list()
    end
    local i, t
    local flfnc
    flfnc = function()
        i,t = next(config,i)
        if i ~= nil then
            local thlua = t.thing..".lua"
            if self.fileList[thlua] ~= nil then
                 self:flash(t.thing,debug)
            end
            return tmr.alarm(0,100,0,flfnc)
        else
            if self.fileList["MetaThing"..".lua"] ~= nil then
                self:flash("MetaThing",debug)
            end
            tmr.alarm(0,100,0,cb)
        end
    end
    tmr.alarm(0,100,0,flfnc)
end

function FlashThing:flash(thingName,debug)
    print("[L] - Flashing:"..thingName..":"..node.heap().."")            
    local thlua = thingName..".lua"
    if debug ~= true then
        node.compile(thlua)
    else
        local thlc = thingName..".lc"
        if self.fileList[thlc] ~= nil then file.remove(thlc) end
    end
    collectgarbage()
    local realThing = require(thingName)
    local sn = string.gsub(string.lower(thingName),"thing","")
    for i,v in pairs(realThing) do
        collectgarbage()
        if type(v) == "function" then
            local fn = sn.."_"..i..".lc"
            if self.fileList[fn] ~= nil then file.remove(fn) end
            file.open(fn, "w+")
            file.write(string.dump(v))
            file.close()
        end
        realThing[i] = nil
        
    end
    realThing = nil
    local thbak = thingName..".bak"
    if self.fileList[thbak] ~= nil then     
        file.remove(thbak)
    end
    file.rename(thlua,thbak)
    package.loaded[thingName] = nil
end

return FlashThing
