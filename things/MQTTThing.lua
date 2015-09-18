local MQTTThing = {}

function MQTTThing:publish(topic,data)
    if self.started == true then
        table.insert(self.pq,topic)
        table.insert(self.pq,data)
        if self.posting ~= true or table.getn(self.pq) > 6 then
            local function post()
                if table.getn(self.pq) ~= 0 then
                    local topic = table.remove(self.pq,1)
                    local data = table.remove(self.pq,1)
--                    print("[Q] - Publish:"..topic..":"..data) 
                    self.posting = true
                    return self.msgQueue:publish(topic,data,0,0,function() post() end)
                else
                    self.posting = false
                end
            end   
            return post()
        end
    end
end

function MQTTThing:connected(msgq)
    self.msgQueue = msgq
    self.pq = {}
    self:stoodUp()
end

function MQTTThing:standUp()
    self.msgAction = {}
    local msgq = mqtt.Client(tmr.now(),120,"","")    
    msgq:on("offline", function() 
            print("[Q] - Lost Connection") 
            self.msgQueue = nil
            self:standDown(function() self:standUp() end) 
        end)
    msgq:on("message", function(con,topic,data)
            self.hasMessage = true
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
                                    self:publish(ntT..string.sub(topic,string.len(evT)+1),retv)
                                end
                            end
                        end
                    end
                    self.hasMessage = false
                end)
    msgq:lwt("lwt", "offline" , 0, 0)
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
    sf = function(self)
            t, a = next(ta,t)
            if t ~= nil then
               return self.msgQueue:subscribe(t,0, function() sf(self) end)
            else
                return cb(h)
            end
        end
    return sf(self)
end

return MQTTThing
