# 赛题「S2602 LiteRT 推理框架移植」的验证

> 验证日期：2026-09-18 至 09-24　验证平台：A210 b2　状态：已完成，冠军已定
>
> 本报告为单题验证记录。全局方法学、组委会侧问题披露与跨题数据见
> 《RVSPOC2026-卷1-总览与裁定》与《RVSPOC2026-卷2-A210》（同目录 `../panel/`）。

## 概述

六个有效提交全部在验证平台（A210 b2，riscv64，Debian 13）按各自说明文件完成复现构建、
精度与时延测试、算子级精度差分与上游行为比对。结论：

| 提交 | 队伍 | 精度（6 组） | 时延达标 | 六模型平均时延 | 结论 |
|---|---|---|---|---|---|
| **PR 6** | **260818** | **6/6** | 4/6 | **97.0 ms** | **通过，冠军** |
| [PR 3](https://github.com/rv2036/rvspoc-S2602-litert/pull/3) | 算力土豆 | 6/6 | 3/6 | 133.7 ms | 不通过 |
| [PR 4](https://github.com/rv2036/rvspoc-S2602-litert/pull/4) | 瑞福扫 | 6/6 | 1/6 | 171.3 ms | 不通过 |
| [PR 1](https://github.com/rv2036/rvspoc-S2602-litert/pull/1) | Leaplab | 6/6 | 1/6 | 298.9 ms | 不通过 |
| [PR 7](https://github.com/rv2036/rvspoc-S2602-litert/pull/7) | 用カの告别是眷戀ベО | 3/6 | 6/6 | 55.8 ms | 精度出局 |
| [PR 2](https://github.com/rv2036/rvspoc-S2602-litert/pull/2) | RVV智能 | 4/6 | 0/6 | 177.8 ms | 不通过 |

判据（赛题详情页）：Top-1 与 x86 参考差异 FP32 ≤ 0.1%、INT8 ≤ 1%；推理时延 ≤ 110 ms；
测试模型不少于 MobileNetV1、MobileNetV2、EfficientNet-Lite0，缺一不可。
时延口径：每模型取较优线程数（1/4 线程）；整体口径下「多数达标」与
「平均 ≤110 ms」两种算法结论一致，仅 PR 6 通过。

### 相关基础数据

**精度**（ImageNetV2 matched-frequency 10,000 张，对 x86 参考实现）：

PR 6、PR 3、PR 4、PR 1 四家精度 6/6 达标；PR 6 与 PR 4 的三个 FP32 正确数与 x86 参考一位不差。
PR 7 三个 FP32 模型 Top-1 为 0.10%–0.13%（等同随机猜测），三个 INT8 达标；
PR 2 两个 MobileNet INT8 为 0.0% 与 1.4%（同批图像同题对照 68.4%/69.8%）。

**PR 2 精度归零的定性**（09-21 闭合）：

| 排除项 | 方法 | 结果 |
|---|---|---|
| 构建产物问题 | 全新构建树重做 | 失败稳定复现 |
| 编译器代码生成差异 | 以 GCC 15.3.0（选手声明 15.2.0，主版本相同）重建，系统库未动 | 三模型结果与 gcc-14 **一字不差**（0.0%/1.4%/73.6%） |
| 交叉验证 | 算子级差分 + 上游原版比对 | INT8 最大差 159/255 LSB，两条独立路径数值相同 |

定性：量化路径代码缺陷。须声明的限度：实测 15.3.0 非声明的 15.2.0，次版本差异
不能绝对排除，但同大版本内出现该量级差异的可能性极低。

**PR 7 FP32 失效的三重独立证据**：

| 方法 | 结果 |
|---|---|
| 模型级（万张 Top-1 对 x86 参考） | 0.13%/0.10%/0.11% |
| 同提交标量/向量档输出张量比对 | FP32 最大差 0.958/1.000，INT8 逐位相同 |
| 上游原版比对（fork 点 `ea79caff`） | 与上表数值完全相同 |

**算子级精度**（同提交标量档 vs 向量档输出张量，FP32 ≤ 1e-5、INT8 ≤ 1 LSB）：

| 提交 | MobileNetV2 INT8 | MobileNetV1 INT8 | FP32 | 判定 |
|---|---:|---:|---:|---|
| [PR 6](https://github.com/rv2036/rvspoc-S2602-litert/pull/6) | 0 | 0 | ≤2.4e-07 | 四项全过 |
| [PR 1](https://github.com/rv2036/rvspoc-S2602-litert/pull/1) | 0 | 0 | ≤5.4e-09 | 四项全过 |
| [PR 4](https://github.com/rv2036/rvspoc-S2602-litert/pull/4) | 0 | 0 | ≤1.2e-07 | 四项全过 |
| [PR 3](https://github.com/rv2036/rvspoc-S2602-litert/pull/3) | **3 LSB** | 0 | ≤1.2e-07 | 一项临界超出（见下） |
| [PR 7](https://github.com/rv2036/rvspoc-S2602-litert/pull/7) | 0 | 0 | **0.958/1.000** | FP32 功能性失效 |
| [PR 2](https://github.com/rv2036/rvspoc-S2602-litert/pull/2) | **159 LSB** | **255 LSB** | ≤2.4e-07 | INT8 功能性失效 |

PR 3 的 MobileNetV2 INT8 分布：1001 个元素中 422 个完全相同、516 个差 1 LSB、
61 个差 2 LSB、仅 2 个差 3 LSB——属舍入次序差异的临界超出，非功能性失效
（其模型级精度 6/6 未受影响）。该项按条款字面（≤1 LSB）计为不通过，
已计入上表结论；其处置不影响 PR 6 的领先地位。

**上游行为比对**（09-24 自查，按 P2601 I420 先例）：以六提交各自 fork 点的上游
LiteRT 原版为参考与各提交向量档比对，超阈值者与上表所提提交、数值完全相同——
**本题不存在移植底座漂移**，三家缺陷均在向量化本身。

## 流程

1. 形式审查；按各提交说明文件复现构建（PR 4/PR 7 用 gcc-13——其 3 参数定点 intrinsics
   为 gcc-14 所不支持；PR 2 用 gcc-14——其 `__RISCV_VXRM_RDN` 为 gcc-13 所无）
2. 时延（自建 harness，warmup 10 + 计时 50，三轮，1/4 线程）
3. 精度（万张全量，x86 参考的允许区间见卷1 附4）
4. 算子级差分与上游比对（自建 harness 的 dump 模式，输出张量按类型解析后比对——
   逐字节比对对 FP32 无意义，此点曾致一次误读，已修正并记录）
5. GCC 15 复现（`dpkg -x` 解包至独立前缀，不安装，系统库未受影响）

## 验证环境

| 项 | 值 |
|---|---|
| 硬件 | A210 b2，riscv64，8 核，VLEN 128（主频锁定 1.896 GHz，与 b1 严禁跨板比对） |
| 系统 | Debian 13 (trixie)，内核 6.6.0 |
| 工具链 | gcc-13 13.3.0 / gcc-14 14.2.0 / GCC 15.3.0（解包不安装），QEMU 10.0.13（09-20 补装） |
| 测试集 | ImageNetV2 matched-frequency 10,000 张（预处理张量块与图片清单 SHA-256 见卷1 第七章） |
| 冻结版本 | PR 1 `faf2a6dd`　PR 2 `7bfae1af`　PR 3 `da727af4`　PR 4 `28bd4f18`　PR 6 `dc1cede4`　PR 7 `36226ec3` |

## raw/ 目录索引

| 内容 | 说明 |
|---|---|
| `s2602_accuracy.tsv` | 精度原始记录（6 提交 × 6 模型 × 10,000 张） |
| `s2602_latency.tsv` | 时延原始记录（6 提交 × 6 模型 × 2 线程档 × 3 轮，含 p95 与 vmhwm） |
| `s2602_build.tsv` | 各提交构建结果与耗时（含 PR 4 gcc-13 重建过程） |
| `all_diff.tsv`、`pr6_diff*.tsv` | 算子级差分结果（24 组） |
| `opacc_tensors/` | 算子级差分的输出张量原件（48 个 `.raw`，差分 TSV 的直接输入） |
| `upstream_diff.tsv`、`upstream_raw/` | 上游行为比对结果（24 组）及上游档输出张量原件（8 个 `.raw`） |
| `pr2_multicc.txt` | PR 2 多编译器验证原始记录（GCC 15 重建结果与 PR 6 库对照） |
| `pr2_clean_verify.txt` | PR 2 全新构建树干净重建复验记录 |
| `kernel_test_targets.txt` | TFLite kernel 测试目标清单 |
| `accuracy_harness.cc` | 验证 harness 源码（含 dump 模式） |
| `opacc.sh`、`kernel_test.sh`、`pr2_gcc15_seed.sh` | 生成脚本（差分比对、kernel 测试、PR 2 GCC 15 依赖预置重建） |
| `logs/` | 全部过程日志（逐模型精度 json/err、构建/cmake/harness 日志，155 个文件） |

ImageNetV2 预处理张量块（1.4 GiB）体积超出公示仓库范围，未入库；
其 SHA-256 见卷1 第七章，复核需要时由组委会另行提供。
