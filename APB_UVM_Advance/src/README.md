### Introduction of AMBA
AMBA (Advanced Microcontroller Bus Architecture) is a standard for on-chip communication in system-on-chip (SoC) designs. It helps connect different components like processors, memory, and peripherals efficiently. It's widely used in embedded systems and mobile devices to streamline development and improve performance.

### History
AMBA was introduced by ARM in 1996. The first AMBA buses were the Advanced System Bus (`ASB`) and the Advanced Peripheral Bus (`APB`).
In its second version, AMBA 2 in 1999, ARM added AMBA High-performance Bus (`AHB`) that is a single clock-edge protocol.
In 2003, ARM introduced the third generation, AMBA 3, including Advanced eXtensible Interface (`AXI`) to reach even higher performance interconnect and the Advanced Trace Bus (`ATB`) as part of the CoreSight on-chip debug and trace solution.
In 2010, the AMBA 4 specifications were introduced starting with AMBA 4 AXI4, then
in 2011, extending system-wide coherency with AMBA 4 AXI Coherency Extensions (ACE).
In 2013, the AMBA 5 Coherent Hub Interface (`CHI`) specification was introduced, with a re-designed high-speed transport layer and features designed to reduce congestion.

Simple SoC

<img src="../../docs/images/1.png" alt="alt text" width="70%" />


AHB is used to connect High Bandwidth components and uses a full duplex parallel communication with a pipelined strtcture. 

### APB
APB is used to interface low bandwidth peripherals like UART, Timers, GPIOs with Soc's processor/memory through bridge (which translates ABP-to-AHB).

The APB protocol is a low-cost interface, optimized for minimal power consumption and reduced interface
complexity. The APB interface is `not pipelined` and is a `simple`, `synchronous protocol`. Every transfer takes at least
`2 cycles` (*`Setup phase:address phase`* & *`Access Phase:data phase`*)to complete. 
The APB interface is designed for `accessing the programmable control registers of peripheral devices`. APB peripherals are typically connected to the main memory system using an APB bridge. This bridge translates the AHB to APB.


### APB Signals

| Signal         | Direction           | Description                                                                 |
|----------------|---------------------|-----------------------------------------------------------------------------|
| **PCLK**       | -                   | System clock; may be directly connected.                                   |
| **PRESETn**    | -                   | Active Low Asynchronous Reset.                                             |
| **PADDR[31:0]**| Master → Slave      | Address bus (up to 32 bits wide).                                          |
| **PWDATA[31:0]**| Master → Slave     | Write data bus (up to 32 bits wide).                                       |
| **PRDATA[31:0]**| Slave → Master     | Read data bus (up to 32 bits wide).                                        |
| **PSELx**      | Master → Slave      | Slave Select; one PSEL signal per slave (e.g., PSEL1, PSEL2,..., PSELn).   |
| **PENABLE**    | Master → Slave      | Indicates the second and subsequent cycles (ACCESS phase).                 |
| **PWRITE**     | Master → Slave      | High = Write operation, Low = Read operation.                              |
| **PREADY**     | Slave → Master      | Slave response signal; High = Ready, Low = Wait (wait states).             |
| **PSLVERR**    | Slave → Master      | Transfer status; High = Error, Low = Success.                              |

---

> An APB interface has a single address bus, `PADDR`, for read and write transfers.  
> It uses two independent data buses: one for read data (`PRDATA`) and one for write data (`PWDATA`).

---

### Operations
<img src="../../docs/images/2.jpg" alt="alt text" width="70%"/>

- **IDLE** : This is the default state of the APB.

- **SETUP:** When a transfer is required the bus moves into the SETUP state, where the appropriate select signal, **PSELx**, is asserted. The bus only remains in the SETUP state for one clock cycle and always moves to the ACCESS state on the next rising edge of the clock.

- **ACCESS**: The enable signal, PENABLE, is asserted in the ACCESS state. The address, write, select, and write data signals must remain stable during the transition from the SETUP to ACCESS state. Exit from the ACCESS state is controlled by the PREADY signal from the slave:

    - If **PREADY** is held LOW by the slave then the peripheral bus remains in the ACCESS state.
    - If **PREADY** is driven HIGH by the slave then the ACCESS state is exited and the bus returns to the IDLE state if no more transfers are required. Alternatively, the bus moves directly to the SETUP state if another transfer follows.
---
### Write & Read Transfer Operations

#### Write Transfer with no wait
<div style="display: flex;">
  <img src="../../docs/images/3.jpg" alt="alt text" width="70%" />
  <img src="../../docs/images/4.png" alt="alt text" width="50%" />
</div>

