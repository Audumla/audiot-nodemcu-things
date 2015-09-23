dofile("settings.lua")
node.setcpufreq(node.CPU160MHZ)
thingsStatus=0
function noop(self) end

th = require "Things" 
th.debug = false
th.clean = false  
th.flash = false 


--tmr.alarm(loadTimerId,1500,0, function()
    --local loader = require("LoaderThing")
    --loader:standUp()
--end)
