local dispatcher = {}

-- client activation
m = mqtt.Client(MQTT_CLIENTID, 60, "", "") -- no pass !

-- actions

local function switch_power_cb(m, pl)
	if pl == "true" then
	    print("MQTT : plug ON for ", MQTT_CLIENTID)
        if switch_power~=nil then switch_power("true") end
        SWITCH_STATE = 1
	else
		print("MQTT : plug OFF for ", MQTT_CLIENTID)
        if switch_power~=nil then switch_power("false") end
        SWITCH_STATE = 0
	end
end

local function set_id(m, pl)
    if pl then
        MQTT_CLIENTID = pl
    end
end

local function public_discovery(m, pl)
    if (pl == "all" or pl == MQTT_CLIENTID) then
        -- publish a message with data = hello, QoS = 0, retain = 0
        m:publish(MQTT_PREFIX .. "/discovery/" .. node.chipid(), "ID:" .. MQTT_CLIENTID .. ":IP:" .. wifi.sta.getip(), 0, 0, function(conn) 
            print("sent discovery") 
        end)
    end
end


-- events
m:lwt('/lwt', MQTT_CLIENTID .. " died !", 0, 0)
MQTT_CONNECTED = 0
m:on('connect', function(m)
	print('MQTT : ' .. MQTT_CLIENTID .. " connected to : " .. MQTT_HOST .. " on port : " .. MQTT_PORT)
	m:subscribe(MQTT_PREFIX .. '/#', 0, function (m)
		print('MQTT : subscribed to ', MQTT_PREFIX) 
        MQTT_CONNECTED = 1
        public_discovery(m,0)
	end)
end)

m:on('offline', function(m)
	print('MQTT : disconnected from ', MQTT_HOST)
   MQTT_CONNECTED = 0
end)

m:on('message', function(m, topic, pl)
	print('MQTT : Topic ', topic, ' with payload ', pl)
	if pl~=nil and dispatcher[topic] then
		dispatcher[topic](m, pl)
	end
end)


-- Start 
gpio.mode(GPIO_BTN, gpio.INPUT)
BTN_PRESSED = 0
-- Setup polling for button
tmr.alarm(0, 50, 1, function() 
--        print("PRESSED"..BTN_PRESSED.." GPIO"..gpio.read(GPIO_BTN))
        if(gpio.read(GPIO_BTN)==0 and BTN_PRESSED == 0) then
            BTN_PRESSED = 1
            if SWITCH_STATE==0 then
               if MQTT_CONNECTED == 1 then
               m:publish(MQTT_MAINTOPIC .. '/state', "true", 0, 1, function(conn) 
                   print("sent switch on command") 
               end)
               else
                   switch_power(m, "true")
               end
            elseif SWITCH_STATE==1 then
               if MQTT_CONNECTED == 1 then
               m:publish(MQTT_MAINTOPIC .. '/state', "false", 0, 1, function(conn) 
                   print("sent switch off command") 
               end)
               else 
                   switch_power(m, "false")
               end
            end
        end
        if(gpio.read(GPIO_BTN)==1 and BTN_PRESSED == 1) then
        BTN_PRESSED = 0
        end
end)


gpio.mode(GPIO_LED, gpio.OUTPUT)
gpio.mode(GPIO_SWITCH, gpio.OUTPUT)
dispatcher[MQTT_MAINTOPIC .. '/state'] = switch_power_cb
--dispatcher[MQTT_PREFIX .. '/discovery/' .. node.chipid()] = set_id
dispatcher[MQTT_PREFIX .. '/poll'] = public_discovery
m:connect(MQTT_HOST, MQTT_PORT, 0, 1)