```bash
Time:        t1  t2  t3  t4
Clock:   ___┌>─┐_┌─┐_┌─┐_┌─┐___
PSEL:    ____┌─────────┐_____
PENABLE: ______┌───────┐_____
PWRITE:  ____┌─────────┐_____
PREADY:  ________┌─────┐_____
         IDLE SETUP ACCESS IDLE
-------------------------------------------------
-> Monitor Sample (When: PSEL && PENABLE && PWRITE (ACCESS phase)  
-> Transaction completes (when: PREADY=1)
```
#### Write Transfer with wait state
 <div style="display: flex;">
  <img src="../../docs/images/5.png" alt="alt text" width="70%" />
  <img src="../../docs/images/6.png" alt="alt text" width="50%" />
</div>
                           
 As seen in figure at during `T1` was the `setup phase` (as during this `PSEL=High`), during `T2` `Access Phase` (`PENBL=HIGH`) but here `PREADY=LOW` which causes delay during T3 & T4, At T5 it becomes high enabling transaction

#### Read Transfer without wait state
<img src="../../docs/images/7.jpg" alt="alt text" width="50%" />

- During read operation the PENABLE, PSEL, PADDR PWRITE, signals are asserted at the clock edge T1 (SETUP cycle).

- At the clock edge T2, (ACCESS cycle), the PENABLE, PREADY are asserted and PRDATA is also read during this phase. The slave must provide the data before the end of the read transfer.
```bsh
Clock:    ___┌─┐_┌─┐_┌─┐_┌─┐___
PSEL:     ____┌─────────┐_____
PENABLE:  ______┌───────┐_____
PWRITE:   ______________________________ (0 for read)
PREADY:   ________┌─────┐_____
PRDATA:   ????????████████????? ← Valid only when PREADY=1
          IDLE SETUP ACCESS IDLE
                  ↑     ↑
              Sample    PRDATA 
              Address   Valid Here!
```

### Key difference between Write and Read
#### WRITE Operation:

- **Master drives data** → `PWDATA` is stable during entire ACCESS phase
- Can sample PWDATA anytime during ACCESS phase
- Data doesn't change based on PREADY
#### READ Operation:

- **Slave drives data** → `PRDATA` is only valid when PREADY=1
- Must wait for `PREADY` before sampling `PRDATA`
- PRDATA can be `garbage/X `before `PREADY `assertion

### Error Response

- PSLVERR shows an error during APB read/write transfers.
- It's valid only in the last cycle when PSEL, PENABLE, and PREADY are all high.
- An error may or may not change the peripheral's state.
- Either case is allowed, depending on the peripheral design.

<img src="../../docs/images/8.png" alt="alt text" width="50%" />

### Example Design:

<img src="../../docs/images/9.png" alt="alt text" width="100%" />

#### Step-by-Step Flow

1. **Test starts**, and the `Seqs` are created and sent to the `Seqr`.
2. `Seqr` uses the UVM **TLM port** to pass transactions to the `Driver`.
3. `Driver` physically drives the **APB signals** to the `DUT` via a **virtual interface** (`vif`).
4. `W_monitor` taps into these signals (write side) and **publishes transactions** via:
   - `wap` → `cm_export_write` (Functional Coverage Model)
   - `wap` → `sb_export_write` (Scoreboard)
5. `R_monitor` observes DUT’s read responses and **publishes transactions** via:
   - `rap` → `cm_export_read` (Functional Coverage Model)
   - `rap` → `sb_export_read` (Scoreboard)
6. The **Scoreboard** compares the expected writes vs actual reads.
7. The **Coverage Model** tracks coverage metrics for protocol-level events.


#### TLM Interfaces 

| Port Type            | Direction        | Usage in Diagram                                 |
|----------------------|------------------|--------------------------------------------------|
| `tlm_analysis_port`  | broadcast out    | `W_monitor` and `R_monitor` (◇ diamonds)         |
| `tlm_analysis_export`| receive in       | `Scoreboard` and `Coverage Model` (🔘 circles)   |
| `tlm_port`           | master(initiator)| From `Seqr` to `Driver`                          |
| `tlm_imp`            | slave(responder) | Implemented in `Driver` to receive items         |

---
### Project flow
<img src="../../docs/images/10_mermaraied.png" alt="alt text" width="70%" />



### Key Concepts Understanding

#### Monitor & Scoreboard Connections (TLM Ports)

```bash
       ENVIRONMENT
    ┌─────────────────────────┐
    │      AGENT              │
    │  ┌─────────────────┐    │    ┌──────────────┐
    │  │ SEQR ←TLM→ DRIVER    │    │              │
    │  └─────────────────┘    │    │  SCOREBOARD  │
    │                         │    │              │
    │  ┌─────────────────┐    │    │ • write_W()  │
    │  │    MONITOR      │──wap───→│ • write_R()  │
    │  │ • wr_phase()    │    │    │ • compare()  │
    │  │ • rd_phase()    │──rap───→│              │
    │  └─────────────────┘    │    └──────────────┘
    └─────────────────────────┘
            │ vif
        ┌───▼───┐
        │  DUT  │
        └───────┘
```
```bash
Monitor.wap ──────→ Scoreboard.sb_export_write
       📤                      📥
   (sends write)           (receives write)

Monitor.rap ──────→ Scoreboard.sb_export_read  
       📤                      📥
   (sends read)            (receives read)
```

