# AMBA APB

SV test bench for APB protocol ram (single slave configuration).

## How to run test bench

- Download the latest release from below or visit the [release page](https://github.com/kumarrishav14/AMBA_APB/releases "Release page") for more old release.
  - SV test bench

     [zip](https://github.com/kumarrishav14/AMBA_APB/archive/v1.0.zip)
     [tar.gz](https://github.com/kumarrishav14/AMBA_APB/archive/v1.0.tar.gz)

  - UVM Test Becnh

     [zip](https://github.com/kumarrishav14/AMBA_APB/archive/v1.0.zip)
     [tar.gz](https://github.com/kumarrishav14/AMBA_APB/archive/v1.0.tar.gz)

- Copy the contents in a folder.
- Compile *tb_top.sv* in any simulator and simulate *top* module.

---

## SV Testbench

### Architecture

![image](images\APB_TB_arch.png)
<p align=center>Architecture</p>

### Components

#### **Transaction**

Signals encapsulated in transaction class is shown below:

```sv
class transaction;
    // Input
    rand bit PWRITE;          
    rand bit[31:0] PWDATA [];   
    rand bit[31:0] PADDR [];   
    rand bit PRESETn;    
    bit PSEL1;
    bit PENABLE;

    // Output
    bit PREADY;
    bit [31:0] PRDATA [int];
    bit PSLVERR;
endclass
```

Transaction class also encapsulates helper function like `printf(string message)`, `compare(transaction trans)`, etc.

#### **Generator**

Generates new packet which is sent to the driver. Main functionality is to randomize transaction class.

```sv
task run();
    assert(trans.randomize());
endtask
```

#### **Driver**

Drives the packet according to the APB protocol. The drive seqeunce is as follows:

![image](images\driver.png)
<!-- <img src = "images\driver.png" height=560 alt="driver flow"> -->

#### **Input Monitor**

Monitors the input signals of the APB protocol and when a complete transaction is monitored, it sends the sampled packet to reference model, which generates the expected value.

#### **Output Monitor**

Monitors the output signals of the APB protocol and after complete transaction is monitored it sends the packet to scoreboard for checking.

#### **Reference Model**

Generates the reference output/value, which is compared with the actual output received from the DUT

#### **Scoreboard**

Compares the actual packet and the reference packet and generates report for all the test cases.

---

## UVM Testbench

### Architecture

![image](images\APB_TB_arch.png)

**_This project is governed by [MIT License](LICENSE)_**
