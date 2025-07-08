module spi_controller (
    input wire clk,             // System clock
    input wire reset,           // System reset
    input wire spi_clk,         // SPI clock from divider
    input wire MISO,            // SPI MISO from slave
    input wire trigger,         // Start transaction (e.g., button)

    output wire MOSI,
    output wire SCK,
    output wire CSN,
    output wire [7:0] received_data,
    output wire done            // High when transaction completes
);

    reg start;
    reg [7:0] tx_data;
    wire [7:0] rx_data;
    wire spi_done;

    // Instantiate the SPI Master
    spi_master spi_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(tx_data),
        .spi_clk(spi_clk),
        .data_out(rx_data),
        .done(spi_done),
        .MOSI(MOSI),
        .MISO(MISO),
        .SCK(SCK),
        .CSN(CSN)
    );

    reg [1:0] state;
    localparam IDLE = 2'b00,
               START = 2'b01,
               WAIT = 2'b10,
               DONE = 2'b11;

    reg [7:0] rx_buffer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            start <= 0;
            tx_data <= 8'h00;
            rx_buffer <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    if (trigger) begin
                        tx_data <= 8'hFF;  // NOP command to read STATUS
                        start <= 1;
                        state <= START;
                    end
                end

                START: begin
                    start <= 0;
                    state <= WAIT;
                end

                WAIT: begin
                    if (spi_done) begin
                        rx_buffer <= rx_data;
                        state <= DONE;
                    end
                end

                DONE: begin
                    // Optional: Do something with rx_buffer
                    state <= IDLE;
                end
            endcase
        end
    end

    assign received_data = rx_buffer;
    assign done = (state == DONE);

endmodule
