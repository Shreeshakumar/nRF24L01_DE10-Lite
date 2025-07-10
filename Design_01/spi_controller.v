module spi_controller (
    input wire clk_10,                   //10Mhz from spi_clock_divider to spi_controller
    input wire rst,                      //reset trigger from top M to spi_controller
    input wire [7:0]data_in,             //data to send from top M
    input wire start_tx,                 //enable tx trigger from top M
    input wire start_rx,                 //enable rx trigger from top M

    input wire miso_tx,                   //in pins to nrf tx
    input wire miso_rx,                   //in pins to nrf rx
    
    output wire mosi_tx,                  //out pins to nrf tx
    output wire mosi_rx,                  //out pins to nrf rx

    output reg done_tx,                   //done tx trigger to top M
    output reg done_rx,                   //done tx trigger to top M
    output reg [7:0]data_out,             //data receiver to top M
);

    reg start;
    reg [7:0] tx_data;
    wire [7:0] rx_data;
    wire spi_done;

    spi_tx spi_tx (
      .clk_10(clk_10),
      .rst(rst),
      .start_tx(start_tx),
      .data_in(data_in),
      .miso_tx(miso_tx),

      .mosi_tx(mosi_tx),
      .csn_tx(csn_tx),
      .data_out(data_out),
      .done_tx(done_tx)
    );

    spi_rx spi_rx (
      .clk_10(clk_10),
      .rst(rst),
      .start_rx(start_rx),
      .data_in(ddata_in),
      .miso_rx(miso_rx),
      .spi_clk(spi_clk),
      .mosi_rx(mosi_rx),
      .csn_rx(csn_rx),
      .data_out(data_out),
      .done_rx(done_rx)
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
