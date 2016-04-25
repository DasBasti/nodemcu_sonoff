-- init all globals
function load_lib(fname)
    if file.open(fname .. ".lc") then
        file.close()
        local ret, err = pcall(function() dofile(fname .. ".lc") end)
        if ret == true then
            print("load: ".. fname .. ".lc")
        else
            print("load: ".. fname .. ".lc -- failed!")
            print(err)
        end
    elseif file.open(fname.. ".lua") then
        file.close()
        local ret, err = pcall(function() dofile(fname .. ".lua") end)
        if ret == true then
            print("load: ".. fname .. ".lua")
        else
            print("load: ".. fname .. ".lua -- failed!")
            print(err)
        end
    else
        print("load: ".. fname .. ".lua/.lc -- not found!")
    end
end

load_lib("config") -- configuration vars
load_lib("switch") -- function to switch relay

local wifiReady = 0

function configureWiFi()
    gpio.mode(GPIO_LED, gpio.OUTPUT)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(WIFI_SSID, WIFI_PASS)
    tmr.alarm(WIFI_ALARM_ID, 2000, 1, wifi_watch)
end
-- while NOT connected to WiFi you blink a LED, see below
function wifi_watch() 
    
    status = wifi.sta.status()
    -- only do something if the status actually changed (5: STATION_GOT_IP.)
    if status == 5 and wifiReady == 0 then
        wifiReady = 1
        print("WiFi: connected")
        turnWiFiLedOn()
        load_lib("ota")
        load_lib("broker")
    elseif wifiReady == 1 then
        -- do nothing
        -- print("WiFi: still connected")
    else
        wifiReady = 0
        print("WiFi: (re-)connecting")
        turnWiFiLedOnOff()
    end
end
function turnWiFiLedOnOff()
    turnWiFiLedOn()
    tmr.alarm(WIFI_LED_BLINK_ALARM_ID, 500, 0, function()
        turnWiFiLedOff()
    end)
end
function turnWiFiLedOn()
    gpio.write(GPIO_LED, gpio.HIGH)
end
function turnWiFiLedOff()
    gpio.write(GPIO_LED, gpio.LOW)
end

-- Configure
tmr.delay(1000)
configureWiFi()
