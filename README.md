# agent-harness

제한 시간 안에 AI 코딩 에이전트(Codex CLI · Claude Code)와 과제 하나를 끝내기 위한 작업 틀이다.
널리 쓰이는 공개 스킬을 고쳐 쓰지 않고 그대로 모았고, 그 위에 하루 진행표와 작업 파일 뼈대, 붙여 쓰는 프롬프트를 얹었다.

목표는 세 가지다: **현장에서 쓰이는 결과물**을 만들고, **왜 그렇게 정했는지**가 파일에 남고, 만든 것을 **내가 설명할 수 있게** 한다.

## 바로 쓰기

```bash
git clone https://github.com/jwyssey/agent-harness && cd agent-harness
./install.sh                      # 핵심 스킬 → ~/.codex/skills 와 ~/.claude/skills
./install.sh init ~/workspace     # PLAN.md 등 작업 파일을 워크스페이스에 복사(있는 파일은 건드리지 않음)
./install.sh --with ml,ui         # 과제를 본 뒤 필요한 묶음만 추가 (ml | ui | parallel | all)
./install.sh list                 # 무엇이 있고 무엇이 설치됐나
./install.sh uninstall            # 이 스크립트가 설치한 것만 지움
```

설치한 뒤에는 **새 세션**을 열어야 스킬 목록이 다시 읽힌다.

| | Codex CLI | Claude Code |
|---|---|---|
| 스킬 부르기 | `$grilling` 또는 `/skills` 에서 선택 | `/grilling` |
| 사용자 단위 위치 | `~/.codex/skills/` (`~/.agents/skills/` 도 읽음) | `~/.claude/skills/` |
| 프로젝트 단위 위치 | `<repo>/.agents/skills/` (`./install.sh --project <repo>`) | `<repo>/.claude/skills/` |

## 들어 있는 것

| 경로 | 내용 |
|---|---|
| [RUNBOOK.md](RUNBOOK.md) | 시간표. 단계마다 부를 것 · 손으로 할 것 · 남길 것 |
| [FALLBACK.md](FALLBACK.md) | 아무것도 가져올 수 없을 때 손으로 치는 여덟 줄과 스킬 대신 보내는 한 줄 |
| `prompts/` | 빈칸을 채워 붙이는 프롬프트 10개(질문 설계 · KPI 사슬 · 설계 대화 · 평가 고정 · 인수 기준 · goal · 대조 · 추적 · 리뷰 통합 · 셀프 출제) |
| `templates/` | 작업 파일 뼈대: PLAN · RESULTS · DECISIONS · ARCHITECTURE · PITCH · `check.sh` · AGENTS 추가 줄 · 리뷰어 지시문 R1~R3 |
| `skills/` | 기본으로 설치하는 스킬 9종(+ 별칭 1) |
| `optional/` | 과제를 보고 켜는 스킬 묶음: `ml` · `ui` · `parallel` |
| `third_party/` | 원저작자 라이선스 전문 |

## 핵심 스킬

별 수는 2026-11-10 기준이다. 모두 원본 그대로이며 출처와 커밋은 [NOTICE.md](NOTICE.md)에 있다.

| 스킬 | 출처(★) | 하는 일 | 쓰는 때 |
|---|---|---|---|
| `grilling` (`grill-me`) | mattpocock/skills (319k) | 계획의 결정들을 선행 관계 순서로 한 라운드씩 캐묻고, 질문마다 추천 답을 붙인다 | KPI · 범위를 고른 직후 |
| `to-questionnaire` | mattpocock/skills | 내가 답할 수 없는 것을 상대에게 물을 질문 문서로 만든다 | 담당자 질문 초안 |
| `handoff` | mattpocock/skills | 대화를 새 세션이 이어받을 문서로 줄인다 | 마일스톤 끝, 새 세션으로 넘어가기 전 |
| `verification-before-completion` | obra/superpowers (315k) | 완료라고 말하기 전에 검사 명령을 돌리고 출력으로 확인하게 한다 | 상시 |
| `receiving-code-review` | obra/superpowers | 리뷰 지적을 그대로 따르지 않고 코드에서 확인한 뒤 수용 · 반박하게 한다 | 리뷰 결과를 받은 뒤 |
| `systematic-debugging` | obra/superpowers | 원인을 찾기 전에는 고치지 않는 4단계 디버깅 | 같은 수정이 두 번 실패했을 때 |
| `karpathy-guidelines` | multica-ai/andrej-karpathy-skills (231k) | 가정을 드러내고, 단순하게, 필요한 곳만 고치고, 검증할 수 있는 완료 조건을 두는 네 가지 규칙 | 상시 |
| `define-goal` | openai/skills (29k) | 흐린 목표를 결과 · 검증 방법 · 범위 · 멈출 조건이 있는 goal 로 다듬는다 | `/goal` 직전 |
| `learning-opportunities` | DrCatHicks/learning-opportunities (2.5k) | 예측 → 관찰, 경로 따라가기 같은 짧은 연습으로 방금 만든 것을 이해하게 한다 | 마일스톤 직후 |

## 조건부 스킬 (`optional/`)

| 묶음 | 스킬 | 출처(★) | 켜는 조건 |
|---|---|---|---|
| `ml` | `scikit-learn` · `shap` · `statsmodels` · `aeon` | K-Dense-AI/scientific-agent-skills (57k) | 표 데이터 모델링 · 설명 · 시계열이 과제의 중심일 때 |
| `ui` | `developing-with-streamlit` | streamlit/agent-skills (226) | 화면을 Streamlit 으로 만들 때 |
| `ui` | `frontend-design` · `webapp-testing` | anthropics/skills (191k) | 웹 화면을 직접 만들 때 / Playwright 를 쓸 수 있을 때 |
| `parallel` | `using-git-worktrees` · `dispatching-parallel-agents` | obra/superpowers | 서로 다른 가설 2개를 같은 평가로 동시에 볼 때 |

## 넣지 않은 것

- **플러그인 통째 설치**(superpowers 전체, gstack, spec-kit 류): 세션 시작 훅과 정해진 작업 사슬이 따라와서, 제공된 환경의 지시문이나 짧은 시간표와 부딪힌다. 필요한 스킬만 낱개로 가져왔다.
- **기능이 겹치는 큰 스킬**(brainstorming, interview-me 등): `grilling` 하나로 충분하고 지시문이 길수록 토큰을 더 쓴다.

## 스킬을 쓸 때 지킬 것

- 스킬이 대신 결정하게 두지 않는다. 부르기 전에 내 생각을 한두 줄 쓰고, 추천 답에는 이유를 붙여 내 말로 답한다.
- 스킬은 워크스페이스가 아니라 홈 폴더에 설치하는 것이 기본이다. 워크스페이스에는 작업 파일만 둔다.
- 제공된 환경에 `AGENTS.md` 가 있으면 그것이 우선이다. `templates/AGENTS.append.md` 는 읽고 나서 필요한 줄만 덧붙인다.
- 써 보지 않은 스킬은 쓰지 않는다. 미리 한 번씩 돌려 본 것만 남긴다.

## 라이선스

이 저장소에서 새로 쓴 문서 · 스크립트(`RUNBOOK.md`, `FALLBACK.md`, `prompts/`, `templates/`, `install.sh`)는 MIT 이다.
`skills/` 와 `optional/` 아래의 스킬은 각 원저작자의 것이고 각자의 라이선스를 따른다 → [NOTICE.md](NOTICE.md).
