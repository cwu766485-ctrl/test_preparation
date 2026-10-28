#!/usr/bin/env python3
"""Create Verilog-2005 counterparts, smoke testbenches, and local Makefiles."""

from __future__ import annotations

import os
import re
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TB_MARKER = "_smoke"
OUTPUTS_ALLOWED_UNKNOWN = {
    # No reset or initialization is provided for this RAM's storage array.
    "async_dp_ram": {"a_rdata", "b_rdata"},
}


def blank_comments(text: str) -> str:
    """Replace comments with spaces while preserving newlines and source offsets."""
    out = list(text)
    i = 0
    state = "code"
    while i < len(text):
        if state == "code":
            if text.startswith("//", i):
                out[i] = out[i + 1] = " "
                i += 2
                state = "line"
                continue
            if text.startswith("/*", i):
                out[i] = out[i + 1] = " "
                i += 2
                state = "block"
                continue
            if text[i] == '"':
                state = "string"
        elif state == "line":
            if text[i] == "\n":
                state = "code"
            else:
                out[i] = " "
        elif state == "block":
            if text.startswith("*/", i):
                out[i] = out[i + 1] = " "
                i += 2
                state = "code"
                continue
            if text[i] != "\n":
                out[i] = " "
        elif state == "string":
            if text[i] == "\\":
                i += 2
                continue
            if text[i] == '"':
                state = "code"
        i += 1
    return "".join(out)


def matching_paren(text: str, start: int) -> int:
    depth = 0
    in_string = False
    i = start
    while i < len(text):
        char = text[i]
        if in_string:
            if char == "\\":
                i += 2
                continue
            if char == '"':
                in_string = False
        elif char == '"':
            in_string = True
        elif char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError("Unbalanced parentheses")


def split_top_level(text: str, separator: str = ",") -> list[str]:
    parts: list[str] = []
    stack: list[str] = []
    in_string = False
    start = 0
    pairs = {")": "(", "]": "[", "}": "{"}
    for i, char in enumerate(text):
        if in_string:
            if char == '"' and (i == 0 or text[i - 1] != "\\"):
                in_string = False
            continue
        if char == '"':
            in_string = True
        elif char in "([{":
            stack.append(char)
        elif char in ")]}":
            if stack and stack[-1] == pairs[char]:
                stack.pop()
        elif char == separator and not stack:
            parts.append(text[start:i].strip())
            start = i + 1
    tail = text[start:].strip()
    if tail:
        parts.append(tail)
    return parts


def module_parts(text: str) -> tuple[str, str, str, str, str]:
    """Return module name, parameter text, port text, body, and full source."""
    clean = blank_comments(text)
    match = re.search(r"\bmodule\s+(\w+)\b", clean)
    if not match:
        raise ValueError("Missing module declaration")
    name = match.group(1)
    cursor = match.end()
    while cursor < len(clean) and clean[cursor].isspace():
        cursor += 1
    parameter_text = ""
    if cursor < len(clean) and clean[cursor] == "#":
        cursor += 1
        while cursor < len(clean) and clean[cursor].isspace():
            cursor += 1
        if clean[cursor] != "(":
            raise ValueError(f"Malformed parameter list in {name}")
        end = matching_paren(clean, cursor)
        parameter_text = text[cursor + 1 : end]
        cursor = end + 1
    while cursor < len(clean) and clean[cursor].isspace():
        cursor += 1
    if cursor >= len(clean) or clean[cursor] != "(":
        raise ValueError(f"Missing port list in {name}")
    port_end = matching_paren(clean, cursor)
    port_text = text[cursor + 1 : port_end]
    semicolon = clean.find(";", port_end)
    endmodule = clean.find("endmodule", semicolon + 1)
    if semicolon < 0 or endmodule < 0:
        raise ValueError(f"Malformed module body in {name}")
    body = text[semicolon + 1 : endmodule]
    full = text[match.start() : endmodule + len("endmodule")]
    return name, parameter_text, port_text, body, full


