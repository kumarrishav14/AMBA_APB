# AMBA APB

Test bench for APB protocol ram (single slave configuration).

[SV Testbench](#sv-testbench) | [UVM Testbench](#uvm-testbench)

## How to run test bench

- Download the latest release from below or visit the [release page][github-release-link]for more old release.

<table border="2" align="center">
<thead>
  <tr>
    <th>SV Testbecnh</th>
    <th>UVM Testbench</th>
  </tr>
</thead>
<tbody>
  <tr align="center">
    <td>
        <a href =  "https://github.com/kumarrishav14/AMBA_APB/archive/v1.0.zip">Zip</a>
    </td>
    <td>
        <a href="https://github.com/kumarrishav14/AMBA_APB/archive/v1.0.zip">Zip</a>
    </td>
  </tr>
  <tr align="center">
    <td>
        <a href="https://github.com/kumarrishav14/AMBA_APB/archive/v1.0.tar.gz">Tar.gz</a>
    </td>
    <td>
        <a href="https://github.com/kumarrishav14/AMBA_APB/archive/v1.0.tar.gz">Tar.gz</a>
    </td>
  </tr>
</tbody>
</table>
<p>
    &NewLine;
</p>

- Copy the contents in a folder.
- Compile *tb_top.sv* in any simulator and simulate *top* module.

---

## SV Testbench

### Architecture

![image](images\APB_TB_arch.png)
<p align=center><b>Fig. 1:</b> Testbench Architecture</p>

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
<p align=center><b>Fig. 2:</b>Flow diagram of driver</p>
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
