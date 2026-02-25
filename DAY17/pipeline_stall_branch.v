module pipeline_stall_branch_cpu (
    input clk,
    input reset,
    output reg [7:0] ACC
);

    reg [3:0] PC;

    // Instruction memory
    reg [7:0] program [0:15];

    // Pipeline registers
    reg [7:0] IF_IR;
    reg [7:0] EX_IR;

    // Decode
    wire [3:0] EX_opcode  = EX_IR[7:4];
    wire [3:0] EX_operand = EX_IR[3:0];

    // Opcodes
    parameter ADD   = 4'b0001;
    parameter SUB   = 4'b0010;
    parameter LOAD  = 4'b0011;
    parameter JUMP  = 4'b0101;

    // Simple data memory
    reg [7:0] data_mem [0:15];

    // Control flags
    reg stall;
    reg flush;

    initial begin
        program[0] = 8'b0011_0010; // LOAD 2
        program[1] = 8'b0001_0001; // ADD 1  (needs stall)
        program[2] = 8'b0101_0100; // JUMP 4
        program[3] = 8'b0001_0010; // (will be flushed)
        program[4] = 8'b0010_0001; // SUB 1

        data_mem[2] = 8'd5;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 0;
            ACC <= 0;
            IF_IR <= 0;
            EX_IR <= 0;
            stall <= 0;
            flush <= 0;
        end else begin

            // -------- STALL DETECTION --------
            if (EX_opcode == LOAD)
                stall <= 1;
            else
                stall <= 0;

            // -------- FETCH STAGE --------
            if (!stall) begin
                IF_IR <= program[PC];
                PC <= PC + 1;
            end

            // -------- PIPELINE SHIFT --------
            if (!stall)
                EX_IR <= IF_IR;

            // -------- EXECUTE STAGE --------
            flush <= 0;

            case (EX_opcode)

                LOAD: ACC <= data_mem[EX_operand];

                ADD:  ACC <= ACC + EX_operand;

                SUB:  ACC <= ACC - EX_operand;

                JUMP: begin
                    PC <= EX_operand;   // jump target
                    flush <= 1;         // clear wrong instruction
                end

            endcase

            // -------- FLUSH WRONG FETCH --------
            if (flush)
                IF_IR <= 0;

        end
    end

endmodule