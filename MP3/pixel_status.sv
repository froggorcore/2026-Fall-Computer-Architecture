module pixel_status (
    input logic clk,
    input logic start_calc,
    input logic [63:0] green_status, // dead or alive
    input logic [63:0] red_status,
    input logic [63:0] blue_status,
    input logic [5:0] pixel, // pixel we care about
    output logic pixel_green_status,
    output logic pixel_red_status,
    output logic pixel_blue_status,
    output logic end_calc
);
    logic current_green;
    logic current_red;
    logic current_blue;
    logic [3:0] green_alive_neighbors, red_alive_neighbors, blue_alive_neighbors;

    logic [5:0] idx_up_left, idx_up_mid, idx_up_right, idx_mid_left, idx_mid_right, idx_dn_left, idx_dn_mid, idx_dn_right;

    wire [2:0] row = pixel[5:3];
    wire [2:0] col = pixel[2:0];

    // top row (wrap row 0 to row 7)
    assign idx_up_left  = {row - 3'd1, col - 3'd1};
    assign idx_up_mid   = {row - 3'd1, col};
    assign idx_up_right = {row - 3'd1, col + 3'd1};

    // same row (wrap column 0 to column 7, and vice versa)
    assign idx_mid_left  = {row, col - 3'd1};
    assign idx_mid_right = {row, col + 3'd1};

    // bottom row (wrap row 7 to row 0)
    assign idx_dn_left  = {row + 3'd1, col - 3'd1};
    assign idx_dn_mid   = {row + 3'd1, col};
    assign idx_dn_right = {row + 3'd1, col + 3'd1};

    logic neighbor_calc;

    always_ff @(posedge clk) begin
        if (start_calc)  begin
            // current status
            current_green <= green_status[pixel];
            current_red <= red_status[pixel];
            current_blue <= blue_status[pixel];

            green_alive_neighbors <= 0;
            red_alive_neighbors <= 0;
            blue_alive_neighbors <= 0;

            green_alive_neighbors <= green_status[idx_up_left]
                                    + green_status[idx_up_mid]
                                    + green_status[idx_up_right]
                                    + green_status[idx_mid_left]
                                    + green_status[idx_mid_right]
                                    + green_status[idx_dn_left]
                                    + green_status[idx_dn_mid]
                                    + green_status[idx_dn_right];

            red_alive_neighbors   <= red_status[idx_up_left]
                                    + red_status[idx_up_mid]
                                    + red_status[idx_up_right]
                                    + red_status[idx_mid_left]
                                    + red_status[idx_mid_right]
                                    + red_status[idx_dn_left]
                                    + red_status[idx_dn_mid]
                                    + red_status[idx_dn_right];

            blue_alive_neighbors  <= blue_status[idx_up_left]
                                    + blue_status[idx_up_mid]
                                    + blue_status[idx_up_right]
                                    + blue_status[idx_mid_left]
                                    + blue_status[idx_mid_right]
                                    + blue_status[idx_dn_left]
                                    + blue_status[idx_dn_mid]
                                    + blue_status[idx_dn_right];
            neighbor_calc <= 1'b1;
        end
        else begin
            neighbor_calc <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (neighbor_calc) begin
            pixel_green_status <= current_green
                ? (green_alive_neighbors == 2 ||
                green_alive_neighbors == 3)
                : (green_alive_neighbors == 3);

            pixel_red_status <= current_red
                ? (red_alive_neighbors == 2 ||
                red_alive_neighbors == 3)
                : (red_alive_neighbors == 3);

            pixel_blue_status <= current_blue
                ? (blue_alive_neighbors == 2 ||
                blue_alive_neighbors == 3)
                : (blue_alive_neighbors == 3);
                end_calc <= 1'b1;
        end
        else begin
            end_calc <= 1'b0;
        end

    end
endmodule
