class adder_monitor extends uvm_monitor;
    `uvm_component_utils(adder_monitor)

    virtual adder_if vif;
    uvm_analysis_port #(adder_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual adder_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "adder_if was not found in uvm_config_db")
    endfunction

    task run_phase(uvm_phase phase);
        adder_item tr;

        forever begin
            @(negedge vif.clk);

            if (vif.valid) begin
                tr = adder_item::type_id::create("tr");

                tr.a         = vif.a;
                tr.b         = vif.b;
                tr.cin       = vif.cin;
                tr.half_sum  = vif.half_sum;
                tr.half_cout = vif.half_cout;
                tr.full_sum  = vif.full_sum;
                tr.full_cout = vif.full_cout;

                `uvm_info("MON",
                    $sformatf("sample a=%0b b=%0b cin=%0b | half=%0b%0b full=%0b%0b",
                              tr.a, tr.b, tr.cin,
                              tr.half_cout, tr.half_sum,
                              tr.full_cout, tr.full_sum),
                    UVM_HIGH)

                ap.write(tr);
            end
        end
    endtask
endclass
