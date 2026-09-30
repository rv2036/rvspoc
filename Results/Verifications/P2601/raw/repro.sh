#!/usr/bin/env bash
# P2601 I420 专项独立复现（组委会验证侧，2026-09-23）。
# 目的：核实评委 P2601-I420-20260922 记录中的失败计数。
# 独立性保证：源码取自组委会自己的 pr-archive 归档（已逐树比对与评委归档零差异），
#            不使用评委提供的 tar；测试驱动用评委的 i420_reference_test.cpp，
#            因其参考函数逐字取自 26.03 原版，是判定「与原版布局是否一致」的必要基准。
set -uo pipefail
cd /work/i420
log(){ echo "[$(date -u +%FT%TZ)] $*"; }
for mode in rvv scalar; do
  if [ "$mode" = rvv ]; then enable=ON; flags='-fno-tree-vectorize';
  else enable=OFF; flags='-fno-tree-vectorize -march=rv64gc'; fi
  for id in 3 4; do
    log "构建 $mode$id (KLEIDICV_ENABLE_RVV=$enable)"
    cmake -S "src$id" -B "$mode$id" -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=g++-14 -DCMAKE_C_COMPILER=gcc-14 \
      -DCMAKE_CXX_FLAGS="$flags" -DKLEIDICV_ENABLE_RVV="$enable" \
      -DKLEIDICV_BUILD_TESTS=OFF -DKLEIDICV_BUILD_EXAMPLES=OFF -DKLEIDICV_BENCHMARK=OFF \
      > "cfg-$mode$id.log" 2>&1 || { log "  configure 失败"; tail -5 "cfg-$mode$id.log"; continue; }
    cmake --build "$mode$id" --parallel "$(nproc)" --target kleidicv \
      > "bld-$mode$id.log" 2>&1 || { log "  构建失败"; grep -iE "error:" "bld-$mode$id.log" | head -3; continue; }
    g++-14 -O2 -std=c++17 -march=rv64gc -fno-tree-vectorize \
      -I"src$id/kleidicv/include" -I"$mode$id/kleidicv/include" \
      i420_reference_test.cpp "$mode$id/kleidicv/libkleidicv.a" -o "test-$mode$id" \
      > "lnk-$mode$id.log" 2>&1 || { log "  测试程序链接失败"; tail -5 "lnk-$mode$id.log"; continue; }
    code=0; "./test-$mode$id" > "out-$mode$id.log" 2>&1 || code=$?
    log "RESULT $mode$id exit=$code"
    grep -E "^(original_parameters|even_decode|even_encode)" "out-$mode$id.log" | sed 's/^/    /'
  done
done
log "I420 REPRO DONE"
