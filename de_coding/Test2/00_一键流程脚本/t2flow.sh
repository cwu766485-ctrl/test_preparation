#!/bin/bash
# =====================================================================
#  t2flow.sh － NM6008 前端设计一键流程
#
#  把本文件放在复制出的工程根目录（例如用 cp -r Module5 Test2 建立的
#  ~/NM6008/Test2），与 Behavioral/、Synthesis/、rtl/ 三个目录同级。
#
#  运行前，Behavioral/ 内必须有：
#     <TOP>.v（及其他 RTL .v 文件）、<TOP>_tb.v、可选的 InputVector*.txt
#
#  在工程根目录使用：
#     chmod +x t2flow.sh                 只需执行一次
#     ./t2flow.sh <TOP>                  依次运行行为仿真、综合、门级仿真、功耗
#     ./t2flow.sh <TOP> beh              只运行行为仿真
#     ./t2flow.sh <TOP> syn gate         只运行指定阶段，顺序仍按流程排列
#     ./t2flow.sh <TOP> clean            清理脚本生成的文件
#
#  各阶段：
#     beh   ：VCS 行为仿真，先验证 RTL 功能（Behavioral/）
#     syn   ：DC 综合，批量执行原来的 run_topdown.tcl（Synthesis/）
#     gate  ：VCS 门级仿真，并反标 SDF 延时（rtl/）
#     power ：波形转 SAIF，再由 dc_shell 生成功耗报告（rtl/PowerAnalysis/）
#
#  每个阶段使用独立 csh 并加载各自的环境文件，避免把 VCS 的 vP_2019
#  与 DC 的 vR_2020 环境混在同一终端。汇总写入根目录 RESULT_<TOP>.txt。
#
#
#  可选环境变量：
#     VCS_EXTRA="-full64" ./t2flow.sh TOP   给 VCS 增加参数
#     STOP_ON_FAIL=0      ./t2flow.sh TOP   仿真有 FAIL 时仍继续后续阶段
# =====================================================================

TOP="$1"
shift
STAGES="$*"
[ -z "$STAGES" ] && STAGES="beh syn gate power"
VCS_EXTRA="${VCS_EXTRA:-}"
STOP_ON_FAIL="${STOP_ON_FAIL:-1}"

ROOT="$(cd "$(dirname "$0")" && pwd)"
BEH="$ROOT/Behavioral"
SYN="$ROOT/Synthesis"
if   [ -d "$ROOT/rtl" ]; then RTLD="$ROOT/rtl"
elif [ -d "$ROOT/RTL" ]; then RTLD="$ROOT/RTL"
else RTLD="$ROOT/rtl"; fi
PWR="$RTLD/PowerAnalysis"
RESULT="$ROOT/RESULT_${TOP}.txt"

# ---------- 屏幕输出与结果记录：成功、警告、失败分别显示 ----------
if [ -t 1 ]; then R=$'\e[31m'; G=$'\e[32m'; Y=$'\e[33m'; B=$'\e[1;34m'; N=$'\e[0m'; else R=; G=; Y=; B=; N=; fi
step() { echo; echo "${B}==================== $* ====================${N}"; }
ok()   { echo "${G}[ OK ]${N} $*"; }
warn() { echo "${Y}[WARN]${N} $*"; echo "WARN: $*" >> "$RESULT"; }
die()  { echo "${R}[FAIL]${N} $*"; echo "FAIL: $*" >> "$RESULT"; echo; echo "Summary so far: $RESULT"; exit 1; }
note() { echo "$*" >> "$RESULT"; }

usage() { sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
[ -z "$TOP" ] && usage
case "$TOP" in -h|--help|help) usage;; esac

