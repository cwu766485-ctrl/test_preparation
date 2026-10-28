# M6 Innovus 布局布线全流程（照着抄版）

> Module 6：Layout of Matrix Multiplier（GF 22FDX，Cadence Innovus 20.12）
> 根据 manual 第 3 节整理，加上 2026-10-15/16 两次实际上机踩过的坑。
> **M6 不用写代码**：输入文件机房全给好了，你要做的是按顺序执行命令（或点 GUI）、看结果、截图、排查问题。

---

## 0. 一页速览（考试或时间紧时只看这里）

```
cd ~/NM6008/Module6
csh
source cshrc_inno
innovus
```
进入 Innovus 后，最省事的做法：
```
source scripts/CHIP.tcl          ;# 机房给的完整流程脚本，一次跑完（约 20–25 分钟）
```
想一步一步来，就按下面 1–15 步执行。

**流程顺序（必背）：**
导入设计 → 全局电源网络 → Floorplan → Power Ring → Special Route → IO Filler → End Cap → 标准单元布局 → CTS（含前后时序优化）→ 布线 → Core Filler → DRC/连通性检查 → GDS → SPEF → SDF → 网表

---

## 准备工作

### 0.1 目录里有什么（机房给好的）
| 文件/目录 | 作用 |
|---|---|
| `Netlist/Syn_MatrixMultiplier.v` | M5 综合出的门级网表（机房提供，也可以换成自己的，端口要一致） |
| `IO/Syn_MatrixMultiplier_IO.v` | 顶层：把上面的网表包进去，加上 IO pad、时钟 pad、电源 pad |
| `IO/Syn_MatrixMultiplier.io` | pad 的摆放位置 |
| `LEF/` | 工艺层定义 + 标准单元 / IO 单元的物理外形 |
| `LIB/` | 时序库（.lib） |
| `RC/*/qrcTechFile` | 各个 RC corner 的寄生参数工艺文件 |
| `Syn_MatrixMultiplier_IO.globals` | 导入配置：告诉 Innovus 读哪些网表、LEF、view |
| `Syn_MatrixMultiplier_IO.view` | MMMC 时序视图（库 / RC corner / 约束的组合） |
| `scripts/CHIP.tcl`、`scripts/Route.tcl` | 现成的流程脚本和布线脚本 |
| `GDS/*.layermap`、`GDS/*_qrc_leftech.map` | GDS 导出层映射、RC 提取层映射 |

### 0.2 助教 2026-10-16 的更新（已经做过；新账号或新机器要重做）
```
cp -r /net/vlsiserver/usr11/library/CSM/GF22FDXPlus/NM6008/Module6/cshrc_inno /home/msc_tum_grp1/NM6008/Module6
cp -r /net/vlsiserver/usr11/library/CSM/GF22FDXPlus/NM6008/Module6/Syn_MatrixMultiplier_IO.globals /home/msc_tum_grp1/NM6008/Module6
```
这次更新修好了：`.globals` 里原来指向别的设计的 `AES_TOP_DP.view`，导致第 1 步 `init_design` 失败。

### 0.3 启动 Innovus
```
cd ~/NM6008/Module6
csh                    # 机房终端默认就是 csh，确认一下
source cshrc_inno      # 设置软件路径和 license（这是 csh 脚本，必须在 csh 里 source）
innovus                # 打开 GUI；不要界面可以用 innovus -no_gui
```
之后命令都在 `innovus 1>` 提示符后面输入。

---

## 第 1 步　导入设计（Loading the global variables）
```
source Syn_MatrixMultiplier_IO.globals
init_design
```
- GUI：File → Import Design… → Load… → 选 `Syn_MatrixMultiplier_IO.globals` → OK
- **看到**：中间是 core 区，四周一圈 IO pad
- **截图**：导入后的整体视图
- ⚠️ 坑：旧版 `.globals` 会报找不到 `AES_TOP_DP.view`。没更新文件时的临时解法：
  ```
  source Syn_MatrixMultiplier_IO.globals
  set init_mmmc_file Syn_MatrixMultiplier_IO.view
  init_design
  ```

## 第 2 步　全局电源网络（Global Net Connection）
```
clearGlobalNets
globalNetConnect vdd -type pgpin -pin VDD -inst *
globalNetConnect gnd -type pgpin -pin VSS -inst *
```
- GUI：Power → Connect Global Nets… → 填好后 Apply
- **作用**：把所有单元的 VDD/VSS 引脚接到全局网络 vdd/gnd 上

