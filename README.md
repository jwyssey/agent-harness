# agent-harness

제한 시간 안에 AI 코딩 에이전트(Codex CLI · Claude Code)와 과제 하나를 끝내기 위한 작업 틀이다.
널리 쓰이는 공개 스킬을 고쳐 쓰지 않고 그대로 모았고, 그 위에 하루 진행표와 작업 파일 뼈대, 붙여 쓰는 프롬프트를 얹었다.

목표는 세 가지다: **현장에서 쓰이는 결과물**을 만들고, **왜 그렇게 정했는지**가 파일에 남고, 만든 것을 **내가 설명할 수 있게** 한다.

## 바로 쓰기

```bash
git clone https://github.com/jwyssey/agent-harness && cd agent-harness
./install.sh                      # 핵심 스킬 → ~/.codex/skills 와 ~/.claude/skills (이름으로 부를 때만 돈다)
./install.sh init ~/workspace     # PLAN.md 등 작업 파일 복사. AGENTS.md 는 없을 때만 만든다
./install.sh --with ui            # 과제를 읽은 뒤 필요한 묶음만 추가 (ml | ui | parallel | process | all)
./install.sh list                 # 무엇이 있고 무엇이 설치됐나
./install.sh uninstall            # 이 스크립트가 설치한 것만 지움
```

설치한 뒤에는 **새 세션**을 열어야 스킬 목록과 `AGENTS.md` 가 다시 읽힌다.

| | Codex CLI | Claude Code |
|---|---|---|
| 지시 파일 | `AGENTS.md` (홈 `~/.codex/AGENTS.md` → 저장소 루트 → 현재 폴더 순으로 읽음) | `CLAUDE.md` (`@AGENTS.md` 한 줄을 적으면 같은 파일을 읽는다) |
| 스킬 부르기 | `$grilling` 또는 `/skills` 에서 선택 | `/grilling` |
| 사용자 단위 위치 | `~/.codex/skills/` (`~/.agents/skills/` 도 읽음) | `~/.claude/skills/` |
| 프로젝트 단위 위치 | `<repo>/.agents/skills/` (`./install.sh --project <repo>`) | `<repo>/.claude/skills/` |

## 들어 있는 것

| 경로 | 내용 |
|---|---|
| [RUNBOOK.md](RUNBOOK.md) | 시간표. 단계마다 부를 것 · 손으로 할 것 · 남길 것 |
| [GUIDE.md](GUIDE.md) | 왜 이렇게 짰나. 근거가 된 연구와 글, 스킬을 고른 기준 |
| [FALLBACK.md](FALLBACK.md) | 아무것도 가져올 수 없을 때 손으로 치는 여덟 줄과 스킬 대신 보내는 한 줄 |
| `prompts/` | 빈칸을 채워 붙이는 프롬프트 10개(질문 설계 · KPI 사슬 · 설계 대화 · 평가 고정 · 인수 기준 · goal · 대조 · 추적 · 리뷰 통합 · 셀프 출제) |
| `templates/` | 작업 파일 뼈대: PLAN · RESULTS · DECISIONS · ARCHITECTURE · PITCH · `check.sh` · `AGENTS.md` · 리뷰어 지시문 R1~R3 |
| `skills/` | 기본으로 설치하는 스킬 5종 |
| `optional/` | 과제를 보고 켜는 스킬 묶음: `ml` · `ui` · `parallel` · `process` |
| `third_party/` | 원저작자 라이선스 전문 |

## 세 가지를 나눠 맡는다

Storey(2026)는 AI와 만든 소프트웨어의 빚을 기술 · 의도 · 인지 세 가지로 나눈다. 그 구분을 빌려 파일을 정리했다. 아래 대응은 이 저장소의 설계 선택이다.

| 무엇 | 묻는 것 | 사람이 하는 일 | 파일 · 프롬프트 | 스킬 |
|---|---|---|---|---|
| **의도** | 무엇을 왜 만드나 | 담당자에게 묻고, 목표와 만들지 않을 것을 고른다 | `PLAN.md` · `DECISIONS.md` · `prompts/01~06` | `grilling` · `define-goal` |
| **기술** | 실제로 돌아가나 | 평가를 먼저 고정하고 대조표를 직접 확인한다 | `check.sh` · `RESULTS.md` · `review/R1~R3` · `prompts/04 · 07 · 09` | 없음(`AGENTS.md` 의 줄로 충분) |
| **인지** | 내가 설명할 수 있나 | 요청 한 건의 흐름을 AI 없이 말하고, 발표와 답을 직접 한다 | `ARCHITECTURE.md` · `PITCH.md` · `prompts/08 · 10` | `learning-opportunities` · `pitch-prep` |

`handoff` 는 세션을 바꿀 때 이 셋의 기록을 다음 세션으로 넘긴다.

## 핵심 스킬

별 수는 2026-11-10 기준이다. `pitch-prep` 만 이 저장소에서 썼고 나머지는 원본 그대로다. 출처와 커밋은 [NOTICE.md](NOTICE.md)에 있다.

