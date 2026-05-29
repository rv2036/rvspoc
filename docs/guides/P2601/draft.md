讲解 rvspoc.org 赛事中的 P2601 (rvspoc-P2601-kleidicv) 题目，核心在于如何在 RISC-V 架构下，利用类似 KleidiCV（或面向 RISC-V 的计算机视觉/SIMD 优化库）的思想或 HAL（硬件抽象层）接口，实现对图像处理/计算机视觉核心算子的加速 porting 与优化。为了向学生、团队成员或评委清晰、直观地讲解这套题目，建议采用“理论背景 $\rightarrow$ 算子剖析 $\rightarrow$ 演示准备 $\rightarrow$ 现场编译与运行演示”的闭环逻辑。以下是为您量身定制的讲解方案与具体的演示设计：

🛠️ 第一部分：题目背景与核心考点讲解在开始演示前，先用 3 分钟说清楚这道题在考什么。赛题定位（P2601）：对象：通常是计算机视觉中的某个基础高频算子（如：Resize 缩放、Gaussian Blur 高斯滤波、Sobel 边缘检测、颜色空间转换等）。

核心任务：将针对传统架构优化的 KleidiCV 算子或 OpenCV HAL 接口，移植（Porting）到 RISC-V 架构上，并利用 RVV (RISC-V Vector Extension) 进行硬件级向量化加速。

讲解切入点：Baseline（基准）：原生的纯 C++ 标量实现，循环嵌套，逐像素处理，无法发挥多核和向量流水线优势。
Optimization（优化目标）：通过分析数据依赖，利用 RVV 寄存器（如 v0-v31）和长向量指令（如 vle8.v, vadd.vv），实现单指令多数据（SIMD）的并行吞吐。

💻 第二部分：具体编译与运行演示设计绘制软件栈图：应用层(OpenCV) -> 算子库(KleidiCV/HAL) -> 硬件指令(RVV) -> 物理芯片。
# 1. 环境准备演示 (Environment Setup)
首先向受众展示你的交叉编译环境，确保环境透明。Bash# 1. 检查 RISC-V 交叉编译器（以 GCC 为例，需支持 RVV 1.0）
riscv64-unknown-linux-gnu-gcc -v

# 2. 确认目标开发板/模拟器环境
（如 Spacemit K1、进红 2036 节点或 QEMU 模拟器）
## 如果是在本地 QEMU 仿真：
qemu-riscv64 -version
2. 源码结构与“优化前 vs 优化后”对比讲解在代码编辑器（如 VS Code）中分屏对比：左边（Scalar C++）：C++// 举例：普通的图像变亮/像素相加算子
for (int i = 0; i < width * height; ++i) {
    dst[i] = std::min(255, src[i] + val);
}
右边（RVV 内联函数/汇编优化）：C++// 引入 RISC-V Vector 内联函数
size_t vl;
for (size_t vl; i < num_pixels; i += vl) {
    vl = __riscv_vsetvl_e8m8(num_pixels - i);
    vuint8m8_t v_src = __riscv_vle8_v_u8m8(&src[i], vl);
    vuint8m8_t v_dst = __riscv_vsadd_vx_u8m8(v_src, val, vl); // 饱和相加
    __riscv_vse8_v_u8m8(&dst[i], v_dst, vl);
}
讲解要点：指出 RVV 的 vsetvl 动态配置元素宽度的特性，强调其如何优雅地处理图像边缘非对齐（Tail pixels）的尾部数据。
3. 编译流程演示 (Compilation Process)现场执行编译，重点解释编译选项，这是体现工程能力的关键。
Bash# 创建编译目录
mkdir -p build && cd build

# 执行 CMake，重点突出开启了 RVV 优化和交叉编译链
cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=../cmake/riscv64-toolchain.cmake \
  -DENABLE_RVV=ON \
  -DCMAKE_BUILD_TYPE=Release