## 第 3 步　Floorplan
```
getIoFlowFlag
setIoFlowFlag 0
floorPlan -site GF22_SST -d 1400 1400 150 150 150 150 -noSnapToGrid
```
- GUI：Floorplan → Specify Floorplan…
- **含义**：芯片 1400 × 1400 µm，core 到芯片边缘四边各留 150 µm
- **截图**：floorplan 后的视图

## 第 4 步　电源环（Power Rings）
```
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer LB -stacked_via_bottom_layer M1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin { standardcell } -skip_via_on_wire_shape { noshape }

addRing -nets {gnd vdd} -type core_rings -follow core -layer {top C2 bottom C2 left C1 right C1} -width {top 1.8 bottom 1.8 left 1.8 right 1.8} -spacing {top 1.8 bottom 1.8 left 1.8 right 1.8} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None
```
- GUI：Power → Power Planning → Add Ring…
- **含义**：在 core 外围加一圈 vdd/gnd 环；上下用 C2 层、左右用 C1 层，宽度、间距、偏移都是 1.8 µm
- **截图**：电源环

## 第 5 步　特殊布线（Special Route / sroute）
```
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { MET1(1) MET4(4) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { MET1(1) MET4(4) } -nets { gnd vdd } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { MET1(1) MET4(4) }
```
- GUI：Route → Special Route…
- **作用**：把电源 pad 接到电源环上，并沿每一行标准单元生成电源轨（follow-pin rail）
- manual 后面还有一串 `selectWire / editResize / editTrim`，是手动修剪几根线，坐标和具体设计有关，**直接用 `scripts/CHIP.tcl` 里的版本最稳**
- **截图**：sroute 后的视图

## 第 6 步　IO Filler（pad 之间填空）
```
addIoFiller -cell "IN22FDX_GPIO18_10M19S40PI_FILL20_V IN22FDX_GPIO18_10M19S40PI_FILL10_V IN22FDX_GPIO18_10M19S40PI_FILL5_V IN22FDX_GPIO18_10M19S40PI_FILL1_V" -prefix IOFILLER_N -side n
addIoFiller -cell "IN22FDX_GPIO18_10M19S40PI_FILL20_V IN22FDX_GPIO18_10M19S40PI_FILL10_V IN22FDX_GPIO18_10M19S40PI_FILL5_V IN22FDX_GPIO18_10M19S40PI_FILL1_V" -prefix IOFILLER_S -side s
addIoFiller -cell "IN22FDX_GPIO18_10M19S40PI_FILL20_H IN22FDX_GPIO18_10M19S40PI_FILL10_H IN22FDX_GPIO18_10M19S40PI_FILL5_H IN22FDX_GPIO18_10M19S40PI_FILL1_H" -prefix IOFILLER_W -side w
addIoFiller -cell "IN22FDX_GPIO18_10M19S40PI_FILL20_H IN22FDX_GPIO18_10M19S40PI_FILL10_H IN22FDX_GPIO18_10M19S40PI_FILL5_H IN22FDX_GPIO18_10M19S40PI_FILL1_H" -prefix IOFILLER_E -side e
```
- **规则**：pad 之间不能有空隙；**先放宽的、再放窄的**（20 → 10 → 5 → 1），否则可能出 DRC/LVS 问题
- 上下两边（n/s）用 `_V`，左右两边（w/e）用 `_H`

## 第 7 步　End Cap
```
snapFPlan -all
set CELL_PREFIX "HDBSLT20"
setEndCapMode -reset
setEndCapMode \
  -topEdge "${CELL_PREFIX}_CAPB1" \
  -bottomEdge "${CELL_PREFIX}_CAPT1" \
  -leftEdge "${CELL_PREFIX}_CAPR9_1" \
  -rightEdge "${CELL_PREFIX}_CAPL9_1" \
  -rightTopCorner "${CELL_PREFIX}_CAPBOUCL9_1" \
  -rightBottomCorner "${CELL_PREFIX}_CAPTOUCL9_1" \
  -leftTopCorner "${CELL_PREFIX}_CAPBOUCR9_1" \
  -leftBottomCorner "${CELL_PREFIX}_CAPTOUCR9_1" \
  -leftBottomEdge "${CELL_PREFIX}_CAPTLINC9_1" \
  -lefttopEdge "${CELL_PREFIX}_CAPBLINC9_1" \
  -rightBottomEdge "${CELL_PREFIX}_CAPTRINC9_1" \
  -righttopEdge "${CELL_PREFIX}_CAPBRINC9_1" \
  -fitGap true
addEndCap -prefix ENDCAP
```
- GUI：Place → Physical Cell → Add End Cap…
- **作用**：每一行标准单元的两端放 end cap，满足阱的 tie-off 和阱延伸的 DRC 规则（这次加了约 20142 个）

