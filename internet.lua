local socket = require("socket")
            
local test = socket.tcp()
test:settimeout(1000)                   -- Set timeout to 1 second
            
local testResult = test:connect("www.google.com", 80)
local testResult1 = test:connect("www.yandex.ru", 80)        -- Note that the test does not work if we put http:// in front

isConnected = false
if not(testResult == nil) or not(testResult1 == nil) then
    isConnected = true
end
            
test:close()
test = nil

return isConnected