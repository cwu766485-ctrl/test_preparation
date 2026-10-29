// NM6008 RTL TEMPLATE (working example: registered 8-bit addition)
// EDIT-RTL-1: change the module name, ports and widths per exam spec.
module ExamDUT (
    input  wire       CLK,
    input  wire       NRST,        // active-low asynchronous reset
    input  wire       START,
    input  wire [7:0] A,
    input  wire [7:0] B,
    output reg  [8:0] RESULT,
    output reg        DONE
);

    // EDIT-RTL-2: Add state/counter/temporary registers if the problem needs them.
    // reg [1:0] state, next_state;

    // EDIT-RTL-3: For sequential circuits, use nonblocking <= in clocked logic.
    always @(posedge CLK or negedge NRST) begin
        if (!NRST) begin
            RESULT <= 9'd0;
            DONE   <= 1'b0;
        end else begin
            DONE <= 1'b0;             // Default: one-cycle done pulse
            if (START) begin
                // EDIT-RTL-4: Replace this computation with the required function.
                RESULT <= {1'b0, A} + {1'b0, B};
                DONE   <= 1'b1;
            end
        end
    end
endmodule