## 第 8 步　标准单元布局（Placement）
```
setPlaceMode -fp false
placeDesign
```
- GUI：Place → Place Standard Cell… → OK
- **看到**：逻辑单元聚在 core 中间一小块（设计是 pad-limited，逻辑只有约 3275 µm²）
- **截图**：布局后的视图

## 第 9 步　时钟树综合（CTS）及前后时序优化
**9a. CTS 之前：查 setup，必要时优化**
```
timeDesign -preCTS -idealClock -pathReports -drvReports -slackReports -numPaths 50 -prefix Syn_MatrixMultiplier_IO_preCTS -outDir timingReports
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -preCTS
```
- GUI：Timing → Report Timing…（Pre-CTS，Setup）；ECO → Optimize Design…
- 结果在 `timingReports/Syn_MatrixMultiplier_IO_preCTS.summary`，看 Violating Paths 是不是 0
- **pre-CTS 不能修 hold**，只能在 post-CTS 修

**9b. CTS（只能用命令）**
```
create_ccopt_clock_tree_spec
ccopt_design -prefix cts
ctd_win -id ctd_window          ;# 打开 Clock Tree Debugger 窗口看时钟树（no_gui 模式下不要执行这句）
```
- GUI：Clock → CCOpt Clock Tree Debugger
- **截图**：Clock Tree Debugger

**9c. CTS 之后：查 setup 和 hold，修 hold**
```
timeDesign -postCTS -pathReports -drvReports -slackReports -numPaths 50 -prefix Syn_MatrixMultiplier_IO_postCTS -outDir timingReports
optDesign -postCTS
timeDesign -postCTS -hold -pathReports -slackReports -numPaths 50 -prefix Syn_MatrixMultiplier_IO_postCTS -outDir timingReports
optDesign -postCTS -hold
```
- CTS 引入了时钟延迟和偏斜，会**冒出 hold 违例**（这次约 −0.8 ns），`optDesign -postCTS -hold` 会插延迟单元修掉
- **截图**：post-CTS 的 setup / hold summary

## 第 10 步　布线（NanoRoute）+ 布线后时序
```
source ./scripts/Route.tcl
```
- GUI：Route → NanoRoute → Route… → OK
- **截图**：布线结果、NanoRoute summary（DRC 和 antenna 应为 0）

**布线后 signoff 时序（manual p.19–20）：**
```
setExtractRCMode -engine postRoute -effortLevel signoff -coupled true -capFilterMode relAndCoup -coupling_c_th 0.1 -total_c_th 0 -relative_c_th 1 -lefTechFileMap GDS/22FDSOI_10M_2Mx_5Cx_1Jx_2Qx_LB_qrc_leftech.map
setAnalysisMode -cppr none -clockGatingCheck true -timeBorrowing true -useOutputPinCap true -sequentialConstProp false -timingSelfLoopsNoSkew false -enableMultipleDriveNet true -clkSrcPath true -warn true -usefulSkew true -analysisType onChipVariation -log true
timeDesign -signoff -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP_TOP_signOff -outDir timingReports
timeDesign -signoff -hold -pathReports -slackReports -numPaths 50 -prefix CHIP_TOP_signOff -outDir timingReports
```
- ⚠️ 已知问题：这一步要做 RC 提取，在机房环境下会失败（见文末“已知问题”），但时序**照样能算完**，只是不含提取的寄生参数。日志里出现 `IMPESI-2017 no coupling capacitance` 就是这个原因
- 本次结果：setup WNS +87.309 ns，0 个违例路径
- **截图**：signoff setup / hold summary

## 第 11 步　Core Filler + 重新布线
```
getFillerMode -quiet
addFiller -cell HDBSLT20_FILL64 HDBSLT20_FILL32 HDBSLT20_FILL16 HDBSLT20_FILL8 HDBSLT20_FILL4 HDBSLT20_FILL3 HDBSLT20_FILL2 HDBSLT20_FILL1 -prefix FILLER -doDRC
source ./scripts/Route.tcl
```
- GUI：Place → Physical Cell → Add Filler…（勾 Do DRC）
- **作用**：把行里剩下的空位填满，保证阱的连续性，避免 DRC 违例
- **截图**：加 filler 后的版图

