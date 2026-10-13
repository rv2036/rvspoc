#!/usr/bin/env bash
# 复验 S2603 #4：改用与对照组同样的完整构建后重跑测试。
#
# 首轮用的是选手文档命令（只编 redis-server/cli/benchmark，不含测试模块），
# 测试在 moduleapi 处中断，故其 6 个 [err] 需在完整构建下复验才能归因。
cd "$(dirname "$0")"
while pgrep -f "correctness.sh|phase2.sh" > /dev/null; do sleep 60; done

d=src/rvspoc-S2603-redis-pr4
lf=logs/rvspoc-S2603-redis-pr4.unit.fullbuild.log
git -C "$d" clean -qfdx
( cd "$d" && make -j"$(nproc)" CC=gcc-14 ) > logs/rvspoc-S2603-redis-pr4.build.full.log 2>&1
if [ $? -ne 0 ]; then echo "FULL BUILD FAILED" > "$lf"; else
  ( cd "$d" && timeout 3600 ./runtest --accurate --no-latency --clients 4 --dont-clean ) > "$lf" 2>&1
fi
{
  echo "=== S2603 #4 完整构建复验 ==="
  echo "err=$(grep -cE "^\[err\]:" "$lf")  ok=$(grep -cE "^\[ok\]:" "$lf")"
  grep -oE "^\[err\]: .*" "$lf" | sed "s/ in tests.*//" | sort -u
} > results/pr4_recheck.txt 2>&1
echo "PHASE3 DONE" >> results/pr4_recheck.txt
