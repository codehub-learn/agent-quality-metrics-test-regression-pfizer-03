---
name: repro-check
description: Check whether a Mockito bug report can be reproduced as written and draft the reply to the reporter. Use when the triage agent routes an issue labelled bug.
---

# Repro check

Decide whether a maintainer could reproduce the reported bug from the issue alone, and write the reply.

## Steps

1. **List what the report contains.** Check for each of these and note yes or no:
   - the Mockito version (or a version range),
   - a code snippet or test that shows the problem,
   - the expected behaviour and the actual behaviour,
   - the error message or stack trace, if the report is about an exception.
2. **Locate the code.** Find the source file in `mockito/` where the reported behaviour lives: the class named in the stack trace, or the public API the snippet calls. Add the file to `evidence`. If you cannot find any related code, say so in the reply instead of guessing.
3. **Write the reply** (at most 800 characters):
   - If the report has a snippet and expected and actual behaviour: thank the reporter, say the report is reproducible as written, and name the class where the behaviour lives.
   - Otherwise: thank the reporter and ask for exactly the missing items from step 1, as a short list.
   - Never promise a fix, a release or a date.