def parse_ports(port_text: str) -> list[dict[str, str]]:
    clean = blank_comments(port_text)
    ports: list[dict[str, str]] = []
    direction = None
    width = ""
    signed = ""
    for item in split_top_level(clean):
        match = re.match(
            r"\s*(?:(input|output|inout)\b\s*)?"
            r"(?:(?:wire|reg|logic|bit|integer)\b\s*)*"
            r"(signed\s+)?(\[[^\]]+\]\s*)?([A-Za-z_$][\w$]*)\s*$",
            item,
        )
        if not match:
            raise ValueError(f"Cannot parse port declaration: {item!r}")
        if match.group(1):
            direction = match.group(1)
            width = ""
            signed = ""
        if not direction:
            raise ValueError(f"Port direction missing: {item!r}")
        if match.group(2) is not None:
            signed = "signed "
        if match.group(3) is not None:
            width = match.group(3).strip()
        ports.append(
            {
                "direction": direction,
                "signed": signed,
                "width": width,
                "name": match.group(4),
            }
        )
    return ports


def strip_assertion_initials(body: str) -> str:
    pattern = re.compile(
        r"\binitial\s+begin\s*assert\s*\((.*?)\)\s*"
        r"else\s*\$fatal\s*\((.*?)\)\s*;\s*end",
        re.S,
    )
    return pattern.sub(
        "// Simulation-only parameter assertion omitted in the Verilog-2005 translation.",
        body,
    )


def convert_enums(text: str) -> str:
    pattern = re.compile(
        r"typedef\s+enum\s+logic\s*(\[[^\]]+\])?\s*\{([\s\S]*?)\}\s*(\w+)\s*;",
        re.S,
    )

    def replace(match: re.Match[str]) -> str:
        width = (match.group(1) or "[0:0]").strip()
        values = split_top_level(blank_comments(match.group(2)))
        names: list[str] = []
        previous = None
        for item in values:
            if not item:
                continue
            if "=" in item:
                enum_name, enum_value = item.split("=", 1)
                enum_name = enum_name.strip()
                enum_value = enum_value.strip()
                previous = enum_value
            else:
                enum_name = item.strip()
                enum_value = "0" if previous is None else f"({previous}) + 1'b1"
                previous = enum_value
            if not re.fullmatch(r"\w+", enum_name):
                raise ValueError(f"Unsupported enum item: {item!r}")
            names.append(f"    localparam {width} {enum_name} = {enum_value};")
        typedef_name = match.group(3)
        declarations = "\n".join(names)
        return f"{declarations}\n    // Verilog-2005 enum constants replace the SystemVerilog typedef."

    return pattern.sub(replace, text)


def procedural_lhs_names(text: str) -> set[str]:
    clean = blank_comments(text)
    # The caller uses this against explicit output names, so a broad LHS scan works.
    return set(
        re.findall(r"\b([A-Za-z_$][\w$]*)\s*(?:<=|(?<![=!<>])=(?!=|>))", clean)
    )


def replace_function_headers(text: str) -> str:
    pattern = re.compile(
        r"function\s+automatic\s+(?P<rtype>integer|logic(?:\s*\[[^\]]+\])?)\s+"
        r"(?P<name>\w+)\s*\((?P<args>[^)]*)\)\s*;"
    )

    def replace(match: re.Match[str]) -> str:
        return_type = match.group("rtype")
        return_type = return_type.replace("logic", "")
        name = match.group("name")
        declarations = []
        for arg in split_top_level(match.group("args")):
            arg = re.sub(r"\binput\s+(?:logic|bit)\b", "input", arg)
            arg = re.sub(r"\b(?:logic|bit)\b", "", arg)
            declarations.append(f"    {arg.strip()};")
        prefix = f"function {return_type.strip()} {name};" if return_type.strip() else f"function {name};"
        return prefix + "\n" + "\n".join(declarations)

    return pattern.sub(replace, text)


