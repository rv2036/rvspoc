#!/usr/bin/env bash
# S2602 算子级精度（§4.C）替代路径 —— 先在 #6 上打通。
#
# 原计划的上游 kernel 单测在本版本 LiteRT 上不可用（五处上游缺陷，第五处为
# 测试框架传递依赖 TF core 的 protobuf 生成头，CMake 路径从不生成）。
# 改用选手 #4 自带的口径：同一提交分别以标量档 rv64gc 与向量档 rv64gcv 构建，
# 对同一输入 dump 输出张量，逐字节比对。标量档即「同提交的参考实现」。
set -uo pipefail
W=/work/s2602; LOG=$W/logs; OUT=$W/results/opacc; mkdir -p "$OUT"
PR=${1:-6}; CC=${2:-gcc-14}; CXX=${3:-g++-14}
SRC=$W/src/rvspoc-S2602-litert-pr$PR
TFSRC=$W/tf-shared; TSL="-I$TFSRC/third_party/xla/xla"
log(){ echo "[$(date -u +%FT%TZ)] $*"; }

build_variant() { # arch tag
  local arch=$1 tag=$2
  local bld=$W/build-op$PR-$tag
  if [ ! -f "$bld/libtensorflow-lite.a" ]; then
    log "configure ($tag, -march=$arch)"
    cmake -S "$SRC/tflite" -B "$bld" -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_C_FLAGS="-march=$arch -mabi=lp64d $TSL" \
      -DCMAKE_CXX_FLAGS="-march=$arch -mabi=lp64d $TSL" \
      -DTENSORFLOW_SOURCE_DIR="$TFSRC" \
      -DTFLITE_ENABLE_XNNPACK=OFF -DTFLITE_ENABLE_GPU=OFF \
      > "$LOG/op$PR-$tag.cmake.log" 2>&1 || { log "  configure 失败"; tail -6 "$LOG/op$PR-$tag.cmake.log"; return 1; }
    log "构建 ($tag)"
    cmake --build "$bld" -j"$(nproc)" --target tensorflow-lite \
      > "$LOG/op$PR-$tag.build.log" 2>&1 || { log "  构建失败"; grep -iE "error:" "$LOG/op$PR-$tag.build.log" | grep -v warning | tail -3; return 1; }
  else
    log "复用已有 $tag 构建树"
  fi
  log "编译 harness ($tag)"
  local incs=(-I"$SRC" -I"$SRC/tflite" -I"$TFSRC" -I"$TFSRC/third_party/xla/xla")
  for d in "$bld"/_deps/*-src "$bld"/flatbuffers "$bld"/abseil-cpp; do
    [ -d "$d" ] && incs+=(-I"$d") && [ -d "$d/include" ] && incs+=(-I"$d/include")
  done
  $CXX -O2 -std=c++17 -march=$arch -mabi=lp64d "$W/accuracy_harness.cc" "${incs[@]}" \
    -o "$W/bin/harness-op$PR-$tag" \
    "$bld/libtensorflow-lite.a" $(find "$bld" -name "*.a" -not -name "libtensorflow-lite.a" 2>/dev/null | tr '\n' ' ') \
    -lpthread -ldl -lm > "$LOG/op$PR-$tag.harness.log" 2>&1 \
    || { log "  harness 编译失败"; tail -6 "$LOG/op$PR-$tag.harness.log"; return 1; }
  log "  harness OK: $W/bin/harness-op$PR-$tag"
}

build_variant rv64gc  gc  || exit 1
build_variant rv64gcv gcv || exit 1
log "OPACC BUILD DONE (pr$PR)"
