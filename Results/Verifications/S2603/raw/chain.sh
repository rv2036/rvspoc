#!/usr/bin/env bash
# 编译 → 补跑缺失工作树 → gcc-14 重试 → 正确性测试
cd "$(dirname "$0")"
while pgrep -f "build_all.sh" > /dev/null; do sleep 60; done
# 用修正版重跑一遍：跳过已 OK 且工作树健在的，补齐缺失的
mv -f build_all.next.sh build_all.sh 2>/dev/null
./build_all.sh >> pipeline.log 2>&1
echo "BUILD PASS 2 DONE" >> pipeline.log
./retry_failed.sh > retry.log 2>&1
echo "RETRY DONE" >> retry.log
./correctness.sh > correctness.log 2>&1
echo "ALL PHASES DONE" >> correctness.log
