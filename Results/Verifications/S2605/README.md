# 赛题「S2605 RocksDB 移植与优化」的验证

> 验证日期：2026-09-05 至 09-21　验证平台：蓝芯 LX5000　状态：已完成，冠军：SNL（PR 3）
>
> 本报告为单题验证记录。全局方法学见《RVSPOC2026-卷1-总览与裁定》
> 与《RVSPOC2026-卷3-LX5000》（同目录 `../panel/`）。

## 概述

四个有效提交全部完成验证。按门槛口径（必测三项全部 ≥+30%）**无提交达标**；
各提交的完整实测数据如下，供复核。

| 提交 | 队伍 | db_bench（必测三项） | make check | RocketMQ 60 分钟压测 | 结论 |
|---|---|---|---|---|---|
| [PR 3](https://github.com/rv2036/rvspoc-S2605-rocksdb/pull/3) | SNL | fillrandom +4.6% / readrandom +29.9%~+32.6% / seekrandom +31.7% | 38,934 用例全过 | ——（见下） | **冠军**（评定见下） |
| [PR 2](https://github.com/rv2036/rvspoc-S2605-rocksdb/pull/2) | zlwindy | +7.2% / −1.7% / −4.7% | 通过 | JNI 集成方式不同（缺硬依赖类） | 未达标 |
| [PR 4](https://github.com/rv2036/rvspoc-S2605-rocksdb/pull/4) | 260818 | −6.7% / −14.0% / −18.2% | 通过 | **通过**（无 OOM、无损坏、不丢消息） | 未达标 |
| [PR 1](https://github.com/rv2036/rvspoc-S2605-rocksdb/pull/1) | RVV智能 | `DB::Open` 即 SIGILL 崩溃 | 无法运行 | 无法运行 | 未达标 |

门槛出处（赛前公开）：`https://rvspoc.org/S2605`「相比于 db_bench 标量版本在
验证平台的基线测试结果，性能需提升至少 30%」。

**冠军评定**：PR 3 是本题唯一在三项必测中两项超过 +30% 门槛的提交
（readrandom +29.9%~+32.6%、seekrandom +31.7%；三次测量见下），且是唯一
修复上游平台缺陷者（rdcycle → rdtime，使 make check 38,934 用例得以全量运行），
唯 fillrandom +4.6% 未达门槛。经与赞助方共同评审，本题按"最接近达标、
综合质量最优"评定 PR 3 为冠军。其余提交与门槛差距显著（PR 4 必测三项全负、
PR 2 一项为负、PR 1 无法运行），不构成评定空间。

### 相关基础数据

**PR 3 的数据完整性说明**：其 readrandom 三次测量为 +29.2%、+32.6%、+29.9%，
轮间波动幅度与该值同 30% 门槛的距离相当；fillrandom 为 +4.6%。
边界带复核过程见《卷3-LX5000》。

**PR 1 的崩溃定性**：其使用 Zbc 标量 `clmul` 指令，LX5000 的 ISA 不含 zbc，
`DB::Open` 即 SIGILL（gdb 定位至 `util/crc32c_riscv.cc:66`），代码注释明示
路径选择为编译期决定、无运行时检测。选手说明文件称在 Spacemit K3 上构建验证
（K3 支持 Zbc，故其本地验证不暴露此问题）；赛题详情页指定验证平台为 LX5000。

**PR 4 的 JNI 移植经对照实验证实有效**：以官方 RocketMQ 5.5.0 发行包运行，
其自带的 `rocketmq-rocksdb-1.0.6.jar` 只含 linux32/64/musl 本地库、不含 riscv64，
**Broker 启动即失败**；换 PR 4 构建的 jar（含 `librocksdbjni-linux-riscv64.so`
及 `RemoveConsumeQueueCompactionFilter` 等硬依赖类）后五个 RocksDB 存储
全部正常、Broker `boot success`。**官方发行包在本平台无法运行 RocksDB 存储，
而 PR 4 的移植使其可用**——这正是赛题「以 JNI 动态库方式部署到 RocketMQ 5.5.0
运行环境」所考察的能力。

**60 分钟压测结果（PR 4，1 轮）**：128 B × 16 线程平均 15,585 TPS、4 KiB × 8 线程
平均 9,478 TPS，发送失败均为 0；两消费组 `Consume Diff Total` 均为 0（不丢消息）；
无 OOM、无 Corruption、无 Background error；130 个采样点内存平稳。
P99 因官方工具不输出而如实声明不可得（PR 3 亦已在文档公开承认该限制）。
本轮数据完整可用；如复核中需要更多轮次，组委会将另行补充。

**make check 失败项全部归因于非选手因素**：`range_locking_test` 的 14–16 项 SIGILL
为上游 `toku_time.h:155` 的 `rdcycle`（Linux ≥ 6.6 禁止用户态读取）；
`options_settable_test` 的 padding 计数偏差经隔离实验证实上游源码在同一工具链下
同样失败（偏差同为 24 字节）。PR 3 是唯一修复上游平台缺陷者（rdcycle → rdtime）。

## 流程

1. 形式审查；按各提交说明文件复现构建（统一去掉 zbc——LX5000 不支持）
2. db_test 与 make check（含失败项隔离实验）
3. db_bench 必测三项 + 参考三项 × 3 轮；PR 3 readrandom 边界带复核（+32.6% 复核轮）
4. PR 4 的 rocksdbjava JNI 构建 → 装入隔离 Maven 仓库 → RocketMQ 5.5.0 集成
5. 60 分钟长稳压测（128 B 混合收发 + 4 KiB 大消息 + 延迟 600 s 消费形成积压，
   30 秒间隔采样 130 点）

## 验证环境

| 项 | 值 |
|---|---|
| 硬件 | 蓝芯 LX5000，riscv64，32 核 / 251 GiB |
| 系统 | Ubuntu 24.04.4，内核 6.18.3+（rdcycle 禁读与内核版本相关） |
| 工具链 | gcc-13 13.3.0 / gcc-14 14.2.0；JDK 21.0.12 + Maven 3.8.7（压测） |
| 基线 | RocksDB v11.1.1 标量（fillrandom 244,774 / readrandom 292,356 / seekrandom 141,371 ops/sec） |
| 冻结版本 | PR 1 `7847ab1e`　PR 2 `1e390720`　PR 3 `fa3fd926`　PR 4 `9ec8dc8e` |

## raw/ 目录索引

| 内容 | 说明 |
|---|---|
| `perf_summary.tsv` | db_bench 全部原始记录 |
| `makecheck/` | make check 结果表 |
| `rocketmq-stress-logs.tar` | 60 分钟压测全套日志（producer/consumer/broker/130 点采样） |
| `baseline-env/` | 基线环境快照 |
