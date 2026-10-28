class adder_sequence extends uvm_sequence #(adder_item);
    `uvm_object_utils(adder_sequence)

    function new(string name = "adder_sequence");
        super.new(name);
    endfunction

    task body();
        adder_item req;

        // Exhaust all 2^3 input combinations.
        for (int i = 0; i < 8; i++) begin
            req = adder_item::type_id::create($sformatf("req_%0d", i));

            start_item(req);
            {req.a, req.b, req.cin} = i[2:0];
            finish_item(req);
        end
    endtask
endclass
