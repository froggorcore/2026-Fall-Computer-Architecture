`timescale 10ns/10ns
`include "top.sv"

module game_of_life_tb;

    logic clk = 0;
    logic _48b;
    logic _45a;

    top u0 (
        .clk              (clk),
        ._48b             (_48b),
        ._45a             (_45a)
    );

    initial begin
        $dumpfile("game_of_life.vcd");
        $dumpvars(0, game_of_life_tb);
        #100000000 // run simulation for 2 seconds
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule
