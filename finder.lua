-- ExpressLRS Signal Finder Script
-- Save as SCRIPTS/FUNCTIONS/finder.lua

local rssiId = nil
local lastBeep = 0

local function init()
    -- Find the RSSI dBm telemetry sensor ID (typically '1RSS' or 'RSSI' in ELRS)
    rssiId = getFieldInfo("1RSS") or getFieldInfo("RSSI")
end

local function run(event)
    -- If RSSI sensor is not found, attempt to re-detect itself
    if not rssiId then
        rssiId = getFieldInfo("1RSS") or getFieldInfo("RSSI")
        return
    end

    local rssiValue = getValue(rssiId.id)

    -- Handle cases where telemetry is lost or zero
    if rssiValue == nil or rssiValue == 0 then
        return
    end

    -- ExpressLRS dBm typically ranges from -128 (worst) to 0 (best/perfect)
    -- Define operational ExpressLRS boundaries for better user feedback
    local minDbm = -120
    local maxDbm = -50

    -- Constrain current value inside boundaries to avoid mathematical overflow
    local cleanRssi = rssiValue
    if cleanRssi < minDbm then cleanRssi = minDbm end
    if cleanRssi > maxDbm then cleanRssi = maxDbm end

    -- Calculate delay: closer to 0 dBm means smaller delay (faster beeps)

    -- Calculate linear coefficient from 0.0 (worst) to 1.0 (perfect)
    local percentage = (cleanRssi - minDbm) / (maxDbm - minDbm)


    -- EXPONENTIAL RESOLUTION STRETCHING
    -- Using 2^x scaling ensures that the difference between a good signal (-60dBm)
    -- and a perfect signal (-50dBm) is dynamically stretched.
    -- This provides maximum acoustic separation exactly where the signal is strongest.
    local dynamicCurve = (math.exp(percentage * 3) - 1) / (math.exp(3) - 1)

    -- Map percentage to EdgeTX internal ticks (1 tick = 10ms)
    -- maxDelay: 20 ticks (200ms) | minDelay: 0.5 ticks (5ms)
    local maxDelay = 20
    local minDelay = 0.5
    local beepDelay = maxDelay - (dynamicCurve * (maxDelay - minDelay))

    -- Beep timing logic
    local now = getTime() -- Returns time in 10ms increments
    if now - lastBeep > beepDelay then
        -- Play a short, high-pitched beep
        -- playTone(frequency, duration, pause [, flags [, freqIncr [, volume]]])
        playTone(2000, 20, 0, PLAY_NOW)
        lastBeep = now
    end
end

return { init=init, run=run }
