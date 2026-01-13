# Design of I2C Protocol & EEPROM Verification (Verilog)
This project implements the Inter-Integrated Circuit (I2C) protocol and verifies an EEPROM memory model using Verilog HDL.
It demonstrates reliable serial communication between a Master and Slave (EEPROM) using two-wire communication (SCL & SDA).
# Overview
- Designed an I2C Master and I2C Slave (EEPROM) using FSM-based Verilog
- Supports Read, Write, and Erase operations
- Verified through testbench and waveform analysis
- Simulates real-time EEPROM communication over I2C
# Functional Description
- The I2C Master generates:
  - Start & Stop conditions
  - Clock (SCL)
  - Address & data transmission
  - ACK/NACK detection
- The I2C Slave (EEPROM):
  - Detects address
  - Sends acknowledgment
  - Stores data in memory
  - Supports read/write operations
- The Testbench:
  - Drives I2C signals
  - Simulates write, read, and erase operations
  - Verifies data integrity
# Implementation & Testing
1. Signal Generation
- SCL generated using clock divider
- SDA controlled via tri-state buffer
2. Data Transfer
- 7-bit address + R/W bit
- Serial data shifted MSB → LSB
3. EEPROM Operation
- Write → Store data
- Read → Retrieve stored data
- Erase → Overwrite with 0x00
# Tools & Technologies
- Verilog HDL
- ModelSim / Vivado Simulator
- Digital Design & FSM Concepts
- I2C Protocol
