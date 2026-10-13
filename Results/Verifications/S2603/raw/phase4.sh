#!/usr/bin/env bash
# 补齐对照缺口：标量 memcached 也跑一次 make test（首轮对照组只跑了 testapp，
# 而选手侧两个套件都跑了，缺少可比基准）。
cd "$(dirname "$0")"
while pgrep -f "correctness.sh|phase2.sh|phase3.sh" > /dev/null; do sleep 60; done
c=$(ls -d "$HOME"/rvspoc-baseline/src/memcached-* 2>/dev/null | head -1)
[ -d "$c" ] || exit 0
lf=logs/CONTROL.memcached.maketest.log
( cd "$c" && timeout 3600 make test ) > "$lf" 2>&1
rc=$?
{
  echo "=== 标量 memcached make test 对照 ==="
  echo "exit=$rc"
  grep -cE "^not ok" "$lf" | sed "s/^/not-ok 行数: /"
} > results/control_maketest.txt 2>&1
echo "PHASE4 DONE" >> results/control_maketest.txt
