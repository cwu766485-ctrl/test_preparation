# NM6008 试题交付与 GitHub 工作流

本文件记录用户明确指定的固定工作流。适用于允许使用外部工具与 AI 的模拟考试、练习和其他授权场景。每次以**该题题目**和用户提供的 **2026 版 Module 3 / Module 6 手册**为基准。手册版本或实验环境变化时，重新核实，不机械套用示例参数。

## 1. 输入与实施方式

用户给出新题（照片、PDF、文字）后：
1. 逐条提取功能、IO、状态/时序、参数、边界条件及交付要求。对未规定的行为使用清晰、尽可能少的假设；如实标注。
2. 推导结构、状态机/数据路径、关键控制信号、Corner Cases；**不可为了让测试通过而硬编码特定输出**。
3. 按题目特点命名独立目录 `nm6008_exam/<topic_slug>/`，不覆盖其他题目或原有 `rtl/`、`tb/`、`de_coding/`。
4. 按以下文件规范交付、测试、上传到 `cwu766485-ctrl/test_preparation` 默认 `main` 分支（有冲突时保护原文件；不强推、不无依据覆写）。

## 2. 每题必须有的文件

```text
nm6008_exam/<topic_slug>/
├── rtl/
│   ├── <topic>.v                 # 可综合 Verilog-2001 RTL
│   └── ...                       # 必要的子模块
├── tb/
│   ├── tb_<topic>.sv             # 自检查 SystemVerilog RTL TB
│   └── tb_<topic>_gate.sv        # 网表 + SDF 的门级 TB
├── scripts/
│   ├── ReadVerilogFiles.tcl      # DC 读取设计
│   ├── run_topdown.tcl          # DC 综合入口
│   ├── synth_<topic>.tcl        # 约束、综合、Netlist/SDF/SDC、Report
│   └── ...                       # 针对 Module 6 的**可用配置**脚本/模板
├── docs/
│   ├── MODULE3_MODULE6_FULL_FLOW.txt   # 实验室按键/菜单/终端操作指南
│   ├── TESTPLAN.md               # 测试点、预期结果、边界、约束
│   └── REPORT_CHECKLIST.md       # 必须截图/实际数据/待验证项
└── README.md                     # 题意、架构、运行指令、状态与限制
```

TB 要覆盖启动/复位、正常路径、边界、时序/握手、异常和可恢复场景；尽量使用独立参考模型、scoreboard / assertion / timeout，显式报 PASS/FAIL。门级 TB 使用综合网表接口、正确层级的 `$sdf_annotate`、工艺 `library.f`，注意 timing checks、timescale、clock period、SDF 警告、数据稳定性，并保留可分析的波形或 VPD 活动。

## 3. 操作指南必须覆盖的流程

**Module 3（Synopsys）：**
1. Linux 目录与工具检查；`csh`；依据手册正确 `source synopsys_linux_vP_2019_cshrc`，VCS 编译/仿真，`simv -gui`，DVE 选择信号并截图；
2. 配置合规的本地 Synopsys / GF22 环境（`.synopsys_dc.setup`、`common_setup_gf22.tcl`、源文件），`source synopsys_linux_vR_2020_cshrc`，Design Vision -> Execute Script -> `run_topdown.tcl`；核查 `check_design` / warning / netlist / SDF / SDC / report；
3. 将真实 `Syn_*.v`、`Syn_*.sdf` 与授权的 `library.f` 放入门级仿真工作目录；VCS `+neg_tchk` 和 SDF 注释（实际使用以工具/设计要求为准）；分析功能、时序、setup/hold；
4. 仿真活动文件 VPD -> VCD -> SAIF；在适配实例层级的 DC/Power Compiler 会话中 `read_saif`、`report_power`、`report_power -hier`；检查注释覆盖率；
5. 从真实日志提取 area / cell count / sequential & combinational counts / setup & hold / critical delay / dynamic & leakage power，不猜测数字。

**Module 6（Cadence Innovus）：**
1. 按手册在实验室配置 `cshrc_inno`、`innovus`；检查已经完成的综合网表、IO wrapper、IO 文件、SDC、LEF/Lib/RC、`*.globals`/init 依赖及工艺兼容性；
2. `source <design>.globals`、`init_design`；global power/ground net connection；
3. Floorplan、Power Rings、Special Route、IO fillers、End Caps；
4. Standard Cell Placement、Pre-CTS setup timing、Pre-CTS optimization；
5. CTS、Post-CTS setup/hold 检查/优化；
6. Detail Route、Post-Route setup/hold / RC / signoff checks；
7. Core fillers、最终 DRC 检查、导出网表/物理设计数据/SDF 和布局截图（具体菜单/命令以提供的2026手册和本地环境为准）。
**注意**：Module 6 示例的 pad/metal layer、floorplan 尺寸、cell 名、路径只适用于对应课程参考设计，不得原样硬套新题；新题未要求 Layout 时把 Layout 标为扩展而非必交。

指南必须写明：终端所在目录、shell 类型、每条命令在哪里执行、需从哪里复制哪些本地许可文件、GUI 菜单点击步骤、看到什么算通过、哪里截屏、遇到错误怎么定位。每个依赖未知时使用明确占位符并指导核实，**不能杜撰用户的实验室真实路径或工艺库名字**。

## 4. 质量关卡与状态声明

- 至少执行源代码审查、可用环境中的语法/编译/回归检查，并检查不同模块的端口连接、宽度、有符号性、复位、时序和综合可用性。
- 在没有 Synopsys 工具、GF22 PDK 或 Innovus 环境时，提供预期命令、测试与已验证/未验证清单；**绝不把未执行的 VCS、综合、后仿、P&R 声称为 PASS**。
- 避免强行保证「100% 正确」：目标是尽可能可靠、可复现，只有实际证据才标为签核通过。
- GitHub public 仓库严禁上传未授权课程内容、商业 PDK/标准单元模型、license、密钥、考试个人信息等。

## 5. 上传与实验室拉取

每题创建有辨识度的目录名，在 GitHub 创建/更新文件并检查写入结果；反馈：
- GitHub 文件/目录链接及完整 commit SHA；
- 文件列表与每个文件用途；
- 已做的验证和明确的剩余工作；
- 实验室 `git pull --ff-only origin main` 和进入目录的准确命令；
- 按用户实验室工具环境可直接执行的 RTL/Gate/Synthesis/P&R 指令。

第一次克隆（在实验室 Linux）：
```bash
cd ~/Downloads
git clone https://github.com/cwu766485-ctrl/test_preparation.git
cd test_preparation
git log -1 --oneline
```

之后每次更新：
```bash
cd ~/Downloads/test_preparation
git status
git pull --ff-only origin main
git log -1 --oneline
```
若有未提交修改先检查，不自动覆写或强制同步。

## 6. 依据

用户提供的《NM6008 Module 3 - Full-Adder》（2026）和《NM6008 Module 6 - Layout of Matrix Multiplier》（2026）；本文件是操作要求的概括，**不是**上传或重新分发课程原始 PDF、工艺文件或受许可配置。
