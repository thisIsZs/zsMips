# zsMips

使用 Verilog 编写的 32 位 MIPS 五级流水线处理器，包含取指（IF）、译码（ID）、执行（EX）、访存（MEM）和写回（WB）五个阶段。适合阅读流水线数据通路、数据相关处理和基础异常处理的实现。

仓库提供 CPU RTL 源码，顶层模块为 `mycpu_top`，定义在 [`my_cpu.v`](my_cpu.v) 中。目前未附带 testbench、程序镜像、自动化测试、FPGA 工程或时序约束；下述功能根据源码整理，不代表已通过完整 MIPS32 兼容性验证。

## 功能概览

- 32 个 32 位通用寄存器，读取 `$zero` 始终返回 0。
- 五级流水线，以及 IF/ID、ID/EX、EX/MEM、MEM/WB 四组流水线寄存器。
- 整数运算、逻辑运算、移位、比较，以及使用 HI/LO 保存结果的乘除法。
- 通用寄存器和 HI/LO 数据旁路，Load-Use 与分支/寄存器跳转相关暂停。
- 分支、跳转、延迟槽标记，以及 `PC + 8` 链接地址写回。
- 字节、半字、字访存，带符号和无符号加载，小端字节通道选择。
- CP0 寄存器、6 路外部中断输入和基础异常处理逻辑。
- 独立的指令与数据 SRAM 接口，以及写回调试接口。

## 数据通路

```mermaid
flowchart LR
    IF["IF：取指 / PC"] --> IFID[IF/ID]
    IFID --> ID["ID：译码 / 读寄存器 / 分支判断"]
    ID --> IDEX[ID/EX]
    IDEX --> EX["EX：ALU / HI·LO 运算"]
    EX --> EXMEM[EX/MEM]
    EXMEM --> MEM["MEM：访存 / 异常处理"]
    MEM --> MEMWB[MEM/WB]
    MEMWB --> WB["WB：写回数据选择"]
    WB --> RF["通用寄存器 / HI·LO"]
    RF --> ID
```

写回选择逻辑位于 `mips_core.v`，没有独立的 `WB_step.v`。分支条件与目标地址在 ID 阶段计算，经 ID/EX 寄存器送往取指逻辑。旁路与暂停分别由 `bypass_ctl.v`、`stall_ctl.v` 控制。

流水线寄存器主要在时钟上升沿更新；通用寄存器、HI/LO 和 CP0 在实例化时接入反相时钟，因此在 CPU 时钟下降沿更新。接入仿真环境或编写约束时需考虑这一时序安排。

## 指令范围

以下列出源码中已有译码或执行路径的指令，实际正确性仍需通过测试确认。

| 类别 | 指令 |
| --- | --- |
| 算术 | `ADD`、`ADDU`、`SUB`、`SUBU`、`ADDI`、`ADDIU` |
| 比较 | `SLT`、`SLTU`、`SLTI`、`SLTIU` |
| 逻辑与立即数 | `AND`、`OR`、`XOR`、`NOR`、`ANDI`、`ORI`、`XORI`、`LUI` |
| 移位 | `SLL`、`SRL`、`SRA`、`SLLV`、`SRLV`、`SRAV` |
| 乘除法 | `MULT`、`MULTU`、`DIV`、`DIVU` |
| HI/LO 访问 | `MFHI`、`MFLO`、`MTHI`、`MTLO` |
| 条件分支 | `BEQ`、`BNE`、`BGTZ`、`BLEZ`、`BGEZ`、`BLTZ`、`BGEZAL`、`BLTZAL` |
| 跳转 | `J`、`JAL`、`JR`、`JALR` |
| 加载 | `LB`、`LBU`、`LH`、`LHU`、`LW` |
| 存储 | `SB`、`SH`、`SW` |
| 系统与异常 | `SYSCALL`、`BREAK`、`MFC0`、`MTC0`、`ERET` |

`NOP` 可使用编码为全零的 `SLL $zero, $zero, 0`。指令编码、ALU 控制码和异常码集中定义在 [`ZsMips.vh`](ZsMips.vh) 中。

