-- ExpressLRS Signal Finder Script
-- Save as SCRIPTS/TOOLS/find_elrs.lua

local rssiId = nil
local lastBeep = 0

local function init()
    -- Find the RSSI dBm telemetry sensor ID (typically '1RSS' or 'RSSI' in ELRS)
    rssiId = getFieldInfo("1RSS") or getFieldInfo("RSSI")
end

local function run(event)
    lcd.clear()
    lcd.drawText(10, 10, "ELRS Signal Finder", MIDSIZE)
    lcd.drawText(10, 25, "Point antenna to find peak signal", DEFAULT)

    if not rssiId then
        -- Try to re-detect if not found initially
        rssiId = getFieldInfo("1RSS") or getFieldInfo("RSSI")
        lcd.drawText(10, 45, "Searching for RSSI telemetry...", BLINK)
        return 0
    end

    local rssiValue = getValue(rssiId.id)

    -- Handle cases where telemetry is lost or zero
    if rssiValue == nil or rssiValue == 0 then
        lcd.drawText(10, 45, "Signal: NO TELEMETRY", DBALIGNED)
        return 0
    end

    -- Display the current dBm
    lcd.drawText(10, 45, "Current RSSI: " .. rssiValue .. " dBm", MIDSIZE)

    -- ExpressLRS dBm typically ranges from -128 (worst) to 0 (best/perfect)
    -- Map the dBm to a beep interval (higher dBm = shorter delay = faster beeping)
    local minDbm = -120
    local maxDbm = -50

    -- Constrain rssiValue for calculation
    local cleanRssi = rssiValue
    if cleanRssi < minDbm then cleanRssi = minDbm end
    if cleanRssi > maxDbm then cleanRssi = maxDbm end

    -- Calculate delay: closer to 0 dBm means smaller delay (faster beeps)
    local percentage = (cleanRssi - minDbm) / (maxDbm - minDbm)
    local beepDelay = 150 - (percentage * 130) -- Delays between 20ms and 150ms (in 10ms increments)

    -- Beep timing logic
    local now = getTime() -- Returns time in 10ms increments
    if now - lastBeep > beepDelay then
        playTone(1200, 60, 0, PLAY_NOW) -- Play a short, high-pitched beep
        lastBeep = now
    end

    -- Visual signal bar
    local barWidth = math.floor(percentage * 100)
    lcd.drawRectangle(10, 60, 104, 10)
    lcd.drawFilledRectangle(12, 62, barWidth, 6)

    -- Exit the script cleanly if the EXIT button is pressed
    if event == EVT_VIRTUAL_EXIT then
        return 1
    end

    return 0
end

return { init=init, run=run }
