#!/usr/bin/env bash
# S2603 #4 六项功能失败的隔离实验。
# 方法:选手工作树上仅将 networking.c / server.c 恢复为上游版本重编重测。
#   失败消失 → 归因于其对这两个文件的改动(协议解析/批处理路径)
#   失败仍在 → 与这两个文件无关,需另行定位
cd "$(dirname "$0")"
d=src/rvspoc-S2603-redis-pr4
out=results/phase8.txt
: > "$out"
[ -d "$d" ] || { echo "工作树缺失" > "$out"; exit 1; }

base=$(git -C "$d" merge-base origin/HEAD HEAD)
cd "$d" && git checkout -q -- . && make distclean -C src > /dev/null 2>&1

# 仅恢复上游 networking.c / server.c(monotonic.c 保持选手版本以单独观察 6 项功能失败)
git checkout "$base" -- src/networking.c src/server.c
echo "已恢复上游 networking.c / server.c;monotonic.c 保留选手版本" >> "$OLDPWD/$out"

make -C src -j"$(nproc)" > "$OLDPWD/logs/pr4_isolation.build.log" 2>&1 || {
  echo "恢复后构建失败" >> "$OLDPWD/$out"; exit 1; }
timeout 3600 ./runtest --accurate --no-latency --clients 4 --dont-clean \
  > "$OLDPWD/logs/pr4_isolation.unit.log" 2>&1
rc=$?
{
  echo "=== 隔离实验:恢复上游 networking.c+server.c 后 ==="
  echo "runtest exit=$rc  err=$(grep -cE "^\[err\]:" "$OLDPWD/logs/pr4_isolation.unit.log")  ok=$(grep -cE "^\[ok\]:" "$OLDPWD/logs/pr4_isolation.unit.log")"
  echo "--- 剩余 [err] 项 ---"
  grep -oE "^\[err\]: .*" "$OLDPWD/logs/pr4_isolation.unit.log" | sed "s/ in tests.*//" | sort -u
  echo "--- 跑完与否 ---"
  grep -qE "All tests passed|The End" "$OLDPWD/logs/pr4_isolation.unit.log" && echo "完整跑完" || echo "中途中断"
} >> "$OLDPWD/$out" 2>&1
# 恢复现场
git checkout HEAD -- src/networking.c src/server.c
echo "PHASE8 DONE" >> "$OLDPWD/$out"
