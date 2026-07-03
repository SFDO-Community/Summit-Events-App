# Agent Instructions — UST Agentic Coding Skills

## ⚡ Read First — Every Session

Before taking any action, read the onboarding skill:

```
~/.copilot/skills/agent-onboarding/SKILL.md
```

This file contains non-negotiable security rules, code style standards, project preferences, and the startup checklist. Nothing in this repo overrides those rules.

---

## Available Skills

The `~/.copilot/skills/` directory in this repo contains task-specific skill files. Read the relevant one(s) before performing the corresponding task — do not rely on memory alone.

| Skill file | Read when... |
|---|---|
| `~/.copilot/skills/agent-onboarding/SKILL.md` | **Every session — read first, always** |
| `~/.copilot/skills/terminal-commands/SKILL.md` | Running any `cci`, `sf`, `jq`, or PowerShell terminal command |
| `~/.copilot/skills/cumulus-ci/SKILL.md` | Deploying metadata, running Apex tests, querying coverage, working with objects/fields/flows, or running the Code Analyzer |
| `~/.copilot/skills/backstopjs-visual-testing/SKILL.md` | Setting up or running BackstopJS visual regression tests |
| `~/.copilot/skills/ai-ready/SKILL.md` | Making a repo AI-ready, setting up AI config, or preparing a repo for AI contributions |
| `~/.copilot/skills/chrome-devtools/SKILL.md` | Browser automation, debugging, visual inspection, or performance profiling in Chrome |
| `~/.copilot/skills/salesforce-apex-quality/SKILL.md` | Writing or reviewing Apex classes, trigger handlers, batch jobs, or test classes |
| `~/.copilot/skills/salesforce-component-standards/SKILL.md` | Building or reviewing LWC, Aura components, or Visualforce pages |
| `~/.copilot/skills/salesforce-education-cloud/SKILL.md` | Writing code that queries, displays, or manipulates Salesforce Education Cloud objects |
| `~/.copilot/skills/salesforce-flow-design/SKILL.md` | Designing or reviewing any Salesforce Flow |
| `~/.copilot/skills/web-coder/SKILL.md` | Working with HTML, CSS, JavaScript, web APIs, HTTP/HTTPS, or any web/internet concepts |

---

## Project Context

- **Stack:** Salesforce DX + CumulusCI + IntelliJ IDEA + Illuminated Cloud
- **Shell:** PowerShell (Windows) — never use cmd syntax
- **Org type:** Scratch orgs managed by CumulusCI
- **Project-specific details** (org aliases, object names, URLs): check `docs/AI-TOOLS-CONFIG.md` in each project repo