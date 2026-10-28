class adder_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(adder_scoreboard)

    uvm_analysis_imp #(adder_item, adder_scoreboard) analysis_imp;

    int pass_count = 0;
    int fail_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_imp = new("analysis_imp", this);
    endfunction

    function void write(adder_item tr);
        logic exp_half_sum;
        logic exp_half_cout;
        logic exp_full_sum;
        logic exp_full_cout;

        exp_half_sum  = tr.a ^ tr.b;
        exp_half_cout = tr.a & tr.b;

        exp_full_sum  = tr.a ^ tr.b ^ tr.cin;
        exp_full_cout = (tr.a & tr.b) |
                        (tr.a & tr.cin) |
                        (tr.b & tr.cin);

        if ((tr.half_sum  !== exp_half_sum)  ||
            (tr.half_cout !== exp_half_cout) ||
            (tr.full_sum  !== exp_full_sum)  ||
            (tr.full_cout !== exp_full_cout)) begin

            fail_count++;

            `uvm_error("SB",
                $sformatf(
                    "FAIL a=%0b b=%0b cin=%0b | HALF got=%0b%0b exp=%0b%0b | FULL got=%0b%0b exp=%0b%0b",
                    tr.a, tr.b, tr.cin,
                    tr.half_cout, tr.half_sum,
                    exp_half_cout, exp_half_sum,
                    tr.full_cout, tr.full_sum,
                    exp_full_cout, exp_full_sum
                ))
        end
        else begin
            pass_count++;

            `uvm_info("SB",
                $sformatf(
                    "PASS a=%0b b=%0b cin=%0b | half=%0b%0b full=%0b%0b",
                    tr.a, tr.b, tr.cin,
                    tr.half_cout, tr.half_sum,
                    tr.full_cout, tr.full_sum
                ),
                UVM_LOW)
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SB_REPORT",
            $sformatf("PASS=%0d FAIL=%0d", pass_count, fail_count),
            UVM_NONE)

        if (fail_count != 0)
            `uvm_error("SB_REPORT", "Adder test FAILED")
    endfunction
endclass
