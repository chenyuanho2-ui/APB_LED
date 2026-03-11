module top (
    input  wire       xtal_clk, // 对应引脚 45
    input  wire       reset_n,  // 对应引脚 15
    output wire [3:0] led       // 对应板载 LED 引脚
);

    // --- 内部总线信号定义 ---
    wire        master_pclk;
    wire        master_prst;
    wire        master_penable;
    wire [7:0]  master_paddr;
    wire        master_pwrite;
    wire [31:0] master_pwdata;
    wire [3:0]  master_pstrb;
    wire [2:0]  master_pprot;
    wire        master_psel1;
    wire [31:0] master_prdata1;
    wire        master_pready1;
    wire        master_pslverr1;

    // --- 1. 例化 Cortex-M3 硬核 (Gowin_EMPU) ---
    Gowin_EMPU_Top your_m3_inst (
        .sys_clk(xtal_clk),               // 外部 27MHz 晶振输入
        .reset_n(reset_n),                // 复位按键
        
        // APB 总线输出信号
        .master_pclk(master_pclk),        // 总线时钟
        .master_prst(master_prst),        // 总线复位
        .master_penable(master_penable),
        .master_paddr(master_paddr),      // [7:0] 位宽
        .master_pwrite(master_pwrite),
        .master_pwdata(master_pwdata),
        .master_pstrb(master_pstrb),
        .master_pprot(master_pprot),
        
        // Master 1 专用接口
        .master_psel1(master_psel1),
        .master_prdata1(master_prdata1),
        .master_pready1(master_pready1),
        .master_pslverr1(master_pslverr1)
    );

    // --- 2. 例化你的自定义 LED 控制器 ---
    apb_led_controller your_led_ctrl_inst (
        .PCLK(master_pclk),               // 使用 EMPU 输出的总线时钟
        .PRESETN(!master_prst),           // 注意：master_prst 通常是高有效，控制器需要低有效
        
        .PADDR({{24{1'b0}}, master_paddr}), // 将 8 位地址补齐到 32 位
        .PSEL(master_psel1),
        .PENABLE(master_penable),
        .PWRITE(master_pwrite),
        .PWDATA(master_pwdata),
        .PRDATA(master_prdata1),
        .PREADY(master_pready1),
        .PSLVERR(master_pslverr1),
        
        .led_out(led)
    );

endmodule