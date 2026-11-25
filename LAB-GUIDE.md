# Lab guide: Evaluating Agent Quality: Metrics, Test Sets, and Regression Checks

This copy of the guide is for **GitHub Copilot CLI**, the agent your course uses.

You will make the quality of an existing agent measurable. The agent triages GitHub issues of the open-source project mockito/mockito: it reads an issue, checks the source, picks one label (bug, enhancement, question or docs), routes the issue to a skill and writes a reply. You do not build it. You get 121 real, recorded runs of it, and you build the eval around those runs.

By the end you can turn "it feels smarter" into pass/fail criteria, build a small eval set you can defend, score runs with deterministic checks and a judge you have calibrated against your own labels, and say which case a change broke before it ships. Nothing is started or installed: the lab is files plus your agent, and no model runs are needed for the data. The course folder grows as the class moves on: files for each section arrive with `git pull` when the instructor releases them ([Files you receive](#files-you-receive-with-each-release)).

## Syllabus

| Thematic unit | Topics |
|---|---|
| **Section 1. From "It Feels Smarter" to a Measurable Target** | **Topic 1**<br>• Turning vague quality goals into observable pass/fail criteria for the triage agent<br><br>**Topic 2**<br>• Task-level vs step-level quality for a multi-step agent (final answer, tool calls, routing)<br><br>**Topic 3**<br>• Cataloguing the agent's failure modes from its logs |
| **Section 2. Building a Small, Honest Eval Set** | **Topic 1**<br>• Sampling the provided transcripts so the eval set matches real usage<br><br>**Topic 2**<br>• Writing the expected outcome per case: gold label, required tool calls, must/must-not conditions<br><br>**Topic 3**<br>• Dev slice vs held-out slice; versioning the eval set alongside the agent code |
| **Section 3. Metrics Beyond Vibes** | **Topic 1**<br>• Deterministic checks: final-label match, required tool calls, output format<br><br>**Topic 2**<br>• LLM-as-judge: writing the rubric, calibrating it against human labels<br><br>**Topic 3**<br>• Reading aggregate results: pass rate, per-failure-mode breakdown, run-to-run noise |
| **Section 4. Catching Regressions Before They Ship** | **Topic 1**<br>• Running the full eval set on every prompt or model change<br><br>**Topic 2**<br>• Setting and tuning a pass-rate gate; isolating and handling flaky cases<br><br>**Topic 3**<br>• Diffing two runs case-by-case to localise what a change broke |

## How to read this guide

Only the lines marked **Run** and **Paste** are things you execute. Each topic starts with **Why** and **What happens**, so you know what you are about to start.

| Label | Meaning |
|---|---|
| **Why** | the question this topic answers and why it matters in real work |
| **What happens** | what the script or prompt does, what it reads and writes, and whether it uses quota or changes state |
| **Run** | a command for a terminal, in the course folder |
| **Paste** | a prompt for the agent; the text is in the named `prompts/` file |
| **Check** | what to look at before you trust a result |

Your agent:

| | GitHub Copilot CLI |
|---|---|
| Start the agent in the course folder | `copilot` |
| First start | answer **yes** to trust the folder |
| List the skills | `/skills` |
| List the agents | `/agent` |
| Reload after new files arrive | restart `copilot` |

## Rules of this lab

- The recorded runs in `data/` are read-only. Everything you create goes to `eval/`.
- Every number the agent gives you must come with the run or case ids behind it. A number you cannot trace is an estimate.
- A gold label comes from you reading the issue, never from the triage agent's own answer.
- Each prompt file has an **Expected answer**. Compare your result with it after you have your own, not before.

## Before you start

| Need | Check |
|---|---|
| Git | `git --version` |
| GitHub Copilot CLI, logged in | `copilot --version` |

The scripts of this lab run under PowerShell 7 (`pwsh`) if you use PowerShell. Check it:

```bash
pwsh --version
```

```powershell
pwsh --version
```

---

## Setup (before the first section)

### Step 1: Get the course folder and the data

**Why:** everybody must work on the same pinned data, so that your numbers can be compared with the expected answers and with each other.

**What happens:** you clone the course repository, and `verify-lab` counts the 121 transcripts, checks each file against its recorded checksum and re-counts a few facts straight from the files. It reads files only and takes a few seconds. It uses no quota.

**Run** (bash):

```bash
git clone <course-repo-url> eval-lab
cd eval-lab
bash scripts/verify-lab.sh 0
```

**Run** (PowerShell):

```powershell
git clone <course-repo-url> eval-lab
Set-Location eval-lab
pwsh -NoProfile -File scripts/verify-lab.ps1 -Stage 0
```

**Check:** `verify-lab` ends with `ALL CHECKS PASSED`. It takes the number of the last release you have.

---

## Section 1. From "It Feels Smarter" to a Measurable Target

**First:** when your instructor says release 1 is out: pull it, verify it, then restart the agent.

```bash
git pull
bash scripts/verify-lab.sh 1
```

```powershell
git pull
pwsh -NoProfile -File scripts/verify-lab.ps1 -Stage 1
```

Goal: say what "better" means for the triage agent in terms a script could check, and list how it fails today.

### Topic 1: Pass/fail criteria

**Why:** "it feels smarter" cannot be tested. A criterion you can check on one run, with no judgement call, can.

**What happens:** you give the agent the triage agent's instructions and ask for five or six criteria, each with the field of a transcript it would look at. The result is saved to `eval/criteria.md`. This uses your agent's normal quota.

**Paste:** the prompt in `prompts/01-measurable-target/01-pass-fail-criteria.md`.

**Check:**
- Every criterion names a field or a step, and none uses words like good, helpful or smart.
- At least one criterion is about the steps, not only the final answer.

### Topic 2: Task level versus step level

**Why:** a run can give the right answer and still break a rule on the way. You want to see both.

**What happens:** the agent applies your criteria to four named runs and builds a table of runs by criteria. It reads four files in `data/transcripts/`.

**Paste:** the prompt in `prompts/01-measurable-target/02-task-vs-step.md`.

**Check:**
- Open `data/transcripts/487-1.json` and find the step that ran a shell command.
- Open `data/transcripts/1346-1.json` and look at how `final` starts.

### Topic 3: Failure modes from the logs

**Why:** you cannot fix or gate what you have not listed. A catalogue with counts tells you where to look first.

**What happens:** the `failure-modes` skill reads the transcripts and lists each failure mode with the run ids behind it. The result is saved to `eval/failure-modes.md`.

**Paste:** the prompt in `prompts/01-measurable-target/03-failure-modes.md`.

**Check:**
- Confirm two counts yourself with the commands in the prompt file ("Check yourself").
- Anything that fits no failure mode must be in an "unclassified" list, not forced into one.

---

## Section 2. Building a Small, Honest Eval Set

**First:** when your instructor says release 2 is out: pull it, verify it, then restart the agent.

```bash
git pull
bash scripts/verify-lab.sh 2
```

```powershell
git pull
pwsh -NoProfile -File scripts/verify-lab.ps1 -Stage 2
```

Goal: build a small eval set of 12 cases that you wrote the expectations for, and version it.

### Topic 1: Sampling the transcripts

**Why:** a set you pick by eye is not the real usage. A sample you can repeat is.

**What happens:** the agent lists the distinct issues and takes every 11th one, compares the labels in the sample with all runs, and adds two cases on purpose. The result is saved to `eval/sample.md`.

**Paste:** the prompt in `prompts/02-eval-set/01-sample-runs.md`.

**Check:** run the command under "Check yourself" in that file and get the same ten issue numbers.

### Topic 2: The expected outcome per case

**Why:** a case without an expected outcome cannot fail. The gold label must come from a person.

**What happens:** the `eval-case` skill reads only the issue text of each case and proposes a gold label, the required tool calls and the must and must-not conditions. You confirm or change each one before it is saved to `eval/cases.jsonl`.

**Paste:** the prompt in `prompts/02-eval-set/02-expected-outcomes.md`.

**Check:**
- You changed a proposal or agreed with it for a reason you can say in one sentence.
- No gold label was copied from the triage agent's own answer.

### Topic 3: Dev, held-out and a version

**Why:** if you tune on every case, you cannot tell whether a fix helps or only fits. The held-out slice is for one honest look at the end.

**What happens:** the agent marks every 4th case as held-out, writes `eval/README.md` with the version and a data fingerprint, and you commit and tag the set with git.

**Paste:** the prompt in `prompts/02-eval-set/03-split-and-version.md`, then run the git commands in that file.

**Check:** the tag list shows `eval-set-v1`, and the fingerprint matches the one in the file.

---

## Section 3. Metrics Beyond Vibes

**First:** when your instructor says release 3 is out: pull it, verify it, then restart the agent.

```bash
git pull
bash scripts/verify-lab.sh 3
```

```powershell
git pull
pwsh -NoProfile -File scripts/verify-lab.ps1 -Stage 3
```

Goal: score the 12 cases with checks you can trust, add a judge for what the checks cannot see, and learn how much of a number is noise.

### Topic 1: Deterministic checks

**Why:** checks that need no judgement are cheap, repeatable and fair. Run them first.

**What happens:** the `eval-checks` skill applies six checks (format, label, route, tool calls, no shell, reply length) to every case and reports the pass rate and the failing cases. It reads files only. The result is saved to `eval/results-v1.md`.

**Paste:** the prompt in `prompts/03-metrics/01-deterministic-checks.md`.

**Check:** every number comes with case ids, and the failing cases are counted once each, not once per failed check.

### Topic 2: An LLM judge, calibrated against you

**Why:** a judge gives you a number. Without human labels you cannot know whether to trust it.

**What happens:** you label six replies yourself against a two-item rubric, then the `judge` skill labels the same six in a new session. You compare agreement and kappa and read the disagreements. This uses quota in two sessions.

**Paste:** the three prompts in `prompts/03-metrics/02-llm-judge.md`, in order.

**Check:**
- You labelled before the judge ran, and the judge session never read your labels.
- When you and the judge disagree, you fix the rubric wording, not your label.

### Topic 3: Reading the results

**Why:** one pass rate hides which failures are common and how much a result moves between runs.

**What happens:** the agent writes a report of the pass rate, the failures by case and the run-to-run noise from the four issues that ran twice. The result is saved to `eval/report-v1.md`.

**Paste:** the prompt in `prompts/03-metrics/03-reading-the-results.md`.

**Check:** the report says "10 of 12" and lists the failing ids, not only a percentage.

---

## Section 4. Catching Regressions Before They Ship

**First:** when your instructor says release 4 is out: pull it, verify it, then restart the agent.

```bash
git pull
bash scripts/verify-lab.sh 4
```

```powershell
git pull
pwsh -NoProfile -File scripts/verify-lab.ps1 -Stage 4
```

Goal: run the eval set on a changed version of the agent, decide whether it may ship, and find what broke.

### Topic 1: Running the eval set after a change

**Why:** a change that "should be harmless" is the usual way quality drops. Run the full set every time.

**What happens:** the `regression-check` skill scores the baseline and a second set of recorded runs (`data/after/`) on the same 12 cases. The second set is the same agent instructions and model, recorded after the agent was moved to a different runtime. The result is saved to `eval/results-after.md`.

**Paste:** the prompt in `prompts/04-regressions/01-run-after-a-change.md`.

**Check:** run the count in "Check yourself" and get the same number.

### Topic 2: A pass-rate gate and flaky cases

**Why:** a gate decides whether a change ships. Too strict blocks good changes and too lax lets bad ones through. Flaky cases make it unreliable unless you handle them.

**What happens:** the agent finds the flaky cases, computes the pass rate over the stable ones and tries three gates on both sets. The result is saved to `eval/gate.md`.

**Paste:** the prompt in `prompts/04-regressions/02-gate-and-flaky-cases.md`.

**Check:** every gate was tried on the baseline too, and the flaky case is listed, not dropped.

### Topic 3: Diffing two runs

**Why:** "the pass rate dropped" does not tell you what to fix. A case-by-case diff does.

**What happens:** the agent builds a table of cases by failing checks for both sets, groups the failures by check and lists what the six checks do not cover. The result is saved to `eval/diff.md`.

**Paste:** the prompt in `prompts/04-regressions/03-diff-two-runs.md`.

**Check:** you can name the check, the level (answer or steps) and the cases that broke, and you can say what the data does not tell you about the cause.

---

## Files you receive with each release

The course folder is released in batches. Batch 0 is what you clone; the others arrive with `git pull` at the start of each section. Files are only ever added, so a pull never overwrites your work. After each pull, restart your agent.
Skills, agents and rules are generated for Copilot CLI into `.github/`.

### Release 0: setup

| File or folder | Role |
|---|---|
| `AGENTS.md` | Standing instructions for the agent: the lab, the safety rules, the working method. |
| `LAB-GUIDE.md` | This guide. |
| `data/transcripts/`, `data/transcripts.sha256` | The 121 recorded runs and their checksums. Read-only. |
| `data/triage-agent/` | The triage agent's own instructions (three files). |
| `scripts/verify-lab.sh`, `scripts/verify-lab.ps1` | Check the data and the files of a release. |
| `scripts/reset-lab.sh`, `scripts/reset-lab.ps1` | Delete what you created in `eval/`. |

### Release 1: start of section 1

| File or folder | Role |
|---|---|
| `prompts/01-measurable-target/` | Three prompts: criteria, task versus step, failure modes. |
| `failure-modes` skill | Lists failure modes with the run ids behind them. |

### Release 2: start of section 2

| File or folder | Role |
|---|---|
| `prompts/02-eval-set/` | Three prompts: sampling, expected outcomes, split and version. |
| `eval-case` skill | Drafts a case from the issue text, for you to review. |

### Release 3: start of section 3

| File or folder | Role |
|---|---|
| `prompts/03-metrics/` | Three prompts: deterministic checks, the judge, reading results. |
| `eval-checks` skill | Applies six fixed checks to the cases. |
| `judge` skill | Judges a reply against a two-item rubric. |
| `data/reference/cases.jsonl` | The 12 reference cases, if you did not finish section 2. |

### Release 4: start of section 4

| File or folder | Role |
|---|---|
| `prompts/04-regressions/` | Three prompts: run after a change, gate and flaky cases, diff. |
| `regression-check` skill | Compares two run sets, applies a gate and diffs them. |
| `data/after/`, `data/after.sha256` | The second set of recorded runs for the 12 eval issues. |

## Start over

**Why:** to repeat an exercise from a clean state.

**What happens:** `reset-lab` lists the files in `eval/` that it would delete, and deletes them only when you add the flag. It never touches `data/`, your agent's settings or git.

**Run:**

```bash
bash scripts/reset-lab.sh          # dry run
bash scripts/reset-lab.sh --yes    # deletes
```

```powershell
pwsh -NoProfile -File scripts/reset-lab.ps1          # dry run
pwsh -NoProfile -File scripts/reset-lab.ps1 -Yes     # deletes
```

## If something goes wrong

| Symptom | Cause and fix |
|---|---|
| `verify-lab` says `missing ...` | You did not pull a release, or the instructor has not pushed it yet. Run `git pull`, or ask. |
| `verify-lab` fails on `checksums` | A file in `data/` changed. Do not edit `data/`. Restore the original file from git, or clone again. |
| New skills or agents do not appear after `git pull` | Restart the agent; it reads them only at startup. |
| The agent shows none of the project hooks, skills or rules | The folder is not trusted, or `copilot` was not started in the course folder. Restart it there and answer yes. |
| The agent's counts differ from the expected answer | Ask it to list the run or case ids behind each number, then compare with the "Check yourself" commands in the prompt file. Count by files, not by memory. |
