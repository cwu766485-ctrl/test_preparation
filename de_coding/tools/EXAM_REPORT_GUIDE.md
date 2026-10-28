# NM6008 考试报告：仿真、综合与结果整理

本指南区分课程手册要求与本地练习 RTL。拿到试题后，先以题面为准确认模块名、端口位宽、复位极性、延迟和有符号规则；具体练习的接口和 TB 期望结果见对应目录 README。

学长提交的 n 位串行加法器报告可作为报告结构参考：波形、综合报告/单元使用情况、原理图、简要架构说明、RTL 和 testbench。报告说明当时没有完成波形仿真；按下文流程可以补齐波形部分。Module 3 是综合和门级仿真的主要参考；Module 6 是矩阵乘法器专用的物理设计流程，需要课程 PDK。

## A. 行为级 VCS 仿真与波形（Module 3）

在课程 Linux 机器或已配置的 WSL 终端中，如果 VCS 或许可证环境尚未设置，先加载实验室提供的 VCS 环境。在含普通 Makefile 的题目目录运行：

~~~sh
make test
~~~

也可以手动使用该目录 README 中的准确 TB 和 RTL 文件名：

~~~sh
vcs -full64 -sverilog -debug_access+all -timescale=1ns/1ps \
  -top <testbench_module> <rtl_file_1.v> <rtl_file_2.v> <testbench.sv> \
  -o simv
./simv
./simv -gui
~~~

不使用 SystemVerilog 语法的 .v 测试平台，课程示例也使用 vcs -debug +v2k 等命令。在 DVE 中展开 testbench 和 DUT，把时钟、复位、输入、状态/计数器、数据寄存器和输出加入波形窗口，然后运行并缩放到完整时间范围。保存能看清关键跳变的截图。多数自检 TB 还会生成 .vcd；如果提交要求波形文件，请一并保留。若可用的其他波形查看器能打开 VCD，则不一定要启动 DVE 图形界面。

波形至少应展示复位、一次正常事务、边界情况、valid/done/strobe 时序，以及题目涉及的重新启动或握手场景。确认 TB 打印 PASS 汇总且没有失败检查后，再将波形作为报告证据。

## B. Design Vision 综合与报告（Module 3）

1. 从课程 Module 3 模板复制一份独立的综合工作目录。把可综合 RTL 放入 sources/；不要把 testbench 放进综合文件列表。保留课程 GF22 工艺库、环境配置和约束文件。
2. 在 scripts/ReadVerilogFiles.tcl 中为每个 RTL 文件添加一条 read_verilog。修改顶层专用 Tcl 和 scripts/run_topdown.tcl，使综合顶层与 Verilog 模块名一致。开始运行前检查 current_design、link、compile 和输出文件名。
3. 根据题面和 TB 时钟周期设置 CLK_PERIOD、输入延迟和输出延迟。时序设计必须有有效时钟约束；组合逻辑需要合理的输入/输出延迟或虚拟时钟约束。不要把串行加法器的时钟周期照搬给其他电路。
4. 在配置好的课程终端中启动图形界面并执行模板脚本：

~~~csh
source <course_synopsys_setup>
design_vision &
~~~

在 Design Vision 中选择 File → Execute Script，然后执行 scripts/run_topdown.tcl。遵循 Module 3 模板的脚本顺序；通常会依次加载环境、读入文件、设计专用 Tcl 和报告脚本。
5. 检查日志中是否有读入、链接或综合错误。保存 logs/report.rpt，以及模板生成的门级网表、SDF 和 SDC。在 Design Vision 命令窗口中，按已安装工具和模板支持的命令收集报告，例如：

~~~tcl
report_area
report_cell
report_timing -significant_digits 4
report_constraint -all_violators
report_qor
report_power
~~~

记录单元数量/面积、关键路径与 slack，以及带单位的估算功耗。确认映射单元来自 GF22 工艺库；GTECH 或未映射的通用单元不能作为完成工艺映射的报告。没有输入开关活动时，功耗只是估算值。
6. 在 Logical Hierarchy 中右键综合后的顶层，选择 Schematic View。展开足够层次以展示电路结构，并保存清晰截图。报告中解释状态机、数据通路、控制使能、算术位宽/符号扩展和运算延迟。

Tcl 命令和输出路径可能随课程模板变化。将课程提供的 .synopsys_dc.setup、common_setup_gf22.tcl、MyDefaults.con、库文件列表和报告脚本一起保留；不要假设另一台实验室机器上存在相同的 GF22 路径。

## C. 综合后门级仿真（Module 3）

使用同一次综合生成的网表、SDF、标准单元 Verilog 模型和库文件列表。TB 中 $sdf_annotate 的实例路径必须与综合网表中的 DUT 层次一致。在门级仿真目录运行：

~~~csh
vcs -full64 -debug +v2k +neg_tchk +define+GATE_SIM \
  <testbench.v> <Syn_top.v> -f library.f -o simv
./simv
~~~

