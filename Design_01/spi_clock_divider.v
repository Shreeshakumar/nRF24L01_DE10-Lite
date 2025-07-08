module spi_clock_divider (
    input wire clk_50,
    input wire rst,
    output reg clk_10,
    output reg [31:0] counter_p,
    output reg [31:0] counter_n
);
    
    always @(posedge clk_50 or posedge rst) begin
        if (rst) begin
            counter_p <= -1;
            clk_10 <= 0;
        end else begin
            if (counter_p == (4)) begin
                clk_10 <= ~clk_10;
                counter_p <= 0;
            end else begin
                counter_p <= counter_p + 1;
            end
        end
    end

    always @(negedge clk_50 or posedge rst) begin
        if (rst) begin
            counter_n <= 2;
        end else begin
            if (counter_n == (4)) begin
                clk_10 <= ~clk_10;
                counter_n <= 0;
            end else begin
                counter_n <= counter_n + 1;
            end
        end
    end

endmodule
