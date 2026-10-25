`include "pixel_status.sv"

module game_processor (
    input logic clk,
    input logic start_calc,
    // input current state for red, green, blue channels on matrix
    input logic [63:0] green_status,
    input logic [63:0] red_status,
    input logic [63:0] blue_status,
    // output next state for red, green, blue channels on matrix
    output logic [63:0] next_green_status,
    output logic [63:0] next_red_status,
    output logic [63:0] next_blue_status,
    output logic calc_done
);
    logic [63:0] pixel_green_status;
    logic [63:0] pixel_red_status;
    logic [63:0] pixel_blue_status;
    logic [63:0] pixel_end_calc;

    // can't instantiate modules with for loop in always_ff :(
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : pixel_gen
            pixel_status pixel_status_instance (
            .clk (clk),
            .start_calc (start_calc),
            .green_status (green_status),
            .red_status (red_status),
            .blue_status (blue_status),
            .pixel (6'(i)),
            .pixel_green_status (pixel_green_status[i]),
            .pixel_red_status (pixel_red_status[i]),
            .pixel_blue_status (pixel_blue_status[i]),
            .end_calc (pixel_end_calc[i])
            );
        end
    endgenerate

    always_ff @(posedge clk) begin
        calc_done <= 1'b0;
        if (&pixel_end_calc) begin
            next_green_status <= pixel_green_status;
            next_red_status <= pixel_red_status;
            next_blue_status <= pixel_blue_status;
            calc_done <= 1'b1;
        end
    end

endmodule
