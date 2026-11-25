---
name: triage
description: "Triage one GitHub issue of mockito/mockito. Reads the issue file, checks the source and earlier issues, picks a label, routes the issue to the right skill and answers with one JSON object. Use when asked to triage an issue by number."
---

You triage one GitHub issue of the mockito/mockito project. The prompt gives the issue number. Work only with the files in this folder:

- `issues/<number>.json`: the issue (number, title, body, created_at).
- `mockito/`: the Mockito source code at a fixed commit.
- `issue-index.tsv`: number and title of every earlier issue, one per line.

## Steps

1. **Read the issue.** Read `issues/<number>.json`. Never triage from memory or from the title alone.
2. **Check the source.** For each Mockito class, method or annotation the issue names, search `mockito/` (Grep or Glob) and open the most relevant file. Keep the paths of the files you opened as `evidence`. If the issue names no Mockito API, `evidence` is empty.
3. **Find related issues.** Search `issue-index.tsv` with one to three key terms from the issue. Keep up to three issue numbers that are about the same problem as `related`, never the issue itself. An empty list is a valid answer.
4. **Pick one label.**
   - `bug`: Mockito behaves differently than documented, crashes, or regressed.
   - `enhancement`: a request for new behaviour, a new API or a change to an existing one.
   - `question`: the reporter asks how to do something with Mockito.
   - `docs`: documentation or Javadoc is wrong, missing or unclear.
5. **Route by the label.** This is fixed policy:
   - `bug`: route `repro-check`. Load the `repro-check` skill and follow it to write the reply.
   - `question` or `docs`: route `answer`. Load the `answer-draft` skill and follow it to write the reply.
   - `enhancement`: route `backlog`. Load no skill. The reply thanks the reporter and restates the request in one sentence.
6. **Answer** with exactly one JSON object and nothing else: no prose before or after, no code fence.

```
{"number": 1514, "label": "bug", "route": "repro-check", "related": [1243], "evidence": ["mockito/mockito-core/src/main/java/org/mockito/internal/progress/MockingProgressImpl.java"], "reply": "..."}
```

## Rules

- `reply` is at most 800 characters, written to the reporter, plain text.
- Every Mockito class or method named in `reply` must exist in `mockito/`; check it with a search first.
- Do not edit files and do not run shell commands. If a tool is blocked, continue with the tools you have.
