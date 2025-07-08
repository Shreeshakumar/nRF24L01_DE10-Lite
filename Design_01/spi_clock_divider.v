module spi_clock_divider #(
    parameter DIVIDER = 5 // Generates 10MHz from 50MHz clk
)(
    input wire clk_50,
    input wire rst,
    output reg clk_10
);

    reg [31:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_10 <= 0;
        end else begin
            if (counter == (DIVIDER - 1)) begin
                clk_10 <= ~clk_10;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
