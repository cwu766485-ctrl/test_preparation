class adder_driver extends uvm_driver #(adder_item);
    `uvm_component_utils(adder_driver)

    virtual adder_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual adder_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "adder_if was not found in uvm_config_db")
    endfunction

    task run_phase(uvm_phase phase);
        adder_item tr;

        // Initialize DUT inputs.
        vif.valid <= 1'b0;
        vif.a   <= 1'b0;
        vif.b   <= 1'b0;
        vif.cin <= 1'b0;

        forever begin
            seq_item_port.get_next_item(tr);

            // Drive on posedge; monitor samples on negedge.
            @(posedge vif.clk);
            vif.a   <= tr.a;
            vif.b   <= tr.b;
            vif.cin <= tr.cin;
            vif.valid <= 1'b1;

            `uvm_info("DRV",
                $sformatf("drive a=%0b b=%0b cin=%0b",
                          tr.a, tr.b, tr.cin),
                UVM_MEDIUM)

            seq_item_port.item_done();
            @(negedge vif.clk);
            vif.valid <= 1'b0;
        end
    endtask
endclass