def submodule_output_actuals(
    module_text: str,
    port_directions: dict[str, dict[str, str]],
) -> set[str]:
    clean = blank_comments(module_text)
    actuals: set[str] = set()
    for child, ports in port_directions.items():
        if not any(direction == "output" for direction in ports.values()):
            continue
        pattern = re.compile(
            r"\b" + re.escape(child) + r"\s*"
            r"(?:#\s*\([\s\S]*?\)\s*)?"
            r"[A-Za-z_$][\w$]*\s*\(",
            re.M,
        )
        for instance in pattern.finditer(clean):
            opening = clean.rfind("(", instance.start(), instance.end())
            closing = matching_paren(clean, opening)
            for connection in split_top_level(clean[opening + 1 : closing]):
                named = re.fullmatch(
                    r"\s*\.\s*([A-Za-z_$][\w$]*)\s*\(\s*([A-Za-z_$][\w$]*)\s*\)\s*",
                    connection,
                )
                if named and ports.get(named.group(1)) == "output":
                    actuals.add(named.group(2))
    return actuals


def convert_logic_declarations(text: str, output_net_names: set[str] | None = None) -> str:
    # Continuous assignments require net types; all other synthesizable logic is
    # represented by Verilog regs, including arrays written in procedural blocks.
    output_net_names = output_net_names or set()
    procedural_text = re.sub(r"\bassign\b[^;]*;", " ", blank_comments(text), flags=re.S)
    decl = re.compile(
        r"(?m)^(?P<indent>[ \t]*)(?P<attr>\(\*[^\n]*?\*\)[ \t]*)?"
        r"(?P<type>logic|bit)\s+(?P<payload>[^;]+);"
    )

    def replace(match: re.Match[str]) -> str:
        indent = match.group("indent")
        attr = match.group("attr") or ""
        payload = match.group("payload").strip()
        qualifier_match = re.match(
            r"(?P<qual>(?:(?:signed|unsigned)\s+)?(?:\[[^\]]+\]\s*)?)(?P<decls>[\s\S]*)",
            payload,
        )
        qualifier = qualifier_match.group("qual").strip()
        entries = split_top_level(qualifier_match.group("decls"))
        grouped: dict[str, list[str]] = defaultdict(list)
        for entry in entries:
            name_match = re.match(r"\s*([A-Za-z_$][\w$]*)", entry)
            if not name_match:
                raise ValueError(f"Cannot parse declaration: {match.group(0)!r}")
            name = name_match.group(1)
            before = procedural_text[: match.start()]
            after = procedural_text[match.end() :]
            # At this point a later procedural/continuous assignment identifies the
            # declaration class. If both are present, emit a net and report VCS's
            # diagnostic during validation rather than guessing silently.
            is_net = name in output_net_names or bool(
                re.search(r"\bassign\s+" + re.escape(name) + r"\b", blank_comments(text))
            )
            assignment = re.compile(
                r"\b" + re.escape(name) + r"\s*(?:<=|(?<![=!<>])=(?!=|>))"
            )
            is_proc = bool(assignment.search(before + after))
            kind = "wire" if is_net and not is_proc else "reg"
            grouped[kind].append(entry.strip())
        generated = []
        for kind, decls in grouped.items():
            generated.append(f"{indent}{attr}{kind} {qualifier + ' ' if qualifier else ''}{', '.join(decls)};")
        return "\n".join(generated)

    return decl.sub(replace, text)


def convert_ports(text: str, port_text: str, body: str) -> str:
    ports = parse_ports(port_text)
    body_clean = re.sub(r"\bassign\b[^;]*;", " ", blank_comments(body), flags=re.S)
    replacements: dict[str, str] = {}
    for port in ports:
        if port["direction"] == "input":
            replacements[port["name"]] = "wire"
        elif port["direction"] == "inout":
            replacements[port["name"]] = "wire"
        else:
            name = port["name"]
            procedural = bool(
                re.search(
                    r"\b" + re.escape(name) + r"\s*(?:<=|(?<![=!<>])=(?!=|>))",
                    body_clean,
                )
            )
            replacements[name] = "reg" if procedural else "wire"

    # Replace type keywords only in ANSI port declarations; all provided RTL uses
    # a direction keyword for every port entry.
    header = text
    for name, kind in replacements.items():
        pattern = re.compile(
            r"\b(input|output|inout)\b\s+(?:(?:wire|reg|logic|bit)\s+)?"
            r"((?:signed\s+)?(?:\[[^\]]+\]\s*)?)" + re.escape(name) + r"\b"
        )
        header = pattern.sub(lambda m: f"{m.group(1)} {kind} {m.group(2)}{name}", header)
    return header


