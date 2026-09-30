#!/usr/bin/env bash
# S2602 算子级精度（§4.C）—— 第一步：打通上游 kernel 单测路径。
#
# 选 #2 作为首个打通对象有两个理由：
#   1. build-pr2-gcc-14 依赖齐全、已配置，无须重新抓取（本机 GitHub 抓取屡次超时）；
#   2. #2 是目前唯一「精度失败已确证、成因无法判定」的提交（两个 MobileNet INT8 归零，
#      而同次构建的 EfficientNet INT8 正常）。kernel 单测是逐算子的
#      「优化实现 vs reference_ops」比对，有可能把失败定位到具体算子。
#
# 注意：kernel 单测的基准在测试内部（reference_ops），不依赖外部参考值，
# 故不受「算子级对比基准未定」这一待裁定事项阻塞；裁定决定的是结果算不算数。
set -uo pipefail
W=/work/s2602; LOG=$W/logs; BLD=$W/build-pr2-gcc-14
SRC=$W/src/rvspoc-S2602-litert-pr2; TFSRC=$W/tf-shared
log(){ echo "[$(date -u +%FT%TZ)] $*"; }

log "磁盘余量: $(df -h /work | awk 'NR==2{print $4}')"
log "重新配置，打开 TFLITE_KERNEL_TEST"
if cmake -S "$SRC/tflite" -B "$BLD" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=gcc-14 -DCMAKE_CXX_COMPILER=g++-14 \
    -DCMAKE_C_FLAGS="-march=rv64gcv -mabi=lp64d -I$TFSRC/third_party/xla/xla" \
    -DCMAKE_CXX_FLAGS="-march=rv64gcv -mabi=lp64d -I$TFSRC/third_party/xla/xla" \
    -DTENSORFLOW_SOURCE_DIR="$TFSRC" \
    -DTFLITE_ENABLE_XNNPACK=OFF -DTFLITE_ENABLE_GPU=OFF \
    -DTFLITE_KERNEL_TEST=ON \
    > "$LOG/kt-pr2.cmake.log" 2>&1; then
  log "configure 成功"
else
  log "configure 失败"; tail -12 "$LOG/kt-pr2.cmake.log"; exit 1
fi

log "枚举已注册的 kernel 测试目标"
mapfile -t TARGETS < <(cmake --build "$BLD" --target help 2>/dev/null \
  | grep -oE "[a-z0-9_]+_test" | sort -u)
log "共 ${#TARGETS[@]} 个测试目标"
printf '%s\n' "${TARGETS[@]}" > "$W/results/kernel_test_targets.txt"

# 先只建本题考点相关的几个，验证路径可行；全量 137 个留到确认后再铺开。
PRIORITY=(depthwiseconv_quantized_test depthwiseconv_float_test
          depthwiseconv_per_channel_quantized_test softmax_quantized_test
          resize_bilinear_test tensor_utils_test)
built=0; failed=0
for t in "${PRIORITY[@]}"; do
  printf '%s\n' "${TARGETS[@]}" | grep -qx "$t" || { log "  跳过 $t（未注册）"; continue; }
  log "PROGRESS: 构建 $t"
  if cmake --build "$BLD" -j"$(nproc)" --target "$t" >> "$LOG/kt-pr2.build.log" 2>&1; then
    built=$((built+1)); log "  $t 构建成功"
  else
    failed=$((failed+1)); log "  $t 构建失败"
    grep -iE "error:" "$LOG/kt-pr2.build.log" | tail -3
  fi
done
log "RESULT 构建成功 $built，失败 $failed"
log "磁盘余量: $(df -h /work | awk 'NR==2{print $4}')"
log "KERNEL TEST BUILD DONE"
