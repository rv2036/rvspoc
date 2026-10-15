#!/usr/bin/env bash
# RVSPOC 2026 复现验证 — 第二步：功能正确性（memo §4.C）
#
# 只对编译成功的提交执行。各题按备忘录口径：
#   S2603  Redis 自带回归测试集
#   S2604  Memcached 自带回归测试集（testapp / make test）
#   S2605  make check + db_test
#
# 注意：本脚本只跑测试并留档，**不做通过与否的最终判定**——
# 上游测试集本身在 RISC-V 上可能有已知失败项，须与标量对照组比较后由评审人定性。

set -uo pipefail
BASE="$HOME/rvspoc-verify"
SRC="$BASE/src"; LOG="$BASE/logs"; RES="$BASE/results"
STATUS="$RES/build_status.tsv"
RETRY="$RES/build_retry.tsv"
OUT="$RES/correctness.tsv"
JOBS=$(nproc)
TEST_TIMEOUT=3600

log() { echo "[$(date -u +%FT%TZ)] $*"; }
[ -f "$OUT" ] || printf 'repo\tpr\tsuite\tresult\tseconds\tpassed\tfailed\tlog\n' > "$OUT"

# 收集编译成功的提交（首轮 OK 或 gcc-14 重试 OK）
built() {
  awk -F'\t' 'NR>1 && $4=="OK"{print $1"\t"$2}' "$STATUS" 2>/dev/null
  awk -F'\t' 'NR>1 && $3=="OK_WITH_GCC14"{print $1"\t"$2}' "$RETRY" 2>/dev/null
}

run_suite() { # repo pr suite cmd
  local repo=$1 pr=$2 suite=$3 cmd=$4
  local tag="${repo}-pr${pr}" dir="$SRC/${repo}-pr${pr}"
  local lf="$LOG/${tag}.${suite}.log"
  [ -d "$dir" ] || return
  # 幂等：已记录过该 (repo, pr, suite) 结果的直接跳过，便于中断后续跑与单项重跑
  if grep -qP "^\Q${repo}\E\t\Q${pr}\E\t\Q${suite}\E\t" "$OUT" 2>/dev/null; then
    log "skip $tag :: $suite (已有结果)"; return
  fi
  log "=== $tag :: $suite ==="
  local t0=$(date +%s)
  if ( cd "$dir" && timeout "$TEST_TIMEOUT" bash -c "$cmd" ) > "$lf" 2>&1; then res=PASS; else res=FAIL; fi
  local t=$(( $(date +%s) - t0 ))
  # 粗略统计通过/失败数，供人工复核参考（各测试框架格式不一，仅作提示）
  local p=$(grep -ciE '\[ok\]|\bOK\b|passed|PASS' "$lf" 2>/dev/null); p=${p:-0}
  local f=$(grep -ciE '\[err\]|\[exception\]|FAILED|\bFAIL\b' "$lf" 2>/dev/null); f=${f:-0}
  log "  -> $res (${t}s, ok~$p err~$f)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$repo" "$pr" "$suite" "$res" "$t" "$p" "$f" "$lf" >> "$OUT"
}

# --- 标量对照组 ---
# 上游测试集在 RISC-V 上可能本就有失败项（与选手改动无关）。先在基线的标量构建上
# 跑同一套测试，得到「上游固有失败」清单；选手侧只有**新增**的失败才归因于其改动。
CTRL="$HOME/rvspoc-baseline/src"
if [ -d "$CTRL" ]; then
  log "### 标量对照组 ###"
  for c in "$CTRL"/redis-* "$CTRL"/memcached-* "$CTRL"/rocksdb; do
    [ -d "$c" ] || continue
    name=$(basename "$c"); lf="$LOG/CONTROL.${name}.log"
    if grep -qP "^CONTROL\t\Q${name}\E\t" "$OUT" 2>/dev/null; then
      log "skip CONTROL $name (已有结果)"; continue
    fi
    case "$name" in
      redis-*)     suite=unit;    cmd="./runtest --accurate --no-latency --clients 4 --dont-clean" ;;
      memcached-*) suite=testapp; cmd="./testapp" ;;
      rocksdb)     suite=db_test; cmd="make -j$JOBS DEBUG_LEVEL=1 LIB_MODE=static DISABLE_WARNING_AS_ERROR=1 db_test && ./db_test" ;;
      *) continue ;;
    esac
    log "=== CONTROL $name :: $suite ==="
    t0=$(date +%s)
    if ( cd "$c" && timeout "$TEST_TIMEOUT" bash -c "$cmd" ) > "$lf" 2>&1; then res=PASS; else res=FAIL; fi
    t=$(( $(date +%s) - t0 ))
    p=$(grep -ciE '\[ok\]|\bOK\b|passed|PASS' "$lf" 2>/dev/null); p=${p:-0}
    f=$(grep -ciE '\[err\]|\[exception\]|FAILED|\bFAIL\b' "$lf" 2>/dev/null); f=${f:-0}
    log "  -> $res (${t}s, ok~$p err~$f)"
    printf 'CONTROL\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$suite" "$res" "$t" "$p" "$f" "$lf" >> "$OUT"
  done
fi

built | sort -u | while IFS=$'\t' read -r repo pr; do
  case "$repo" in
    rvspoc-S2603-redis)
      # --accurate 关闭随机化，保证可复现；单元测试与集成测试分开留档
      run_suite "$repo" "$pr" "unit"  "./runtest --accurate --no-latency --clients 4 --dont-clean"
      ;;
    rvspoc-S2604-memcached)
      run_suite "$repo" "$pr" "testapp" "./testapp"
      run_suite "$repo" "$pr" "maketest" "make test"
      ;;
    rvspoc-S2605-rocksdb)
      run_suite "$repo" "$pr" "db_test" "make -j$JOBS DEBUG_LEVEL=1 LIB_MODE=static DISABLE_WARNING_AS_ERROR=1 db_test && ./db_test"
      ;;
  esac
done

log "CORRECTNESS PHASE DONE"
column -t -s$'\t' "$OUT"
