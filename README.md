# Advanced SCOMP Peripheral Design: Sound Detection

## Project Overview

This project focuses on the design and implementation of a custom sound detection peripheral for the SCOMP system. The peripheral streamlines sound-related interactions by detecting loud sounds and providing capabilities such as counting, magnitude measurement, and timing. The design aims to enhance SCOMP's utility for programmers working on sound-related applications. 

---

## Features

- **Sound Detection**: Detects sounds above a specified threshold.
- **Counting**: Counts the number of loud sounds detected within a 1-second buffer.
- **Magnitude Measurement**: Records the maximum sound magnitude below the negative 2's complement threshold.
- **Timing**: Tracks the elapsed time between two detected sounds using clock cycles.
- **Reset Functionality**: Provides a reset option to clear data for subsequent sound recordings.
- **Growth Room**: Reserved operations for future feature expansion.

---

## How It Works

1. **Initialization**: 
   - Send `0` via the `OUT` instruction to reset the peripheral.
2. **Operation Modes**: 
   - Use the `OUT` instruction with values in the ACC register to specify the desired operation:
     - `1`: Counting
     - `2`: Magnitude
     - `3`: Timing
   - Use the `IN` instruction to input the desired value into the ACC register to retrieve the output.

3. **Data Handling**: 
   - Data is recorded and retained between resets, with outputs calculated dynamically based on system clock cycles.

---

## Design Highlights

- **Threshold-based Detection**:
  - Set the threshold at `x1800` for sound amplitude values to classify loud sounds.
  - Values above `x8000` are ignored as they represent negative numbers in 2's complement.

- **1-Second Clock Buffer**:
  - Implemented to consolidate multiple amplitude values of a single sound within one second.
  - Adjusted clock cycle duration to precisely one second (system clock: 12 MHz, value: `x"00B71B00"`).

- **Optimizations**:
  - Reduced buffering errors by refining the slow clock duration.
  - Enhanced system accuracy for sound classification.

---

## Challenges and Lessons Learned

- Initial configurations using a 1.3-second clock caused inaccuracies in sound buffering, leading to the adoption of a 1-second buffer.
- Fine-tuning sound thresholds and clock cycles was critical for optimizing detection accuracy.
- Proactive identification of potential issues in early design stages would have improved project outcomes.
