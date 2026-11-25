---
name: answer-draft
description: Draft a reply to a Mockito usage question or documentation report, grounded in the Mockito source and Javadoc. Use when the triage agent routes an issue labelled question or docs.
---

# Answer draft

Write a reply that points the reporter to the right Mockito API or documentation, using only what is in the source.

## Steps

1. **Find the topic in the source.** Search `mockito/` for the API the issue asks about. The main user documentation is the Javadoc of `mockito/mockito-core/src/main/java/org/mockito/Mockito.java`; class-level Javadoc of the class in question comes next. Add every file you open to `evidence`.
2. **Check every name.** Each class, method or annotation you will mention in the reply must appear in the source. Search for it. Drop it if you cannot find it.
3. **Write the reply** (at most 800 characters):
   - For a `question`: answer it in two or three sentences, name the API to use, and point to the Javadoc section or class.
   - For `docs`: confirm which page or Javadoc is affected and what is wrong or missing, in one or two sentences.
   - If the source does not answer the question, say so plainly and do not invent an API.