## 文件说明

| 文件 | 职责 |
| --- | --- |
| `my_cpu.v` | 顶层 `mycpu_top`，连接 CPU、SRAM 接口和调试信号，处理数据地址映射 |
| `mips_core.v` | 流水线集成、控制信号连接、写回数据选择 |
| `IF_step.v`、`pc.v` | 取指地址、顺序执行、跳转和异常入口选择 |
| `ID_step.v`、`decoder.v` | 读寄存器、指令译码、分支判断和目标地址计算 |
| `EX_step.v`、`aludec.v`、`alu.v` | 操作数选择、ALU 译码、运算和旁路数据选择 |
| `MEM_step.v` | 字节通道、对齐检查、数据访存和异常处理单元连接 |
| `IF_ID.v`、`ID_EX.v`、`EX_MEM.v`、`MEM_WB.v` | 级间数据、控制信号与异常信息寄存 |
| `regfile.v`、`hilo_reg.v` | 通用寄存器堆和 HI/LO 寄存器 |
| `bypass_ctl.v`、`stall_ctl.v` | 数据转发和相关暂停控制 |
| `cp0_reg.v`、`exception_unit.v` | CP0 状态保存、中断与异常判定 |
| `sram_interface.v` | SRAM 使能、字节写使能、加载数据选取与扩展 |
| `signext.v` | 立即数符号扩展、零扩展和高 16 位装载 |
| `instdec.v` | 将部分指令转换为 ASCII 助记符，辅助波形调试 |
| `ZsMips.vh` | 公共宏定义 |

## 顶层接口与地址

所有方向均相对于 `mycpu_top`。

| 信号 | 方向 / 位宽 | 说明 |
| --- | --- | --- |
| `clk` | 输入 / 1 | CPU 时钟 |
| `resetn` | 输入 / 1 | 低电平有效复位，内部转换为高有效 `rst` |
| `ext_int` | 输入 / 6 | 高电平有效的外部中断输入 |
| `inst_sram_en` | 输出 / 1 | 指令端口使能，等于 `resetn` |
| `inst_sram_wen` | 输出 / 4 | 指令端口写使能，固定为 0 |
| `inst_sram_addr` | 输出 / 32 | 取指地址 |
| `inst_sram_wdata` | 输出 / 32 | 指令端口写数据，固定为 0 |
| `inst_sram_rdata` | 输入 / 32 | 外部存储器返回的指令 |
| `data_sram_en` | 输出 / 1 | 数据读或写使能 |
| `data_sram_wen` | 输出 / 4 | 数据端口逐字节写使能 |
| `data_sram_addr` | 输出 / 32 | 字对齐、经过映射的数据地址 |
| `data_sram_wdata` | 输出 / 32 | 存储数据 |
| `data_sram_rdata` | 输入 / 32 | 外部存储器返回的完整数据字 |
| `debug_wb_pc` | 输出 / 32 | WB 阶段指令地址 |
| `debug_wb_rf_wen` | 输出 / 4 | 通用寄存器写使能的四位复制值 |
| `debug_wb_rf_wnum` | 输出 / 5 | 写回目标寄存器编号 |
| `debug_wb_rf_wdata` | 输出 / 32 | 写回数据 |

- **复位地址：** `0xBFC00000`，定义于 `pc.v`。
- **异常入口：** `0xBFC00380`，定义于 `IF_step.v`。
- **数据地址映射：** KSEG0（`0x80000000`～`0x9FFFFFFF`）与 KSEG1（`0xA0000000`～`0xBFFFFFFF`）地址清除高 3 位；其他地址保持不变。
- **指令地址：** 直接输出取指地址，顶层未执行与数据端相同的映射。外部指令存储器需要正确解码复位和异常入口地址。
- **字节顺序：** 地址低两位为 `00` 时选择数据字的 `[7:0]`，为 `11` 时选择 `[31:24]`。

SRAM 接口没有 `ready`、`valid` 或等待应答信号，流水线也没有存储器等待控制。外部环境需在相应流水级的采样时刻前提供有效读数据；不能直接假定任意同步 RAM 或可变延迟总线都能接入。

