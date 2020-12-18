# AMBA_APB

To design SV test bench for APB protocol slave. Slave is taken as a **single port ram**.

## Architecture

![image](image\APB_TB_arch.png)

## Components

1. **Transaction** - Enacpsulates all the signals in one class
2. Generator
3. Driver
4. Input Monitor
5. Output Monitor
6. Environment
7. Test

### Transaction

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
