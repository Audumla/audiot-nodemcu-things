local MetaThing = {}

function MetaThing:standDown(cb)
    self.stoodDown = function(self) 
            tmr.alarm(0,10,0,noop)
            self.started = false
            if cb ~= nil then
                cb(self)
            else
                print("[L] - Stopped:"..self.thing..":"..node.heap().."")
            end
        end
    tmr.alarm(0,500, 0, function()
            local status, err = pcall(function()
                    print("[L] - Stopping:"..self.thing..":"..node.heap().."")
                    local function sd()
                        loadfile(self.thing.."standDown.lua")(self)
                    end
                    if things[self[1]+1] == nil or things[self[1]+1].started ~= true then
                        return sd(self) 
                    else
                        return things[self[1]+1]:standDown(sd)
                    end
                end)
            if status ~= true then
                print("[L] - Error Standing down ["..self.thing.."]["..err.."]")
            end
        end)
end

function MetaThing:stoodUp()
    tmr.wdclr()
    tmr.alarm(0,10,0,noop)
    self.started = true
    if things[self[1]+1] ~= nil then
        return things[self[1]+1]:standUp()
    else
        print("[L] - Things Started")
        thingsStatus = 1
    end
end

function MetaThing:standUp()
    thingsStatus = 3
    print("[L] - Starting "..self.thing..":"..node.heap().."")
    tmr.wdclr()
        local status, ret = pcall(function()
            local tmo    
            if self.timeout == nil then tmo = defaultTimeout else tmo = self.timeout end
            local realFnc = loadfile(self.thing.."standUp.lua")
            tmr.alarm(0,tonumber(tmo), 0, function()
                    print("[L] - "..self.thing..":standUp Timeout")
                    return self.stop()
                end)            
            return realFnc(self)
        end)
        if status ~= true then
            print("[L] - Error Standing up ["..self.thing.."]["..ret.."]")
        end
        return ret
end

function MetaThing:stop()
    thingsStatus = 2
    local sd = function(self)
            for k, v in ipairs(things) do
                things[k] = nil
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
