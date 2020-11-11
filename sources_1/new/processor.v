`timescale 1ns / 1ps

module processor(
    input clk, // Clock signal
    input valid_in, // Run when 1, stop when 0
    output valid_out // Instruction memory program finish indicator
    );
    
    reg [15:0] Dmem [511:0]; // Data memory
    reg [5:0] Imem [127:0]; // Instruction memory
    reg [15:0] Regs [31:0]; // Registers
     
    reg [15:0]PC = 16'h0000, PC_next=16'h0000; // Program counter
    
    reg valid_out_r = 1'b0, valid_out_r_next=1'b0; // Register to control end of program
 
    // Instructions
    localparam ADD = 3'b000, SUB = 3'b001;
    localparam MOVE = 3'b010, SHIFT = 3'b011;
    localparam LOAD = 3'b100, STORE = 3'b101;
    localparam JUMP = 3'b110, BRANCH = 3'b111;
    
    // Running or idle states
    localparam RUNNING = 1'b1, IDLE = 1'b0;
    
    // Necessary variables
    reg [17:0] instruction;
    reg [2:0] opcode;
    reg [4:0] Ya, Yb, Yc;
    reg [15:0] tmp; // Temporary variable since the same register is used for both input and output
    
    reg state = IDLE, state_next = IDLE; // State control register
    
    // Assign register to their first values
    integer i;
    initial begin
        for(i=0; i<32; i=i+1) begin
            Regs[i] = i<16 ? i : 0;
        end
    end
    
    always @* begin
        // Default values of variables that will be used in every cycle
        PC = PC_next;
        state = state_next;
        instruction = {Imem[PC], Imem[PC + 1'b1], Imem[PC + 2'b10], Imem[PC + 2'b11]};
        opcode = instruction[17:15];
        Ya = instruction[14:10];
        Yb = instruction[9:5];
        Yc = instruction[4:0];
        
        // Check end of program
        if(PC == 16'h00FF) begin
            state_next = IDLE;
        end
        
        // Run the instructions if program is running 
        if(state == RUNNING) begin
            opcode = instruction[17:15];
            Ya = instruction[14:10];
            Yb = instruction[9:5];
            Yc = instruction[4:0];
            
            case(opcode)
            
                ADD: begin
                    Regs[Ya] = Regs[Yb] + Regs[Yc];
                    PC_next = PC_next + 4'b0011;
                end
                
                SUB: begin
                    Regs[Ya] = Regs[Yb] - Regs[Yc];
                    PC_next = PC_next + 4'b0011;
                end
                
                TASI: begin
                    Regs[Ya] = {Regs[Yb][15:8], Regs[Yc][7:0]};
                    PC_next = PC_next + 4'b0011;
                end
                
                SHIFT: begin
                    Regs[Ya] = Regs[Ya] << Regs[Yb];
                    PC_next = PC_next + 4'b0011;
                end
                
                LOAD: begin
                    tmp = Regs[Yb];
                    Regs[Ya] = Dmem[tmp];
                    PC_next = PC_next + 4'b0011;
                end
                
                STORE: begin
                    tmp = Regs[Yb];
                    Dmem[tmp] = Regs[Ya];
                    PC_next = PC_next + 4'b0011;
                end
                
                JUMP: begin
                    if(instruction[1:0] == 1'b0) begin
                        PC_next = PC + Regs[Ya];
                    end
                    else begin
                        Regs[Ya] = Regs[Yb] * Regs[Yc];
                        PC_next = PC_next + 4'b0011;
                    end
                end
                
                BRANCH: begin
                    if(Regs[Yb] == Regs[Yc]) begin
                        PC_next = Regs[Ya];
                    end
                    else begin
                        PC_next = PC_next + 4'b0011;
                    end
                end
            endcase
        end
        
        // Wait if program is not running
        else if (state == IDLE) begin
            PC = 16'h0000;
            valid_out_r_next = 0;
        end
    end
    
    // Assignments in the end of cycle
    always @(posedge clk) begin
        PC_next = PC + 3'b100;
        if(PC == 16'h00FF) begin
            state = IDLE;
        end
        valid_out_r = valid_out_r_next;
    end

    // Assignent of output for the end of program 
    assign valid_out = valid_out_r;
        
endmodule
