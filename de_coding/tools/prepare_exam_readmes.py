#!/usr/bin/env python3
"""Add a consistent exam quick-reference to each HDL exercise directory."""

from __future__ import annotations

import re
import os
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HDL_SUFFIXES = {".v", ".sv"}
MODULE_RE = re.compile(r"\bmodule\s+(\w+)", re.IGNORECASE)
TB_NAME_RE = re.compile(r"(^tb\w*|\w*tb\w*|\w*testbench\w*)", re.IGNORECASE)
BLOCK_START = "<!-- BEGIN generated exam quick reference -->"
BLOCK_END = "<!-- END generated exam quick reference -->"
SKIP_DIRS = {".git", "build", "csrc", "simv.daidir", "DVEfiles", "AN.DB", "work"}


def hdl_files(folder: Path) -> list[Path]:
    return sorted((p for p in folder.iterdir() if p.is_file() and p.suffix.lower() in HDL_SUFFIXES), key=lambda p: p.name.lower())


def modules(path: Path) -> list[str]:
    try:
        data = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return []
    data = re.sub(r"/\*.*?\*/", " ", data, flags=re.DOTALL)
    data = re.sub(r"//[^\n]*", " ", data)
    return MODULE_RE.findall(data)


def is_testbench(path: Path) -> bool:
    names = modules(path)
    return bool(TB_NAME_RE.search(path.stem) or any(TB_NAME_RE.search(name) for name in names))


def first_comments(path: Path) -> str:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()[:14]
    collected: list[str] = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("//"):
            text = stripped[2:].strip()
            if text and not re.fullmatch(r"[=*_#\-\s]+", text):
                collected.append(text)
        elif stripped and not stripped.startswith(("/*", "*", "*/")):
            if collected:
                break
    summary = " ".join(collected)
    if len(summary) > 180:
        cut = summary.rfind("。", 0, 180)
        if cut < 100:
            cut = summary.rfind(" ", 0, 180)
        summary = summary[:cut if cut >= 100 else 180].rstrip(" ，；、") + "…"
    return summary


def topic(folder: Path) -> str:
    rel = folder.relative_to(ROOT).as_posix()
    if rel.startswith("Test2/"):
        return folder.name
    return folder.name.replace("_", " ")


def makefile_text(folder: Path, sources: list[Path], benches: list[Path]) -> str:
    tops = []
    for tb in benches:
        names = modules(tb)
        candidates = [name for name in names if TB_NAME_RE.search(name)]
        if not candidates and names:
            candidates = names[:1]
        if candidates:
            tops.append(candidates[0])
    tops = list(dict.fromkeys(tops))
    source_names = " ".join(p.name for p in sources)
    tb_names = " ".join(p.name for p in benches)
    all_names = " ".join(p.name for p in [*sources, *benches])
    text_files = " ".join(p.name for p in sorted(folder.glob("*.txt")))
    first_top = tops[0] if tops else ""
    return f"""VCS ?= vcs
VCS_FLAGS ?= -full64 -sverilog -debug_access+all -timescale=1ns/1ps +define+VCS
TOPS := {' '.join(tops)}
TOP ?= {first_top}
BUILD := build
HDL := {all_names}

.PHONY: all test clean
all: test

test: test_$(TOP)

test_%:
\t@mkdir -p $(BUILD)/$*
\t@for file in *.txt; do if test -f "$$file"; then cp "$$file" $(BUILD)/$*/; fi; done
\tcd $(BUILD)/$* && $(VCS) $(VCS_FLAGS) -top $* $(addprefix ../../,$(HDL)) -o simv -l compile.log
\tcd $(BUILD)/$* && ./simv -l sim.log
\t@if grep -Eiq '(^|[^[:alpha:]_])FAIL([^[:alpha:]_]|$)|(^|[^[:alpha:]_])ERROR([^[:alpha:]_]|$)' $(BUILD)/$*/sim.log; then cat $(BUILD)/$*/sim.log; exit 1; else echo 'PASS: $*'; fi

clean:
\trm -rf $(BUILD)
"""


