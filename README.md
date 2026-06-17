# RC Signal Finder (Acoustic Radar) for EdgeTX

A professional, high-performance Lua script designed for **EdgeTX / OpenTX** transmitters (such as the **RadioMaster Boxer, TX16S, and Zorro**) that turns your radio into an acoustic "Geiger-Counter" style tracker to locate lost RC models, drones, and fixed-wing aircraft using either **ExpressLRS (ELRS)** or **FlySky** telemetry links.

The project consists of two specialized scripts optimized for background execution via EdgeTX Special Functions:
1. **`findelrs.lua`**: Main telemetry parser for ExpressLRS links (utilizes native dBm calculations).
2. **`findflsk.lua`**: Main telemetry parser for FlySky protocols (utilizes native percentage/quality calculations).

---

## Overview

When searching for a downed model, looking down at a screen can be dangerous and inefficient. These scripts translate telemetry data directly into a dynamic acoustic pulse.

### Key Characteristics:
* **Worst Signal ($-120$ dBm or lower):** Slow, rhythmic warning chirps spaced **$200$ ms** apart.
* **Best Signal ($-50$ dBm or higher):** Ultra-high-frequency acoustic buzz with an intensive **$5$ ms** interval.
* **Dynamic Signal Scaling:** Using 2^x scaling ensures that the difference between a good signal (-60dBm) and a perfect signal (-50dBm) is dynamically stretched. This provides maximum acoustic separation exactly where the signal is strongest.
* **Optimized Execution Loop:** Engineered for background execution via EdgeTX **Special Functions**, bypassing standard LCD rendering loops to ensure stutter-free audio parsing and zero control latency.
* **EdgeTX Compliant:** Named perfectly within the strict **6-character limitation** required by EdgeTX to ensure visibility under the function assignment system.

## Installation Workflow

### Critical Pre-Installation Constraint
EdgeTX requires files located in the `FUNCTIONS` directory to have a filename length of **6 characters or less** (excluding the `.lua` extension). The name length of the lua file must not be longer than 8 characters.

### Step-by-Step Deployment:
1. Power on your **RadioMaster Boxer** into **Bootloader Mode** (Press and hold both horizontal trim buttons inward while pushing the Power button).
2. Connect your transmitter via USB-C to your PC and select **"USB Storage (SD)"**.
3. Access the mass storage directory of the transmitter.
4. Navigate to the directory: **`[SD_CARD_ROOT]/SCRIPTS/FUNCTIONS/`**
   * *Note: If the `FUNCTIONS` folder does not exist inside your `SCRIPTS` folder, create it manually.*
5. Copy the required script file (`findelrs.lua` or `findflsk.lua`) directly into this folder.
6. Safely unmount/eject the SD card storage from your computer and unplug the USB cable. Press **Exit** on the Boxer to boot into standard system firmware.

---

## Binding the Script to a Transmitter Switch

To gain instantaneous, field-ready access to your signal locator, map it to a physical switch using the **Special Functions** matrix:

1. Press the **MDL** (Model) button on your interface.
2. Use the rotary roller to navigate to the **SPECIAL FUNCTIONS** page (commonly page 10 or 11 depending on your EdgeTX target layout).
3. Scroll down to the first available empty line (e.g., `SF1`) and hit **Enter**.
4. **Switch Selection:** Highlight the first block, hit **Enter**, then flip the physical switch you want to designate (e.g., a momentary switch like `SH↓`, or a structural toggle switch like `SF↓`).
5. **Action Assignment:** Scroll to the next column (**Action**), click, and cycle through the options until you find **Lua Script**. Select it.
6. **Script Definition:** Scroll to the next column (**Value/Script name**), click, and pick your script (**`findelrs`** or **`findflsk`**) from the populated system menu.
7. **Activation Check:** Scroll to the final column on the right (**Enable**) and click it to ensure the checkbox contains a **checkmark** (Activated).

---

## Sensor Configuration & Telemetry Check

If you flip your configured switch and the radio remains silent despite everything being turned on, your radio has not discovered the internal sensors yet.

1. Power on your aircraft/quad and make sure the receiver is green and bound to your Boxer.
2. In your radio's **MDL** menu, navigate to the **TELEMETRY** page.
3. Scroll down to **Discover New** and press it.
4. Locate the **`1RSS`** line entry in the sensor registry table and verify that its dBm properties are dynamically fluctuating.
5. Stop discovery. The background script is now initialized and reading data streams.

---

## Field-Rescue Search Technique

Locating a lost aircraft using an omnidirectional or directional antenna setup requires adherence to RF physics:

1. **Activate:** Flip your designated switch to activate the acoustic tracking radar.
2. **Isolation:** Hold the radio outward, parallel to your chest, away from body mass which can block RF energy.
3. **The 360° Sweep:** Slowly rotate your entire body $360^\circ$ in a continuous, controlled circle.
4. **Locate Peak:** Pay close attention to the chirp speed. Identify the exact heading vector where the audio tone approaches a **solid, high-speed buzz**.
   * *Note: If using standard T-style antennas, the strongest signal projects from the flat side of the T, while the tip represents a null zone.*
5. **Track:** Walk carefully along the peak signal path. As you move closer, the base frequency will climb, providing immediate confirmation that you are closing the distance to your lost aircraft. Turn off the toggle switch when the search is complete.
