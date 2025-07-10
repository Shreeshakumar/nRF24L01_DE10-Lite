module spi_rx (
    input wire clk_10,
    input wire rst,
    input wire start_rx,
    input wire miso_rx,

    output reg [7:0] data_out,
    output reg mosi_rx,
    output reg csn_rx,
    output reg done_rx
);

    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;
    reg rx_active;

    always @(posedge clk_10 or posedge rst) begin
        if (rst) begin
            csn_rx <= 1;
            mosi_rx <= 0;
            done_rx <= 0;
            data_out <= 0;
            bit_cnt <= 0;
            rx_active <= 0;
        end else begin
            if (start_rx && !rx_active) begin
                rx_active <= 1;
                csn_rx <= 0;
                bit_cnt <= 0;
                shift_reg <= 0;
                done_rx <= 0;
            end else if (rx_active) begin
                shift_reg <= {shift_reg[6:0], miso_rx};  // shift in MSB first
                bit_cnt <= bit_cnt + 1;
                mosi_rx <= 0;  // could toggle dummy bits if needed

                if (bit_cnt == 3'd7) begin
                    rx_active <= 0;
                    csn_rx <= 1;
                    data_out <= {shift_reg[6:0], miso_rx};
                    done_rx <= 1;
                end
            end else begin
                done_rx <= 0;
            end
        end
    end

endmodule
