// RVSPOC 2026 S2602 板端 Top-1 评测 harness（组委会统一工具）。
//
// 设计要点：**预处理不在板上做**。10,000 张图已在 x86 上用与 eval_top1.py 完全相同的
// PIL BILINEAR resize + center crop 预处理成 224x224x3 uint8 连续块。板端只做
// 归一化与量化——纯算术，与 x86 逐位一致。这样两侧唯一的差异就是推理引擎本身，
// 正是 S2602 要测的量；避免 resize 实现差异污染 0.1% 的判定阈值。
//
// 同一份 harness 链接各选手各自构建的 libtensorflow-lite.a，保证横向可比。
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <chrono>

#include "tflite/interpreter.h"
#include "tflite/kernels/register.h"
#include "tflite/model_builder.h"

int main(int argc, char** argv) {
  if (argc < 5) {
    fprintf(stderr,
            "用法:\n"
            "  精度: %s acc <model.tflite> <tensors_u8.bin> <labels.i32> <count> [threads]\n"
            "  时延: %s lat <model.tflite> <tensors_u8.bin> <warmup> <runs> [threads]\n"
            "  张量: %s dump <model.tflite> <tensors_u8.bin> <out.raw> [threads]\n",
            argv[0], argv[0]);
    return 2;
  }
  const std::string mode = argv[1];
  if (mode != "acc" && mode != "lat" && mode != "dump") { fprintf(stderr, "未知模式: %s\n", argv[1]); return 2; }
  // 统一右移一位，兼容两种模式
  argv++; argc--;
  const char* model_path = argv[1];
  const char* blob_path  = argv[2];
  // 两种模式的第 3、4 个参数含义不同：
  //   acc: <labels.i32> <count>      lat: <warmup> <runs>
  const char* lbl_path   = (mode == "acc") ? argv[3] : nullptr;
  const char* dump_path  = (mode == "dump") ? argv[3] : nullptr;
  const int   count      = (mode == "acc") ? atoi(argv[4]) : 1;   // lat 只需第 0 张图
  const int   threads    = (argc > 5) ? atoi(argv[5]) : 1;

  const size_t kHW = 224 * 224 * 3;

  int fb = open(blob_path, O_RDONLY);
  if (fb < 0) { perror("open blob"); return 1; }
  struct stat sb{};
  fstat(fb, &sb);
  if ((size_t)sb.st_size < (size_t)count * kHW) {
    fprintf(stderr, "blob 太小: %zu < %zu\n", (size_t)sb.st_size, (size_t)count * kHW);
    return 1;
  }
  const uint8_t* blob = (const uint8_t*)mmap(nullptr, (size_t)count * kHW, PROT_READ,
                                             MAP_PRIVATE, fb, 0);
  if (blob == MAP_FAILED) { perror("mmap"); return 1; }

  std::vector<int32_t> labels;
  if (mode == "acc") {
    labels.resize(count);
    FILE* fl = fopen(lbl_path, "rb");
    if (!fl || fread(labels.data(), 4, count, fl) != (size_t)count) {
      fprintf(stderr, "读取 labels 失败\n"); return 1;
    }
    fclose(fl);
  }

  auto model = tflite::FlatBufferModel::BuildFromFile(model_path);
  if (!model) { fprintf(stderr, "模型加载失败: %s\n", model_path); return 1; }
  tflite::ops::builtin::BuiltinOpResolver resolver;
  std::unique_ptr<tflite::Interpreter> interp;
  if (tflite::InterpreterBuilder(*model, resolver)(&interp) != kTfLiteOk || !interp) {
    fprintf(stderr, "Interpreter 构建失败\n"); return 1;
  }
  interp->SetNumThreads(threads);
  if (interp->AllocateTensors() != kTfLiteOk) {
    fprintf(stderr, "AllocateTensors 失败\n"); return 1;
  }

  const int in_idx  = interp->inputs()[0];
  const int out_idx = interp->outputs()[0];
  TfLiteTensor* in  = interp->tensor(in_idx);
  TfLiteTensor* out = interp->tensor(out_idx);

  const bool quant_in = (in->type == kTfLiteUInt8);
  const float in_scale = in->params.scale;
  const int   in_zero  = in->params.zero_point;
  const int n_classes  = out->dims->data[out->dims->size - 1];
  const int label_off  = (n_classes == 1001) ? 1 : 0;

  fprintf(stderr, "模型=%s 输入=%s scale=%g zero=%d 类别=%d 偏移=%d 线程=%d\n",
          model_path, quant_in ? "uint8" : "float32", in_scale, in_zero,
          n_classes, label_off, threads);

  if (mode == "dump") {
    // 张量 dump（§4.C 算子级精度的替代路径）：用固定的第 0 张图推理一次，
    // 把输出张量按其原始字节写出。同一提交分别以 -march=rv64gc（标量）与
    // rv64gcv（向量）构建，两份 .raw 逐字节比对即可判定向量化是否改变数值。
    // 不做任何归一化或重排，以使比对完全无损、可被选手独立复现。
    // 喂数据的 LUT 口径与 acc/lat 两种模式完全一致，保证三者输入相同。
    {
      const uint8_t* px = blob;
      uint8_t l8[256]; float lf[256];
      for (int v = 0; v < 256; ++v) {
        float norm = ((float)v - 127.0f) / 128.0f;
        lf[v] = norm;
        float q = std::round(norm / in_scale) + (float)in_zero;
        l8[v] = (uint8_t)std::min(255.0f, std::max(0.0f, q));
      }
      if (quant_in) {
        uint8_t* dst = interp->typed_tensor<uint8_t>(in_idx);
        for (size_t k = 0; k < kHW; ++k) dst[k] = l8[px[k]];
      } else {
        float* dst = interp->typed_tensor<float>(in_idx);
        for (size_t k = 0; k < kHW; ++k) dst[k] = lf[px[k]];
      }
    }
    if (interp->Invoke() != kTfLiteOk) { fprintf(stderr, "Invoke 失败\n"); return 1; }
    const size_t nbytes = out->bytes;
    FILE* fp = fopen(dump_path, "wb");
    if (!fp) { fprintf(stderr, "无法写入 %s\n", dump_path); return 1; }
    if (fwrite(out->data.raw, 1, nbytes, fp) != nbytes) {
      fprintf(stderr, "写入不完整\n"); fclose(fp); return 1;
    }
    fclose(fp);
    const char* tname = (out->type == kTfLiteUInt8)  ? "uint8"
                      : (out->type == kTfLiteInt8)   ? "int8"
                      : (out->type == kTfLiteFloat32)? "fp32" : "other";
    printf("DUMP %s bytes=%zu dtype=%s classes=%d\n", dump_path, nbytes, tname, n_classes);
    return 0;
  }

  if (mode == "lat") {
    // 时延：固定用第 0 张图，warmup 后计时 runs 次，报 avg/p50/p95/std/throughput。
    // 不依赖上游 benchmark_model（该工具在本快照下因 StatWithPercentiles 模板冲突编不过），
    // 改用同一 harness 保证六个提交口径一致。
    const int warmup = atoi(argv[3]);
    const int runs   = atoi(argv[4]);
    const uint8_t* px = blob;
    uint8_t l8[256]; float lf[256];
    for (int v = 0; v < 256; ++v) {
      float norm = ((float)v - 127.0f) / 128.0f;
      lf[v] = norm;
      float q = std::round(norm / in_scale) + (float)in_zero;
      l8[v] = (uint8_t)std::min(255.0f, std::max(0.0f, q));
    }
    auto feed = [&]() {
      if (quant_in) {
        uint8_t* dst = interp->typed_tensor<uint8_t>(in_idx);
        for (size_t k = 0; k < kHW; ++k) dst[k] = l8[px[k]];
      } else {
        float* dst = interp->typed_tensor<float>(in_idx);
        for (size_t k = 0; k < kHW; ++k) dst[k] = lf[px[k]];
      }
    };
    for (int i = 0; i < warmup; ++i) { feed(); interp->Invoke(); }
    std::vector<double> ms;
    ms.reserve(runs);
    for (int i = 0; i < runs; ++i) {
      feed();                                   // 喂数据不计入推理时延
      auto a = std::chrono::steady_clock::now();
      interp->Invoke();
      auto b = std::chrono::steady_clock::now();
      ms.push_back(std::chrono::duration<double, std::milli>(b - a).count());
    }
    std::vector<double> srt = ms;
    std::sort(srt.begin(), srt.end());
    double sum = 0; for (double v : ms) sum += v;
    double avg = sum / runs;
    double var = 0; for (double v : ms) var += (v - avg) * (v - avg);
    double sd = std::sqrt(var / runs);
    double p50 = srt[(size_t)(runs * 0.50)];
    double p95 = srt[std::min((size_t)(runs * 0.95), srt.size() - 1)];
    long vmhwm = 0;
    if (FILE* fs = fopen("/proc/self/status", "r")) {
      char ln[256];
      while (fgets(ln, sizeof ln, fs)) if (sscanf(ln, "VmHWM: %ld kB", &vmhwm) == 1) break;
      fclose(fs);
    }
    printf("{\"model\":\"%s\",\"threads\":%d,\"runs\":%d,\"avg_ms\":%.3f,\"p50_ms\":%.3f,"
           "\"p95_ms\":%.3f,\"std_ms\":%.3f,\"p95_over_avg\":%.3f,\"throughput_ips\":%.2f,"
           "\"vmhwm_kb\":%ld}\n",
           model_path, threads, runs, avg, p50, p95, sd, p95 / avg, 1000.0 / avg, vmhwm);
    return 0;
  }

  // 归一化/量化只依赖输入字节值（0..255），预先建 256 项查找表。
  // 算术与逐像素写法完全相同，只是把 15 万次 round/除法降为查表——
  // 不改变任何数值结果，仅消除 harness 自身的开销，避免污染时延测量。
  uint8_t lut_u8[256];
  float   lut_f32[256];
  for (int v = 0; v < 256; ++v) {
    float norm = ((float)v - 127.0f) / 128.0f;
    lut_f32[v] = norm;
    float q = std::round(norm / in_scale) + (float)in_zero;
    lut_u8[v] = (uint8_t)std::min(255.0f, std::max(0.0f, q));
  }

  long correct = 0;
  auto t0 = std::chrono::steady_clock::now();
  for (int i = 0; i < count; ++i) {
    const uint8_t* px = blob + (size_t)i * kHW;
    if (quant_in) {
      uint8_t* dst = interp->typed_tensor<uint8_t>(in_idx);
      for (size_t k = 0; k < kHW; ++k) dst[k] = lut_u8[px[k]];
    } else {
      float* dst = interp->typed_tensor<float>(in_idx);
      for (size_t k = 0; k < kHW; ++k) dst[k] = lut_f32[px[k]];
    }
    if (interp->Invoke() != kTfLiteOk) {
      fprintf(stderr, "第 %d 张 Invoke 失败\n", i); return 1;
    }
    int best = 0;
    if (out->type == kTfLiteUInt8) {
      const uint8_t* s = interp->typed_tensor<uint8_t>(out_idx);
      for (int c = 1; c < n_classes; ++c) if (s[c] > s[best]) best = c;
    } else {
      const float* s = interp->typed_tensor<float>(out_idx);
      for (int c = 1; c < n_classes; ++c) if (s[c] > s[best]) best = c;
    }
    if (best - label_off == labels[i]) ++correct;
    if ((i + 1) % 1000 == 0)
      fprintf(stderr, "  %d/%d top1=%.4f\n", i + 1, count, (double)correct / (i + 1));
  }
  double secs = std::chrono::duration<double>(std::chrono::steady_clock::now() - t0).count();

  printf("{\"model\":\"%s\",\"images\":%d,\"correct\":%ld,\"top1\":%.6f,"
         "\"input_dtype\":\"%s\",\"n_classes\":%d,\"threads\":%d,\"elapsed_s\":%.1f}\n",
         model_path, count, correct, (double)correct / count,
         quant_in ? "uint8" : "float32", n_classes, threads, secs);
  return 0;
}