# 编译并输出详细构建日志
make -j$(nprocs) VERBOSE=1
现场讲解：向受众指出输出日志中的 -march=rv64gcv 参数。“-march=rv64gcv 中的 v 字，就是激活 RISC-V 向量扩展、允许编译器识别并生成向量指令的关键。”

4. 运行与性能数据演示 (Execution & Benchmark)将编译好的可执行文件推送到 RISC-V 板端（或通过 QEMU）运行。
Bash# 将程序传送到目标 RISC-V 开发板
scp ./bin/rvspoc_p2601_benchmark root@riscv-board:/root/

# 在板端运行性能测试
ssh root@riscv-board "./rvspoc_p2601_benchmark"
演示输出效果设计（终端打印）：Plaintext===========================================================
[RVSPOC P2601] KleidiCV-style Operator Benchmark on RISC-V
===========================================================
Image Size  : 1920 x 1080 (1080p, 8-bit Gray)
-----------------------------------------------------------
[Baseline] Scalar C++ Implementation : 12.45 ms  (1.00x)
[Optimized] RVV Vectorization        :  1.82 ms  (6.84x)
-----------------------------------------------------------
Verification: PASSED (Output buffers match perfectly!)
===========================================================

# 🎯 第三部分：讲解与答辩时的金句/加分项

如果您是在进行赛事答辩、代码 Review 或技术分享，结合以下几点会让讲解更有深度：

精准控制循环边界（VSETVL）：说明在移植 KleidiCV 算子时，如何规避了传统 SIMD（如 ARM Neon）需要显式编写残差循环（Residual Loop）的痛点，展示了 RISC-V “硬件自动处理不齐整边界” 的架构优雅性。

内存对齐与访存优化：如果算子涉及多通道（如 RGB 交叉存储），顺便提一句你如何使用了 vlseg3e8.v（分段加载指令）来替代高开销的乱序访存，这能证明你对 RISC-V 硬件特性的理解已经到了底层。
正确性校验（Verification）：演示中一定要包含 Verification: PASSED。

强调性能优化绝不以牺牲精度为代价（特别是饱和截断、浮点四舍五入时的边界处理是否与原生算法完全一致）。


行编译和运行演示时，对着这三段代码，你需要向受众强调以下三个技术代差：

📈 痛点对比 1：分支预测（Scalar vs SIMD）
标量版中的 if (temp > 255) 在 CPU 内部会引发灾难性的分支预测失败。

Neon 和 RVV 1.0 都在硬件电路层面引入了饱和加法指令（Neon 的 vqadd，RVV 的 vsadd），在一条指令内完成了“相加+截断”，干掉了所有的 if 判断，流水线极其顺畅。

🔄 痛点对比 2：残差处理（Neon vs RVV 1.0）
ARM Neon（以及传统 X86 SSE/AVX） 的寄存器长度是硬编码死（128位）的。如果图像总像素数不是 16 的整数倍，程序员必须在主循环后面手写一个标量“收尾”循环。这不仅增加了代码体积，还容易写出 Bug。

RISC-V Vector 1.0 引入了 vsetvl 机制。当循环进行到最后，剩下的像素不够一个满载向量时，vl 会自动缩小为剩余的像素数（例如剩 5 个，vl 就变成 5），然后用同一套向量指令把这 5 个像素处理完。RVV 完美的干掉了残差循环，代码极为优雅。

⏱️ 性能演示效果设计
如果现场运行 Benchmark，你可以打印出类似这样的耗时对比（以 4K 图像 8,294,400 像素为例）：

Scalar 标量版本：~15.4 ms （受分支预测拖累）

ARM Neon 版本：~1.2 ms （约 12-13 倍加速）

RISC-V Vector 1.0 版本：~0.9 ms （由于硬件向量长度可能比 Neon 的 128 位更长，如 256 位或 512 位，且没有尾部吞吐损耗，通常能跑出比 Neon 更高的吞吐量和加速比！）

