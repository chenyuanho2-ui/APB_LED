module apb_led_controller (
    // APB 总线接口信号
    input  wire        PCLK,      // 时钟信号
    input  wire        PRESETN,   // 复位信号 (低电平有效)
    input  wire [31:0] PADDR,     // 地址总线
    input  wire        PSEL,      // 片选信号
    input  wire        PENABLE,   // 使能信号
    input  wire        PWRITE,    // 读写控制 (1:写, 0:读)
    input  wire [31:0] PWDATA,    // 写数据总线
    output reg  [31:0] PRDATA,    // 读数据总线
    output wire        PREADY,    // 就绪信号 (简单外设直接拉高即可)
    output wire        PSLVERR,   // 错误信号 (简单外设不报错)
    
    // 物理输出引脚
    output wire [3:0]  led_out    // 连接到板载 LED
);

    // 定义一个 32 位的寄存器用于控制 LED
    reg [31:0] led_reg;

    // 简单外设总是准备好接收/发送数据
    assign PREADY  = 1'b1;
    assign PSLVERR = 1'b0;
    
    // 将寄存器的低4位直接输出给 LED 物理引脚
    // Tang Nano 4K 的 LED 通常是低电平点亮，这里做了个按位取反
    assign led_out = ~led_reg[3:0];

    // APB 写逻辑：当 Cortex-M3 向外设写数据时触发
    always @(posedge PCLK or negedge PRESETN) begin
        if (!PRESETN) begin
            led_reg <= 32'h00000000; // 复位时全灭
        end else if (PSEL && PENABLE && PWRITE) begin
            // 假设我们只有一个寄存器，忽略 PADDR 地址偏移，直接写入
            led_reg <= PWDATA; 
        end
    end

    // APB 读逻辑：当 Cortex-M3 读取外设状态时触发
    always @(*) begin
        if (PSEL && !PWRITE) begin
            PRDATA = led_reg; // 将寄存器当前值放回读数据总线
        end else begin
            PRDATA = 32'h00000000;
        end
    end

endmodule