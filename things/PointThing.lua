local PointThing = {}

function PointThing:onAction(topic,msg)
    local value = tonumber(msg)
    if value ~= nil then
        for gpioid in string.gmatch(topic, "%/(%d+)") do
            local ngpioid = tonumber(gpioid)
            value = (value == 2 and (gpio.read(ngpioid) == 1 and 0 or 1 )) or value
            gpio.write(ngpioid,value)
        end
    end
    return value
end

function PointThing:standUp() 
    for gpioids,name in pairs(self.gpio) do 
        local gpioid = tonumber(gpioids)
--        log("P","Configured ["..name.."]")
        gpio.mode(gpioid,gpio.OUTPUT,gpio.FLOAT)
        gpio.write(gpioid,gpio.LOW)
    end
    
    return self.mqtt:setAction({[ptT]="onAction"},self,function(self) self:stoodUp() end)
end

function PointThing:standDown()
    return self:stoodDown()
end

return PointThing
