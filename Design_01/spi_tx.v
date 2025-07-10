module spi_tx (
    input wire clk_10,           // System clock
    input wire rst,         // Active high reset
    input wire start_tx,         // Trigger SPI transaction
    input wire [7:0] data_in, // Data to transmit
    input wire miso_tx,       // SPI clock (from divider)
    
    output reg [7:0] data_out, // Data received from MISO
    output reg mosi_tx,           // Transaction done
    output reg csn_tx,           // Master Out Slave In
    output reg done_tx,
);

    reg [2:0] bit_cnt;
    reg [7:0] shift_reg_tx;
    reg [7:0] shift_reg_rx;
    reg active;
    reg spi_clk_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_cnt <= 0;
            shift_reg_tx <= 0;
            shift_reg_rx <= 0;
            SCK <= 0;
            MOSI <= 0;
            CSN <= 1;
            done <= 0;
            active <= 0;
            spi_clk_prev <= 0;
        end else begin
            spi_clk_prev <= spi_clk;

            // Start condition
            if (start && !active) begin
                active <= 1;
                CSN <= 0;
                shift_reg_tx <= data_in;
                shift_reg_rx <= 0;
                bit_cnt <= 7;
                done <= 0;
            end

            // SPI Active
            if (active) begin
                // SPI mode 0: sample on rising edge
                if (spi_clk && !spi_clk_prev) begin
                    // Shift out MSB first
                    MOSI <= shift_reg_tx[bit_cnt];

                    // Shift in MISO bit
                    shift_reg_rx[bit_cnt] <= MISO;

                    // After last bit, finish transaction
                    if (bit_cnt == 0) begin
                        active <= 0;
                        CSN <= 1;
                        data_out <= shift_reg_rx;
                        done <= 1;
                    end else begin
                        bit_cnt <= bit_cnt - 1;
                    end

                    // Toggle SPI clock output
                    SCK <= 1;
                end else if (!spi_clk && spi_clk_prev) begin
                    SCK <= 0; // Clock low on falling edge
                end
            end else begin
                done <= 0;
            end
        end
    end

endmodule
