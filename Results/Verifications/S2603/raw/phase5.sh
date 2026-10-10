#!/usr/bin/env bash
# S2603 #2 / #6 的 LTO 归因实验。
#
# 二者用 gcc-13/gcc-14 均失败于 lto1: target specific builtin not available：
# Redis 默认 -flto=auto，LTO 链接期以基线 -march 重新 codegen，V 扩展 builtin 失效。
# 本实验验证「仅禁用 LTO 是否即可编过」：
#   编过  → 选手 RVV 代码本身无误，缺的是构建配置对 LTO 的处理（可复现，可讨论）
#   仍不过 → 需进一步定位，不可草率归因
# 结论仅用于公开讨论的事实陈述，不直接作为判定。
cd "$(dirname "$0")"
while pgrep -f "correctness.sh|phase[234].sh" > /dev/null; do sleep 60; done

out=results/lto_experiment.txt
: > "$out"
for pr in 2 6; do
  d="src/rvspoc-S2603-redis-pr$pr"
  [ -d "$d" ] || continue
  lf="logs/rvspoc-S2603-redis-pr$pr.build.nolto.log"
  git -C "$d" clean -qfdx
  ( cd "$d" && make -C src -j"$(nproc)" CC=gcc-14 \
      REDIS_CFLAGS="-fno-lto" REDIS_LDFLAGS="-fno-lto" ) > "$lf" 2>&1
  rc=$?
  echo "S2603 #$pr  禁用LTO后: $([ $rc -eq 0 ] && echo 编译通过 || echo 仍失败)  (rc=$rc)" >> "$out"
  [ $rc -ne 0 ] && grep -iE "error|fatal" "$lf" | grep -v "^cc\|Werror" | tail -3 >> "$out"
done
echo "PHASE5 DONE" >> "$out"