### 11+. 物理检查（manual 没写，但一定要做）
```
verify_drc
ecoRoute -fix_drc        ;# 如果 verify_drc 报错（上次报了 30 个 M1 spacing/short），用它修
verify_drc               ;# 再查一次，应为 0
verifyConnectivity       ;# 应为 0
```
- 注意：NanoRoute 报 0 DRC，不代表 `verify_drc` 也是 0，它更严格
- **截图**：verify_drc 和 verifyConnectivity 都是 0 violation

## 第 12 步　导出 GDS
```
streamOut Syn_MatrixMultiplier_IO.gds2 -mapFile GDS/22FDSOI_10M_2Mx_5Cx_1Jx_2Qx_LB_edi2gds_colored.layermap -libName DesignLib -structureName Syn_MatrixMultiplier_IO -units 1000 -mode ALL
```
- GUI：File → Save → GDS/OASIS…

## 第 13 步　寄生参数提取（SPEF）✅ 2026-10-16 已跑通
```
setExtractRCMode -reset      ;# 关键！清掉第 10 步留下的 postRoute + signoff 设置，恢复成默认的 preRoute
extractRC                    ;# 看到 PreRoute RC Extraction DONE 才算成功
rcOut -spef Syn_MatrixMultiplier_IO.spef -rc_corner typical
```
- GUI：Timing → Extract RC… → 勾 SPEF → corner 选 typical → OK
- **为什么要先 reset**：第 10 步按 manual 设了 `-engine postRoute -effortLevel signoff`，这个设置会一直生效。rcOut 要先做提取，用 signoff 档就会调用 Quantus，机房缺 GLIBC 起不来，于是报 `IMPDC-495`。查当前设置：`getExtractRCMode -effortLevel`
- postRoute 的各档都不行：signoff 报 GLIBC；medium 报 NREX-94；low 报 IMPEXT-6192（没有 captable，不允许）。**只有 preRoute 能用**
- manual 写的是 `-rc_corner cap`，但现在的 MMMC 里**没有叫 cap 的 corner**（报 IMPEXT-2900），要用 `typical`
- 成功的标志：`ls -lh Syn_MatrixMultiplier_IO.spef` 约 8.5 MB；`grep -c D_NET Syn_MatrixMultiplier_IO.spef` 约 12250
- 如果是 restoreDesign 进来的：`restoreDesign save_design/MatrixMultiplier_signoff_v2.dat Syn_MatrixMultiplier_IO`（顶层名是 Syn_MatrixMultiplier_IO，不是 MatrixMultiplier）

## 第 14 步　导出 SDF（时序文件）
```
all_hold_analysis_views
all_setup_analysis_views
write_sdf Syn_MatrixMultiplier_IO_rc.sdf
```
- GUI：Timing → Write SDF…
- 必须在第 13 步 extractRC 成功之后做，这样 SDF 里的 INTERCONNECT 延迟才来自提取的 RC（约 12782 条）
- 这次用了新文件名 `_rc.sdf`，没有覆盖旧的 SDF
- 想看用了提取 RC 后的时序：`report_timing -max_paths 1`（setup +87.311 ns）和 `report_timing -early -max_paths 1`（hold +0.422 ns）。不要用 `timeDesign -postRoute`，它会强制走 postRoute 提取，又报 NREX-94

## 第 15 步　导出布线后网表
```
saveNetlist output_netlist/Syn_MatrixMultiplier_IO.v
```
- GUI：File → Save → Netlist…

## 存档（方便以后恢复）
```
saveDesign save_design/MatrixMultiplier_signoff_v2
```
恢复（Innovus 要在 Module6 目录下启动）：
```
restoreDesign save_design/MatrixMultiplier_signoff_v2.dat Syn_MatrixMultiplier_IO
```
`.dat` 是一个**文件夹**，在 `~/NM6008/Module6/save_design/` 下。

结束后记得在 Innovus 里输入 `exit`，别一直占着 license。

---

## 已知问题与排查表

