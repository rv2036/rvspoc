#!/usr/bin/env bash
# RVSPOC 2026 复现验证 — 第一步：批量编译（memo §4.B 可复现性）
#
# 在 LX5000 上按各 PR 说明文件的步骤编译 S2603/S2604/S2605 的 11 个提交。
# 每个 PR 独立目录、独立日志；失败不中断后续，失败现象留档以进公开讨论流程。
#
# cmd_source 字段记录构建命令的来源，判定时必须区分：
#   doc         — 取自选手说明文件或 PR 描述，失败即为选手侧问题
#   doc-adapted — 取自选手文档但改了其中的绝对路径等环境相关项
#   default     — 选手文档未给明确命令，用项目常规构建；**失败不得直接判选手不合格**，
#                 须回查文档后人工复核

set -uo pipefail

BASE="$HOME/rvspoc-verify"
SRC="$BASE/src"; LOG="$BASE/logs"; RES="$BASE/results"
mkdir -p "$SRC" "$LOG" "$RES"
ORG=rv2036
JOBS=$(nproc)

log() { echo "[$(date -u +%FT%TZ)] $*"; }

SPECS=(
  "rvspoc-S2603-redis|2|5a29525ade3bedf37956cc1d1f389fe562c0464e|make -C src -j$JOBS|default"
  "rvspoc-S2603-redis|3|621fc1bd7b59b53040831e4847c2be4eb219d004|make -j$JOBS CC=gcc-14 REDIS_CFLAGS=-fno-omit-frame-pointer|doc"
  "rvspoc-S2603-redis|4|82647349bae3838890184483e0b9865468ecca24|make -C src -j$JOBS redis-server redis-cli redis-benchmark|doc"
  "rvspoc-S2603-redis|6|6dbbc85eeda393863bd3fb4cc4fe1e85ec300769|make -C src -j$JOBS BUILD_RVV=yes MALLOC=libc BUILD_TLS=no|doc"
  "rvspoc-S2604-memcached|1|e52d97f5292e6c3d02575c050a206fc48ce0df05|./autogen.sh && ./configure && make -j$JOBS|doc"
  "rvspoc-S2604-memcached|2|7ee8609d9cf70ca3234e79059c6e6c840b8bbdc4|./autogen.sh && ./configure --enable-riscv-rvv CC=gcc-14 && make -j$JOBS|doc"
  "rvspoc-S2604-memcached|3|883e87647e6a7b0c0985a36f7314f6330c2d7ed9|./autogen.sh && ./configure && make -j$JOBS memcached testapp|doc"
  "rvspoc-S2605-rocksdb|1|7847ab1e4bf62d54dcfbf04d7ab66c81eba75f7b|make -j$JOBS db_bench DEBUG_LEVEL=0 DISABLE_WARNING_AS_ERROR=1|doc"
  "rvspoc-S2605-rocksdb|2|1e390720396ea52e76903854f5cc08de588b48c2|make -j$JOBS db_bench DEBUG_LEVEL=0 DISABLE_WARNING_AS_ERROR=1|doc"
  "rvspoc-S2605-rocksdb|3|fa3fd926f91dd69528387bd54ff4c1740e3156bc|make -j$JOBS db_bench DEBUG_LEVEL=0 DISABLE_WARNING_AS_ERROR=1|default"
  "rvspoc-S2605-rocksdb|4|9ec8dc8e446ef95d1311ae93e2242e72f274c5c6|cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DWITH_GFLAGS=1 -DWITH_BENCHMARK_TOOLS=1 && cmake --build build -j$JOBS --target db_bench|doc-adapted"
)

STATUS="$RES/build_status.tsv"
[ -f "$STATUS" ] || printf 'repo\tpr\tsha\tresult\tseconds\tcmd_source\tcmd\n' > "$STATUS"

for spec in "${SPECS[@]}"; do
  IFS='|' read -r repo pr sha cmd cmdsrc <<< "$spec"
  tag="${repo}-pr${pr}"
  dir="$SRC/$tag"
  lf="$LOG/${tag}.build.log"

  # 已成功且工作树仍在的才跳过；工作树缺失则必须重建（后续阶段依赖它）
  if grep -q "^${repo}	${pr}	.*	OK	" "$STATUS" 2>/dev/null && [ -d "$dir/.git" ]; then
    log "skip $tag (already OK)"; continue
  fi

  log "=== $tag @ ${sha:0:8} [$cmdsrc] ==="

  # 每个仓库只从 GitHub 克隆一次，各 PR 的工作树从本地缓存派生。
  # 板子到 GitHub 的链路在大仓库（redis ~700M、rocksdb ~2G）上会中途断连
  # （fetch-pack: unexpected disconnect），逐 PR 重复克隆必然反复失败。
  cache="$SRC/_cache/$repo"
  if [ ! -d "$cache/.git" ]; then
    mkdir -p "$SRC/_cache"
    for a in 1 2 3 4 5; do
      git clone --quiet "https://github.com/$ORG/$repo.git" "$cache" && break
      log "  cache clone retry $a"; rm -rf "$cache"; sleep 30
    done
  fi
  [ -d "$cache/.git" ] || { printf '%s\t%s\t%s\tCLONE_FAIL\t0\t%s\t%s\n' "$repo" "$pr" "$sha" "$cmdsrc" "$cmd" >> "$STATUS"; continue; }

  # PR head 可能在 fork 上，先抓进缓存（小增量，链路压力低）
  for a in 1 2 3 4 5; do
    git -C "$cache" fetch --quiet origin "pull/$pr/head:refs/prs/$pr" 2>/dev/null && break
    log "  fetch pull/$pr retry $a"; sleep 20
  done

  # 从本地缓存派生（走文件系统，不碰网络），随后立即 repack 断开对缓存的对象依赖：
  # --shared 的派生树不拥有自己的对象，缓存侧一旦变动或被 gc，工作树即损坏，
  # 而后续正确性/性能阶段还要用这些树。
  if [ ! -d "$dir/.git" ]; then
    git clone --quiet --shared "$cache" "$dir" 2>>"$lf" || {
      printf '%s\t%s\t%s\tCLONE_FAIL\t0\t%s\t%s\n' "$repo" "$pr" "$sha" "$cmdsrc" "$cmd" >> "$STATUS"; continue; }
    git -C "$dir" fetch --quiet "$cache" "refs/prs/$pr:refs/prs/$pr" 2>>"$lf"
    git -C "$dir" repack -a -d --quiet 2>>"$lf"
    rm -f "$dir/.git/objects/info/alternates"
  fi
  if ! git -C "$dir" checkout --quiet --detach "$sha" 2>>"$lf"; then
    log "  CHECKOUT FAILED"
    printf '%s\t%s\t%s\tCHECKOUT_FAIL\t0\t%s\t%s\n' "$repo" "$pr" "$sha" "$cmdsrc" "$cmd" >> "$STATUS"; continue
  fi
  git -C "$dir" clean -qfdx

  log "  \$ $cmd"
  t0=$(date +%s)
  if ( cd "$dir" && eval "$cmd" ) > "$lf" 2>&1; then res=OK; else res=BUILD_FAIL; fi
  t=$(( $(date +%s) - t0 ))
  log "  -> $res (${t}s)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$repo" "$pr" "$sha" "$res" "$t" "$cmdsrc" "$cmd" >> "$STATUS"
done

log "BUILD PHASE DONE"
cut -f1-6 "$STATUS" | column -t -s$'\t'
