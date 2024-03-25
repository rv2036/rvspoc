# P2308 选手产出验证

## 验证

* [李程](https://github.com/shiptux)
* [孙敏](https://github.com/sunmin89)

## 产出要求

- 能够在 Milk-V Duo 上运行基础的 Xv6，默认支持中断处理，UART 通讯等功能。
- 支持基础外设驱动主要包括 UART、GPIO、I2C、SPI、ADC、PWM 并编写相应示例。
- （加分项）支持 mailbox 驱动，并编写与大核的通讯示例。

## 当前提交
https://github.com/plctlab/rvspoc-p2308-xv6-riscv/pull/1

https://github.com/plctlab/rvspoc-p2308-xv6-riscv/pull/2

https://github.com/plctlab/rvspoc-p2308-xv6-riscv/pull/3

https://github.com/plctlab/rvspoc-p2308-xv6-riscv/pull/4

## 验证结果

Y 通过
Y？ 不确定是否通过,可能依赖于相应硬件
N 不通过/否
NA 无法测试

|  PR | 2 | ~~1~~/3 | 4 |
| -------- | -------- | -------- |-------- |
| 提交时间     | Feb 29,2024,PM 7:11 GMT+8    | Mar 1,2024 AM 9:31 GMT+8  |Mar 1,2024 PM 4:19 GMT+8 |
| 是否提供 sd 镜像    | Y     | ~~Y~~/N |N|
| 中断处理     | Y     | Y     | Y|
| UART     | Y     | Y     |Y |
| GPIO     | Y     | Y     |Y |
| I2C     |   Y   | NA     |Y |
| SPI     |   Y |  Y     |Y |
| ADC     | Y   | N |Y |
| PWM     | Y    |  Y     |Y |
| Mailbox （加分项）    | N     | N |N|
| 备注    |    | PR1 和 PR3 来自同一个小队的提交 ||


~~#### PR1 验证:~~ 合并到 PR3


### PR 2 验证:

![](https://md.oss.ac.cn/uploads/b7c66dbb-1581-4bb5-bc98-26f4ccdf19ee.png)

```bash
$ mkdir P2308
$ git fetch origin pull/2/head:pr2
$ git checkout pr2
$ sudo apt install genimage -y
$ sudo ./sudo ./build_for_milkv_duo.sh
```

烧录后的启动日志。 使用 Debian Sid 自带的编译器和 genimage 工具链:

```bash
FSBL Jb28g9:gf2df47913:2024-02-29T16:35:38+08:00                                
st_on_reason=d0000                                                              
st_off_reason=0                                                                 
P2S/0x1000/0x3bc0da00.                                                          
SD/0xca00/0x1000/0x1000/0.P2E.                                                  
DPS/0xda00/0x2000.                                                              
SD/0xda00/0x2000/0x2000/0.DPE.                                                  
DDR init.                                                                       
ddr_param[0]=0x78075562.                                                        
pkg_type=3                                                                      
D3_1_4                                                                          
DDR2-512M-QFN68                                                                 
Data rate=1333.                                                                 
DDR BIST PASS             根据手册计算，我测出我的当前的                                                      
PLLS.                                                                           
PLLE.                                                                           
C2S/0xfa00/0x83f40000/0x3600.                                                   
 2RET.:00/0x3600/0x3600/0.RSC.                                                  
 [M1S./302x51437010]0P/r0ex 8s0y0s0t0e0m0 0i/n0ixt1 bd0o0n0e.                   
                                                                                
RT: [1.331791]CVIRTOS Build Date:Feb 29 2024  (Time :16:35:37)                  
RT: [1.337794]Post system init done                                             
RT: [1.341109]create cvi task                                                   
RT: [1.343935][cvi_spinlock_init] succeess                                      
RT: [1.347829]prvCmdQuRunTask run                                               
SD/0x13000/0x1b000/0x1b000/0.ME.                                                根据手册计算，我测出我的当前的
L2/0x2e000.                                                                     
SD/0x2e000/0x200/0x200/0.L2/0x414d3342/0xcafebfd8/0x80200000/0x23000/0x23000    
COMP/1.                                                                         
SD/0x2e000/0x23000/0x23000/0.DCP/0x80200020/0x1000000/0x81500020/0x23000/1.     
DCP/0x4a307/0.                                                                  
Loader_2nd loaded.                                                              
Use internal 32k                                                                
Jump to monitor at 0x80000000.                                                  
OPENSBI: next_addr=0x80200020 arg1=0x80080000                                   
OpenSBI v0.9                                                                    
   ____                    _____ ____ _____                                     
  / __ \                  / ____|  _ \_   _|                                    
 | |  | |_ __   ___ _ __ | (___ | |_) || |                                      
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |                                      
 | |__| | |_) |  __/ | | |____) | |_) || |_                                     
  \____/| .__/ \___|_| |_|_____/|____/_____|                                    
        | |                                                            $ ./adc
adc raw: 4095         
        |_|                                                                     
                                                                                
Platform Name             : Milk-V Duo                                          
Platform Features         : mfdeleg                                             
Platform HART Count       : 1                                                   
Platform IPI Device       : clint                                               
Platform Timer Device     : clint                                               
Platform Console Device   : uart8250                                            
Platform HSM Device       : ---                                             根据手册计算，我测出我的当前的    
Platform SysReset Device  : ---                                                 
Firmware Base             : 0x80000000                                          
Firmware Size             : 132 KB                                              
Runtime SBI Version       : 0.3                                                 
                                                                                
Domain0 Name              : root                                                
Domain0 Boot HART         : 0                                                   
Domain0 HARTs             : 0*                                                  
Domain0 Region00          : 0x0000000074000000-0x000000007400ffff (I)           
Domain0 Region01          : 0x0000000080000000-0x000000008003ffff ()            
Domain0 Region02          : 0x0000000000000000-0xffffffffffffffff (R,W,X)       
Domain0 Next Address      : 0x0000000080200020                                  
Domain0 Next Arg1         : 0x0000000080080000                                  
Domain0 Next Mode         : S-mode                                              
Domain0 SysReset          : yes                                                 
                                                                                
Boot HART ID              : 0                                                   
Boot HART Domain          : root                                                
Boot HART ISA             : rv64imafdcvsux                                      
Boot HART Features        : scounteren,mcounteren,time                          
Boot HART PMP Count       : 16                                                  
Boot HART PMP Granularity : 4096                                                
Boot HART PMP Address Bits: 38                                                  
Boot HART MHPM Count      : 8                                                   
Boot HART MHPM Count      : 8                                                   
Boot HART MIDELEG         : 0x0000000000000222                                  
Boot HART MEDELEG         : 0x000000000000b109                                  
                                                                                
                                                                                
U-Boot 2021.10 (Feb 29 2024 - 16:53:07 +0800)cvitek_cv180x                      
                                                                                
DRAM:  63.3 MiB                                                                 
gd->relocaddr=0x83ef8000. offset=0x3cf8000                                      
MMC:   cv-sd@4310000: 0                                                         
Loading Environment from <NULL>... OK                                           
In:    serial                                                                   
Out:   serial                                                                   
Err:   serial                                                                   
Net:                                                                            
Warning: ethernet@4070000 (eth0) using random MAC address - 66:af:79:59:29:5e   
eth0: ethernet@4070000                                                          
Hit any key to stop autoboot:  0                                                
Boot from SD ...                                                                
switch to partitions #0, OK                                                     
mmc0 is current device                                                          
1590733 bytes read in 72 ms (21.1 MiB/s)                                        
## Loading kernel from FIT Image at 81400000 ...                                
   Using 'config-cv1800b_milkv_duo_sd' configuration                            
   Trying 'kernel-1' kernel subimage                                            
   Verifying Hash Integrity ... crc32+ OK                                       
## Loading fdt from FIT Image at 81400000 ...                                   
   Using 'config-cv1800b_milkv_duo_sd' configuration                            
   Trying 'fdt-1' fdt subimage                                                  
   Verifying Hash Integrity ... sha256+ OK                                      
   Booting using the fdt blob at 0x8158315c                                     
   Loading Kernel Image                                                         
   Decompressing 1585152 bytes used 2ms                                         
   Loading Device Tree to 00000000836ac000, end 00000000836aff73 ... OK         
                                                                                
Starting kernel ...                                                             
                                                                                
                                                                                
xv6 kernel is booting                                                           
                                                                                
SBI specification v0.3 detected                                                 
SBI TIME extension detected                                                     
SBI IPI extension detected                                                      
SBI RFNC extension detected                                                     
SBI HSM extension detected                                                      
                                                                                
init: starting sh 
```

- 在 Windows 上烧录 OK

- 在 Linux 烧录 OK

#### GPIO test

```bash
$ ./blink 5 
```

蓝色 led 灯会闪烁 5 此，基于这个 LED 灯本身也是一个 GPIOL 设备。`

#### ADC: 通过

登入 Shell 后 连接 GP26（ADC1）和 3.3v OUT

```bash
$ ./pwm 1000000 900000

$ ./pwm 1000000 600000
```

![](https://md.oss.ac.cn/uploads/cb8e34b3-8cbf-4975-988a-c26fa0020898.png)

![](https://md.oss.ac.cn/uploads/9d3132cb-e550-482d-b878-dc913cd311b7.png)


不同的参数有明显的明暗变化，第二个参数越小，灯亮度越低。逻辑分析仪也能识别出正确的占空比。

#### I2C: 通过

使用和选手相同的芯片，测出环境温度为 

整数位 0x16
小数点后 0xf

转为十进制相加为 22.15 摄氏度

```bash
$ ./i2c 0x57 0xff                 
0x15
$ ./i2c 0x57 0x21 1            
$ ./i2c 0x57 0x1f  
0x16                                             
$  ./i2c 0x57 0x20./script
0xF      
```

此后尝试用逻辑分析仪抓取了 i2c 信息:

```
13847250-13847252 I²C: Bits: 0
13847252-13847254 I²C: Bits: 0
13847254-13847269 I²C: Bits: 0
13847269-13847271 I²C: Bits: 1
13847271-13847273 I²C: Bits: 0
13847273-13847275 I²C: Bits: 0
13847275-13847288 I²C: Bits: 0
13847288-13847301 I²C: Bits: 1
22507343-22507345 I²C: Bits: 1
22507345-22507347 I²C: Bits: 0
22507347-22507362 I²C: Bits: 1
22507362-22507364 I²C: Bits: 0
22507364-22507366 I²C: Bits: 0
22507366-22507368 I²C: Bits: 0
22507368-22507381 I²C: Bits: 0
22507381-22507394 I²C: Bits: 0
24248051-24248053 I²C: Bits: 1
24248053-24248055 I²C: Bits: 1
24248055-24248057 I²C: Bits: 1
24248057-24248070 I²C: Bits: 0
24248070-24248072 I²C: Bits: 0
24248072-24248074 I²C: Bits: 0
24248074-24248076 I²C: Bits: 0
24248076-24248078 I²C: Bits: 0
27065660-27065675 I²C: Bits: 1
27065675-27065677 I²C: Bits: 0
27065677-27065679 I²C: Bits: 0
27065679-27065681 I²C: Bits: 0
27065681-27065696 I²C: Bits: 0
27065696-27065698 I²C: Bits: 0
27065698-27065705 I²C: Bits: 1
27065705-27065712 I²C: Bits: 1
13847250-13847288 I²C: Address/Data: Address read: 08
13847233-13847233 I²C: Address/Data: Start
13847288-13847301 I²C: Address/Data: Read
13847290-13847303 I²C: Address/Data: ACK
13847293-13847293 I²C: Address/Data: Stop
22507341-22507341 I²C: Address/Data: Start
22507343-22507381 I²C: Address/Data: Address write: 50
22507381-22507394 I²C: Address/Data: Write
24248049-24248062 I²C: Address/Data: ACK
24248051-24248078 I²C: Address/Data: Data write: E0
24248081-24248083 I²C: Address/Data: ACK
24248122-24248122 I²C: Address/Data: Stop
27065658-27065658 I²C: Address/Data: Start
27065660-27065705 I²C: Address/Data: Address read: 41
27065705-27065712 I²C: Address/Data: Read
27065707-27065714 I²C: Address/Data: ACK
27065740-27065740 I²C: Address/Data: Stop
```

#### SPI: 通过

在终端下直接运行 ./spi 此时会打印一串 0, 连接 GP7 和 GP8 后，再次 运行 SPI 会打印 0-31 

```bash

RX:
   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 $ ./spi 
```

此时 GP7 可以测得以下信号

![](https://md.oss.ac.cn/uploads/19b4cbf4-7ce2-42c0-94e7-48410545fbcb.png)


```bash
$ ./spi                                                       
RX:
   0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 $
```

### PR3 验证

#### 从源码编译 sd 镜像

- 获取源码

```bash
git fetch origin pull/3/head:pr3
git checkout pr3
```

- 修改工具链

```bash
diff --git a/Makefile b/Makefile
index 526f41e..ccb5621 100644
--- a/Makefile
+++ b/Makefile
@@ -39,7 +39,8 @@ OBJS = \
 
 # riscv64-unknown-elf- or riscv64-linux-gnu-
 # perhaps in /opt/riscv/bin
-#TOOLPREFIX =
+TOOLPREFIX = /home/shiptux/Xuantie-900-gcc-elf-newlib-x86_64-V2.6.1-20220906/Xuantie-900-gcc-elf-newlib-x86_64-V2.6.1/bin/riscv64-unknown-elf-
+
 
 # Try to infer the correct TOOLPREFIX if not set
 ifndef TOOLPREFIX

```

- 调用编译脚本

```bash
sudo make duo
#镜像位于
vendor/milkv-duo/images/ milkv-duo.img
```

- 使用 rufus ， balenaetcher 或者 dd 工具烧录到 sd 卡

#### I2C test
3333333333333333333333333333333333333333333333333333333333333333333333
选手未提供用户测试程序

#### GPIO test

执行 gpiotest 程序，能看到板载蓝色led灯闪烁。

**注意无法通过 ctrl-C 等方式退出**

```bash
$ ./gpiotest
gpio open success! fd:3
```

#### PWM test

执行pwmtest后，通过 PWM5引脚连接 LED 正极，GND 连接 LED 负极。能够看到 LED 的亮度变化，在最后段最明显。

```bash=
pwm H/L:17/83
pwm H/L:16/84
pwm H/L:15/85
pwm H/L:14/86
pwm H/L:13/87
pwm H/L:12/88
pwm H/L:11/89
pwm H/L:10/90
pwm H/L:9/91
pwm H/L:8/92
pwm H/L:7/93
pwm H/L:6/94
pwm H/L:5/95
pwm H/L:4/96
pwm H/L:3/97
pwm H/L:2/98
pwm H/L:1/99
pwm test done!
```

通过逻辑分析仪能看到一个占空比递减的波形

![](https://md.oss.ac.cn/uploads/a4dce456-2cd2-49ef-8591-24563c7db12c.png)


#### SPI test

执行spilcdtest例程，SPI2_SCK、SPI2_TX引脚能看到有SPI信号输出。

能够看到 PWM5 输出 PWM 信号
SPI2_SCK 和 SPI2_TX 输出 SPI 信号

![](https://md.oss.ac.cn/uploads/40635134-3481-4eab-a552-77fc1a4e770d.png)


### PR4 验证

- 源码获取

```bash
$ git fetch origin pull/4/head:pr4
$ git checkout pr4
$ script`
```

- 配置 toolchain 注意脚本里面带了一个 dd 命令
![](https://md.oss.ac.cn/uploads/9d9a0a0a-6204-4d17-a2a2-281812845f86.png)

- 把镜像(~10MB)拷贝到 windows上，用 rufus 烧录
```bash
scp sunmin@192.168.0.200:/home/sunmin/data/duo/xv6/pr4/rvspoc-p2308-xv6-riscv/port/image/output/milkv-duo.img xv6-pr4.img
```
![](https://md.oss.ac.cn/uploads/8256ce01-7268-40ad-b074-8e464019f0cb.png)

- i2c 

```bash
$ ./i2ctest                                                                     
open i2c-1 success                                                              
set slave address to 0x68 success!                                              
ACCE_X: 8224                                                                    
ACCE_Y: 8224                                                                    
ACCE_Z: 8224                                                                    
GYRO_X: 8224                                                                    
GYRO_Y: 8224                                                                    
GYRO_Z: 8224                                                                    
                                                                                
ACCE_X: 8224                                                                    
ACCE_Y: 8224  
```

- UART OK

首先在 UART4 具体参考 DUO 引脚图连接 USB 转 TTL 设备，之后在 uart0 中的 console 输入 ./uarttest 10 开始 uart 测试。
此时能够在 UART4 收到信息。

此处 uart4 使用 picocom uart0 使用 minicom

```bash
Terminal ready
uart 4 test
```

- ADC OK

理论上 3.3 输入 ADC 和 无输入应该有两个不同的读数:

实际效果:

```bash
接入 vcc 下测试
./adctest
         adc result: 4095
空置测试
./adctest
         adc result: 18
```

- pwm OK

SOC 提供了 4 个 pwm controller，开发板从 controller 1 和 2 引出引脚。

驱动支持每次控制任意 1 个 controller 的任意 1 个 channel，ioctl 配置并使能 channel。

为了演示方便，测试示例只驱动 pwm5（pwm 1 的 channel 1）。

测试示例需要连接 DF9GMS 180 微型舵机，可以对 pwm5 设置不同的 duty，使舵机的舵进行不同角度旋转。

串口日志

```bash
$ ./pwmtest                                                                     
open pwm success!                                                               
duty: 60000                                                                     
duty: 70000                                                                     
duty: 80000                                                                     
duty: 90000                                                                     
duty: 100000                                                                    
duty: 110000                                                                    
duty: 120000                                                                    
duty: 130000                                                                    
duty: 140000                                                                    
duty: 150000                                                                    
duty: 160000                                                                    
duty: 170000                                                                    
duty: 180000                                                                    
duty: 190000                                                                    
duty: 200000                                                                    
duty: 210000                                                                    
duty: 220000                                                                    
duty: 230000                                                                    
duty: 240000                                                                    
duty: 250000 
```

变化的占空比

![](https://md.oss.ac.cn/uploads/aed0918a-8909-452e-8719-1bd0a2aeebf0.png)

![](https://md.oss.ac.cn/uploads/41008db0-fcc9-467c-9e39-ea170ba5f7cd.png)


**连接 MG90S，PWM5 连接舵机信号线，运行 pwmtest 程序可以见到舵机以不同角度旋转，最后回到原点。（DF9GS 太贵买不起，仓库里找到了一个吃灰的 MG90S**

- gpio OK

SOC 提供了 4 个 gpio controller，开发板从 4 个 controller 都有引出 gpio 引脚。

驱动支持每次控制任意 1 个 controller 的任意 1 个 channel，ioctl 配置为输入或输出，并 read 或 write 值。

为了演示方便，测试示例只驱动开发板上的 GP0（gpio 0 的 channel 28）和 GP25（gpio 2 的 channel 24）。

测试示例会先使开发板的蓝色 led 进行闪烁，然后读取 10 次 GP0 处的输入。GP0 的原始输入是 1，接地后输入为 0。

测试日志

```bash
./gpiotest
open gpio-2 success!
start flashing led
open gpio-0 success!
please change input at GP0
input: 1
input: 1
input: 1
input: 0
input: 0
```


- spi OK

SOC 提供了 4 个 spi controller，开发板从 controller 2 引出引脚。

驱动支持每次控制任意 1 个 controller，ioctl 配置模式与频率，并启动读写。

为了演示方便，测试示例只驱动 spi 2。

测试示例为 spi 回环测试，需要短接 spi 2 的两个数据引脚。发出的数据会一摸一样得被接收到。

```bash
 $ ./spitest
tx_buffer: testing spi right now...        rx_buffer: testing spi right now...
```

![](https://md.oss.ac.cn/uploads/b7c66dbb-1581-4bb5-bc98-26f4ccdf19ee.png)    

