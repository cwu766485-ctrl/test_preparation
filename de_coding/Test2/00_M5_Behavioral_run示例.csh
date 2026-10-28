#!/bin/csh
# 仅用于原版 Module5/Behavioral：在 Behavioral/ 内执行 csh run。
# 若换新题，必须把下面三个输入文件名改成本题文件，不能照抄运行。

foreach f ( MatrixMultiplier.v MatrixMultiplier_tb.v InputVector.txt )
    if ( ! -e "$f" ) then
        echo "ERROR: 缺少 $f；请确认当前目录是 Behavioral/。"
        exit 1
    endif
end

# 最新截图显示环境文件就在 Behavioral/；旧截图中 rtl/ 也有一份。
if ( -e ./synopsys_linux_vP_2019_cshrc ) then
    source ./synopsys_linux_vP_2019_cshrc
else if ( -e ../rtl/synopsys_linux_vP_2019_cshrc ) then
    source ../rtl/synopsys_linux_vP_2019_cshrc
else
    source synopsys_linux_vP_2019_cshrc
endif
if ( $status != 0 ) exit 1

# 保留上一次的检查结果，避免把旧 PASS 看成这次运行的结果。
if ( -e Check.txt ) mv Check.txt "Check.previous_$$.txt"

# 编译 tb + 本题设计 RTL；InputVector.txt 在运行时由 tb 自己读取。
vcs -debug +v2k ./MatrixMultiplier_tb.v ./MatrixMultiplier.v -l compile.log
if ( $status != 0 ) then
    echo "ERROR: VCS 编译失败；查看 compile.log。"
    exit 1
endif

./simv -l sim.log
if ( $status != 0 ) then
    echo "ERROR: 仿真进程失败；查看 sim.log。"
    exit 1
endif

if ( ! -e Check.txt ) then
    echo "ERROR: 没有生成 Check.txt；先检查 sim.log。"
    exit 1
endif

echo "=== Check.txt ==="
cat Check.txt

# 有些 tb 在 FAIL 后仍以 $finish 正常退出，因此还需查日志内容。
grep -i -q 'FAIL' sim.log Check.txt
if ( $status == 0 ) then
    echo "ERROR: sim.log 或 Check.txt 含 FAIL，请打开日志查原因。"
    exit 1
endif
grep -E -q '^PASS: [0-9]+ vectors and asynchronous reset$' Check.txt
if ( $status != 0 ) then
    echo "ERROR: Check.txt 没有最终 PASS 总结；请查看 sim.log。"
    exit 1
endif

echo "T1 文字自检通过。还要在 DVE 看 CLK/NRST/START/A/B/OUT/OUT_STROBE。"

# 想让本脚本自动打开 DVE，就删除下一行最前面的 #；运行后仍须在 GUI 中添加信号并 Start/Continue。
# ./simv -gui &
