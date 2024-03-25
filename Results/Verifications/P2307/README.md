# P2307 选手产出验证

## 验证者

* [李程](https://github.com/shiptux)
* [孙敏](https://github.com/sunmin89)

## 产出要求

1. 能够在 Milk-V Duo 上运行基础的 Zephyr，默认支持中断处理，任务切换，UART 通讯等功能。
2. 支持基础外设驱动主要包括 UART、GPIO、I2C、SPI、ADC、PWM 并编写相应示例。
3. 支持 mailbox 驱动，并编写与大核的通讯示例。
4. （加分项）支持 camera 的使用，推荐 GC2083。
5. （加分项）使用 openamp/rpmsg-lite 和大核进行交互。

## 验证环境特殊说明

SD 卡型号 EAGET 64GB U3 V30
逻辑分析仪使用 nanoDLA

## 当前提交

https://github.com/plctlab/rvspoc-p2307-zephyr/pull/1

https://github.com/plctlab/rvspoc-p2307-zephyr/pull/2

## 验证结果

**同时测试了选手的代码内容和二进制内容，两项有一项通过下表就会填通过。**

PASS: 验证通过
FAILED: 验证失败
NONE: 选手提交中未有此项目

|  PR | PR1 | PR2 |
| -------- | -------- | -------- |
| PR 创建时间     | Feb 25, 2024, 4:57 PM GMT+8 | Feb 27, 2024, 1:20 PM GMT+8|
| 最后更新时间     | Feb 27, 2024, 2:12 PM GMT+8 | Feb 29, 2024, 10:20 PM GMT+8    |
| 中断处理     | PASS     | PASS     |
| 任务切换     | NONE     | PASS     |
| UART     | PASS     | PASS     |
| GPIO     | PASS     | PASS     |
| I2C     | NONE    | PASS    |
| SPI     | NONE     | NONE     |
| ADC     | NONE     | NONE     |
| PWM     | PASS     | NONE     |
| Mailbox     | PASS     |  NONE     |
| camera     | NONE     | NONE     |
| openamp/rpmsg-lite     | NONE     | NONE     |

#### PR1 验证:

#### 验证项目

samples/basic/blinky 通过
涉及：GPIO，SysTick (CLINT 中断)

samples/subsys/shell/shell_module 通过
涉及：UART (interrupt driven)，PLIC 中断，PINMUX

tests/drivers/pwm/pwm_api 通过
涉及：PWM，PINMUX

samples/boards/milkv_duo/mbox 通过
涉及：Mailbox (大小核通讯)

#### 准备 zephyr 环境

初始化环境参考

https://docs.zephyrproject.org/latest/develop/getting_started/index.html#

准备 PR1 的源码

```bash
mkdir pr1
cd pr1
git clone git@github.com:xingrz/zephyr.git --depth 1 -b rvspoc-p2307-zephyr/pr 
mkdir .west
#准备west workspace
cat .west/config
[manifest]
path = zephyr
file = west.yml
```

#### 验证过程


**验证过程中使用 UART1**

![](https://md.oss.ac.cn/uploads/b7c66dbb-1581-4bb5-bc98-26f4ccdf19ee.png)

首先重新烧写 DUO 环境，烧写去掉了 PINMUX 的一个新镜像.

Hello world 用于验证 Board 是否正常:

```bash
#编译
west build -p always -b milkv_duo samples/hello_world
# 将 SD 卡放入读卡器，并挂载 boot 分区
# 使用下面的命令打包并替换 fip.bin
python3 ~/git/github/duo-buildroot-sdk/fsbl/plat/cv180x/fiptool.py     -v genfip "/media/shiptux/boot/fip.bin"     --OLD_FIP="/media/shiptux/boot/fip.bin"     --BLCP_2ND="build/zephyr/zephyr.bin"
```

重新插入 Duo sd 卡槽并上电开机

```bash
*** Booting Zephyr OS build 90d153b26ed5 ***
Hello World! milkv_duo
```

##### samples/basic/blinky

- [x] samples/basic/blinky
涉及：GPIO，SysTick (CLINT 中断)

首先将大核 linux 的 /mnt/system/blink.sh 重命名，此时不 LED 灯将不再默认闪烁。

```bash
#编译
west build -p always -b milkv_duo samples/basic/blinky
# 将 SD 卡放入读卡器，并挂载 boot 分区
# 使用下面的命令打包并替换 fip.bin
python3 ~/git/github/duo-buildroot-sdk/fsbl/plat/cv180x/fiptool.py     -v genfip "/media/shiptux/boot/fip.bin"     --OLD_FIP="/media/shiptux/boot/fip.bin"     --BLCP_2ND="build/zephyr/zephyr.bin"
```

重新插入 DUO sd 卡槽并上电开机，蓝色 LED 灯重新开始闪烁。

##### samples/subsys/shell/shell_module

- [x] samples/subsys/shell/shell_module
涉及：UART (interrupt driven)，PLIC 中断，PINMUX

**正常登入 Shell 并使用 version 命令**

```bash
uart:~$ version
Zephyr version 3.5.99
```

##### tests/drivers/pwm/pwm_api

涉及：PWM，PINMUX

- [x] tests/drivers/pwm/pwm_api

串口可见 PWM 日志，外接 LED 可见周期性闪烁 

![](https://md.oss.ac.cn/uploads/1ff9de15-46c8-4551-afd8-80d8b1099723.png)

通过逻辑分析仪捕获到对应引脚输出 PWM 波形，占空比 50%

![](https://md.oss.ac.cn/uploads/511f4637-06f9-440a-a0a3-98054dd2bade.png)


```bash
*** Booting Zephyr OS build 90d153b26ed5 ***
Running TESTSUITE pwm_basic
===================================================================
START - test_pwm_cycle
[PWM]: 1, [period]: 64000, [pulse]: 32000
[PWM]: 1, [period]: 64000, [pulse]: 64000
[PWM]: 1, [period]: 64000, [pulse]: 0
 PASS - test_pwm_cycle in 3.012 seconds
===================================================================
START - test_pwm_nsec
[PWM]: 1, [period]: 2000000, [pulse]: 1000000
[PWM]: 1, [period]: 2000000, [pulse]: 2000000
[PWM]: 1, [period]: 2000000, [pulse]: 0
 PASS - test_pwm_nsec in 3.013 seconds
===================================================================
TESTSUITE pwm_basic succeeded

------ TESTSUITE SUMMARY START ------

SUITE PASS - 100.00% [pwm_basic]: pass = 2, fail = 0, skip = 0, total = 2 duration = 6.025 seconds
 - PASS - [pwm_basic.test_pwm_cycle] duration = 3.012 seconds
 - PASS - [pwm_basic.test_pwm_nsec] duration = 3.013 seconds
```

##### samples/boards/milkv_duo/mbox

涉及：Mailbox (大小核通讯)

- [x] samples/boards/milkv_duo/mbox

成功通过 Milk-V 官方的 mailbox 用例

大核日志

```bash
[root@milkv-duo]~# ./mailbox_test 
C906B: cmd.param_ptr = 0x4
C906B: cmd.param_ptr = 0x3
```

小核上的日志

```bash
*** Booting Zephyr OS build 90d153b26ed5 ***
cmdq->ip_id =0
cmdq->cmd_id =19
cmdq->param_ptr =2
Ping (on channel 1)
recv cmd(19) from C906B, param_ptTextr [0x2]
recv cmd(19) from C906B...send [0x4] to C906B
cmdq->ip_id =0
cmdq->cmd_id =19
cmdq->param_ptr =3
Ping (on channel 1)
recv cmd(19) from C906B, param_ptr [0x3]
recv cmd(19) from C906B...send [0x4] to C906B
```

### PR 2 验证:

#### 验证项目

- Hello World 
- samples/synchronization 时钟中断与任务切换 通过
- posix/uname UART 终端 通过
- basic/blinky 板载 led 灯 通过
- basic/button  GPIO 中断 通过
- sensor/sht3xd 通过


#### 验证过程

##### 准备zeypher环境

https://docs.zephyrproject.org/latest/develop/getting_started/index.html#

- 准备 PR2的源码

```bash
mkdir pr2
cd pr2
git clone --depth 1 -b milkv-duo-dev git@github.com:Judehahh/rvspoc-p2307-zephyr.git
mkdir .west
#准备west workspace
sunmin@debian:~/data/duo/pr2$ cat .west/config
[manifest]
path = rvspoc-p2307-zephyr
file = west.yml
```

**验证过程中使用 UART1**

![](https://md.oss.ac.cn/uploads/b7c66dbb-1581-4bb5-bc98-26f4ccdf19ee.png)

##### Hello world

- [x] Hello world

```bash
#编译
west build -p always -b milkv_duo_cv1800b samples/hello_world
#打包 fip.bin
cd prebuilt
./fip.sh
# 把 fip.bin 放到 sd 卡 boot 分区
# 连接 UART1
# 上电开机
```

这里是 Hello World 的串口输出

Windows 下:
![](https://md.oss.ac.cn/uploads/69f65091-137c-462d-a8a7-2a571bc920cc.png)

##### samples/synchronization:

- [x] samples/synchronization

thread_a 和 thread_b 反复打印 hello world. 

```bash
*** Booting Zephyr OS build 9102821fbe28 ***
thread_a: Hello World from cpu 0 on milkv_duo_cv1800b!
thread_b: Hello World from cpu 0 on milkv_duo_cv1800b!
```

##### basic/blinky:

- [x] basic/blinky:

关闭大核的灯光控制脚本--通过重命名 /mnt/system/blink.sh. 此时开机，usb c 口附近的 led 灯将不再闪烁。再次刷写源码或者 prebuild/image 中的 fip-blinky.bin 则再次闪烁。

##### posix/uname：

- [x] posix/uname： 

UART 终端，可通过 uname -a 命令查看内核信息。 

**从源码编译的选手提交，能够登录到 uart,但是没有内置基本命令**

![](https://md.oss.ac.cn/uploads/6d18236a-97e7-447e-aa54-c2e98221e627.png)


直接用 PR 里面的 binary 可以使用 uname -r 命令

https://github.com/Judehahh/rvspoc-p2307-zephyr/blob/milkv-duo-dev/prebuilt/images/fip-uname.bin

![](https://md.oss.ac.cn/uploads/5b9dadc6-7513-49f0-b1fb-5a781c3463e6.png)


##### basic/button

通过连接及断开 GP15 与 3V3 来模拟按钮，以验证 GPIO 中断。

prebuild/image 验证
插拔 GP15 和 3v3 之间的线，灯会发生变化。串口有按键的日志。

```bash
*** Booting Zephyr OS build zephyr-v3.5.0-2680-ge3608e5c03ab ***
Set up button at gpio@3020000 pin 15
Set up LED at gpio@3022000 pin 24
Press the button
Button pressed at 142862519
Button pressed at 142924443
Button pressed at 202274428
```

源码构建验证:

插拔 GP15 和 3v3 之间的线，灯会发生变化。串口有按键的日志。

```bash
Button pressed at 193640606
Button pressed at 245745360
Button pressed at 246075753
Button pressed at 246137675
Button pressed at 246202637
Button pressed at 246269707
Button pressed at 246332537
Button pressed at 246397503
Button pressed at 246615031
Button pressed at 246676952
Button pressed at 248069898
Button pressed at 248131815
Button pressed at 248196761
Button pressed at 248261730
Button pressed at 273797372
```


##### sensor/sht3xd

按照这个接线方式，连接 duo 和 sht30，更换 prebuild/image 或者 编译出的部分可以在 UART1 中看到 温湿度信息打印。(SHT30 是一款 I2C 协议的温湿度传感器。)

Duo----------SHT30-D
3V3(OUT)-----VIN
GND----------GND
GP10---------SDA
GP11---------SCL



![](https://md.oss.ac.cn/uploads/3f6944ce-8c68-426f-b429-fb0d391b6801.png)

```bash
SHT3XD: 18.45 Cel ; 54.96 %RH
SHT3XD: 18.45 Cel ; 54.82 %RH
SHT3XD: 18.43 Cel ; 54.67 %RH
SHT3XD: 18.43 Cel ; 54.63 %RH
SHT3XD: 18.43 Cel ; 54.56 %RH
SHT3XD: 18.46 Cel ; 54.51 %RH
SHT3XD: 18.43 Cel ; 54.49 %RH
SHT3XD: 18.45 Cel ; 54.46 %RH
SHT3XD: 18.46 Cel ; 54.44 %RH
```