def convert_sv_module(
    module_text: str,
    module_port_directions: dict[str, dict[str, str]] | None = None,
) -> str:
    name, parameters, ports, body, _ = module_parts(module_text)
    converted = module_text
    converted = strip_assertion_initials(converted)
    converted = convert_enums(converted)
    converted = replace_function_headers(converted)
    converted = re.sub(r"\bparameter\s+int\b", "parameter integer", converted)
    converted = re.sub(r"\blocalparam\s+int\b", "localparam integer", converted)
    converted = re.sub(r"\bint\s+unsigned\b", "integer", converted)
    converted = re.sub(r"\bint\b", "integer", converted)
    converted = re.sub(r"\balways_ff\b", "always", converted)
    converted = re.sub(r"\balways_comb\b", "always @*", converted)
    converted = re.sub(r"\balways_latch\b", "always @*", converted)
    converted = re.sub(r"(?<![\w$])'0\b", "0", converted)
    converted = re.sub(r"(?<![\w$])'1\b", "-1", converted)
    converted = re.sub(r"\b([A-Za-z_$][\w$]*)\s*\+\+", r"\1 = \1 + 1", converted)
    converted = re.sub(r"\b([A-Za-z_$][\w$]*)\s*--", r"\1 = \1 - 1", converted)

    # Convert enum variables to width-matched regs.
    enum_types = re.findall(
        r"typedef\s+enum\s+logic\s*(?:\[[^\]]+\])?\s*\{[\s\S]*?\}\s*(\w+)\s*;",
        blank_comments(module_text),
    )
    original_clean = blank_comments(module_text)
    for enum_type in enum_types:
        enum_match = re.search(
            r"typedef\s+enum\s+logic\s*(\[[^\]]+\])?\s*\{([\s\S]*?)\}\s*"
            + re.escape(enum_type)
            + r"\s*;",
            original_clean,
        )
        width = (enum_match.group(1) or "[0:0]").strip() if enum_match else "[0:0]"
        converted = re.sub(
            r"\b" + re.escape(enum_type) + r"\b",
            "reg " + width,
            converted,
        )

    # Function inputs and ordinary declarations are now Verilog-compatible.
    connected_outputs = submodule_output_actuals(
        module_text,
        module_port_directions or {},
    )
    converted = convert_logic_declarations(converted, connected_outputs)

    # Convert logic/bit on ports after determining whether outputs are procedural.
    _, _, converted_ports, converted_body, _ = module_parts(converted)
    converted = convert_ports(converted, converted_ports, converted_body)

    # Verilog-2005 requires loop variables to be declared at module scope.
    loop_vars = sorted(set(re.findall(r"\bfor\s*\(\s*integer\s+(\w+)\s*=", converted)))
    for var in loop_vars:
        converted = re.sub(r"\bfor\s*\(\s*integer\s+" + re.escape(var) + r"\s*=", f"for ({var} =", converted)
        if not re.search(r"(?m)^\s*integer\s+[^;]*\b" + re.escape(var) + r"\b", converted):
            # Insert declarations immediately after the module's port terminator.
            clean = blank_comments(converted)
            module_start = re.search(r"\bmodule\s+\w+\b", clean).start()
            port_open = clean.find("(", module_start)
            port_close = matching_paren(clean, port_open)
            insert_at = clean.find(";", port_close) + 1
            converted = converted[:insert_at] + f"\n    integer {var};" + converted[insert_at:]

    # Translate the remaining common SystemVerilog data types and procedural forms.
    converted = re.sub(r"\blogic\b", "reg", converted)
    converted = re.sub(r"\bbit\b", "reg", converted)
    return converted


