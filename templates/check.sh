#!/usr/bin/env bash
# 커밋 전마다 실행한다. 하나라도 실패하면 0이 아닌 값으로 끝난다.
# 실행 검증(tests/ · PLAN.md 5번 검증 명령 · 아래 주석 단계)이 하나도 돌지 않으면 통과로 치지 않는다(종료 코드 2).
# 같은 지적이 두 번 나오면 그 검사를 여기에 한 줄 추가한다.
set -uo pipefail
fail=0
ran=0
step() { printf '\n== %s\n' "$1"; }
PY="$(command -v python3 || command -v python || true)"

step "tests"
if [ -d tests ] && [ -n "$PY" ]; then
  ran=1; "$PY" -m pytest -q || fail=1
else
  echo "tests/ 없음 - 건너뜀"
fi

step "검증 명령 (PLAN.md 5번)"
VERIFY="$(grep -m1 -E '^- 검증 명령[^:]*:' PLAN.md 2>/dev/null | sed -E 's/^- 검증 명령[^:]*: *//; s/^`//; s/`$//' || true)"
if [ -z "$VERIFY" ] || [ "${VERIFY#*___}" != "$VERIFY" ]; then
  echo "PLAN.md 5번 '검증 명령:' 이 비어 있음 - 건너뜀"
else
  ran=1; echo "\$ $VERIFY"; bash -c "$VERIFY" || fail=1
fi

# 아래 두 단계는 파일이 고정된 그대로인지만 본다. 실행 검증으로 세지 않는다.
step "eval 고정 (해시)"
if [ -f eval.sha256 ]; then
  sha256sum -c eval.sha256 || fail=1
else
  echo "eval.sha256 없음 - 건너뜀"
fi

# 해시 파일까지 새로 찍으면 위 검사는 통과한다. 그래서 고정 커밋 이후의 변경을 따로 본다.
step "eval 고정 (고정 커밋 이후 변경)"
FREEZE="$(grep -oE 'eval 고정 커밋: *[0-9a-f]{7,40}' PLAN.md 2>/dev/null | tail -n 1 | grep -oE '[0-9a-f]{7,40}$' || true)"
if [ -z "$FREEZE" ]; then
  echo "PLAN.md에 'eval 고정 커밋: <해시>' 줄이 없음 - 건너뜀"
elif ! git cat-file -e "$FREEZE^{commit}" 2>/dev/null; then
  echo "고정 커밋 $FREEZE 를 찾을 수 없음"; fail=1
elif ! changed="$(git diff --name-only "$FREEZE" -- eval data/split.json eval.sha256 2>&1)"; then
  echo "git diff 실패: $changed"; fail=1
elif [ -n "$changed" ]; then
  echo "고정 커밋 $FREEZE 이후 바뀐 파일:"; echo "$changed" | sed 's/^/  /'
  echo "담당자 기준이 바뀌어 고친 것이면 PLAN.md에 새 고정 커밋 줄과 이유를 남긴다."
  fail=1
else
  echo "변경 없음 ($FREEZE)"
fi

# 필요할 때 주석을 풀어 쓴다.
# step "lint";  ran=1; ruff check . || fail=1
# step "앱 기동"; ran=1; timeout 20 "$PY" -c "import app" || fail=1

echo
if [ "$fail" = 0 ] && [ "$ran" = 0 ]; then
  echo "check: NOT CONFIGURED - 실행한 검증이 없다. tests/ 를 만들거나 PLAN.md 5번 '검증 명령:' 을 채운다."; exit 2
fi
if [ "$fail" = 0 ]; then echo "check: OK"; else echo "check: FAIL"; fi
exit "$fail"