def generated_block(folder: Path, files: list[Path]) -> str:
    tb_files = [p for p in files if is_testbench(p)]
    rtl_files = [p for p in files if p not in tb_files]
    rtl_names = ", ".join(f"`{p.name}`" for p in rtl_files) or "（本目录没有独立 RTL；见上级工程）"
    tb_lines: list[str] = []
    for p in tb_files:
        tops = modules(p)
        top = next((name for name in tops if TB_NAME_RE.search(name)), tops[0] if tops else "未识别顶层")
        tb_lines.append(f"- `{p.name}`（顶层 `{top}`）：驱动输入并在仿真中检查 DUT 输出/时序。")
    if not tb_lines:
        tb_lines = ["- 本目录没有 testbench；在父目录工程或相邻 TB 文件夹运行对应验证。"]

    design_modules = [name for p in rtl_files for name in modules(p)]
    design_names = ", ".join(f"`{name}`" for name in design_modules) or "见 RTL 文件中的 module 声明"
    comment = next((first_comments(p) for p in rtl_files if first_comments(p)), "")
    if folder.name == "counters":
        overview = "包含向上计数、向下计数和 mod-N 计数实现；各自的 TB 分别验证计数方向、边界回绕和终端计数标志。"
    elif folder.name == "17_可变位宽串行加法器":
        overview = "复用一个 1 位全加器和 FSM/计数器，逐位处理最多 16 位输入；TB 覆盖 N=1..16、进位、锁存、DONE 和边界值。"
    elif folder.name == "nm6008_matrix_multiplier":
        overview = "按 Module 5 接口把两组有符号 8 位操作数串行送入，计算 A1*B1+A0*B0，使用 17 位符号扩展并以 OUT_STROBE 标记结果。"
    elif folder.relative_to(ROOT).as_posix() == "07_arithmetic_and_datapath/comparator":
        overview = "固定四位 secret-code 比较器：Comparator 比较每个 3 位输入，Test2 汇总四个相等信号控制 open；本例只做比较，不负责生成候选数字。"
    elif "secretcode" in folder.parts and "assignment" in folder.parts:
        overview = "NM6008 secret-code 发生器：四个独立 mod-8 数字块或单个 12 位计数器遍历候选码，逻辑块比较并控制 relay。"
    elif folder.relative_to(ROOT).as_posix() in {
        "07_arithmetic_and_datapath/secretcode/Behavioral",
        "07_arithmetic_and_datapath/secretcode/rtl",
    }:
        overview = "旧 keypad password-lock 练习，输入为 key_valid/key_data 并带失败报警；不是题目要求的数字发生器。"
    elif folder.relative_to(ROOT).as_posix().endswith("secretcode/Library"):
        overview = "GF22 工艺标准单元/原语模型，只供对应课程网表仿真使用，不是可移植的练习 RTL。"
    elif "secretcode/Synthesis" in folder.relative_to(ROOT).as_posix():
        overview = "旧 keypad password-lock 的课程综合源文件或生成网表；考试 secret-code number generator 请用同级 assignment/。"
    elif folder.name == "16_代码改错":
        overview = "故意含有多个错误版本；对应 TB 的预期是检测到错误，不应把这些 bug RTL 当作正确提交版本。"
    else:
        overview = f"本题练习 `{topic(folder)}`，RTL 顶层/子模块为 {design_names}。"
        if comment:
            overview += f" 源文件说明：{comment}"

    rel_to_guide = Path(__import__("os").path.relpath(ROOT / "tools" / "EXAM_REPORT_GUIDE.md", folder)).as_posix()
    rel = folder.relative_to(ROOT).as_posix()
    mf = folder / "Makefile"
    parent_mf = folder.parent / "Makefile"
    if rel == "01_combinational_logic/adders_uvm/tb":
        command = "```sh\nmake -C .. run\nmake -C .. clean\n```"
        note = "使用父目录的 UVM Makefile；请在课程配置好的 VCS/UVM 环境中运行。"
    elif rel in {
        "07_arithmetic_and_datapath/secretcode/Behavioral",
        "07_arithmetic_and_datapath/secretcode/rtl",
    }:
        command = "```sh\ncd de_coding\nbash tools/run_secretcode_vcs.sh\n```"
        note = "该回归会运行 assignment number-generator 与 legacy keypad 示例；它们是不同题目。脚本用临时目录并自动清理。"
    elif folder.relative_to(ROOT).as_posix().endswith("secretcode/Library") or "secretcode/Synthesis" in rel:
        command = "本目录是课程库模型/生成文件，不单独执行 VCS；按父级 secretcode 项目的正确 PDK 配置使用。"
        note = "不要把课程工艺库或生成网表当作考试题目的行为级 RTL。"
    elif rel.startswith("Test2/") and folder.name == "16_代码改错":
        command = "```sh\nmake test\nmake clean\n```"
        note = "该 Makefile 调用全套 Test2 回归；故意错误的 6 个变体必须被 TB 检出。仿真在临时目录运行并自动清理。"
    elif mf.exists():
        command = "```sh\nmake test\nmake clean\n```"
        note = "`make test` 在 VCS 下编译并运行；波形和日志位于 `build/`，交报告前先保存所需截图再执行 `make clean`。"
    elif parent_mf.exists():
        command = "```sh\nmake -C .. test\nmake -C .. clean\n```"
        note = "仿真由父目录 Makefile 统一编译本目录文件。"
    elif "secretcode" in folder.parts and "assignment" in folder.parts:
        command = "```sh\nmake -C .. test\nmake -C .. clean\n```"
        note = "在 assignment 父目录编译完整 RTL 和 TB。"
    else:
        command = "```sh\nvcs -full64 -sverilog -debug_access+all -top <testbench_module> <RTL files> <testbench file> -o simv\n./simv\nmake clean\n```"
        note = "把尖括号内容替换为本页列出的文件；若没有本地 Makefile，运行后删除 simv/build 等新生成物。"

    lines = [
        BLOCK_START,
        "## RTL、TB 与考试命令",
        "",
        f"**设计说明：**{overview}",
        "",
        f"**RTL 文件：**{rtl_names}。",
        "",
        "**TB 文件：**",
        *tb_lines,
        "",
        "**VCS：**",
        "",
        command,
        "",
        note,
        "",
        f"综合、门级仿真、波形和报告写作步骤见[考试报告流程]({rel_to_guide})。",
        BLOCK_END,
    ]
    return "\n".join(lines)


