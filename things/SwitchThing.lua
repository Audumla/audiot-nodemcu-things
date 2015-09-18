local SwitchThing = {}

function SwitchThing:standUp() 
    for gpioids,name in pairs(self.gpio) do 
        local gpioid = tonumber(gpioids)
--        log("P","Configured ["..name.."]")
        gpio.trig(gpioid,"down",function() 
            self.mqtt:publish(swT..gpioid.."",1)   
        end)
        gpio.mode(gpioid,gpio.INT,gpio.FLOAT)
        gpio.write(gpioid,gpio.LOW)
    end
    return self:stoodUp()
end

function SwitchThing:standDown()
    for gpioids,name in pairs(self.gpio) do 
        gpio.trig(tonumber(gpioids),"down",noop)
    end    
    return self:stoodDown()
end

return SwitchThing
