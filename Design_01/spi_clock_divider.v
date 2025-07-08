module spi_clock_divider #(
    parameter DIVIDER = 5 // Generates 10MHz from 50MHz clk
)(
    input wire clk,
    input wire reset,
    output reg spi_clk
);

    reg [31:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            spi_clk <= 0;
        end else begin
            if (counter == (DIVIDER/2 - 1)) begin
                spi_clk <= ~spi_clk;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
