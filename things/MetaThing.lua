local MetaThing = {}

function MetaThing:standDown(cb)
    tmr.alarm(0,20,0, function ()
        if cb ~= nil then
            self.stoodDown = function(self) 
                    tmr.alarm(0,10,0,noop)
                    self.started = false
                    cb(self)
                end
        else
            self.stoodDown = function(self) 
                    tmr.alarm(0,10,0,noop)
                    self.started = false
                    print("[L] - Stopped:"..self.thing..":"..node.heap().."")
                end
        end
        local sd = loadfile(self.thing.."_standDown.lc")
        tmr.alarm(0,20, 0, function()
                local status, err = pcall(function()
                        if self.chain == nil or self.chain.started ~= true then
                            if sd == nil then return self:stoodDown() else return sd(self) end
                        else
                            print("[L] - Stopping:"..self.chain.thing..":"..node.heap().."")
                            local ch = self.chain
                            return ch:standDown(function(self) 
                                    if sd == nil then return self:stoodDown() else return sd(self) end
                                end)
                        end
                    end)
                if status ~= true then
                    print("[L] - Error Standing down ["..self.thing.."]["..err.."]")
                end
            end)
    end)
end

function MetaThing:stoodUp()
    self.started = true
    tmr.alarm(0,100,0, function ()
        tmr.alarm(0,10,0,noop)
        if things[self[1]+1] ~= nil then
            return things[self[1]+1]:standUp()
        else
            print("[L] - Things Started")
            thingsStatus = 1
        end
    end)
end

function MetaThing:standUp()
    thingsStatus = 3
    print("[L] - Starting "..self.thing..":"..node.heap().."")
    local tmo    
    if self.timeout == nil then tmo = defaultTimeout else tmo = self.timeout end
    local status, err = pcall(function()
        tmr.alarm(0,tonumber(tmo), 0, function()
                print("[L] - "..self.thing..":standUp Timeout")
                return self.stop()
            end)
        if file.list()[self.thing.."_standUp.lc"] ~= nil then
            return loadfile(self.thing.."_standUp.lc")(self)
        else
            return self:stoodUp()
        end
    end)
    if status ~= true then
        print("[L] - Error Standing up ["..self.thing.."]["..err.."]")
    end
end

function MetaThing:stop()
    thingsStatus = 2
    local sd = function(self)
            for k, v in ipairs(things) do
                ta[k] = nil
            end
            thingsStatus = 0
        end
    things[1]:standDown(sd)
end

function MetaThing:restart()
    return things[1]:standDown(
        function()
            node.restart()
        end)
end

return MetaThing
