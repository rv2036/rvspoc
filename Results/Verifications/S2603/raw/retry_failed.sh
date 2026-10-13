#!/usr/bin/env bash
# 对 build_all.sh 中失败的提交做第二轮重试：换用 gcc-14。
#
# 背景：板上默认 cc 是 gcc 13.3，不支持 RVV 段式存取的 tuple 类型 intrinsics
# （__riscv_vsseg3e8_v_u8m2x3 等，GCC 14 起才有）。选手若在更新的工具链上开发，
# 用板上默认编译器会失败——这是环境问题，不能记作选手代码编译不过。
#
# 重试仍失败者，才进入公开讨论流程（memo §4.B）。

set -uo pipefail
BASE="$HOME/rvspoc-verify"
SRC="$BASE/src"; LOG="$BASE/logs"; RES="$BASE/results"
STATUS="$RES/build_status.tsv"
RETRY="$RES/build_retry.tsv"
JOBS=$(nproc)

log() { echo "[$(date -u +%FT%TZ)] $*"; }
[ -f "$RETRY" ] || printf 'repo\tpr\tresult\tseconds\tcompiler\tcmd\n' > "$RETRY"

awk -F'\t' '$4=="BUILD_FAIL"{print $1"\t"$2"\t"$7}' "$STATUS" | while IFS=$'\t' read -r repo pr cmd; do
  tag="${repo}-pr${pr}"; dir="$SRC/$tag"; lf="$LOG/${tag}.build.gcc14.log"
  [ -d "$dir" ] || continue
  log "=== retry $tag with gcc-14 ==="

  # 已带 CC= 的命令不覆盖，其余统一指定 gcc-14
  # cmake 分支另加 -DPORTABLE=rv64gcv：RocksDB 的 CMake 在 PORTABLE 未设时使用
  # -march=native，而 RISC-V GCC 不接受该值（ISA string must begin with rv32/rv64）。
  # 选手的构建脚本面向交叉编译（/opt/riscv 工具链），此处改为等效的原生编译参数，
  # 保留其 rv64gcv 目标 ISA 意图。
  case "$cmd" in
    *CC=*) newcmd="$cmd" ;;
    *cmake*) newcmd="${cmd/cmake -S . -B build/cmake -S . -B build -DPORTABLE=rv64gcv -DCMAKE_C_COMPILER=gcc-14 -DCMAKE_CXX_COMPILER=g++-14}" ;;
    *configure*) newcmd="${cmd/.\/configure/.\/configure CC=gcc-14}" ;;
    *) newcmd="$cmd CC=gcc-14" ;;
  esac
  # cmake 需清掉上一轮的 cache，否则旧的 -march=native 会残留
  case "$cmd" in *cmake*) rm -rf "$dir/build" ;; esac

  ( cd "$dir" && git clean -qfdx )
  log "  \$ $newcmd"
  t0=$(date +%s)
  if ( cd "$dir" && eval "$newcmd" ) > "$lf" 2>&1; then res=OK_WITH_GCC14; else res=STILL_FAIL; fi
  t=$(( $(date +%s) - t0 ))
  log "  -> $res (${t}s)"
  printf '%s\t%s\t%s\t%s\tgcc-14\t%s\n' "$repo" "$pr" "$res" "$t" "$newcmd" >> "$RETRY"
done

log "RETRY PHASE DONE"
column -t -s$'\t' "$RETRY"
