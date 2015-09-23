local ManageThing = {}

function ManageThing:statusUpdate(wifiAPs)
--    return wifi.sta.getap({["ssid"]=self.wifi.ssid},1,
--        function(wifiAPs)
            local state = {}
            state.ipaddress = wifi.sta.getip()
            state.mac = wifi.sta.getmac()
            state.thing = dn
            state.memory = node.heap(0)
--            state.wifi = wifiAPs
            return self.mqtt:publish(stT,cjson.encode(state)) 
--        end)
end

function ManageThing:saveFile(topic,data)
    for fileName in string.gmatch(topic, "save%/(%s*)") do
        file.remove(fileName)
        file.open(fileName)
        file.write(data)
        file.close(fileName)
        if string.sub(fileName,string.len(fileName)-3) == "lua" then
            node.compile(fileName)
            file.remove(fileName)
        end
    end
end

function ManageThing:standUp()    
    return self.mqtt:setAction(
        {[rsT]="restart",
         [svT]="saveFile"}
        ,self,function(self) 
                 tmr.alarm(timerM,intervalStatus, 1, function() 
                     self:statusUpdate()     
                end)
                 return self:stoodUp() 
              end)
end

function ManageThing:standDown()
    tmr.stop( timerM )
    return self:stoodDown() 
end

return ManageThing
