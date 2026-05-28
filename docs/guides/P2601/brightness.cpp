#include <iostream>
#include <vector>
#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>

//编译方法
//1. Native 编译
//g++ -I /home/pi/KleidiCV/install-kleidicv263/include/opencv4/  -L /home/pi/KleidiCV/install-kleidicv263/lib brightness_benchmark.cpp -lopencv_core -lopencv_imgcodecs -lopencv_highgui -o brightness_benchmark
//2.交叉编译
//riscv64-unknown-linux-gnu-g++ \
-O2 -march=rv64gcv \
-I/home/sunmin/workspace/opencv/install-rvv/include/opencv4/ \
-L/home/sunmin/workspace/opencv/install-rvv/lib/ \
brightness_benchmark.cpp \
-lopencv_core -lopencv_imgcodecs -lopencv_highgui -lopencv_imgproc \
-o brightness_benchmark

//用法
//1.基于 Shell 环境
//./brightness_benchmark --@image=/home/pi/KleidiCV/opencv-4.13.0/samples/data/leuvenA.jpg
//2.基于 qemu-user 环境
//qemu-riscv64 \
-L /home/sunmin/riscv/sysroot/ \
-E LD_LIBRARY_PATH=/home/sunmin/workspace/opencv/install-rvv/lib \
./brightness_benchmark --@image=../data/leuvenA.jpg

// ==========================================
// 硬件架构自动侦测与头文件引入
// ==========================================
#if defined(__riscv) || defined(__riscv__)
    #define LAYER_ARCH_RISCV
    #include <riscv_vector.h>

#elif defined(__ARM_NEON) || defined(__ARM_NEON__) || defined(_M_ARM64)
    #define LAYER_ARCH_ARM
    #include <arm_neon.h>

#else
    #define LAYER_ARCH_SCALAR
#endif

// ----------------------------------------------------------------------------
// 标量降级版本（作为保底，或用于正确性比对）
// ----------------------------------------------------------------------------
void brightness_scalar(const uint8_t* src, uint8_t* dst, int N, uint8_t val) {
    for (int i = 0; i < N; ++i) {
        int temp = src[i] + val;
        dst[i] = (temp > 255) ? 255 : static_cast<uint8_t>(temp);
    }
}

// ----------------------------------------------------------------------------
// 统一的加速接口：内部自动分流
// ----------------------------------------------------------------------------
void brightness_accelerated(const uint8_t* src, uint8_t* dst, int N, uint8_t val) {

#if defined(LAYER_ARCH_RISCV)
    // ------------- RISC-V RVV 实现 -------------
    for (size_t vl; N > 0; N -= vl, src += vl, dst += vl) {
        vl = __riscv_vsetvl_e8m8(N);
        vuint8m8_t v_src = __riscv_vle8_v_u8m8(src, vl);
        vuint8m8_t v_dst = __riscv_vsaddu_vx_u8m8(v_src, val, vl);
        __riscv_vse8_v_u8m8(dst, v_dst, vl);
    }

#elif defined(LAYER_ARCH_ARM)
    // ------------- ARM NEON 实现 -------------
    int i = 0;
    uint8x16_t v_val = vdupq_n_u8(val);

    // 主循环处理 16 字节对齐部分
    for (; i <= N - 16; i += 16) {
        uint8x16_t v_src = vld1q_u8(src + i);
        uint8x16_t v_dst = vqaddq_u8(v_src, v_val);
        vst1q_u8(dst + i, v_dst);
    }
    // 尾部残差处理
    for (; i < N; ++i) {
        int temp = src[i] + val;
        dst[i] = (temp > 255) ? 255 : static_cast<uint8_t>(temp);
    }

#else
    // ------------- 没有任何 SIMD 的普通平台 -------------
    brightness_scalar(src, dst, N, val);
#endif
}

