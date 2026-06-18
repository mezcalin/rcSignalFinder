-- ExpressLRS Signal Finder Script
-- Save as SCRIPTS/FUNCTIONS/findelrs.lua

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
        return 0
    end

    local rssiValue = getValue(rssiId.id)

    -- Handle cases where telemetry is lost or zero
    if rssiValue == nil or rssiValue == 0 then
        return 0
    end

    -- ExpressLRS dBm typically ranges from -128 (worst) to 0 (best/perfect)
    -- Define operational ExpressLRS boundaries for better user feedback
    local minDbm = -120
    local maxDbm = -50

    -- Constrain current value inside boundaries to avoid mathematical overflow
    local cleanRssi = rssiValue
    if cleanRssi < minDbm then cleanRssi = minDbm end
    if cleanRssi > maxDbm then cleanRssi = maxDbm end

    -- Calculate linear coefficient from 0.0 (worst) to 1.0 (perfect)
    local percentage = (cleanRssi - minDbm) / (maxDbm - minDbm)

    -- EXPONENTIAL RESOLUTION STRETCHING
    -- Using 2^x scaling ensures that the difference between a good signal (-60dBm)
    -- and a perfect signal (-50dBm) is dynamically stretched.
    -- This provides maximum acoustic separation exactly where the signal is strongest.
    local dynamicCurve = (math.exp(percentage * 3) - 1) / (math.exp(3) - 1)

    -- 1. DYNAMIC SPEED (Delay between beeps changes based on proximity)
    -- Calculate delay: closer to 0 dBm means smaller delay (faster beeps)
    -- Map percentage to EdgeTX internal ticks (1 tick = 10ms)
    -- maxDelay: 20 ticks (200ms) | minDelay: 0.5 ticks (5ms)
    local maxDelay = 20
    local minDelay = 0.5
    local beepDelay = maxDelay - (dynamicCurve * (maxDelay - minDelay))

    -- 2. DYNAMIC PITCH (Frequency changes based on proximity)
    -- Far away: 800 Hz (low tone) | Extremely close: 3000 Hz (high alarm)
    local minFreq = 800
    local maxFreq = 3000
    local toneFrequency = minFreq + (dynamicCurve * (maxFreq - minFreq))

    -- Beep timing logic
    local now = getTime() -- Returns time in 10ms increments
    if now - lastBeep > beepDelay then
        -- Play a short, high-pitched beep
        -- playTone(frequency, duration, pause [, flags [, freqIncr [, volume]]])
        playTone(toneFrequency, 60, 0, PLAY_NOW)
        lastBeep = now
    end

    if event == EVT_VIRTUAL_EXIT then
        return 1
    end

    return 0
end

return { init=init, run=run }
