#include "gw1ns4c.h"

// 对应 FPGA 内部 APB2 Master 1 的物理基地址
#define MY_LED_BASE  0x40002400
// 定义控制寄存器指针
#define LED_DATA_REG (*(volatile uint32_t *)(MY_LED_BASE))

void Delay(uint32_t count) {
    while(count--) {
        __nop(); // 占用 CPU 周期
    }
}

int main(void) {
    // 1. 初始化系统（必须在 system_gw1ns4c.c 中设置正确频率）
    SystemInit(); 

    while(1) {
        // 2. 向总线写值：触发 Verilog 模块的 PSEL/PWRITE
        LED_DATA_REG = 0x01; // 点亮 LED 0
        Delay(2000000);
        
        LED_DATA_REG = 0x02; // 点亮 LED 1
        Delay(2000000);
        
        LED_DATA_REG = 0x00; // 全灭
        Delay(2000000);
    }
}