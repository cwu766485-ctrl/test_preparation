# 考试时只改这里的名字；四个 run 会读取同一份配置。
# TOP 必须等于设计文件中的顶层 module 名，区分大小写。
set TOP = "X"
set TB_FILE = "X_tb.v"
set TB_MODULE = "X_tb"
set DUT_INSTANCE = "U1"

# 列出 Behavioral/ 中所有设计 RTL；不要放 testbench。
# 多文件示例：( "Adder4.v" "FullAdder.v" )
set RTL_FILES = ( "X.v" )
