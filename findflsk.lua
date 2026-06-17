-- FlySky Signal Finder Script
-- Save as SCRIPTS/FUNCTIONS/findflsk.lua

local rssiId = nil
local lastBeep = 0

local function init()
    -- Find the RSSI dBm telemetry sensor ID (typically '1RSS' or 'RSSI' in ELRS)
    rssiId = getFieldInfo("RSSI") or getFieldInfo("TRSS") or getFieldInfo("RQly")
end

local function run(event)
    -- If RSSI sensor is not found, attempt to re-detect itself
    if not rssiId then
        rssiId = getFieldInfo("RSSI") or getFieldInfo("TRSS") or getFieldInfo("RQly")
        return
    end

    local rssiValue = getValue(rssiId.id)

    -- Handle cases where telemetry is lost or zero
    if rssiValue == nil or rssiValue == 0 then
        return
    end

    -- ADJUSTED FOR FLYSKY 250 SCALE:
    -- Typical FlySky telemetry scaling under Multi-Protocol/EdgeTX maxes out near 250.
    local minSignal = 30
    local maxSignal = 245

    -- Constrain current value inside boundaries to avoid mathematical overflow
    local cleanRssi = rssiValue
    if cleanRssi < minSignal then cleanRssi = minSignal end
    if cleanRssi > maxSignal then cleanRssi = maxSignal end

    -- Calculate delay: closer to 0 dBm means smaller delay (faster beeps)

    -- Calculate linear coefficient from 0.0 (worst) to 1.0 (perfect)
    local percentage = (cleanRssi - minSignal) / (maxSignal - minSignal)


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
