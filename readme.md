# IITB-RISC-23: A Pipelined IITB RISC CPU

This repository contains the design and implementation of a **6-stage pipelined processor**, the IITB-RISC-23, developed as part of the **Microprocessors** course under the guidance of **Prof. Virendra Singh**. The project emphasizes the architectural concepts and pipeline optimization techniques.

---

## Table of Contents
1. [Abstract](#abstract)  
2. [Architecture Overview](#architecture-overview)  
3. [Data Path Components](#data-path-components)  
    - [Instruction Fetch](#instruction-fetch)  
    - [Instruction Decode](#instruction-decode)  
    - [Register Read](#register-read)  
    - [Execution](#execution)  
    - [Memory Write/Read](#memory-write-read)  
    - [Write Back](#write-back)  
4. [Hazard Detection and Mitigation](#hazard-detection-and-mitigation)  
5. [RTL Simulation](#rtl-simulation)  
---

## Abstract
The IITB-RISC-23 is a custom-designed 16-bit processor based on a simple yet extensible **instruction set architecture (ISA)** with 8 general-purpose registers (R0 to R7), where R0 serves as the **Program Counter (PC)**. Tailored for educational applications, the processor supports pipelined execution and incorporates hazard mitigation techniques, making it suitable for demonstrating core concepts of computer architecture.

Key Features:
- **16-bit ISA** with R, I, and J instruction formats.  
- **8 General-Purpose Registers** (R0-R7).  
- **Pipeline Stages**: Instruction Fetch, Instruction Decode, Register Read, Execution, Memory Write/Read, and Write Back.  
- **Hazard Mitigation Techniques**: Data forwarding, pipeline stalling, and hazard-specific handling.  

---

## Architecture Overview
The IITB-RISC-23 architecture includes the following components:

### Core Components
- **Program Counter (PC)**: 16-bit counter implemented in R0 of the register file
- **Instruction Memory**: 16-bit wide memory storing program instructions
- **Register File**: 8 general-purpose 16-bit registers (R0-R7)
- **ALU System**: Three ALUs for different operations:
  - ALU1: Main arithmetic/logic unit with carry and zero flags
  - ALU2: Address calculation and PC increment
  - ALU3: Branch target calculation
- **Data Memory**: 16-bit wide memory for load/store operations
- **Pipeline Registers**: Five pipeline registers (P1-P5) managing data flow

### Instruction Formats
1. **R-Type Instructions**:
   - Format: `[opcode(4) | RA(3) | RB(3) | RC(3) | CZ(2) | unused(1)]`
   - Examples: ADA, NDU, ADC, ACZ
   - Conditional execution based on carry/zero flags

2. **I-Type Instructions**:
   - Format: `[opcode(4) | RA(3) | RB(3) | IMM(6)]`
   - Examples: ADI (Add Immediate), LW, SW
   - 6-bit immediate value with sign extension

3. **J-Type Instructions**:
   - Format: `[opcode(4) | RA(3) | IMM(9)]`
   - Examples: JAL, JLR, BEQ
   - 9-bit immediate value for branch/jump targets
---

## Data Path Components

### 1. Instruction Fetch
- Retrieves the instruction from memory using the **Program Counter (PC)**.
- Updates PC using `PC + 2`.

### 2. Instruction Decode
- Decodes instruction fields and generates control signals for the pipeline stages.
- Handles sign-extension for immediate values (6-bit or 9-bit).

### 3. Register Read
- Accesses register values based on decoded operands.
- Resolves immediate dependencies via **hazard muxes** for data forwarding.

### 4. Execution
- Executes operations in the **ALU**, such as ADD, NAND, comparison, and flag updates.
- Performs additional processing for load/store and jump instructions.

### 5. Memory Write/Read
- Interfaces with data memory for load/store instructions.
- Manages address and data forwarding for consecutive memory accesses.

### 6. Write Back
- Updates the Program Counter or registers based on the instruction type and execution stage.

---

## Hazard Detection and Mitigation
Hazard handling techniques employed:
1. **R0 Hazard**: Avoids unintended modifications to the **Program Counter** stored in R0.  
2. **Data Dependencies**: Implements data forwarding from different pipeline stages to avoid stalls.  
3. **Load-Store Hazards**: Stalls the pipeline for one cycle during load instructions to allow data to be fetched.  
4. **LM-SM Hazards**: Special handling for **Load Multiple (LM)** and **Store Multiple (SM)** instructions to prevent incorrect pipeline updates during execution.

---

## RTL Simulation
The design is verified using **RTL simulation** tools. Key outputs include:
- **Pipeline Functionality**: Verified correct operation of all pipeline stages.  
- **Hazard Mitigation**: Ensured proper forwarding, stalling, and conditional execution.  

### RTL Viewer
The following figures demonstrate the RTL simulation and architecture design:

![RTL Simulation](resources/RTL%20Simulation.png)
*Figure 1: RTL Simulation showing pipeline stages execution*

![RTL Viewer](resources/RTL%20Viewer.png) 
*Figure 2: RTL Viewer visualization of the processor architecture* 


---