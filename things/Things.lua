local Things = {}

function Things:start()
    package.loaded.Things = nil
    if file.open("thing.config","r") ~= nil then
        local config = cjson.decode(file.read())
        file.close()
        if self.flash ~= false then
            local flasher = require "FlashThing"
            return flasher:flashAll(config,self.clean,self.debug, function()
                    tmr.alarm(0, 10 , 0 , noop)
                    local status, err = pcall(function()
                        things = require("BootstrapThing"):doThings(config)
                        things[1]:standUp()
                    end)
                    if status ~= true then
                        print("[L] - Error Starting ["..err.."]")
                    end
                end)
        else
            local status, err = pcall(function()
                things = require("BootstrapThing"):doThings(config)
                things[1]:standUp()
            end)
            if status ~= true then
                print("[L] - Error Starting ["..err.."]")
            end
        end        
    else
        print("[L] - Cannont find 'things.config'")
    end       
end

return Things
