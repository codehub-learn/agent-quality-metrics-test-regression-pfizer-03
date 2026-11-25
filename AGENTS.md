# AGENTS.md

Lab: "Evaluating Agent Quality: Metrics, Test Sets, and Regression Checks". The learner makes the quality of an existing issue-triage agent measurable: they turn goals into pass/fail criteria, build a small eval set from 121 real recorded runs of the agent on mockito/mockito issues, score runs with deterministic checks and an LLM judge, and catch regressions with a pass-rate gate and a run diff.

## Stack

- No runtime, database or service: the lab is files plus the agent. Nothing to install or start.
- Data: `data/transcripts/` holds 121 recorded runs of the triage agent (`<issue>-<run>.json`, checksums in `data/transcripts.sha256`). `data/triage-agent/` holds the triage agent's own instructions (`triage-agent.md`, `repro-check.md`, `answer-draft.md`). The agent under test was run with the model claude-haiku-5-5.
- Agent: GitHub Copilot CLI.
- Tools: only the agent's own file tools. No servers or MCP.
- Boundary: the recorded transcripts are read-only data. Learner output goes to `eval/` and nowhere else; never edit `data/`. A prompt is never the boundary, so `verify-lab` checks the data checksums.

## Safety rules for the agent

- Show the exact command or SQL before anything that changes state.
- Ask before any destructive or hard-to-reverse action, and say what it would affect.
- Use the narrowest tool or server that can do the job; say which one you use.
- If a tool blocks an action, report it. Do not look for a way around it.
- Never print secrets or connection strings.
- Never grade a result without a written criterion or rubric, and never invent a gold label: a gold label comes from a human or is marked as a proposal.
- Report every number with where it came from (counted from which files, by which command).

## Working method

- Verify results before presenting them: counts, sanity checks, a second way to compute the same number.
- If a request is ambiguous, ask one short clarifying question before acting.
- State assumptions and what you could not verify.

## Repo layout

- `prompts/`: copy and paste prompts for learners, with expected answers. Every command in them is given as a bash block and a PowerShell block.
- `scripts/`: setup, reset and verify scripts (`.sh` and `.ps1`).
- `.github/`: the agent components (skills, agents, instructions, hooks), not edited by hand.
- `data/`: the recorded runs and the triage agent's instructions (read-only).
- `eval/`: what the learner creates: criteria, cases, rubric, results.

## Style

- Plain prose, no em dashes, write like a human.