def update_readme(folder: Path) -> None:
    files = hdl_files(folder)
    if not files:
        return
    readme = folder / "README.md"
    block = generated_block(folder, files)
    old = readme.read_text(encoding="utf-8", errors="replace") if readme.exists() else f"# {topic(folder)}\n"
    if BLOCK_START in old and BLOCK_END in old:
        before = old.split(BLOCK_START, 1)[0].rstrip()
        after = old.split(BLOCK_END, 1)[1].lstrip()
        new = before + "\n\n" + block + ("\n\n" + after if after else "\n")
    else:
        new = old.rstrip() + "\n\n" + block + "\n"
    readme.write_text(new, encoding="utf-8", newline="\n")


def add_test2_makefile(folder: Path, files: list[Path]) -> bool:
    if folder.name == "16_代码改错" or (folder / "Makefile").exists():
        return False
    benches = [p for p in files if is_testbench(p)]
    if not benches:
        return False
    rtl = [p for p in files if p not in benches]
    (folder / "Makefile").write_text(makefile_text(folder, rtl, benches), encoding="utf-8", newline="\n")
    return True


def exercise_folders():
    def ignore_walk_error(_error: OSError) -> None:
        return None

    for current, dirs, _files in os.walk(ROOT, onerror=ignore_walk_error):
        folder = Path(current)
        if folder != ROOT:
            yield folder
        dirs[:] = [name for name in dirs if name not in SKIP_DIRS]
        if folder.name == "Library":
            dirs[:] = []


def main() -> None:
    folders = sorted(exercise_folders(), key=lambda p: p.as_posix().lower())
    readmes = 0
    makefiles = 0
    for folder in folders:
        files = hdl_files(folder)
        if not files:
            continue
        if folder.relative_to(ROOT).parts[0] == "Test2":
            makefiles += int(add_test2_makefile(folder, files))
        before = (folder / "README.md").exists()
        update_readme(folder)
        readmes += int(not before)
    print(f"Updated HDL quick references; created {readmes} README files and {makefiles} Test2 Makefiles.")


if __name__ == "__main__":
    main()