def extract_modules(path: Path) -> list[tuple[str, str]]:
    text = path.read_text(encoding="utf-8-sig", errors="replace")
    clean = blank_comments(text)
    starts = list(re.finditer(r"\bmodule\s+(\w+)\b", clean))
    result = []
    for start in starts:
        end = clean.find("endmodule", start.end())
        if end < 0:
            raise ValueError(f"{path}: module {start.group(1)} has no endmodule")
        result.append((start.group(1), text[start.start() : end + len("endmodule")]))
    return result


def write_smoke_tb(module_name: str, module_text: str, path: Path) -> None:
    name, parameter_text, port_text, _, _ = module_parts(module_text)
    ports = parse_ports(port_text)
    lines = [
        "`timescale 1ns/1ps",
        f"// Generated standalone smoke test for {name}.",
        f"module tb_{name}_smoke;",
    ]
    for item in split_top_level(blank_comments(parameter_text)):
        parameter = re.match(
            r"\s*(?:parameter\s+)?(?:(?:integer|int)\s+)?(\w+)\s*=\s*([\s\S]+?)\s*$",
            item,
        )
        if parameter:
            lines.append(f"    localparam integer {parameter.group(1)} = {parameter.group(2)};")
    for port in ports:
        kind = "reg" if port["direction"] == "input" else "wire"
        decl = f"    {kind} "
        if port["signed"]:
            decl += "signed "
        if port["width"]:
            decl += port["width"] + " "
        lines.append(decl + port["name"] + ";")

    lines.append("")
    lines.append(f"    {name} dut (")
    lines.append(",\n".join(f"        .{p['name']}({p['name']})" for p in ports))
    lines.append("    );")

    clock_ports = [
        p for p in ports
        if p["direction"] == "input" and re.search(r"clk|clock", p["name"], re.I)
    ]
    reset_ports = [
        p for p in ports
        if p["direction"] == "input" and re.search(r"rst|reset", p["name"], re.I)
    ]
    for index, port in enumerate(clock_ports):
        lines.append(f"    always #{5 + 2 * index} {port['name']} = ~{port['name']};")

    lines.extend(["", "    integer cycle;", "    integer errors;", "    initial begin"])
    lines.append("        errors = 0;")
    for port in ports:
        if port["direction"] != "input":
            continue
        name_i = port["name"]
        if any(name_i == c["name"] for c in clock_ports):
            lines.append(f"        {name_i} = 1'b0;")
        elif any(name_i == r["name"] for r in reset_ports):
            active_low = bool(re.search(r"(?:_n|_b|_neg)$", name_i, re.I))
            lines.append(f"        {name_i} = 1'b{'0' if active_low else '1'};")
        else:
            lines.append(f"        {name_i} = 0;")
    lines.append("        cycle = 0;")
    lines.append("        #20;")
    for port in reset_ports:
        active_low = bool(re.search(r"(?:_n|_b|_neg)$", port["name"], re.I))
        lines.append(f"        {port['name']} = 1'b{'1' if active_low else '0'};")
    if clock_ports:
        lines.append("        repeat (24) begin")
        lines.append(f"            @(negedge {clock_ports[0]['name']});")
        for port in ports:
            if port["direction"] == "input" and port not in clock_ports and port not in reset_ports:
                lines.append(f"            {port['name']} = $random;")
        lines.append("            #1;")
        for port in ports:
            if port["direction"] == "output" and port["name"] not in OUTPUTS_ALLOWED_UNKNOWN.get(name, set()):
                lines.append(
                    f"            if ((^{port['name']}) === 1'bx) begin "
                    f'$display("FAIL: {name}.{port["name"]} is unknown at cycle %0d", cycle); '
                    "errors = errors + 1; end"
                )
        lines.append("            cycle = cycle + 1;")
        lines.append("        end")
    else:
        lines.append("        repeat (24) begin")
        lines.append("            #5;")
        for port in ports:
            if port["direction"] == "input" and port not in reset_ports:
                lines.append(f"            {port['name']} = $random;")
        lines.append("            #1;")
        for port in ports:
            if port["direction"] == "output" and port["name"] not in OUTPUTS_ALLOWED_UNKNOWN.get(name, set()):
                lines.append(
                    f"            if ((^{port['name']}) === 1'bx) begin "
                    f'$display("FAIL: {name}.{port["name"]} is unknown at cycle %0d", cycle); '
                    "errors = errors + 1; end"
                )
        lines.append("            cycle = cycle + 1;")
        lines.append("        end")
    lines.extend(
        [
            "        #10;",
            "        if (errors != 0)",
            f'            $display("FAIL: {name} reported %0d unknown outputs", errors);',
            "        else",
            f'            $display("PASS: tb_{name}_smoke completed %0d cycles", cycle);',
            "        $finish;",
            "    end",
            "endmodule",
            "",
        ]
    )
    path.write_text("\n".join(lines), encoding="utf-8", newline="\n")


