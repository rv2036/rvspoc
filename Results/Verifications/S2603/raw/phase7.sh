#!/usr/bin/env bash
# 排查 S2603 #4 完整构建后新增的 9 个 benchmark 类失败。
# 首轮（仅编 redis-server/cli/benchmark）无此类失败，完整构建后出现，
# 需确认是否为构建方式差异所致，而非选手改动。
cd "$(dirname "$0")"
while pgrep -f "phase6.sh" > /dev/null; do sleep 30; done
out=results/phase7.txt
: > "$out"

d=src/rvspoc-S2603-redis-pr4
lf=logs/rvspoc-S2603-redis-pr4.unit.fullbuild.log
{
  echo "=== benchmark 类失败的具体报错 ==="
  grep -A4 "^\[err\]: benchmark: set,get" "$lf" 2>/dev/null | head -8
  echo
  echo "=== 对照组同名测试结果 ==="
  grep -cE "^\[ok\]: benchmark:" logs/CONTROL.redis-8.8.0.log | sed "s/^/对照组 benchmark 通过数: /"
  grep -cE "^\[err\]: benchmark:" logs/CONTROL.redis-8.8.0.log | sed "s/^/对照组 benchmark 失败数: /"
  echo
  echo "=== 首轮(选手文档命令)是否跑到 benchmark 测试 ==="
  grep -cE "benchmark:" logs/rvspoc-S2603-redis-pr4.unit.log | sed "s/^/首轮 benchmark 相关行数: /"
  echo
  echo "=== redis-benchmark 二进制是否存在及可运行 ==="
  ls -la "$d/src/redis-benchmark" 2>&1 | tail -1
  ( cd "$d" && ./src/redis-benchmark --version 2>&1 | head -2 )
} >> "$out" 2>&1
echo "PHASE7 DONE" >> "$out"