这套“从标量的臃肿，到 Neon 的强悍，再到 RVV 1.0 的优雅与高性能”的递进式讲解，能把 P2601 赛题的硬核技术背景剖析得淋漓尽致。


会议主题：RISC-V软件移植与优化挑战赛培训
发言人：孙敏、李程
会议摘要：本次培训孙敏详细讲解了将 Halide 组件移植至 RISC-V 架构并利用 RVV 进行加速的赛题背景、技术实现路径及编译环境搭建，李程针对演示卡顿问题提出了改进建议。
---
一、赛题背景与核心任务
针对 RISC-V 架构在计算机视觉领域缺乏高效并行加速的现状，会议明确了本次挑战赛的优化目标与技术路径：
1. 赛题痛点与优化方向
性能瓶颈分析：目前 RISC-V 上的 OpenCV 基础算子（如调整大小、高斯滤波）仍依赖传统标量方式实现，无法有效利用多核及向量流水线优势。
技术对标：赛题要求借鉴 ARM 平台上基于 Neon 和 SVE 的实现经验，将 Halide 高性能算子移植到 RISC-V 平台，利用 RVV 寄存器和长向量指令实现硬件级 SIMD 并行加速。
2. 核心任务要求
算子适配与验证：选手需将现有 Neon/SVE 算子适配为 RVV 实现，其中 90% 的优化算子必须使用 RVV 内联汇编或 Intrinsics 函数，并支持 `vsetvl` 的灵活向量长度特性。
精度与兼容性：所有算子必须通过回归测试进行精度验证，支持现有的 CMake 构建机制及交叉编译工具链，并提供标量版本作为回退方案。
二、开发环境与测试平台
为确保开发与验证的一致性，会议详细介绍了编译工具链与测试环境的配置标准：
1. 编译工具链配置
编译器要求：推荐使用支持 RVV 1.0 的 GCC 编译器，可通过 `gcc -march=rv64gcv_zba_zbb -mabi=lp64d` 命令验证是否支持 RVV 1.0。
构建方式选择：ARM64 架构建议使用 Native 编译，而 RISC-V 架构推荐使用交叉编译方式，需确保工具链支持 RVV。
2. 测试环境搭建
仿真与真机验证：前期开发可在 QEMU User 或 System 模式下进行，其中 System 模式需传递 System Root 以加载动态库；后期验证将基于“之猴 A210”远程访问环境。
QEMU 版本要求：建议使用较新版本（如 9.0.2 及以上）以确保对 RVV 1.0 的完整支持。
三、技术实现与演示
会议通过代码片段对比了标量、Neon 及 RVV 三种实现方式的差异，并演示了 OpenCV 源码编译流程：
1. SIMD 向量化优化策略
数据并行处理：利用 RVV Intrinsics 实现单指令多数据（SIMD）并行计算，一次性处理多个像素数据，相比标量循环嵌套大幅提升效率。
残差处理优化：RVV 相比 Neon 在尾部数据（残差）处理上有所改进，通过动态向量长度避免了复杂的边界判断逻辑。
2. OpenCV 编译与集成
源码编译配置：演示了从源码编译 OpenCV 4.13 的过程，需通过 `cmake` 参数指定 Halide 源码路径（`-DWITH_HALIDE=ON`），并开启 Benchmark 测试支持。
版本确认：成功编译后，需在输出信息中确认 Halide 版本为 26.03（赛题要求版本），而非 OpenCV 自带的 0.7.0 版本。
四、培训复盘与改进建议
针对培训过程中的演示问题，李程老师进行了现场复盘并提出了具体改进意见：
1. 演示流程卡顿问题
时间浪费分析：指出培训开头存在约 5 分钟的静态画面停顿，导致整体节奏拖沓，影响了培训效果。
内容衔接建议：建议将静态画面部分调整为过渡式内容，或结合讲稿进行更流畅的讲解，避免长时间无操作。
---
五、待办事项
调整培训讲稿与演示流程，解决开头停顿问题，提升培训流畅度。 @孙敏
