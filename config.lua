-- GPIOS
GPIO_LED = 7
GPIO_SWITCH = 6
GPIO_BTN = 3

-- WiFi
WIFI_SSID = "YOUR_SSID"
WIFI_PASS = "YOUR PASSWORD"

-- Alarms
WIFI_ALARM_ID = 0
WIFI_LED_BLINK_ALARM_ID = 1

-- MQTT
MQTT_HOST = "YOUR_HOST"
MQTT_CLIENTID = "20"
MQTT_PORT = 1883
MQTT_PREFIX = "/Herbert/devices"
MQTT_MAINTOPIC = MQTT_PREFIX .."/".. MQTT_CLIENTID .. "/inlinesw"

-- Confirmation message
print("\nGlobal variables loaded...\n")
