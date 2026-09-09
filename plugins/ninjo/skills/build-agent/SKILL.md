---
name: build-agent
description: Create a new Ninjo sales agent from a brief, or iterate an existing one from real conversations. Use when the operator says "quiero crear un agente", "armá el agente para mi lanzamiento", "cambiá cómo responde cuando preguntan el precio", "el agente suena muy vendedor", "agregá esta objeción", or asks to rewrite, tune or deploy a prompt. Builds the full SDK (system prompt plus the 8 v5Config fields) through the Ninjo MCP tools and deploys with deploy_agent_sdk.
---

# Build or iterate a Ninjo agent

A Ninjo agent is a **system**: a system prompt, eight v5Config fields, the triggers that route
messages to it, and the automation wired around it. This skill covers the prompt and the
eight fields. Automation is the `wire-automation` skill; run it after every new agent.
Reply in the operator's language. Prompts are written in the creator's own dialect.

## 0. Load the playbook first

Call `get_playbook_index`, then `get_playbook_doc` on:

- `templates/principles`: the single prompt architecture ("fewer rules, more examples").
- The motion flavor that matches how the creator closes:
  `templates/principles-express` (low ticket, drop the resource fast),
  `templates/principles-consultative` (mid ticket, discovery then link in DM),
  `templates/principles-deep-nurture` (premium, empathy plus video, DM closes),
  `templates/principles-book-the-call` (high ticket, the call closes, DM only qualifies).
- `knowledge/best-practices-top10`: the quality rubric and the only home of the numbers
  (example cap, principle count, hard-rule count).
- One worked sample in a similar vertical (`sample-wellness-bookcall`,
  `sample-petcare-consultative`, `sample-finance-bookcall`, `sample-prodev-consultative`).
  Pass `section` to read one file, for example `examples`.

## 1. Start from what is live

- **Iterating:** `get_agent_config(agent_id)` is the source of truth. Never edit from memory
  or from a pasted copy; the operator may have changed the agent in Ninjo since.
- **Creating:** `get_me` gives the `influencer_id`. If `scope` is `multi-influencer`, pass
  `influencer_id` on every call. `get_self_serve_data` may already hold the creator's bio,
  program and Instagram posts; use them.
- Gather the brief: identity, voice (5 or 6 real messages the creator wrote), conversation
  flow, resources with real URLs, program and pricing, happy-path examples, edge cases. If
  the operator shared a style guide or example conversations, **that is the source of truth
  for tone**; examples must be adaptations of it, not inventions.

## 2. Author the SDK

- `system`: identity and mission, voice, one simple flow, at most 7 principles, tools.
  No hard-rule lists; style lives in examples. Principles beat rules.
- `examples`: the highest-leverage field. Real or adapted conversations that show the flow
  end to end, including the moment the link or resource goes out. Pure dialogue, no
  instructions inside.
- `knowledge_base`, `objections`, `personal_story`: prose. `keywords`, `program`,
  `resources`, `case_studies`: JSON values (arrays or objects), never JSON-encoded strings.
- **All eight fields on a first deploy.** `system`, `examples` and `knowledge_base` must carry
  real content; at least one of `keywords` or `program` must be populated. A keywords-only
  config runs but is not a real agent, and nothing stops it from going live.
- Cross-check before deploying: every URL in the prompt exists in `resources`; examples obey
  the system prompt; no two files disagree on a price, a date or a link (BP-5); no action the
  agent can take is unguarded (BP-7).
- **Do not solve platform problems with prompt rules.** The agent does not know what a
  "bubble" is; message splitting, delays, stopping after a purchase and follow-ups are
  platform settings and automation, not prose.
- Custom properties are set by the platform's evaluator reading the transcript afterwards.
  The agent cannot set them; never write "el agente marca la propiedad X".

## 3. Deploy and verify

1. New agent: `create_agent` with the system prompt, inactive and unattached. Capture `agent_id`.
2. `deploy_agent_sdk(agent_id, ...)`. Patch semantics: an omitted field stays untouched. It
   diffs, writes only what changed, re-fetches and verifies. On `verified: false` or
   `partial: true` call `restore_prompt_version` with the `rollback_version_id` it returned.
3. `get_agent_config` again: the config is complete, and the four JSON fields came back as
   arrays or objects, not strings.
4. Test before the operator does: `generate_synthetic_conversations` on the deployed agent,
   then read each transcript yourself. Automated scores are a hint, not a verdict.
5. New agent only: run the `wire-automation` skill, then `diagnose_agent` until it reports
   `complete: true`. Then link the agent to a connected account (`set_connected_account`) and
   activate it (`set_agent_status`). Without the link, incoming DMs never reach the agent.

## 4. When iterating from a complaint

One hypothesis per iteration. Pull the conversations that show the problem
(`search_conversations` with the relevant filter, or the `conversation_id` the operator gave),
name the single change, make it in the one file that owns the behaviour, deploy only that
field, and re-test with synthetic conversations. If the same problem survives two or three
iterations the issue is structural: simplify the flow or split it, do not add more rules.