## 异常与 CP0

`exception_unit.v` 包含外部/软件中断、取指与加载地址错误、存储地址错误、系统调用、断点、算术溢出和保留指令的判定路径。源码同时传递延迟槽信息，用于记录 EPC 与 Cause.BD。

| CP0 编号 | 寄存器 | 源码中的用途 |
| --- | --- | --- |
| 8 | `BadVAddr` | 地址异常对应的地址，只读 |
| 9 | `Count` | 每个 CP0 时钟上升沿加一，可写 |
| 12 | `Status` | 中断屏蔽、IE、EXL 等状态 |
| 13 | `Cause` | 异常码、延迟槽标记、软件中断位 |
| 14 | `EPC` | 异常返回地址 |

当前未实现 TLB、Cache 或完整 CP0 寄存器集合，也没有 `Compare` 定时中断寄存器。

## 编译与仿真接入

### 源码编译检查

安装 Icarus Verilog 后，在仓库根目录执行：

```bash
mkdir -p build
iverilog -g2005 -Wall -I . -s mycpu_top -o build/mycpu_top.vvp ./*.v
```

该命令用于语法和顶层展开检查。仓库没有生成时钟、复位和存储器响应的 testbench，直接执行这个顶层产物不能完成功能验证。本文档更新时的环境未提供 `iverilog` 或 `verilator`，上述命令尚未在该环境执行。

### 接入自己的测试平台

1. 实例化 `mycpu_top`，生成时钟，并让 `resetn` 保持低电平跨越若干时钟周期后释放。
2. 不测试中断时，将 `ext_int` 连接为 `6'b0`。
3. 提供指令存储器模型，将启动程序映射到 `0xBFC00000`；测试异常时提供 `0xBFC00380` 入口代码。
4. 提供数据存储器模型，按 `data_sram_wen` 更新字节通道，并根据映射后的地址返回完整的 32 位数据字。
5. 对照 `debug_wb_*` 与预期寄存器写回结果；比较有效通用寄存器写入时排除目标为 `$zero` 的记录。
6. 逐步覆盖算术、加载/存储、数据相关、分支延迟槽、HI/LO 和异常处理。

若自行将测试平台保存为 `tb/mycpu_top_tb.v`，并命名模块为 `mycpu_top_tb`，可执行：

```bash
mkdir -p build
iverilog -g2005 -Wall -I . -s mycpu_top_tb \
  -o build/mycpu_top_tb.vvp ./*.v tb/mycpu_top_tb.v
vvp build/mycpu_top_tb.vvp
```

这里的 `tb/mycpu_top_tb.v` 是需要自行编写的文件。波形输出也需要在测试平台中添加相应配置。

接入 FPGA 工程时，应加入全部 `.v` 文件和 `ZsMips.vh`，设置头文件搜索路径，并选择 `mycpu_top` 为 CPU 顶层。板级存储器、外设、引脚和时序约束需要另行提供。

## 当前限制与待验证项

- **缺少回归验证资料：** 仓库没有测试程序、测试结果或综合报告，暂不能据此给出最高频率、资源占用或指令测试通过率。
- **保留指令检测不完整：** `decoder.v` 使用 `func > 6'h3F` 检测部分 R 型非法编码，但 `func` 仅为 6 位，该条件不会成立。
- **ERET 状态恢复需要检查：** 已存在返回 EPC 的地址选择，但 `cp0_reg.v` 的 `en` 仅连接普通异常信号，`exception_unit.v` 对 ERET 不置该信号，当前路径不能完成正常的 EXL 清除。
- **乘除法采用组合运算：** `alu.v` 直接使用 `*`、`/`、`%`，没有多周期乘除法握手；实际综合面积和时序需要在目标器件上评估。
- **寄存器初始化方式：** 通用寄存器与 HI/LO 使用 `initial` 初始化，没有复位端口，运行中拉低 `resetn` 不会重新清空这些寄存器。

以上是阅读源码确认的边界与问题，不构成完整 RTL 审查。后续可先补充测试平台，再针对异常返回、相关冲突和访存时序建立回归用例。
