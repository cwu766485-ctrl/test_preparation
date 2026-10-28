class adder_item extends uvm_sequence_item;
    rand bit a;
    rand bit b;
    rand bit cin;

    logic half_sum;
    logic half_cout;
    logic full_sum;
    logic full_cout;

    `uvm_object_utils_begin(adder_item)
        `uvm_field_int(a,         UVM_ALL_ON)
        `uvm_field_int(b,         UVM_ALL_ON)
        `uvm_field_int(cin,       UVM_ALL_ON)
        `uvm_field_int(half_sum,  UVM_ALL_ON)
        `uvm_field_int(half_cout, UVM_ALL_ON)
        `uvm_field_int(full_sum,  UVM_ALL_ON)
        `uvm_field_int(full_cout, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "adder_item");
        super.new(name);
    endfunction
endclass