# 按给定顺序在候选目录中查找环境配置文件，供各阶段的 csh 加载。
find_rc() {   # $1 是文件名匹配片段，后续参数是按优先级排列的目录
    local pat="$1"; shift
    local d f
    for d in "$@"; do
        for f in "$d"/*${pat}*cshrc "$d"/sourcefiles; do
            [ -f "$f" ] && { echo "$f"; return 0; }
        done
    done
    return 1
}

# 在独立 csh 中进入工作目录、加载环境，再执行命令并把输出写入日志。
run_csh() {   # $1 工作目录，$2 环境文件，$3 命令，$4 日志文件
    csh -c "cd '$1' && source '$2' >& /dev/null && $3" > "$4" 2>&1
}

# 检查 VCS 编译日志和仿真日志；有编译错误或 FAIL 时报告对应文件。
check_vcs_log() {   # $1 编译日志，$2 仿真日志，$3 阶段名称
    if grep -q -E "^Error-|Error-\[" "$1"; then
        grep -n -A4 -E "Error-" "$1" | head -40
        die "$3: VCS compile error (see $1)"
    fi
    [ -f "$2" ] || die "$3: simulation did not run (see $1)"
    local nfail
    nfail=$(grep -c -E "FAIL" "$2")
    grep -E "DONE|PASS:|errors" "$2" | tail -3
    if [ "$nfail" -gt 0 ]; then
        grep -E "FAIL" "$2" | head -10
        if [ "$STOP_ON_FAIL" = "1" ]; then die "$3: $nfail FAIL line(s) in $2"; else warn "$3: $nfail FAIL line(s) in $2"; fi
    else
        ok "$3: no FAIL lines"
    fi
    note "$3: $(grep -E 'DONE|errors' "$2" | tail -1)"
}

# =====================================================================
#  CLEAN：清理脚本生成的文件，保留 RTL、输入向量和工程脚本
# =====================================================================
if [ "$STAGES" = "clean" ]; then
    step "CLEAN"
    rm -rf "$BEH"/simv "$BEH"/simv.daidir "$BEH"/csrc "$BEH"/*.vpd "$BEH"/*.log "$BEH"/Check.txt "$BEH"/ucli.key "$BEH"/run_beh.out
    rm -f  "$SYN"/netlist/* "$SYN"/logs/* "$SYN"/ddc/* "$SYN"/t2_syn.tcl "$SYN"/command.log "$SYN"/default.svf
    rm -rf "$RTLD"/simv "$RTLD"/simv.daidir "$RTLD"/csrc "$RTLD"/*.vpd "$RTLD"/*.log "$RTLD"/Check.txt "$RTLD"/Syn_* "$RTLD"/ucli.key "$RTLD"/run_gate.out
    rm -f  "$PWR"/*.vcd "$PWR"/*.saif "$PWR"/rpt_* "$PWR"/t2_power.tcl "$PWR"/*.log
    ok "generated files removed (your .v / .txt / scripts are kept)"
    exit 0
fi


# =====================================================================
#  PREFLIGHT：运行前确认目录、模块名、testbench 和时钟约束
# =====================================================================
step "PREFLIGHT  top = $TOP   stages = $STAGES"
: > "$RESULT"
note "t2flow result for $TOP  ($(date))"
note "project: $ROOT"

for d in "$BEH" "$SYN" "$SYN/scripts" "$RTLD"; do
    [ -d "$d" ] || die "folder $d not found - run this script in the ROOT of a copied Module (cp -r Module5 Test2)"
done

TB_FILE="$BEH/${TOP}_tb.v"
[ -f "$TB_FILE" ] || TB_FILE="$(ls "$BEH"/*_tb*.v 2>/dev/null | head -1)"
[ -f "$TB_FILE" ] || die "no testbench *_tb.v in $BEH"
TB_NAME="$(basename "$TB_FILE")"
TB_MOD="$(grep -m1 -E '^\s*module\s+' "$TB_FILE" | sed -E 's/^\s*module\s+([A-Za-z_0-9]+).*/\1/')"

# Behavioral/ 下除了 testbench 以外的所有 .v 文件都作为 RTL 输入。
RTL_FILES=""
for f in "$BEH"/*.v; do
    b="$(basename "$f")"
    case "$b" in *_tb*.v|*~) continue;; esac
    RTL_FILES="$RTL_FILES $b"
done
RTL_FILES="${RTL_FILES# }"
[ -n "$RTL_FILES" ] || die "no RTL .v files in $BEH"
grep -q -E "^\s*module\s+$TOP\b" "$BEH"/*.v || die "no 'module $TOP' found in Behavioral/*.v (check the name / case)"

# 找 testbench 中待测模块（DUT）的实例名，通常应为 U1。
INST="$(grep -E "^\s*$TOP\b" "$TB_FILE" | head -1 | sed -E "s/^\s*$TOP\s*(#\s*\(.*\))?\s*([A-Za-z_0-9]+)\s*\(.*/\2/")"
echo "$INST" | grep -q -E '^[A-Za-z_][A-Za-z_0-9]*$' || INST=""
if [ -z "$INST" ] || [ "$INST" = "$TOP" ]; then INST="U1"; fi

echo "  testbench : $TB_NAME   (module $TB_MOD, DUT instance $INST)"
echo "  RTL files : $RTL_FILES"
note "testbench: $TB_NAME (module $TB_MOD, instance $INST); RTL: $RTL_FILES"

# 提前检查 testbench 是否具备门级 SDF 与功耗波形所需的语句。
grep -q 'GATE_SIM'         "$TB_FILE" || warn "tb has no \`ifdef GATE_SIM ... \$sdf_annotate - gate-level sim will have NO delays"
grep -q "Syn_${TOP}.sdf"   "$TB_FILE" || warn "tb does not mention Syn_${TOP}.sdf in \$sdf_annotate"
grep -q 'vcdpluson'        "$TB_FILE" || warn "tb has no \$vcdpluson - power analysis needs inter.vpd"
grep -q 'inter.vpd'        "$TB_FILE" || warn "tb does not write inter.vpd (\$vcdplusfile(\"inter.vpd\"))"

# 根据 RTL 是否含时钟沿触发，判断是时序电路还是组合电路。
if grep -q -E "posedge|negedge" $(for f in $RTL_FILES; do echo "$BEH/$f"; done); then SEQ=1; else SEQ=0; fi

# 比较 testbench 的时钟周期与综合约束 MyDefaults.con 的 CLK_PERIOD。
CON="$SYN/scripts/MyDefaults.con"
TB_HALF="$(grep -v -E '^\s*//' "$TB_FILE" | grep -m1 -E '(parameter|localparam)\s+(integer\s+)?CLK_T\s*=\s*[0-9.]+' | sed -E 's/.*CLK_T\s*=\s*([0-9.]+).*/\1/')"
[ -z "$TB_HALF" ] && TB_HALF="$(grep -v -E '^\s*//' "$TB_FILE" | grep -m1 -E '(forever|always)\s*#\s*[0-9.]+' | sed -E 's/.*#\s*([0-9.]+).*/\1/')"
CON_PER="$(cat "$CON" "$SYN"/scripts/*.tcl 2>/dev/null | grep -m1 -E '^\s*set\s+CLK_PERIOD\s+[0-9.]+' | sed -E 's/.*CLK_PERIOD\s+([0-9.]+).*/\1/')"
if [ "$SEQ" = "1" ]; then
    if [ -n "$TB_HALF" ] && [ -n "$CON_PER" ]; then
        TB_PER=$(awk "BEGIN{print 2*$TB_HALF}")
        if awk "BEGIN{exit !($TB_PER == $CON_PER)}"; then ok "clock: tb period $TB_PER ns = CLK_PERIOD $CON_PER ns"
        else warn "clock MISMATCH: tb period = $TB_PER ns, MyDefaults.con CLK_PERIOD = $CON_PER ns (change one of them)"; fi
    else
        warn "could not read the clock period (tb CLK_T='$TB_HALF', CLK_PERIOD='$CON_PER') - check by hand"
    fi
    if [ -f "$CON" ] && grep -q -E '^\s*#\s*create_clock' "$CON"; then
        warn "create_clock is commented out in MyDefaults.con, but the design is sequential (timing will be unconstrained)"
    fi
else
    echo "  design is combinational (no posedge/negedge)"
    if [ -f "$CON" ] && grep -q -E '^\s*create_clock' "$CON"; then
        warn "combinational design but create_clock is active in MyDefaults.con - clock errors in DC can be ignored (manual Note 1)"
    fi
fi

T0=$(date +%s)

# =====================================================================
#  第 1 阶段：行为仿真，先确认 RTL 功能和测试向量正确
# =====================================================================
if echo " $STAGES " | grep -q " beh "; then
    step "1. BEHAVIOURAL SIMULATION  (Behavioral/)"
    RC_SIM="$(find_rc vP_2019 "$BEH" "$RTLD")" || die "no synopsys_linux_vP_2019_cshrc found"
    rm -rf "$BEH"/simv "$BEH"/simv.daidir "$BEH"/csrc "$BEH"/Check.txt
    FILES="./$TB_NAME"; for f in $RTL_FILES; do FILES="$FILES ./$f"; done
    echo "  vcs -debug +v2k +define+VCS $VCS_EXTRA $FILES"
    run_csh "$BEH" "$RC_SIM" "vcs -debug +v2k +define+VCS $VCS_EXTRA $FILES -l compile_beh.log && ./simv -l sim_beh.log" "$BEH/run_beh.out"
    [ -f "$BEH/compile_beh.log" ] || { tail -20 "$BEH/run_beh.out"; die "vcs did not start (see Behavioral/run_beh.out)"; }
    check_vcs_log "$BEH/compile_beh.log" "$BEH/sim_beh.log" "behavioural sim"
    echo "  waveform: cd Behavioral; csh; source $(basename "$RC_SIM"); ./simv -gui &"
fi

# =====================================================================
#  第 2 阶段：逻辑综合，生成门级网表、SDF 和面积/时序报告
# =====================================================================
if echo " $STAGES " | grep -q " syn "; then
    step "2. SYNTHESIS  (Synthesis/, batch dc_shell)"
    RC_DC="$(find_rc vR_2020 "$SYN" "$PWR")" || die "no synopsys_linux_vR_2020_cshrc found in Synthesis/"
    S="$SYN/scripts"
    [ -d "$S.orig" ] || cp -r "$S" "$S.orig"          # 首次运行时备份原始综合脚本

    # 找顶层设计脚本 X.tcl；排除 ReadVerilogFiles、report 等通用脚本。
    if [ -f "$S/$TOP.tcl" ]; then
        TOPSCRIPT="$TOP.tcl"
    else
        CAND="$(ls "$S"/*.tcl | xargs -n1 basename | grep -v -E '^(ReadVerilogFiles|report|run_topdown|t2_.*)\.tcl$')"
        [ "$(echo "$CAND" | wc -l)" -eq 1 ] || die "cannot identify the top synthesis script in scripts/ (found: $CAND)"
        OLD="${CAND%.tcl}"
        echo "  renaming $OLD -> $TOP in scripts/"
        sed "s/$OLD/$TOP/g" "$S/$CAND" > "$S/$TOP.tcl" && rm -f "$S/$CAND"
        sed -i "s/$OLD/$TOP/g" "$S/run_topdown.tcl"
        TOPSCRIPT="$TOP.tcl"
    fi
    grep -q "$TOPSCRIPT" "$S/run_topdown.tcl" || warn "run_topdown.tcl does not source $TOPSCRIPT - check it"
    grep -q "$TOP" "$S/$TOPSCRIPT" || warn "$TOPSCRIPT does not mention $TOP - check lines 10/12"

    # 更新综合使用的 RTL 源文件及 ReadVerilogFiles.tcl 读入清单。
    mkdir -p "$SYN/sources" "$SYN/netlist" "$SYN/logs"
    rm -f "$SYN"/sources/*.v "$SYN"/netlist/* "$SYN"/logs/*
    : > "$S/ReadVerilogFiles.tcl"
    for f in $RTL_FILES; do
        cp "$BEH/$f" "$SYN/sources/"
        echo "read_verilog ./sources/$f" >> "$S/ReadVerilogFiles.tcl"
    done
    echo "  ReadVerilogFiles.tcl:"; sed 's/^/     /' "$S/ReadVerilogFiles.tcl"

    # 批处理入口：执行与 GUI 相同的综合脚本，额外导出常用报告后退出。
    cat > "$SYN/t2_syn.tcl" <<EOF
source scripts/run_topdown.tcl
current_design $TOP
report_qor                             > logs/t2_qor.rpt
report_area                            > logs/t2_area.rpt
report_cell                            > logs/t2_cell.rpt
report_timing -significant_digits 4    > logs/t2_timing.rpt
report_timing -delay_type min -significant_digits 4 > logs/t2_timing_hold.rpt
report_constraint -all_violators       > logs/t2_violators.rpt
report_power                           > logs/t2_power_syn.rpt
exit
EOF
    echo "  dc_shell-xg-t -f t2_syn.tcl   (about 1 minute)"
    run_csh "$SYN" "$RC_DC" "dc_shell-xg-t -f t2_syn.tcl" "$SYN/logs/t2_dc.log"

    NET="$SYN/netlist/Syn_${TOP}.v"
    [ -f "$NET" ] || { grep -n -E "^Error|Error:" "$SYN/logs/t2_dc.log" | head -20; die "no netlist $NET (see Synthesis/logs/t2_dc.log)"; }
    [ -f "$SYN/netlist/Syn_${TOP}.sdf" ] || die "no SDF Syn_${TOP}.sdf (see Synthesis/logs/t2_dc.log)"
    NERR=$(grep -c -E "^Error" "$SYN/logs/t2_dc.log")
    [ "$NERR" -gt 0 ] && warn "$NERR Error line(s) in the DC log (clock errors are OK for combinational designs) - grep ^Error Synthesis/logs/t2_dc.log"
    if grep -q -E "GTECH_|SEQGEN" "$NET"; then
        warn "netlist still contains GTECH/SEQGEN cells - NOT mapped to the GF22 library!"
    else
        ok "netlist mapped to library cells"
    fi
    if grep -q -E "\|\s*Latch\s*\|" "$SYN/logs/t2_dc.log"; then
        warn "a LATCH was inferred (see 'Inferred memory devices' in Synthesis/logs/t2_dc.log) - check your combinational always blocks"
    fi

    [ -f "$SYN/logs/t2_area.rpt" ] || warn "extra reports missing (does $TOPSCRIPT end with exit/quit?) - use logs/report.rpt"
    AREA="$(grep -h -m1 -i 'Total cell area' "$SYN"/logs/t2_area.rpt "$SYN"/logs/report.rpt 2>/dev/null | head -1 | awk '{print $NF}')"
    NCELL="$(grep -h -m1 -i 'Number of cells' "$SYN"/logs/t2_area.rpt "$SYN"/logs/report.rpt 2>/dev/null | head -1 | awk '{print $NF}')"
    NSEQ="$(grep -h -m1 -i 'Sequential Cell Count' "$SYN"/logs/t2_qor.rpt 2>/dev/null | awk '{print $NF}')"
    SLACK="$(grep -h -m1 -E 'slack' "$SYN"/logs/t2_timing.rpt "$SYN"/logs/report.rpt 2>/dev/null | head -1)"
    HSLACK="$(grep -h -m1 -E 'slack' "$SYN"/logs/t2_timing_hold.rpt 2>/dev/null)"
    echo "  cells: $NCELL   sequential: $NSEQ   area: $AREA"
    echo "  setup: $SLACK"
    echo "  hold : $HSLACK"
    note "synthesis: cells=$NCELL sequential=$NSEQ area=$AREA"
    note "  setup: $SLACK"
    note "  hold : $HSLACK"
    grep -q "VIOLATED" "$SYN/logs/t2_violators.rpt" 2>/dev/null && warn "constraint violations - see Synthesis/logs/t2_violators.rpt (hold with ideal clock is usual, see Module 5)"
    ok "synthesis done: netlist/Syn_${TOP}.v .sdf ; reports in Synthesis/logs/t2_*.rpt"
    echo "  schematic (for a screenshot): cd Synthesis; csh; source $(basename "$RC_DC"); design_vision &"
    echo "                                File > Execute Script > scripts/run_topdown.tcl, then Schematic View"
fi

# =====================================================================
#  第 3 阶段：门级仿真，使用综合网表并反标 SDF 延时
# =====================================================================
if echo " $STAGES " | grep -q " gate "; then
    step "3. GATE-LEVEL SIMULATION  ($(basename "$RTLD")/, with SDF)"
    RC_SIM="$(find_rc vP_2019 "$RTLD" "$BEH")" || die "no synopsys_linux_vP_2019_cshrc found"
    [ -f "$RTLD/library.f" ] || die "no library.f in $RTLD"
    [ -f "$SYN/netlist/Syn_${TOP}.v" ] || die "no netlist - run the syn stage first"
    rm -rf "$RTLD"/simv "$RTLD"/simv.daidir "$RTLD"/csrc "$RTLD"/Check.txt "$RTLD"/inter.vpd "$RTLD"/Syn_*
    cp "$SYN"/netlist/Syn_${TOP}.* "$RTLD/"
    cp "$TB_FILE" "$RTLD/"
    cp "$BEH"/*.txt "$RTLD/" 2>/dev/null
    rm -f "$RTLD/Check.txt"
    echo "  vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM $VCS_EXTRA ./$TB_NAME ./Syn_${TOP}.v -f ./library.f"
    run_csh "$RTLD" "$RC_SIM" "vcs -debug +v2k +neg_tchk +define+VCS +define+GATE_SIM $VCS_EXTRA ./$TB_NAME ./Syn_${TOP}.v -f ./library.f -l compile_gate.log && ./simv -l sim_gate.log" "$RTLD/run_gate.out"
    [ -f "$RTLD/compile_gate.log" ] || { tail -20 "$RTLD/run_gate.out"; die "vcs did not start (see $RTLD/run_gate.out)"; }
    check_vcs_log "$RTLD/compile_gate.log" "$RTLD/sim_gate.log" "gate-level sim"
    SDFL="$(grep -h -i -E 'sdf.*(error|annotat)|total errors' "$RTLD/compile_gate.log" "$RTLD/sim_gate.log" | head -5)"
    [ -n "$SDFL" ] && { echo "$SDFL" | sed 's/^/  /'; note "SDF: $(echo "$SDFL" | tr '\n' ' ')"; }
    grep -h -q -i "SDF.*not found\|Unable to open.*sdf\|Cannot open.*sdf" "$RTLD/compile_gate.log" "$RTLD/sim_gate.log" && warn "SDF file not found / not annotated"
    [ -f "$RTLD/inter.vpd" ] && ok "inter.vpd written (for power)" || warn "no inter.vpd in $RTLD - power stage will fail"
fi

# =====================================================================
#  第 4 阶段：功耗分析，由门级波形生成 SAIF 并统计功耗
# =====================================================================
if echo " $STAGES " | grep -q " power "; then
    step "4. POWER ANALYSIS  ($(basename "$RTLD")/PowerAnalysis/)"
    [ -d "$PWR" ] || die "no folder $PWR"
    [ -f "$RTLD/inter.vpd" ] || die "no $RTLD/inter.vpd - run the gate stage first"
    RC_DC="$(find_rc vR_2020 "$PWR" "$SYN")" || die "no synopsys_linux_vR_2020_cshrc found"
    if [ -f "$PWR/common_setup_gf22.tcl" ] && grep -E "SEARCH_PATH" "$PWR/common_setup_gf22.tcl" | grep -q "/home/"; then
        grep -E "SEARCH_PATH" "$PWR/common_setup_gf22.tcl" | sed 's/^/  /'
        warn "absolute library path in PowerAnalysis/common_setup_gf22.tcl - make sure it still exists"
    fi
    rm -f "$PWR"/inter.vcd "$PWR"/inter.saif "$PWR"/rpt_*
    cat > "$PWR/t2_power.tcl" <<EOF
read_verilog ../Syn_${TOP}.v
current_design ${TOP}
link
read_saif -input ./inter.saif -instance ${TB_MOD}/${INST}
report_saif                 > rpt_saif.txt
report_power                > rpt_power.txt
report_power -hier          > rpt_power_hier.txt
report_power -hier -nosplit > rpt_power_hier_nosplit.txt
report_power -cell          > rpt_power_cell.txt
exit
EOF
    echo "  vpd2vcd -> vcd2saif -> dc_shell-xg-t -f t2_power.tcl   (instance ${TB_MOD}/${INST})"
    run_csh "$PWR" "$RC_DC" "vpd2vcd ../inter.vpd inter.vcd && vcd2saif -i ./inter.vcd -o inter.saif && dc_shell-xg-t -f t2_power.tcl" "$PWR/t2_power.log"
    [ -s "$PWR/inter.saif" ] || die "inter.saif not created (see PowerAnalysis/t2_power.log)"
    [ -f "$PWR/rpt_power.txt" ] || die "no rpt_power.txt (see PowerAnalysis/t2_power.log)"
    grep -q -i "Unable to resolve reference" "$PWR/t2_power.log" && warn "link: unresolved references - library path in PowerAnalysis/common_setup_gf22.tcl?"
    grep -i -E "user annotated|annotated" "$PWR/rpt_saif.txt" | head -4 | sed 's/^/  /'
    if ! grep -q "100.00" "$PWR/rpt_saif.txt"; then
        warn "rpt_saif.txt shows no 100% annotation - check the instance name ${TB_MOD}/${INST}"
    fi
    PLINES="$(grep -i -E 'Total Dynamic Power|Cell Leakage Power|Cell Internal Power|Net Switching Power' "$PWR/rpt_power.txt")"
    echo "$PLINES" | sed 's/^/  /'
    note "power (SAIF):"; echo "$PLINES" | sed 's/^/  /' >> "$RESULT"
    ok "power reports in $(basename "$RTLD")/PowerAnalysis/rpt_*.txt"
fi

# =====================================================================
step "FINISHED in $(( $(date +%s) - T0 )) s"
echo "  summary: $RESULT"
note "finished in $(( $(date +%s) - T0 )) s"
echo
cat "$RESULT"
exit 0
