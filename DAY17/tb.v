module tb_stall_branch;

    reg clk = 0;
    reg reset = 1;
    wire [7:0] ACC;

    pipeline_stall_branch_cpu DUT (
        .clk(clk),
        .reset(reset),
        .ACC(ACC)
    );

    always #5 clk = ~clk;

    initial begin
        #10 reset = 0;
        #250 $finish;
    end

endmodule