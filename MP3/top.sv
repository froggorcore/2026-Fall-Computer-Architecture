`include "memory.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "game_processor.sv"

// game_of_life top level module

module top(
    input logic     clk,
    output logic    _48b,
    output logic    _45a
);
    // initial pixel data
    logic [7:0] init_red_data;
    logic [7:0] init_green_data;
    logic [7:0] init_blue_data;

    // current pixel color data
    logic [7:0] red_data;
    logic [7:0] green_data;
    logic [7:0] blue_data;

    // current pixel status for each color channel
    logic [63:0] green_status;
    logic [63:0] red_status;
    logic [63:0] blue_status;

    // next pixel status for each color channel
    logic [63:0] next_green_status;
    logic [63:0] next_red_status;
    logic [63:0] next_blue_status;

    // controller outputs
    logic start_calc; // signal to start the game processor calculation
    logic transmit_pixel; // signal to transmit the current pixel's color data
    logic [5:0] pixel; // signal to load the shift register with the current pixel's color data
    logic load_sreg; // signal to load the shift register

    // WS2812B output driver signals
    logic shift;
    logic [23:0] shift_reg = 24'd0;
    logic ws2812b_out;

    logic calc_done; // updates the current pixel status with the next pixel status

    logic [6:0] load_memory_count = 7'd0; // counter to load the initial pixel data from memory
    logic load_memory = 1'b1;
    logic load_wait = 1'b0;


    memory #(
        .INIT_FILE      ("red.txt")
    ) u1 (
        .clk            (clk),
        .read_pixel     (load_memory_count[5:0]),
        .read_data      (init_red_data)
    );

    memory #(
        .INIT_FILE      ("green.txt")
    ) u2 (
        .clk            (clk),
        .read_pixel     (load_memory_count[5:0]),
        .read_data      (init_green_data)
    );

    memory #(
        .INIT_FILE      ("blue.txt")
    ) u3 (
        .clk            (clk),
        .read_pixel     (load_memory_count[5:0]),
        .read_data      (init_blue_data)
    );

    game_processor u4 (
        .clk                (clk),
        .start_calc         (start_calc),
        .green_status       (green_status),
        .red_status         (red_status),
        .blue_status        (blue_status),
        .next_green_status  (next_green_status),
        .next_red_status    (next_red_status),
        .next_blue_status   (next_blue_status),
        .calc_done          (calc_done)
    );

    controller
    #(.IDLE_CYCLES(1000000))
    // use this parameter for test bench
    u5 (
        .clk            (clk),
        .enable         (!load_memory), // enable once memory is loaded
        .start_calc     (start_calc),
        .load_sreg      (load_sreg),
        .transmit_pixel (transmit_pixel),
        .pixel          (pixel)
    );

    ws2812b u6 (
        .clk            (clk),
        .serial_in      (shift_reg[23]),
        .transmit       (transmit_pixel),
        .ws2812b_out    (ws2812b_out),
        .shift          (shift)
    );

    always_ff @(posedge clk) begin
        if (load_memory) begin
            if (!load_wait) begin
                // takes a clock cycle to load the initial pixel data from memory
                load_wait <= 1'b1;
            end
            else begin
                // store the current pixel's initial color status
                red_status[load_memory_count[5:0]]
                    <= (init_red_data != 8'h00);

                green_status[load_memory_count[5:0]]
                    <= (init_green_data != 8'h00);

                blue_status[load_memory_count[5:0]]
                    <= (init_blue_data != 8'h00);

                if (load_memory_count == 7'd63) begin
                    // All 64 pixels have been initialized
                    load_memory <= 1'b0;
                end
                else begin
                    load_memory_count <= load_memory_count + 1'b1;
                end

                load_wait <= 1'b0;
            end
        end
        else begin
            // game state controls the LEDs
            if (calc_done) begin
                red_status   <= next_red_status;
                green_status <= next_green_status;
                blue_status  <= next_blue_status;
            end

            red_data   <= red_status[pixel]   ? 8'h60 : 8'h00;
            green_data <= green_status[pixel] ? 8'h60 : 8'h00;
            blue_data  <= blue_status[pixel]  ? 8'h60 : 8'h00;
        end
    end

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            shift_reg <= { green_data, red_data, blue_data };
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
