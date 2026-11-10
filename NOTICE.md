# NOTICE — third-party skills

Everything under `skills/` and `optional/`, except `skills/pitch-prep` (written for this repository, MIT),
was copied **unmodified** from the repositories below. The files in this repository stay as upstream.
`install.sh` changes only the **installed copy**: it adds an empty `.agent-harness` marker file and, unless
`--auto` is given, turns off automatic invocation (appends `policy.allow_implicit_invocation: false` to
`agents/openai.yaml`, and adds `disable-model-invocation: true` to the `SKILL.md` frontmatter).
Full license texts are in `third_party/licenses/` or next to the skill as `LICENSE.txt`.

| Path in this repo | Source | Commit (date) | License |
|---|---|---|---|
| `skills/grilling`, `skills/grill-me`, `skills/to-questionnaire`, `skills/handoff` | [mattpocock/skills](https://github.com/mattpocock/skills) `skills/productivity/` | `4ae2317ddb` (2026-10-31) | MIT © 2026 Matt Pocock — `third_party/licenses/mattpocock-skills.LICENSE` |
| `optional/process/verification-before-completion`, `optional/process/receiving-code-review`, `optional/process/systematic-debugging`, `optional/parallel/using-git-worktrees`, `optional/parallel/dispatching-parallel-agents` | [obra/superpowers](https://github.com/obra/superpowers) `skills/` | `22f0b463e7` (2026-11-03) | MIT © 2025 Jesse Vincent — `third_party/licenses/obra-superpowers.LICENSE` |
| `optional/process/karpathy-guidelines` | [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) `skills/karpathy-guidelines/` | `2c60614193` (2026-04-20) | MIT, as stated in the upstream README and the skill's frontmatter (upstream ships no separate license file) |
| `skills/define-goal` | [openai/skills](https://github.com/openai/skills) `skills/.curated/define-goal/` | `49f948faa9` (2026-06-23) | Apache-2.0 — `skills/define-goal/LICENSE.txt` |
| `skills/learning-opportunities` | [DrCatHicks/learning-opportunities](https://github.com/DrCatHicks/learning-opportunities) by Dr. Cat Hicks | `3862d2eb6e` (2026-08-19) | [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — `third_party/licenses/learning-opportunities.LICENSE`. No changes made. |
| `optional/ui/developing-with-streamlit` | [streamlit/agent-skills](https://github.com/streamlit/agent-skills) | `c69a265613` (2026-07-23) | Apache-2.0 — `third_party/licenses/streamlit-agent-skills.LICENSE` |
| `optional/ui/frontend-design`, `optional/ui/webapp-testing` | [anthropics/skills](https://github.com/anthropics/skills) `skills/` | `2c5958ecac` (2026-11-06) | Apache-2.0 — `LICENSE.txt` in each folder |
| `optional/ml/scikit-learn`, `optional/ml/shap`, `optional/ml/statsmodels`, `optional/ml/aeon` | [K-Dense-AI/scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills) `skills/` | `2d2065fb45` (2026-11-09) | MIT © 2025 K-Dense Inc. — `third_party/licenses/k-dense-scientific-agent-skills.LICENSE.md` (the `license:` field inside each SKILL.md names the license of the Python library it documents) |

If you are an author of one of these skills and want it removed or attributed differently, open an issue.