def module_instantiations(module_text: str, known_names: set[str]) -> set[str]:
    clean = blank_comments(module_text)
    found = set()
    for candidate in known_names:
        pattern = re.compile(
            r"\b" + re.escape(candidate) + r"\s*"
            r"(?:#\s*\([\s\S]*?\)\s*)?"
            r"([A-Za-z_$][\w$]*)\s*\(",
            re.M,
        )
        for match in pattern.finditer(clean):
            if match.group(1) not in {"if", "case", "function", "task"}:
                found.add(candidate)
                break
    return found


def makefile_for_directory(
    directory: Path,
    modules: list[tuple[str, Path, str]],
    all_names: set[str],
) -> str:
    tops = sorted(
        [
            (name, path, text)
            for name, path, text in modules
            if path.parent == directory and not name.startswith("tb_")
        ],
        key=lambda item: (item[0], item[1].as_posix()),
    )
    if not tops:
        return ""

    def choose_source(dep: str, parent: Path) -> Path:
        candidates = [(path, text) for name, path, text in modules if name == dep]
        if not candidates:
            raise ValueError(f"No Verilog source found for instantiated module {dep}")
        candidates.sort(
            key=lambda item: (
                item[0].parent == parent.parent,
                common_prefix_len(parent.parent.parts, item[0].parent.parts),
                item[0].as_posix(),
            ),
            reverse=True,
        )
        return candidates[0][0]

    def source_closure(top: str, top_path: Path) -> list[Path]:
        visited_modules: set[tuple[Path, str]] = set()
        visited_paths: set[Path] = set()

        def visit(name: str, source_path: Path) -> None:
            key = (source_path, name)
            if key in visited_modules:
                return
            visited_modules.add(key)
            source_text = next(
                text for module_name, path, text in modules
                if module_name == name and path == source_path
            )
            visited_paths.add(source_path)
            for dep in sorted(module_instantiations(source_text, all_names)):
                if dep != name and dep in all_names:
                    visit(dep, choose_source(dep, source_path))

        visit(top, top_path)
        return sorted(visited_paths, key=lambda p: p.as_posix())

    lines = [
        "# Generated per-directory VCS targets; run make or make test_<module>.",
        "VCS ?= vcs",
        "VCS_FLAGS ?= -full64 -v2005 -timescale=1ns/1ps",
        "ROOT := $(abspath .)",
        "BUILD := build",
        "TOPS := " + " ".join(top for top, _, _ in tops),
        "TEST_TARGETS := " + " ".join(f"test_{top}" for top, _, _ in tops),
        "",
        ".PHONY: all test clean $(TEST_TARGETS)",
        "all: test",
        "test: $(TEST_TARGETS)",
        "",
    ]
    for top, top_path, _ in tops:
        sources = source_closure(top, top_path)
        srcs = " ".join(f"$(ROOT)/{Path(os.path.relpath(p, directory)).as_posix()}" for p in sources)
        tb = f"$(ROOT)/tb_{top}_smoke.v"
        lines.extend(
            [
                f"test_{top}:",
                f"\t@mkdir -p $(BUILD)/{top}",
                f"\tcd $(BUILD)/{top} && $(VCS) $(VCS_FLAGS) -top tb_{top}_smoke {srcs} {tb} -o simv && ./simv > run.log 2>&1; status=$$?; cat run.log; test $$status -eq 0 && ! grep -q '^FAIL:' run.log",
                "",
            ]
        )
    lines.extend(
        [
            "clean:",
            "\trm -rf $(BUILD)",
            "",
        ]
    )
    return "\n".join(lines)


