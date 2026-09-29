#!/usr/bin/env bash
# #2 用 gcc-15 重建（依赖预置版）。
# 供体为同一提交 #2 自己的 gcc-14 构建树，依赖版本按定义完全一致，无跨提交污染风险
# （对比：为 #4 预置时曾发现其与 #2 锁定的 abseil 并非同一 commit，故当时只借用了
#  逐字节比对确认一致的 8 项）。
set -uo pipefail
W=/work/s2602; LOG=$W/logs; G=$W/gcc15/root; D=$W/build-pr2-gcc-14
SRC=$W/src/rvspoc-S2602-litert-pr2; BLD=$W/build-pr2-gcc15
TFSRC=$W/tf-shared; TSL="-I$TFSRC/third_party/xla/xla"
export PATH="$G/usr/bin:$PATH"
log(){ echo "[$(date -u +%FT%TZ)] $*"; }

SEED=()
for d in "$D"/*/; do
  n=$(basename "$d"); [ -f "$d/CMakeLists.txt" ] || continue
  case "$n" in *-download|*-source) continue;; esac
  u=$(printf '%s' "$n" | tr '[:lower:]' '[:upper:]')   # 保留连字符
  SEED+=( "-DFETCHCONTENT_SOURCE_DIR_${u}=$d" )
done
log "预置依赖 ${#SEED[@]} 项: $(printf '%s ' "${SEED[@]}" | grep -oE 'SOURCE_DIR_[A-Z0-9_-]+' | sed 's/SOURCE_DIR_//' | tr '\n' ' ')"
log "编译器: $($G/usr/bin/gcc-15 --version | head -1)"

log "configure"
if cmake -S "$SRC/tflite" -B "$BLD" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="$G/usr/bin/gcc-15" -DCMAKE_CXX_COMPILER="$G/usr/bin/g++-15" \
    -DCMAKE_C_FLAGS="-march=rv64gcv -mabi=lp64d $TSL" \
    -DCMAKE_CXX_FLAGS="-march=rv64gcv -mabi=lp64d $TSL" \
    -DTENSORFLOW_SOURCE_DIR="$TFSRC" \
    -DTFLITE_ENABLE_XNNPACK=OFF -DTFLITE_ENABLE_GPU=OFF \
    "${SEED[@]}" > "$LOG/pr2-gcc15.cmake.log" 2>&1; then
  log "configure 成功"
else
  log "configure 失败"; tail -10 "$LOG/pr2-gcc15.cmake.log"; exit 1
fi

log "构建 tensorflow-lite"
t0=$(date +%s)
if cmake --build "$BLD" -j"$(nproc)" --target tensorflow-lite > "$LOG/pr2-gcc15.build.log" 2>&1; then
  log "RESULT 构建成功（$(( $(date +%s)-t0 ))s）"
else
  log "RESULT 构建失败（$(( $(date +%s)-t0 ))s）"
  grep -iE "error:" "$LOG/pr2-gcc15.build.log" | grep -v warning | head -5; exit 1
fi

log "编译 harness"
incs=(-I"$SRC" -I"$SRC/tflite" -I"$TFSRC" -I"$TFSRC/third_party/xla/xla")
for d in "$BLD"/_deps/*-src "$BLD"/*/; do
  [ -d "$d" ] && incs+=(-I"$d"); [ -d "$d/include" ] && incs+=(-I"$d/include")
done
if "$G/usr/bin/g++-15" -O2 -std=c++17 -march=rv64gcv -mabi=lp64d \
     "$W/accuracy_harness.cc" "${incs[@]}" -o "$W/bin/harness-pr2-gcc15" \
     "$BLD/libtensorflow-lite.a" $(find "$BLD" -name "*.a" -not -name "libtensorflow-lite.a" | tr '\n' ' ') \
     -lpthread -ldl -lm > "$LOG/pr2-gcc15.harness.log" 2>&1; then
  log "harness OK"
else
  log "harness 编译失败"; tail -8 "$LOG/pr2-gcc15.harness.log"; exit 1
fi

log "精度复测（两个 MobileNet INT8 + 对照的 EfficientNet INT8，各 500 张）"
for m in mobilenet_v2_1.0_224_quant mobilenet_v1_1.0_224_quant; do
  r=$("$W/bin/harness-pr2-gcc15" acc "$W/models/$m.tflite" \
        "$W/tensor_dump/tensors_u8.bin" "$W/tensor_dump/labels.i32" 500 1 2>/dev/null | tail -1)
  log "RESULT gcc15 $m -> $r"
done
r=$("$W/bin/harness-pr2-gcc15" acc "$W/models/efficientnet-lite0/efficientnet-lite0-int8.tflite" \
      "$W/tensor_dump/tensors_u8.bin" "$W/tensor_dump/labels.i32" 500 1 2>/dev/null | tail -1)
log "RESULT gcc15 efficientnet_lite0_int8 -> $r"
log "PR2 GCC15 DONE"
