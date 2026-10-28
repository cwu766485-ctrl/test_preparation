module comparator #(
    parameter W = 8
)(
    input [W-1:0] a,
    input [W-1:0] b,

    output reg gt,
    output reg eq, 
    output reg lt
/*
    output gt,
    output eq, 
    output lt
*/
);


    always @(*) begin
        gt = (a > b);
        eq = (a == b);
        lt = (a < b);
    end

/*
    assign gt = (a > b);
    assign eq = (a == b);
    assign lt = (a < b);
*/


endmodule