def common_prefix_len(a: tuple[str, ...], b: tuple[str, ...]) -> int:
    count = 0
    for left, right in zip(a, b):
        if left != right:
            break
        count += 1
    return count


def main() -> None:
    converted_sources: list[Path] = []
    sv_paths = sorted(ROOT.rglob("*.sv"))
    module_port_directions: dict[str, dict[str, str]] = defaultdict(dict)
    for source_path in [*sv_paths, *sorted(ROOT.rglob("*.v"))]:
        for module_name, module_text in extract_modules(source_path):
            if module_name.startswith("tb_"):
                continue
            try:
                _, _, port_text, _, _ = module_parts(module_text)
                for port in parse_ports(port_text):
                    module_port_directions[module_name][port["name"]] = port["direction"]
            except ValueError:
                # Test or legacy non-ANSI modules are not used to infer output nets.
                continue

    for sv_path in sv_paths:
        rel = sv_path.relative_to(ROOT).as_posix()
        if "/tb/" in f"/{rel}" or sv_path.name.lower().startswith("tb"):
            continue
        sv_modules = extract_modules(sv_path)
        if not sv_modules:
            # UVM packages/interfaces/classes are verification infrastructure,
            # not synthesizable RTL to translate into a Verilog design module.
            continue
        converted = []
        original = sv_path.read_text(encoding="utf-8-sig", errors="replace")
        clean = blank_comments(original)
        first = re.search(r"\bmodule\s+\w+\b", clean)
        if first:
            converted.append(original[: first.start()])
        for _, module_text in sv_modules:
            converted.append(convert_sv_module(module_text, module_port_directions))
        out_path = sv_path.with_suffix(".v")
        out_path.write_text("\n\n".join(converted), encoding="utf-8", newline="\n")
        converted_sources.append(out_path)

    # Build a module-to-source index from all Verilog RTL now in the tree.
    module_sources: list[tuple[str, Path, str]] = []
    for verilog_path in sorted(ROOT.rglob("*.v")):
        for module_name, module_text in extract_modules(verilog_path):
            if module_name.startswith("tb_"):
                continue
            module_sources.append((module_name, verilog_path, module_text))

    # Every Verilog module gets an independent smoke TB; this includes existing
    # .v RTL so the local Makefile can exercise each source file's design tops.
    for module_name, verilog_path, module_text in module_sources:
        tb_path = verilog_path.parent / f"tb_{module_name}{TB_MARKER}.v"
        write_smoke_tb(module_name, module_text, tb_path)

    all_names = {module_name for module_name, _, _ in module_sources}
    makefiles = 0
    directories = sorted({path.parent for _, path, _ in module_sources})
    for directory in directories:
        contents = makefile_for_directory(directory, module_sources, all_names)
        if not contents:
            continue
        makefile = directory / "Makefile"
        if makefile.exists():
            existing = makefile.read_text(encoding="utf-8", errors="replace")
            # Refresh only Makefiles previously generated by this script. Preserve
            # hand-written or exercise-specific Makefiles instead of replacing them.
            if "# Generated per-directory VCS targets" not in existing:
                continue
        makefile.write_text(contents, encoding="utf-8", newline="\n")
        makefiles += 1

    print(f"Converted SV sources: {len(converted_sources)}")
    print(f"Verilog modules covered: {len(module_sources)}")
    print(f"Generated smoke testbenches: {len(module_sources)}")
    print(f"Generated per-directory Makefiles: {makefiles}")


if __name__ == "__main__":
    main()
