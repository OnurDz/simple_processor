`timescale 1ns / 1ps

module processor_tb;
    reg clk = 1, valid_in;
    wire valid_out;
    integer i;
    reg flag = 1'b1;   
    islemci uut (clk, valid_in, valid_out);
    
    always begin
        clk = ~clk;
        #10;
    end
    
    initial begin
        valid_in = 1'b1;
        $readmemb("Imem2.mem", uut.Imem);
        $readmemh("Dmem.mem", uut.Dmem);
        wait(valid_out == 1);
        valid_in = 1'b0;
        
        for (i = 53 ; i>49; i=i-1) begin
            if (uut.Dmem[i] != 16'h0066) begin 
                flag = 1'b0;
            end  
        end
        for (i = 49 ; flag && i>46 ; i=i-1) begin
            if (uut.Dmem[i] != 16'h0055) begin 
                flag = 1'b0;
            end  
        end
        for (i = 46 ; flag && i>40 ; i=i-1) begin
            if (uut.Dmem[i] != 16'h0050) begin 
                flag = 1'b0;
            end  
        end
        for (i = 40 ; flag && i>37 ; i=i-1) begin
            if (uut.Dmem[i] != 16'h0040) begin 
                flag = 1'b0;
            end  
        end
      
        if (flag == 1) $display("OK !");
        else $display("FAILED :(");
        
        #80;
        valid_in =1'b1;
        for(i=16; i<32 ; i=i+1) begin
            uut.Regs[i] = 16'b0;
        end
        $readmemb("Imem.mem", uut.Imem);
        $readmemh("Dmem.mem", uut.Dmem);
        wait(valid_out == 1);
        
        for (i = 52 ; i>48; i=i-1) begin
            if (uut.Dmem[i] != 16'h0017) begin 
            flag = 1'b0;
            end  
        end
        for (i = 48 ; flag && i>45 ; i=i-1) begin
            if (uut.Dmem[i] != 16'h0016) begin 
                flag = 1'b0;
            end  
        end
        for (i = 45 ; flag && i>39 ; i=i-1) begin
            if (uut.Dmem[i] != 16'h0015) begin 
                flag = 1'b0;
            end  
        end
        for (i = 39 ; flag && i>36 ; i=i-1) begin
            if (uut.Dmem[i] != 16'h0014) begin 
                flag = 1'b0;
            end  
        end
        
        if (flag == 1) $display("OK !");
        else $display("FAILED :(");
        valid_in = 1'b0;
    end
 
endmodule