int main(int argc, char** argv) {
    // 打印当前编译启用的优化轨道
#if defined(LAYER_ARCH_RISCV)
    std::cout << "Compiled with: RISC-V RVV Optimization" << std::endl;
#elif defined(LAYER_ARCH_ARM)
    std::cout << "Compiled with: ARM NEON Optimization" << std::endl;
#else
    std::cout << "Compiled with: Standard Scalar Mode (No SIMD)" << std::endl;
#endif

    // 后续的 OpenCV 读取、压测逻辑完全不需要动...

    // 模仿 dft.cpp 使用命令行解析器
    cv::CommandLineParser parser(argc, argv,
        "{help h || print this message}"
        "{@image | ../data/lena.jpg | input image}"
        "{val    | 50               | brightness increment value (0-255)}"
        "{loop   | 1000             | number of loops for performance test}"
    );

    if (parser.has("help")) {
        parser.printMessage();
        return 0;
    }

    std::string filename = parser.get<std::string>("@image");
    uint8_t val = static_cast<uint8_t>(parser.get<int>("val"));
    int loop_count = parser.get<int>("loop");

    if (!parser.check()) {
        parser.printErrors();
        return -1;
    }

    // 读取图像并强制转换为灰度图（确保是连续的 uint8_t 数组）
    cv::Mat img = cv::imread(filename, cv::IMREAD_GRAYSCALE);
    if (img.empty()) {
        std::clog << "Cannot read image file: " << filename << std::endl;
        return -1;
    }

    cv::imwrite("result_original_gray.jpg", img);

    // 确保图像内存在物理上是连续的（剔除每行末尾的 padding 干扰）
    if (!img.isContinuous()) {
        img = img.clone();
    }

    int N = static_cast<int>(img.total());
    std::cout << "Image size: " << img.cols << "x" << img.rows
              << " | Total pixels (N): " << N
              << " | Brightness adjustment: +" << (int)val << std::endl;

    // 申请输出缓冲区
    cv::Mat dst_scalar(img.size(), img.type());
    cv::Mat dst_simd(img.size(), img.type());

    // ------------------------------------------------------------------------
    // 正确性验证（Accuracy Check）
    // ------------------------------------------------------------------------
    brightness_scalar(img.data, dst_scalar.data, N, val);
    brightness_accelerated(img.data, dst_simd.data, N, val);

    // 比对两个 Mat 的像素值是否完全相同
    cv::Mat diff;
    cv::absdiff(dst_scalar, dst_simd, diff);
    double max_val = 0;
    cv::minMaxLoc(diff, nullptr, &max_val);

    if (max_val > 0) {
        std::cerr << "[ ERROR ] Results mismatch! Max absolute pixel difference: " << max_val << std::endl;
        return -1;
    } else {
        std::cout << "[ SUCCESS ] Correctness check passed. Results are identical." << std::endl;
    }

    // ------------------------------------------------------------------------
    // 性能压测（Performance Benchmark）
    // ------------------------------------------------------------------------
    std::cout << "\nRunning benchmark (Loops = " << loop_count << ")..." << std::endl;

    // 1. 压测标量版本
    int64 t_scalar_start = cv::getTickCount();
    for (int i = 0; i < loop_count; ++i) {
        brightness_scalar(img.data, dst_scalar.data, N, val);
    }
    int64 t_scalar_end = cv::getTickCount();
    double time_scalar = (t_scalar_end - t_scalar_start) * 1000.0 / cv::getTickFrequency();

    // 2. 压测 SIMD 版本
    int64 t_simd_start = cv::getTickCount();
    for (int i = 0; i < loop_count; ++i) {
        brightness_accelerated(img.data, dst_simd.data, N, val);
    }
    int64 t_simd_end = cv::getTickCount();
    double time_simd = (t_simd_end - t_simd_start) * 1000.0 / cv::getTickFrequency();

    // ------------------------------------------------------------------------
    // 打印性能报告
    // ------------------------------------------------------------------------
    std::cout << "-----------------------------------------------" << std::endl;
    std::cout << "Scalar average time: " << (time_scalar / loop_count) << " ms" << std::endl;
    std::cout << "SIMD average time:    " << (time_simd / loop_count) << " ms" << std::endl;
    std::cout << "-----------------------------------------------" << std::endl;
    std::cout << "Speedup ratio:       " << (time_scalar / time_simd) << " x" << std::endl;
    std::cout << "-----------------------------------------------" << std::endl;

    // 可选：将结果保存（如果在仿真环境下不需要看图，可将下面两行注释掉）
    cv::imwrite("result_scalar.jpg", dst_scalar);
    cv::imwrite("result_simd.jpg", dst_simd);

    return 0;
}