| 스킬 | 출처(★) | 하는 일 | 쓰는 때 |
|---|---|---|---|
| `grilling` | mattpocock/skills (319k) | 계획의 결정들을 선행 관계 순서로 한 라운드씩 캐묻고, 질문마다 추천 답을 붙인다 | KPI · 범위를 고른 직후 |
| `define-goal` | openai/skills (29k) | 흐린 목표를 결과 · 검증 방법 · 범위 · 멈출 조건이 있는 goal 로 다듬는다 | `/goal` 직전 |
| `learning-opportunities` | DrCatHicks/learning-opportunities (2.5k) | 예측 → 관찰, 경로 따라가기 같은 짧은 연습으로 방금 만든 것을 이해하게 한다 | 마일스톤 직후 |
| `handoff` | mattpocock/skills | 대화를 새 세션이 이어받을 문서로 줄인다 | 마일스톤 끝, 새 세션으로 넘어가기 전 |
| `pitch-prep` | 이 저장소 | 작업 기록에서 발표 뼈대를 뽑고, 약한 지점부터 하나씩 물어 내 답을 파일과 대조한다. 대본은 쓰지 않는다 | 동결 직후 |

**스킬은 이름으로 부를 때만 돈다.** 설치할 때 각 스킬에 자동 호출을 끄는 설정을 붙인다(Codex 는 `agents/openai.yaml` 의 `allow_implicit_invocation: false`, Claude Code 는 `disable-model-invocation: true`). 설명 문구만 보고 에이전트가 과제와 맞지 않는 절차를 끌어오는 일을 막기 위해서다. 원본의 자동 호출을 그대로 두려면 `./install.sh --auto`.

## 조건부 스킬 (`optional/`)

과제를 읽고 그 도구를 쓰기로 정한 뒤에만 설치한다. 도메인이 정해지기 전에는 설치하지 않는다.

| 묶음 | 스킬 | 출처(★) | 켜는 조건 |
|---|---|---|---|
| `ml` | `scikit-learn` · `shap` · `statsmodels` · `aeon` | K-Dense-AI/scientific-agent-skills (57k) | 표 데이터 모델링 · 설명 · 시계열이 과제의 중심일 때 |
| `ui` | `developing-with-streamlit` | streamlit/agent-skills (226) | 화면을 Streamlit 으로 만들 때 |
| `ui` | `frontend-design` · `webapp-testing` | anthropics/skills (191k) | 웹 화면을 직접 만들 때 / Playwright 를 쓸 수 있을 때 |
| `parallel` | `using-git-worktrees` · `dispatching-parallel-agents` | obra/superpowers (315k) | 서로 다른 가설 2개를 같은 평가로 동시에 볼 때 |
| `process` | `verification-before-completion` · `receiving-code-review` · `systematic-debugging` | obra/superpowers | 쓰는 모델이 검증 · 원인 진단을 스스로 하지 않을 때 |
| `process` | `to-questionnaire` | mattpocock/skills | 마주 앉아 물을 수 없어 질문 문서를 보내야 할 때 |

## 넣지 않은 것

- **플러그인 통째 설치**(superpowers 전체, gstack, spec-kit 류): 세션 시작 훅과 정해진 작업 사슬이 따라와서, 제공된 환경의 지시문이나 짧은 시간표와 부딪힌다. 필요한 스킬만 낱개로 가져왔다.
- **기능이 겹치는 큰 스킬**(brainstorming, interview-me 등): `grilling` 하나로 충분하고 지시문이 길수록 토큰을 더 쓴다.
- **늘 켜 두는 절차 스킬**: 검증 · 디버깅 · 리뷰 수용은 기본 설치에서 뺐다. 최신 모델에서는 이런 지시가 중복이 되기 쉽고, 단계가 촘촘한 지시는 과제와 맞지 않을 때 오히려 결과를 나쁘게 한다. 같은 내용은 `AGENTS.md` 의 몇 줄과 FALLBACK 의 한 줄로 남겼다 → [GUIDE.md](GUIDE.md).

## 스킬을 쓸 때 지킬 것

- 과제 문서와 제공된 지시가 스킬보다 우선한다. 전제가 다르거나 절차가 과하면 부르지 않는다.
- 스킬이 대신 결정하게 두지 않는다. 부르기 전에 내 생각을 한두 줄 쓰고, 추천 답에는 이유를 붙여 내 말로 답한다.
- 스킬은 워크스페이스가 아니라 홈 폴더에 설치하는 것이 기본이다. 워크스페이스에는 작업 파일만 둔다.
- 제공된 환경에 `AGENTS.md` 가 있으면 그것이 우선이다. `init` 은 그 파일을 건드리지 않고 `AGENTS.append.md` 를 옆에 둔다. 읽고 나서 부딪히지 않는 줄만 덧붙인다.
- 써 보지 않은 스킬은 쓰지 않는다. 미리 한 번씩 돌려 본 것만 남긴다.

## 라이선스

이 저장소에서 새로 쓴 문서 · 스크립트(`RUNBOOK.md`, `GUIDE.md`, `FALLBACK.md`, `prompts/`, `templates/`, `install.sh`, `skills/pitch-prep`)는 MIT 이다.
`skills/` 와 `optional/` 아래의 나머지 스킬은 각 원저작자의 것이고 각자의 라이선스를 따른다 → [NOTICE.md](NOTICE.md).
