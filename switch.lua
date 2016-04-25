SWITCH_STATE = 0
function switch_power(pl)
    if pl == "true" then
        gpio.write(GPIO_SWITCH, gpio.HIGH)
        gpio.write(GPIO_LED, gpio.LOW)
--        SWITCH_STATE = 1
    else
        gpio.write(GPIO_SWITCH, gpio.LOW)
        gpio.write(GPIO_LED, gpio.HIGH)
--        SWITCH_STATE = 0
    end
end
