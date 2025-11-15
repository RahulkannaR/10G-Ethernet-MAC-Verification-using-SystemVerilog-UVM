# 🌐 10G Ethernet MAC Verification — UVM Environment (RX/TX Path)

This repository contains the complete **UVM-based Verification Environment** for a **10G Ethernet MAC**, validating both RX and TX datapaths, CRC logic, IFG timing, frame structure, and error-handling robustness. The project ensures full protocol compliance and functional correctness under constrained-random traffic and aggressive corner-case scenarios.

> 🧩 Verification Type: 10G Ethernet MAC (RX/TX)  
> 🧪 Methodology: UVM 1.2 + Constrained-Random + SVA  
> 🛠️ Tools: QuestaSim 2024.3  
> 📅 Duration: Jul 2024 – Nov 2024  

---

## 🧠 Project Highlights

- Layered UVM environment generating **5000+ constrained-random packets**
- Verified:
  - CRC-32 generation & validation  
  - Inter-Packet Gap (IPG/IFG) timing  
  - Frame structure, minimum/maximum lengths  
  - Error-injection robustness (CRC errors, runt frames, alignment issues)  
  - Deterministic TX → RX behavior
- Achieved **95% protocol + functional coverage**
- Integrated SVA checks for:
  - VALID/READY timing  
  - Frame boundary rules  
  - CRC result stability  
  - IPG timing constraints  
- Scoreboard verifies CRC, payload, length, and MAC timing consistency

---

## 📁 Repository Structure

EthernetMAC-UVM/  
├── rtl/  
│   ├── eth_mac.sv  
│   ├── eth_tx.sv  
│   ├── eth_rx.sv  
│   ├── crc32.sv  
│   ├── fifo.sv  
│   └── defines.vh  
│  
├── tb/  
│   ├── top_tb.sv  
│   ├── mac_if.sv  
│   ├── mac_env.sv  
│   ├── mac_agent.sv  
│   ├── mac_driver.sv  
│   ├── mac_monitor.sv  
│   ├── mac_sequencer.sv  
│   ├── mac_sequence.sv  
│   ├── mac_transaction.sv  
│   ├── mac_scoreboard.sv  
│   ├── mac_coverage.sv  
│   ├── mac_assertions.sv  
│   └── mac_test.sv  
│  
├── scripts/  
│   ├── compile.do  
│   ├── run.do  
│   └── regress.sh  
│  
├── results/  
│   ├── logs/  
│   ├── waves/  
│   └── coverage/  
│  
└── README.md  

---

## 🚀 Getting Started

### Requirements
- QuestaSim 2024.3  
- UVM 1.2  
- IEEE 802.3 10G MAC specifications  

### Compile & Run
vlog rtl/*.sv tb/*.sv  
vsim top_tb -do "run -all"  

Or use regression:  
sh scripts/regress.sh  

---

## 🔧 Verification Scope

- 10G MAC frame format validation  
- CRC-32 generation + checking  
- Length/type field and preamble validation  
- Inter-Packet Gap (IPG) timing checks  
- Error-injected runt/giant/alignment frames  
- RX/TX latency and cycle-accurate timing  
- Correct transmission ordering  
- FIFO overflow/underflow corner cases  
- Backpressure and handshake protocol analysis  

---

## 🧪 Testbench Components

- **UVM Agent**: sequencer + driver + monitor  
- **Scoreboard**: payload, CRC, timing & metadata checks  
- **Coverage**: length bins, CRC patterns, error cases, IPG bins  
- **Assertions**: frame boundary, CRC correctness, IPG stability  
- **Sequences**: CRV packets, jumbo frames, error-injection, IFG-stress  

---

## 📊 Coverage Achievement

- **95%+ functional + protocol coverage**  
- Verified 5000+ CRV Ethernet frames  
- Coverage bins include:  
  - Payload sizes  
  - CRC variations  
  - IFG intervals  
  - Error-injection classes  
  - RX/TX sequence order  

---

## 📁 Results Directory

results/  
├── logs/       → Simulation logs  
├── waves/      → VCD/WLF waveform dumps  
└── coverage/   → UCDB + HTML coverage reports  

---

## ✨ Author

R. Rahul  
Design Verification Engineer — Ethernet MAC, UVM, High-Speed Protocols  
Email: rahulkanna170504@gmail.com  

---

## 🔖 Keywords

10G Ethernet, MAC, UVM, CRC32, IFG/IPG, RX/TX Pipeline,  
Functional Coverage, Constrained-Random, SVA, High-Speed Interfaces
