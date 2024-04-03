# S2310 选手产出验证 

NCNN 选手提交验证 

## 验证:

* [李程](https://github.com/shiptux)
* [孙敏](https://github.com/sunmin89)

## 产出要求

产出及评分要求：
回归测试不引入新的 failure。
使用 RVV0.7、TPU 或者 Duo 上其它可用计算部件进行加速。
尽可能多的正确的跑起来 benchmark 目录下的模型，并记录运行时间。



## 当前提交

- https://github.com/plctlab/rvspoc-s2310-ncnn/pull/1
- https://github.com/plctlab/rvspoc-s2310-ncnn/pull/2

PASS: 验证通过
FAILED: 验证失败
NONE: 选手提交中未有此项目

| PR       | PR1      | PR2      |
| -------- | -------- | -------- |
| 创建时间     | 2024-02-28T04:10:42Z     | 2024-02-28T08:54:56Z     |
| 最后更新    | 2024-02-27T15:24:24Z     | 2024-02-28T09:00:44Z      |
| 回归测试无 failure     | FAILED     | FAILED(开启 SWAP 则 PASS)    |
| RVV0.7    | PASS    | PASS    |
| TPU     | NONE     | NONE    |
| 是否优化后有原有不通过的可以运行     | NONE     | NONE （开启 SWAP 则 PASS）         |

**PR1: 对比未经任何优化的数据缺少以下（是否开启 SWAP 不影响此项目）:**

```bash
--- /tmp/reference.list 2024-03-12 21:17:51.018384421 +0800
+++ /tmp/pr1.list       2024-03-12 21:18:41.478384011 +0800
@@ -12,10 +12,7 @@
 efficientnetv2_b0
 regnety_400m
 blazeface
-googlenet_int8
-resnet18_int8
 mobilenet_ssd
-mobilenet_ssd_int8
 mobilenetv2_yolov3
 nanodet_m
 yolo-fastest-1.1
```

**PR2: 不开启 SWAP 情况下对比未经任何优化的数据缺少以下:** 
**开启 SWAP 则此项通过**

```bash
--- /tmp/reference.list 2024-03-12 21:17:51.018384421 +0800
+++ /tmp/pr2.list       2024-03-12 23:06:48.898331216 +0800
@@ -16,8 +16,8 @@
 resnet18_int8
 mobilenet_ssd
 mobilenet_ssd_int8
-mobilenetv2_yolov3
 nanodet_m
 yolo-fastest-1.1
 yolo-fastestv2
 FastestDet
```


## 验证环境

Milk-v Duo 64M 版本
无 SWAP
不进行 CPU 超频
统一无额外散热

```bash
[root@milkv-duo]~# free -h
              total        used        free      shared  buff/cache   available
Mem:          55.3M       14.1M       32.2M       80.0K        9.0M       37.4M
Swap:             0           0           0

[root@milkv-duo]~# mount -t debugfs none /sys/kernel/debug
mount: mounting none on /sys/kernel/debug failed: Resource busy
[root@milkv-duo]~# cat /sys/kernel/debug/clk/clk_summary | grep c906_0
       clk_c906_0                     1        1        0   850000000          0     0  50000
```

## 参考数据

备注: 
- **删除了在验证环境中无法运行通过的模型**
- **未使用 SWAP**

```bash
[root@milkv-duo]~/benchmark# ./benchncnn 1 1 0 -1 0
syscall error -1
loop_count = 1
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 0
          squeezenet  min =  278.40  max =  278.40  avg =  278.40
     squeezenet_int8  min = 10022.07  max = 10022.07  avg = 10022.07
           mobilenet  min =  413.21  max =  413.21  avg =  413.21
      mobilenet_int8  min = 15439.51  max = 15439.51  avg = 15439.51
        mobilenet_v2  min =  317.38  max =  317.38  avg =  317.38
        mobilenet_v3  min =  255.47  max =  255.47  avg =  255.47
          shufflenet  min =  467.04  max =  467.04  avg =  467.04
       shufflenet_v2  min =  297.71  max =  297.71  avg =  297.71
             mnasnet  min =  315.45  max =  315.45  avg =  315.45
     proxylessnasnet  min =  366.20  max =  366.20  avg =  366.20
     efficientnet_b0  min =  439.45  max =  439.45  avg =  439.45
   efficientnetv2_b0  min =  618.68  max =  618.68  avg =  618.68
        regnety_400m  min =  445.80  max =  445.80  avg =  445.80
           blazeface  min =  151.79  max =  151.79  avg =  151.79
      googlenet_int8  min = 22358.78  max = 22358.78  avg = 22358.78
       resnet18_int8  min = 23054.94  max = 23054.94  avg = 23054.94
       mobilenet_ssd  min =  939.62  max =  939.62  avg =  939.62
  mobilenet_ssd_int8  min = 49881.95  max = 49881.95  avg = 49881.95
  mobilenetv2_yolov3  min = 1098.70  max = 1098.70  avg = 1098.70
           nanodet_m  min =  687.58  max =  687.58  avg =  687.58
    yolo-fastest-1.1  min =  392.46  max =  392.46  avg =  392.46
      yolo-fastestv2  min =  234.64  max =  234.64  avg =  234.64
          FastestDet  min =  248.45  max =  248.45  avg =  248.45
```

## 测试过程

```bash
[root@milkv-duo]~# free -h
              total        used        free      shared  buff/cache   available
Mem:          55.3M       13.8M       21.7M       80.0K       19.9M       37.7M
Swap:             0           0           0
```

刷写 55.3 M 的 milkv-duo  镜像

```bash
[root@milkv-duo]~# free -h
              total        used        free      shared  buff/cache   available
Mem:          55.3M       13.8M       21.7M       80.0K       19.9M       37.7M
Swap:             0           0           0
```

### PR1 测试过程:

```bash
$ mkdir PR1
$ git clone git@github.com:plctlab/rvspoc-s2310-ncnn.git
$ cd rvspoc-s2310-ncnn
$ git fetch origin pull/1/head:pr1
$ git checkout pr1
$ mkdir build && cd build
$ vim ../toolchains/c906-v240.toolchain.cmake
+set(CMAKE_C_COMPILER "${RISCV_ROOT_PATH}/bin/riscv64-unknown-linux-musl-gcc")
+set(CMAKE_CXX_COMPILER "${RISCV_ROOT_PATH}/bin/riscv64-unknown-linux-musl-g++")
$ cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/c906-v240.toolchain.cmake -DCMAKE_BUILD_TYPE=release -DNCNN_OPENMP=OFF -DNCNN_THREADS=OFF -DNCNN_RUNTIME_CPU=OFF -DNCNN_RVV=ON -DNCNN_SIMPLEOCV=ON -DNCNN_BUILD_EXAMPLES=OFF -DNCNN_BUILD_TESTS=OFF -DNCNN_BENCHMARK=OFF  ..
$ cmake --build .
$ cp benchmark/benchncnn ../benchmark/
$ scp -r -O ../benchmark root@192.168.42.1:

```


### PR1 测试结果


```bash
[root@milkv-duo]~/benchmark-PR1# ./benchncnn 4 1 0 -1 1
syscall error -1
loop_count = 4
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 1
          squeezenet  min =  273.85  max =  283.38  avg =  280.66
     squeezenet_int8  min =  947.34  max =  960.44  avg =  955.34
           mobilenet  min =  411.55  max =  418.63  avg =  416.43
      mobilenet_int8  min = 1442.45  max = 1469.55  avg = 1452.38
        mobilenet_v2  min =  315.15  max =  323.82  avg =  319.46
        mobilenet_v3  min =  255.07  max =  265.44  avg =  260.04
          shufflenet  min =  466.01  max =  478.57  avg =  473.11
       shufflenet_v2  min =  295.06  max =  304.71  avg =  299.83
             mnasnet  min =  313.24  max =  323.19  avg =  320.46
     proxylessnasnet  min =  365.82  max =  374.71  avg =  372.20
     efficientnet_b0  min =  441.74  max =  447.47  avg =  445.48
   efficientnetv2_b0  min =  625.27  max =  634.00  avg =  627.76
        regnety_400m  min =  447.17  max =  456.86  avg =  454.11
           blazeface  min =  151.67  max =  161.80  avg =  154.45
       mobilenet_ssd  min =  941.67  max =  999.45  avg =  969.37
  mobilenetv2_yolov3  min = 1099.68  max = 1111.64  avg = 1103.85
           nanodet_m  min =  694.12  max =  705.20  avg =  699.98
    yolo-fastest-1.1  min =  391.83  max =  401.47  avg =  398.28
      yolo-fastestv2  min =  232.54  max =  246.13  avg =  238.64
          FastestDet  min =  241.89  max =  252.62  avg =  246.98
```

- PR1 交叉验证结果

```
[root@milkv-duo]~/pr1# ./benchncnn 1 1 0 -1 0
syscall error -1
loop_count = 1
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 0
          squeezenet  min =  273.79  max =  273.79  avg =  273.79
     squeezenet_int8  min =  986.31  max =  986.31  avg =  986.31
           mobilenet  min =  412.75  max =  412.75  avg =  412.75
      mobilenet_int8  min = 1494.34  max = 1494.34  avg = 1494.34
        mobilenet_v2  min =  317.82  max =  317.82  avg =  317.82
        mobilenet_v3  min =  256.46  max =  256.46  avg =  256.46
          shufflenet  min =  467.84  max =  467.84  avg =  467.84
       shufflenet_v2  min =  296.52  max =  296.52  avg =  296.52
             mnasnet  min =  314.86  max =  314.86  avg =  314.86
     proxylessnasnet  min =  382.68  max =  382.68  avg =  382.68
     efficientnet_b0  min =  530.39  max =  530.39  avg =  530.39
   efficientnetv2_b0  min =  619.97  max =  619.97  avg =  619.97
        regnety_400m  min =  479.56  max =  479.56  avg =  479.56
           blazeface  min =  159.89  max =  159.89  avg =  159.89
       mobilenet_ssd  min =  955.87  max =  955.87  avg =  955.87
  mobilenetv2_yolov3  min = 1091.97  max = 1091.97  avg = 1091.97
           nanodet_m  min =  727.14  max =  727.14  avg =  727.14
    yolo-fastest-1.1  min =  395.32  max =  395.32  avg =  395.32
      yolo-fastestv2  min =  235.44  max =  235.44  avg =  235.44
          FastestDet  min =  242.64  max =  242.64  avg =  242.64
```

PR1 开启 256M SWAP 的测试结果 (和 PR2 对照)

```bash
[root@milkv-duo]~/benchmark# ./benchncnn 4 1 0 -1 1
syscall error -1
loop_count = 4
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 1
          squeezenet  min =  273.83  max =  284.72  avg =  278.86
     squeezenet_int8  min =  955.24  max =  959.32  avg =  957.51
           mobilenet  min =  417.96  max =  419.56  avg =  418.78
      mobilenet_int8  min = 1441.15  max = 1443.78  avg = 1442.21
        mobilenet_v2  min =  315.44  max =  323.83  avg =  319.86
        mobilenet_v3  min =  255.67  max =  264.42  avg =  259.97
          shufflenet  min =  465.57  max =  474.16  avg =  471.88
       shufflenet_v2  min =  296.89  max =  304.38  avg =  300.39
             mnasnet  min =  313.95  max =  323.97  avg =  321.11
     proxylessnasnet  min =  366.19  max =  375.35  avg =  372.78
     efficientnet_b0  min =  438.52  max =  448.55  avg =  445.14
   efficientnetv2_b0  min =  625.44  max =  634.50  avg =  628.33
        regnety_400m  min =  445.70  max =  456.76  avg =  453.00
           blazeface  min =  151.72  max =  160.47  avg =  154.16
       mobilenet_ssd  min =  939.92  max =  984.90  avg =  951.35
  mobilenetv2_yolov3  min = 1100.38  max = 1110.35  avg = 1103.64
           nanodet_m  min =  693.31  max =  703.68  avg =  698.56
    yolo-fastest-1.1  min =  391.26  max =  400.06  avg =  397.81
      yolo-fastestv2  min =  232.25  max =  242.63  avg =  237.85
          FastestDet  min =  241.09  max =  250.78  avg =  246.04
```

备注: **以下是提升频率版本，不作为本次参赛结果。**

```bash
[root@milkv-duo]~/benchmark-pr1# cat /sys/kernel/debug/clk/clk_summary | grep c906_0
       clk_c906_0                     1        1        0  1050000000          0     0  50000

[root@milkv-duo]~/benchmark-pr1# ./benchncnn 4 1 0 -1 1
syscall error -1
loop_count = 4
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 1
          squeezenet  min =  235.92  max =  243.61  avg =  239.74
     squeezenet_int8  min =  809.23  max =  894.42  avg =  848.99
           mobilenet  min =  343.78  max =  438.38  avg =  371.40
      mobilenet_int8  min = 1185.08  max = 1300.01  avg = 1221.19
        mobilenet_v2  min =  270.38  max =  278.94  avg =  274.88
        mobilenet_v3  min =  217.83  max =  227.81  avg =  220.41
          shufflenet  min =  401.62  max =  407.94  avg =  405.25
       shufflenet_v2  min =  252.26  max =  261.04  avg =  256.64
             mnasnet  min =  266.84  max =  275.71  avg =  271.47
     proxylessnasnet  min =  310.40  max =  319.90  avg =  316.96
     efficientnet_b0  min =  370.73  max =  379.83  avg =  377.01
   efficientnetv2_b0  min =  534.68  max =  537.25  avg =  536.02
        regnety_400m  min =  388.93  max =  398.48  avg =  395.24
           blazeface  min =  139.52  max =  147.42  avg =  141.72
       mobilenet_ssd  min =  783.33  max =  811.01  avg =  796.68
  mobilenetv2_yolov3  min =  927.90  max =  936.83  avg =  934.04
           nanodet_m  min =  592.94  max =  603.52  avg =  596.77
    yolo-fastest-1.1  min =  333.78  max =  342.88  avg =  340.24
      yolo-fastestv2  min =  204.11  max =  213.89  avg =  208.60
          FastestDet  min =  211.02  max =  218.66  avg =  213.12
```

### PR2 测试过程:

```bash
$ mkdir PR2
$ git clone git@github.com:plctlab/rvspoc-s2310-ncnn.git
$ cd rvspoc-s2310-ncnn/
$ git fetch origin pull/2/head:pr2
$ git checkout pr2
$ mkdir build && cd build
$ cp ../toolchains/c906-v240.toolchain.cmake ../toolchains/c906-v240-musl.toolchain.cmake
$ vim ../toolchains/c906-v240-musl.toolchain.cmake
+set(CMAKE_C_COMPILER "${RISCV_ROOT_PATH}/bin/riscv64-unknown-linux-musl-gcc")
+set(CMAKE_CXX_COMPILER "${RISCV_ROOT_PATH}/bin/riscv64-unknown-linux-musl-g++")
$ cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/c906-v240-musl.toolchain.cmake -DCMAKE_BUILD_TYPE=release -DNCNN_BENCHMARK=OFF -DNCNN_OPENMP=OFF -DNCNN_THREADS=OFF -DNCNN_RUNTIME_CPU=OFF -DNCNN_RVV=ON -DNCNN_SIMPLEOCV=ON -DNCNN_BUILD_EXAMPLES=ON -DNCNN_BUILD_TESTS=OFF ..
$ make -j 16
$ cp benchmark/benchncnn ../benchmark/benchncnn
$ scp -r -O ../benchmark root@192.168.42.1:
```

### PR2 测试结果:

#### PR2 未开启 SWAP 情况下: 

**无法完整运行 PR 中宣称的 squeezenet_ssd_int8模型以及不能运行 mobilenetv2_yolov3。（偷偷测了 master 分支是可以的，但是 master 分支有比赛结束后的提交不能采用.）**

```bash
[root@milkv-duo]~/benchmark-PR2# ./benchncnn 4 1 0 -1 1
loop_count = 4
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 1
          squeezenet  min =  225.23  max =  232.55  avg =  227.92
     squeezenet_int8  min =  545.96  max =  558.20  avg =  551.83
           mobilenet  min =  336.71  max =  346.98  avg =  341.48
      mobilenet_int8  min =  923.75  max =  931.03  avg =  928.78
        mobilenet_v2  min =  234.56  max =  246.16  avg =  239.98
        mobilenet_v3  min =  207.59  max =  216.46  avg =  209.97
          shufflenet  min =  165.20  max =  174.23  avg =  167.67
       shufflenet_v2  min =  157.75  max =  168.15  avg =  162.84
             mnasnet  min =  255.76  max =  265.65  avg =  260.74
     proxylessnasnet  min =  299.50  max =  309.64  avg =  304.35
     efficientnet_b0  min =  368.08  max =  376.62  avg =  374.18
   efficientnetv2_b0  min =  510.19  max =  512.13  avg =  511.09
        regnety_400m  min =  344.57  max =  353.10  avg =  350.65
           blazeface  min =  119.08  max =  128.86  avg =  121.91
      googlenet_int8  min = 2798.06  max = 2811.32  avg = 2804.61
       resnet18_int8  min = 2829.30  max = 2848.24  avg = 2839.05
Killed
```

- 交叉验证结果
```
[root@milkv-duo]~/pr2# ./benchncnn 1 1 0 -1 0
loop_count = 1
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 0
          squeezenet  min =  232.82  max =  232.82  avg =  232.82
     squeezenet_int8  min =  541.17  max =  541.17  avg =  541.17
           mobilenet  min =  337.81  max =  337.81  avg =  337.81
      mobilenet_int8  min =  893.10  max =  893.10  avg =  893.10
        mobilenet_v2  min =  232.87  max =  232.87  avg =  232.87
        mobilenet_v3  min =  211.80  max =  211.80  avg =  211.80
          shufflenet  min =  174.39  max =  174.39  avg =  174.39
       shufflenet_v2  min =  167.92  max =  167.92  avg =  167.92
             mnasnet  min =  269.91  max =  269.91  avg =  269.91
     proxylessnasnet  min =  316.08  max =  316.08  avg =  316.08
     efficientnet_b0  min =  369.63  max =  369.63  avg =  369.63
   efficientnetv2_b0  min =  502.99  max =  502.99  avg =  502.99
        regnety_400m  min =  346.72  max =  346.72  avg =  346.72
           blazeface  min =  122.14  max =  122.14  avg =  122.14
      googlenet_int8  min = 2772.25  max = 2772.25  avg = 2772.25
       resnet18_int8  min = 2812.46  max = 2812.46  avg = 2812.46
 squeezenet_ssd_int8  min = 3640.85  max = 3640.85  avg = 3640.85
       mobilenet_ssd  min =  838.68  max =  838.68  avg =  838.68
  mobilenet_ssd_int8  min = 2070.02  max = 2070.02  avg = 2070.02
  mobilenetv2_yolov3  min = 1012.02  max = 1012.02  avg = 1012.02
           nanodet_m  min =  400.46  max =  400.46  avg =  400.46
    yolo-fastest-1.1  min =  186.61  max =  186.61  avg =  186.61
      yolo-fastestv2  min =  168.96  max =  168.96  avg =  168.96
          FastestDet  min =  176.89  max =  176.89  avg =  176.89
```

##### PR2 临时删除 mobilenetv2_yolov3 和 squeezenet_ssd_int8 的测试 结果:

```bash
[root@milkv-duo]~/benchmark-PR2# ./benchncnn 4 1 0 -1 1
loop_count = 4
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 1
          squeezenet  min =  225.33  max =  233.98  avg =  229.93
     squeezenet_int8  min =  547.42  max =  557.40  avg =  553.88
           mobilenet  min =  336.39  max =  347.00  avg =  343.13
      mobilenet_int8  min =  923.16  max =  931.43  avg =  928.77
        mobilenet_v2  min =  235.58  max =  244.32  avg =  237.94
        mobilenet_v3  min =  206.68  max =  217.55  avg =  211.75
          shufflenet  min =  165.44  max =  174.52  avg =  167.88
       shufflenet_v2  min =  157.18  max =  166.94  avg =  160.15
             mnasnet  min =  256.03  max =  266.57  avg =  261.32
     proxylessnasnet  min =  300.74  max =  309.77  avg =  305.76
     efficientnet_b0  min =  366.82  max =  376.54  avg =  373.56
   efficientnetv2_b0  min =  509.28  max =  512.86  avg =  511.43
        regnety_400m  min =  344.84  max =  354.90  avg =  352.17
           blazeface  min =  119.01  max =  128.45  avg =  121.78
      googlenet_int8  min = 2800.76  max = 2809.55  avg = 2804.85
       resnet18_int8  min = 2833.07  max = 2843.04  avg = 2837.62
fopen squeezenet_ssd_int8.param failed
network graph not ready
 squeezenet_ssd_int8  min =    0.02  max =    0.02  avg =    0.02
       mobilenet_ssd  min =  787.84  max =  798.55  avg =  794.69
  mobilenet_ssd_int8  min = 1973.08  max = 1982.78  avg = 1976.84
fopen mobilenetv2_yolov3.param failed
network graph not ready
  mobilenetv2_yolov3  min =    0.02  max =    0.02  avg =    0.02
           nanodet_m  min =  389.49  max =  398.26  avg =  395.40
    yolo-fastest-1.1  min =  184.05  max =  194.42  avg =  186.96
      yolo-fastestv2  min =  159.69  max =  170.00  avg =  163.46
          FastestDet  min =  162.86  max =  171.33  avg =  167.25
```

##### PR2 Master 分支的结果

```bash
[root@milkv-duo]~/pr2-benchmark# ./benchncnn 4 1 0 -1 1
loop_count = 4
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 1
          squeezenet  min =  224.29  max =  230.82  avg =  227.17
     squeezenet_int8  min =  539.61  max =  553.39  avg =  546.80
           mobilenet  min =  336.59  max =  341.72  avg =  338.66
      mobilenet_int8  min =  914.54  max =  918.60  avg =  917.04
        mobilenet_v2  min =  233.99  max =  239.54  avg =  236.83
        mobilenet_v3  min =  207.40  max =  209.86  avg =  208.23
          shufflenet  min =  165.46  max =  168.88  avg =  166.96
       shufflenet_v2  min =  156.93  max =  160.57  avg =  158.51
             mnasnet  min =  256.24  max =  259.11  avg =  257.22
     proxylessnasnet  min =  299.46  max =  302.56  avg =  301.37
     efficientnet_b0  min =  365.95  max =  368.40  avg =  367.48
   efficientnetv2_b0  min =  504.08  max =  507.46  avg =  505.11
        regnety_400m  min =  343.63  max =  347.76  avg =  345.89
           blazeface  min =  119.51  max =  122.18  avg =  120.30
      googlenet_int8  min = 2769.98  max = 2773.24  avg = 2771.59
       resnet18_int8  min = 2801.82  max = 2807.66  avg = 2804.71
 squeezenet_ssd_int8  min = 3501.53  max = 3547.48  avg = 3519.85
       mobilenet_ssd  min =  777.87  max =  788.81  avg =  781.38
  mobilenet_ssd_int8  min = 1986.25  max = 1994.66  avg = 1990.86
  mobilenetv2_yolov3  min =  835.46  max =  896.37  avg =  875.85
           nanodet_m  min =  391.80  max =  395.68  avg =  393.88
    yolo-fastest-1.1  min =  184.02  max =  187.97  avg =  185.03
      yolo-fastestv2  min =  157.59  max =  161.17  avg =  159.17
          FastestDet  min =  164.67  max =  166.42  avg =  165.84
```

#### PR2 开启 256M SWAP 的测试结果

```bash
[root@milkv-duo]~/benchmark-PR2# ./benchncnn 4 1 0 -1 1
loop_count = 4
num_threads = 1
powersave = 0
gpu_device = -1
cooling_down = 1
          squeezenet  min =  224.73  max =  233.52  avg =  227.30
     squeezenet_int8  min =  547.28  max =  557.33  avg =  552.17
           mobilenet  min =  337.14  max =  347.72  avg =  344.63
      mobilenet_int8  min =  929.60  max =  931.77  avg =  930.80
        mobilenet_v2  min =  235.26  max =  246.10  avg =  240.34
        mobilenet_v3  min =  207.16  max =  216.20  avg =  209.85
          shufflenet  min =  165.06  max =  172.03  avg =  168.06
       shufflenet_v2  min =  157.21  max =  167.47  avg =  160.38
             mnasnet  min =  255.33  max =  264.88  avg =  260.33
     proxylessnasnet  min =  301.35  max =  311.99  avg =  305.94
     efficientnet_b0  min =  367.03  max =  376.65  avg =  374.07
   efficientnetv2_b0  min =  509.26  max =  513.18  avg =  511.10
        regnety_400m  min =  345.74  max =  354.48  avg =  351.83
           blazeface  min =  119.32  max =  128.67  avg =  121.86
      googlenet_int8  min = 2803.00  max = 2810.07  avg = 2807.72
       resnet18_int8  min = 2833.28  max = 2847.11  avg = 2839.94
 squeezenet_ssd_int8  min = 3552.37  max = 4313.61  avg = 3908.55
       mobilenet_ssd  min =  782.61  max =  799.10  avg =  793.56
  mobilenet_ssd_int8  min = 2013.93  max = 2022.96  avg = 2019.20
  mobilenetv2_yolov3  min =  828.71  max =  839.82  avg =  835.66
           nanodet_m  min =  394.89  max =  403.29  avg =  400.35
    yolo-fastest-1.1  min =  184.94  max =  251.24  avg =  203.58
      yolo-fastestv2  min =  158.12  max =  168.22  avg =  163.17
          FastestDet  min =  165.38  max =  173.91  avg =  167.54
```