`MONITOR (Sender Side)`
```sv
class monitor extends uvm_monitor;
    // PORTS - for sending data OUT
    uvm_analysis_port#(sequence_item) wap;  // Write Analysis Port
    uvm_analysis_port#(sequence_item) rap;  // Read Analysis Port
    
    // Usage: Send data to scoreboard
    wap.write(transaction);  // Send write transaction
    rap.write(transaction);  // Send read transaction
endclass
```
`SCOREBOARD (Receiver Side)`
```sv
class scoreboard extends uvm_scoreboard;
    // EXPORTS/IMPS - for receiving data IN
    uvm_analysis_imp_W #(sequence_item, scoreboard) sb_export_write;
    uvm_analysis_imp_R #(sequence_item, scoreboard) sb_export_read;
    
    // Functions that get called automatically when data arrives
    function void write_W(sequence_item trans);  // Handles write data
    function void write_R(sequence_item trans);  // Handles read data
endclass
```
`environment or agent (connect paths)`
```sv
monitor.wap.connect(scoreboard.sb_export_write);  // Connect write path
monitor.rap.connect(scoreboard.sb_export_read);   // Connect read path

```
#### Comparison Logic in Scoreboard
```bash
Write Queue: [100, 200, 300] ←── Data written to memory
Read Queue:  [100, 200, 300] ←── Data read from memory
             
Compare: 100==100?   //PASS
         200==200?  // PASS  
         300==300? //PASS
```
```sv
task run_phase(uvm_phase phase);
    forever begin
        @(posedge vif.PCLK) begin 
            // If both queues have data, compare them
            if(write_q.size() >0 && read_q.size() >0) begin 
                read  = read_q.pop_front();   // Get oldest read data
                write = write_q.pop_front();  // Get oldest write data
                compare();                    // Compare them
            end
        end
    end
endtask
```


#### Verbosity Level Control for Debugging
- Simulation commands with different verbosity
```sv
vsim +UVM_VERBOSITY=UVM_NONE     //Printed Always: only NONE messages //Critical info, final reports
vsim +UVM_VERBOSITY=UVM_LOW      //Default Level: NONE + LOW messages //Important events  
vsim +UVM_VERBOSITY=UVM_MEDIUM   //Medium Detail: NONE + LOW + MEDIUM //More detailed info 
vsim +UVM_VERBOSITY=UVM_HIGH     //High detail: NONE + LOW + MEDIUM + HIGH // Debug information
vsim +UVM_VERBOSITY=UVM_DEBUG    //Debug only: ALL messages // Detailed debug traces
```
- Activate detailed debugging by using this command in run.do file:
```bash
vsim +UVM_VERBOSITY=UVM_DEBUG
```

### UVM Hierarchy
<img src="../../docs/images/12.png" alt="alt text" width="70%" />

---

### Simulation Results
Waveforms for Read/Write Burst size of 8.

<img src="../../docs/images/11.png">



### APB Protocol Sequence Analysis:
#### Write Transaction (First Half):
Write Transaction Waveform:
<img src="../../docs/images/14.png">
1. IDLE → SETUP (T3): PSEL=1, PENABLE=0, Address & Data driven (PADDR=0x0, PWDATA=0x5f41cbae)
2. SETUP → ACCESS (T4): PENABLE=1 asserted, all signals remain stable
3. ACCESS Complete: PREADY=1 from slave, transaction completes, return to IDLE
   
#### Read Transaction (Second Half):
Read Transaction Waveform:
<img src="../../docs/images/15.png">
1. IDLE → SETUP (TA): PSEL=1, PENABLE=0, PWRITE=0, Address driven (PADDR=0x0)
2. SETUP → ACCESS (TB): PENABLE=1 asserted, wait for slave response
3. ACCESS Complete: PREADY=1, PRDATA=0x5f41cbae valid (same data written earlier)

### Scoreboard Output
<img src="../../docs/images/16.png" alt="alt text" width="70%" />

#### Key Observations:
1. 2-cycle minimum: Each transaction takes exactly 2 cycles (SETUP + ACCESS)
2. Write-then-Read: Perfect APB sequence showing data integrity
3. PREADY control: Slave controls transaction completion timing
4. Data match: Read data matches previously written data (verification success!)
5. This waveform shows a perfect APB write followed by read from the same address - classic verification pattern!







---
### References
- Design:
  https://github.com/kumarraj5364/AMBA-APB-PROTOCOL?tab=readme-ov-file
- Design & Verification: https://github.com/PRADEEPCHANGAL/APB-Protocol-Verification-using-UVM
  
---