课程 TB 也可能需要 +define+VCS 才会记录 VPD。检查日志确认 SDF 标注成功，并把输出与行为级仿真结果对照。如果 SDF、库、实例路径或工艺配置缺失/不匹配，则门延迟结果尚未验证，不能将该次运行报告为成功。

## D. Module 6 Innovus 布局布线（仅矩阵乘法器作业）

Module 6 不是可以直接用于任意 RTL 目录的一组通用命令。它依赖课程 GF22 PDK、焊盘库、工艺 LEF/lib、IO 封装与网表、引脚位置文件、.globals、.io、SDC 和 Innovus 环境。使用配套 Module 6 工程作为模板；替换设计文件前先核对焊盘和端口名称是否仍匹配。

在课程机器中按要求使用 C shell 和课程环境：

~~~csh
cd ~/Module6
source cshrc_inno
innovus
~~~

然后按给定 scripts/script.tcl 和 Module 6 流程顺序执行：

1. 执行 source Syn_MatrixMultiplier_IO.globals，然后运行 init_design。
2. 清除并连接全局电源/地线网络，连接到对应库引脚。
3. 按课程站点、核心尺寸和边距创建 floorplan。
4. 添加电源环/电源条并完成电源布线；放置需要的 IO filler、endcap 和标准单元。
5. 执行 CTS 前时序、优化和布局检查；构建时钟树（CTS）后再执行 CTS 后检查。
6. 布置信号线，执行布线后时序/DRC 检查，并生成课程要求的交付物：布线后网表、SDF、SPEF 和 GDS 输出。

以下是 Module 6 手册中的命令位置示例。需要与课程 scripts/script.tcl 对照；课程脚本才是当前工程的权威版本，可能还包含其他 IO、filler 或工艺配置：

~~~tcl
source Syn_MatrixMultiplier_IO.globals
init_design
clearGlobalNets
globalNetConnect vdd -type pgpin -pin VDD -inst *
globalNetConnect gnd -type pgpin -pin VSS -inst *

# 仅为手册示例 floorplan；只适用于匹配的 GF22 site/project。
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site GF22_SST -d 1400 1400 150 150 150 150 -noSnapToGrid

# 课程脚本还会提供精确的 addRing、sroute、filler 和 endcap 设置。
setPlaceMode -fp false
placeDesign
timeDesign -preCTS -idealClock -pathReports -drvReports -slackReports \
  -numPaths 50 -prefix Syn_MatrixMultiplier_IO_preCTS -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS
create_ccopt_clock_tree_spec
ccopt_design -prefix cts
source ./scripts/Route.tcl

# 布线后提取，以及手册要求生成的文件。
timeDesign -signoff -pathReports -drvReports -slackReports -numPaths 50 \
  -prefix Syn_MatrixMultiplier_IO_postRoute -outDir timingReports
rcOut -spef Syn_MatrixMultiplier_IO.spef -rc_corner typical
all_hold_analysis_views
all_setup_analysis_views
write_sdf Syn_MatrixMultiplier_IO.sdf
saveNetlist output_netlist/Syn_MatrixMultiplier_IO.v
streamOut Syn_MatrixMultiplier_IO.gds2 -mapFile <foundry_gds_layermap> \
  -libName DesignLib -structureName Syn_MatrixMultiplier_IO -units 1000 -mode ALL
~~~

手册还会执行详细的 addRing、sroute、filler/endcap 和布线后提取命令。只有工艺库匹配时才使用它的金属层名（C1/C2、MET1…）和单元前缀。如果输入文件缺失，应先找到正确的课程工程文件，不要猜测 PDK 名称。与 floorplan、CTS、布线相关的截图，以及 timingReports/*preCTS.summary、*postCTS.summary、*postRoute.summary 和 hold 报告都应保留。

保存 floorplan、布局、时钟树、布线结果和相关时序/DRC 报告截图。Tcl 命令、site 名称、电源网名称和尺寸以本地 GF22 工程为准。不要把其他 PDK 的 floorplan 尺寸、引脚坐标或电源引脚名照搬过来。如果机器没有课程 PDK、Innovus 或许可证，应在报告中说明缺少的前置条件；不能声称该流程已经运行。

## E. 一页报告检查表

- [ ] 题目要求、设计假设、端口表、复位和延迟。
- [ ] RTL 架构解释和带注释的原理图截图。
- [ ] 自检 TB 汇总和代表性行为波形。
- [ ] 综合单元/面积、关键时序/slack，以及带单位的功耗估算。
- [ ] 若题目要求且环境具备条件，提交映射网表和 SDF 门级仿真结果。
- [ ] 若课程环境提供 PDK，矩阵乘法器作业还需 floorplan/布局/CTS/布线截图和报告。
- [ ] 在附录或提交目录中放入最终 RTL 和 TB 源码。
- [ ] 收集所需截图/报告后，在练习目录运行 make clean；清理前先复制需要提交的结果。

本练习流程不包含形式验证。仿真只能说明 testbench 实际覆盖的场景。
