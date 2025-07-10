module spi_tx (
    input wire clk_10,
    input wire rst,
    input wire start_tx,
    input wire [7:0] data_in,
    input wire miso_tx,

    output reg mosi_tx,
    output reg csn_tx,
    output reg done_tx
);

    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;
    reg tx_active;

    always @(posedge clk_10 or posedge rst) begin
        if (rst) begin
            csn_tx <= 1;      // idle high
            mosi_tx <= 0;
            done_tx <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            tx_active <= 0;
        end else begin
            if (start_tx && !tx_active) begin
                tx_active <= 1;
                csn_tx <= 0;            // select device
                shift_reg <= data_in;
                bit_cnt <= 0;
                done_tx <= 0;
            end else if (tx_active) begin
                mosi_tx <= shift_reg[7];     // send MSB first
                shift_reg <= {shift_reg[6:0], 1'b0};
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt == 3'd7) begin
                    tx_active <= 0;
                    csn_tx <= 1;             // deselect
                    done_tx <= 1;            // indicate done
                end
            end else begin
                done_tx <= 0;                // reset done
            end
        end
    end

endmodule
