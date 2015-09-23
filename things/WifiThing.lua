local WifiThing = {}

function WifiThing:processStatus(lastState)
    local status = wifi.sta.status() 
    if status ~= 1 then
        if status == 5 then
            if not self.connected then
                self.connected = true
                print("[W] - Connected ["..self.ssid.."]"); 
                tmr.alarm(timerW,30000,1,function() 
                        if wifi.sta.status() ~= 5 then self:processStatus() end 
                    end);
                return self:stoodUp(); 
            end
        else
            if self.connected then
                print("[W] - Status ["..status.."]"); 
                return self:standDown( self.standUp )
            else
                return self:standUp()
            end
        end
    else
        tmr.alarm(timerW,300,0, function () self:processStatus() end)
    end
end

function WifiThing:standUp()
    print("[W] - Connecting ["..self.ssid.."]"); 
    self.connected = false
    wifi.setmode(wifi.STATION)   
    wifi.sta.config(self.ssid, self.password,0)
    wifi.sta.connect() 
    return tmr.alarm(timerW,300,0, function() self:processStatus() end)
end

function WifiThing:standDown()
    tmr.alarm(timerW,10,0,noop)
    wifi.sta.disconnect()
    self.connected = false
    return self:stoodDown()
end

return WifiThing
