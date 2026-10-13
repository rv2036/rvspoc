#!/usr/bin/env bash
cd "$(dirname "$0")"
out=results/phase6.txt
: > "$out"

# (1) 修正组委会侧构建错误：S2604 #3 首轮用了简化命令 `make memcached testapp`，
#     漏掉选手文档中的 memcached-debug 等目标，testapp 因 exec 不到该二进制而失败。
d=src/rvspoc-S2604-memcached-pr3
if [ -d "$d" ]; then
  ( cd "$d" && make -j"$(nproc)" memcached memcached-debug testapp sizes timedrun rvv-test rvv-bench ) \
      > logs/rvspoc-S2604-memcached-pr3.build.full.log 2>&1
  ( cd "$d" && timeout 1800 ./testapp ) > logs/rvspoc-S2604-memcached-pr3.testapp.full.log 2>&1
  echo "S2604 #3 完整构建后 testapp: exit=$? (按选手文档全部目标)" >> "$out"
fi

# (2) 定位 S2605 #1 的非法指令：用选手文档中的标量变体（PORTABLE=rv64gc）重编同一测试。
#     标量版不崩 → 崩溃发生在其 RVV 路径；两者都崩 → 与向量化无关。
d=src/rvspoc-S2605-rocksdb-pr1
if [ -d "$d" ]; then
  git -C "$d" clean -qfdx
  ( cd "$d" && PORTABLE=rv64gc make -j"$(nproc)" DEBUG_LEVEL=1 LIB_MODE=static \
      DISABLE_WARNING_AS_ERROR=1 db_test ) > logs/rvspoc-S2605-rocksdb-pr1.build.scalar.log 2>&1
  if [ $? -eq 0 ]; then
    ( cd "$d" && timeout 3600 ./db_test --gtest_filter=DBTest.MockEnvTest ) \
        > logs/rvspoc-S2605-rocksdb-pr1.scalar.MockEnvTest.log 2>&1
    echo "S2605 #1 标量构建(PORTABLE=rv64gc) MockEnvTest: exit=$?" >> "$out"
    grep -qE "Received signal|Illegal" logs/rvspoc-S2605-rocksdb-pr1.scalar.MockEnvTest.log \
      && echo "  标量版同样崩溃 → 与 RVV 路径无关" >> "$out" \
      || echo "  标量版正常 → 崩溃发生在 RVV 路径" >> "$out"
  else
    echo "S2605 #1 标量构建失败，无法对比" >> "$out"
  fi
fi
echo "PHASE6 DONE" >> "$out"