| 现象 | 出现在 | 原因 | 处理 |
|---|---|---|---|
| `init_design` 报找不到 `AES_TOP_DP.view` | 第 1 步 | 旧 `.globals` 是从别的设计复制过来的 | 已由助教更新修复；没更新时 `set init_mmmc_file Syn_MatrixMultiplier_IO.view` |
| `GLIBC_2.27 / 2.28 not found`、`child process exited abnormally` | effort=signoff 的 RC 提取（第 10 / 13 / 14 步） | Quantus 24.10 需要更新的 GLIBC，机房 Linux 太旧 | 学生改不了，已报告助教 |
| `NREX-94: 11 routing layers, 1 layers are mapped to techfile` | effort=medium 的 RC 提取（tQuantus） | layer map 和 qrcTechFile 的层名对不上 | 学生改不了，已报告助教 |
| `IMPDC-495 Run RC extraction before invoking RC output` / `IMPEXT-7050` | 第 13 步 rcOut | 第 10 步的 signoff 设置还在，提取没成功 | `setExtractRCMode -reset` → `extractRC` → `rcOut`（见第 13 步） |
| `IMPEXT-6192 Effort level 'low' ... not allowed` | postRoute + low | 没有 captable 文件 | 用 preRoute |
| `IMPESI-2017 no coupling capacitance` | 第 10 步 signoff 时序 | 提取失败，退回无寄生参数模式 | 报告里注明时序不含提取 RC |
| verify_drc 有 M1 spacing/short | 第 11 步之后 | NanoRoute 没查出来 | `ecoRoute -fix_drc` |
| post-CTS hold 违例 | 第 9 步 | 时钟树带来延迟和偏斜 | `optDesign -postCTS -hold` |
| `rcOut -rc_corner cap` 报 corner 不存在 | 第 13 步 | 设计里没有 cap corner | 改用 `typical` |

**关键理解**：第 10、13、14 步都要用同一个 RC 提取功能。第 10、14 步拿不到提取结果会退回估算值继续跑（只报 warning），第 13 步必须拿到提取结果才能写 SPEF，所以只有它报 error。前面 1–12 步的结果不受影响。

---

## 机房操作小贴士
- 终端默认是 **csh**：不认 `2>/dev/null`、`for ... do`、`<<'EOF'` 这些 bash 写法；需要时先输入 `bash`
- `cshrc_inno` 是 csh 脚本，要在 csh 里 `source`
- 隔着 VNC 打不出 `_` 和 `/`：用剪贴板粘贴（终端里按 Ctrl+Shift+V），或者直接坐在机房电脑前操作
- 一次跑完的批处理写法（bash 里）：
  ```
  nohup csh -c 'source cshrc_inno; innovus -no_gui -files 你的脚本.tcl -log 日志名' > console.txt 2>&1 &
  ```
  用 `-no_gui` 时，脚本里不能有 `ctd_win` 这类 GUI 命令

---

## 概念速记（笔试可能考）
| 名词 | 一句话 |
|---|---|
| Floorplan | 定芯片和 core 的尺寸、行（row）的位置 |
| Power ring / stripe / rail | core 外围的电源环 / 跨 core 的电源条 / 每行单元上下的电源轨 |
| IO filler | 填 pad 之间的空隙，保证 pad ring 连续 |
| End cap | 行两端的物理单元，满足阱的 tie-off 和阱延伸的 DRC 规则 |
| Core filler | 填满行里的空位，保证阱连续、避免 DRC |
| CTS | 时钟树综合：插 buffer 把时钟送到所有触发器，控制 skew 和 insertion delay |
| Setup / Hold | 数据要在时钟沿**之前**稳定够久 / 时钟沿**之后**还要保持够久；hold 违例 = 数据来得太快 |
| 为什么 hold 在 post-CTS 修 | 真实时钟偏斜要等 CTS 之后才知道；pre-CTS 用理想时钟 |
| WNS / TNS | 最差 slack / 所有负 slack 的总和；slack = required − arrival，正数为 MET |
| OCV | On-Chip Variation：signoff 时考虑片上工艺偏差的分析模式 |
| DRC / LVS | 查版图几何规则 / 查版图连接是否和网表一致 |
| GDS | 最终交给工厂的版图文件 |
| SPEF | 布线后提取的寄生电阻、电容（用于精确时序和后仿） |
| SDF | 每个门和每根线的延迟（用于带延迟的门级仿真） |
| Pad-limited | 芯片面积由 pad 数量决定，而不是由逻辑大小决定（本设计利用率只有 0.32%） |
