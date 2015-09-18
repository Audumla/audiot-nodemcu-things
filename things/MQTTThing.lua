local MQTTThing = {}

function MQTTThing:onMessage(con,topic,data)
    print("[Q] - Received:"..topic..":"..data)
    for h,a in pairs(self.msgAction) do
        for i,v in pairs(a) do
            if string.match(topic,i) ~= nil then
                local retv = nil
                if type(v) == "function" then
                    retv = v(h,topic,data)
                else
                    retv = h[v](h,topic,data)
                end
                if retv ~= nil then
                    return self.msgQueue:publish("audiot/notify",retv,0,0)
                    --ntT..string.sub(topic,string.len(evT)+1),retv,0,0)
                end
            end
        end
    end
end

function MQTTThing:connected(msgq)
    self.msgQueue = msgq
    self.msgQueue:on("offline", function() 
            print("[Q] - Lost Connection") 
            self:standDown(self.standUp) 
        end)
    self.msgQueue:on("message", 
    function(con,topic,data)
--        print("[Q] - Received:"..topic..":"..data)
        for h,a in pairs(self.msgAction) do
            for i,v in pairs(a) do
                if string.match(topic,i) ~= nil then
                    local retv = nil
                    if type(v) == "function" then
                        retv = v(h,topic,data)
                    else
                        retv = h[v](h,topic,data)
                    end
                    if retv ~= nil then
                        return self.msgQueue:publish(ntT..string.sub(topic,string.len(evT)+1),retv,0,0)
                    end
                end
            end
        end
    end)    
--    function(con,topic,data) 
--            return self:onMessage(con,topic,data) 
--        end)
    self.msgQueue:lwt("lwt", "offline" , 0, 0)
    self:stoodUp()
end

function MQTTThing:standUp()
    self.msgAction = {}
    local msgq = mqtt.Client(tmr.now(),120,"","")    
    msgq:connect(self.host, self.port, 0, function(msgq)
            tmr.alarm(timerQ,1,1,noop)
            self:connected(msgq)
        end)
end

function MQTTThing:standDown()
    tmr.alarm(timerQ,1,1,noop)
    if self.msgQueue ~= nil then
        self.msgQueue:on("offline", function() 
                tmr.alarm(timerQ,10,0, function()
                        self.msgQueue = nil 
                        self.msgAction = nil
                        self:stoodDown() 
                    end)
                end)
            
        self.msgQueue:close()        
    else
        self.msgAction = nil
        return self:stoodDown()
    end
end

function MQTTThing:setAction(ta,h,cb)
    if self.msgAction[h] == nil then
        self.msgAction[h] = {}
    end
    for t,a in pairs(ta) do
        self.msgAction[h][string.gsub(t,"[(%^%$%(%)%%%.%[%]%*%+%-%?#)]", function(a) 
                if a == "#" then return ".*" else return "%"..a end
            end)] = a
    end
    local sf, t, a
    sf = function()
            t, a = next(ta,t)
            if t ~= nil then
               return self.msgQueue:subscribe(t,0, function() sf() end)
            else
                return cb(h)
            end
        end
    return sf()
end

return MQTTThing
