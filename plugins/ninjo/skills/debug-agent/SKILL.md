---
name: debug-agent
description: Diagnose a live Ninjo agent that is misbehaving. Use when the operator reports a symptom rather than asking a question, for example "el agente no responde", "dejó de contestar", "mirá esta conversación, algo anda mal", "le sigue escribiendo a alguien que ya compró", "el follow up no se envía", "la keyword no dispara", "no me llegan las notificaciones", "tengo cero agendas", "lo deployé y sigue igual". Runs the runbook for that symptom over the Ninjo MCP tools and stops at the first confirmed cause.
---

# Debug a live Ninjo agent

An operator arrives with a symptom, not a diagnosis. Your job is to find the one mechanism
that explains it, using the platform's own decision record, and to fix it or hand back one
exact next step. Reply in the operator's language.

## 0. Collect the ids, then read the runbook

- You need the `agent_id` and, if the complaint is about one lead, the `conversation_id`.
  `list_agents` resolves a name to an id. If you cannot get an id, say which one you need and
  why; never diagnose from a description alone.
- Call `search_playbook` with the complaint **in the operator's own words** (Spanish is fine).
  The top hit is a runbook. Fetch it with `get_playbook_doc` and work its hypotheses **in
  order**, cheapest first. Stop at the first hit. Do not collect every hypothesis.
- Runbook ids, by symptom:

| Operator says | `get_playbook_doc` id |
|---|---|
| no responde / dejó de contestar | `knowledge/runbooks/agent-not-answering` |
| le sigue escribiendo a alguien que ya compró | `knowledge/runbooks/agent-wont-stop` |
| mirá esta conversación, algo anda mal | `knowledge/runbooks/conversation-went-wrong` |
| el follow up no se envía / se manda a todos | `knowledge/runbooks/followup-never-fires` |
| la keyword no dispara | `knowledge/runbooks/keyword-not-triggering` |
| no me llegan las notificaciones | `knowledge/runbooks/notification-never-arrives` |
| no se envía el pdf / el link no llega | `knowledge/runbooks/resource-not-delivered` |
| pausé y el agente igual respondió | `knowledge/runbooks/handoff-doesnt-stick` |
| repite el saludo / manda el mensaje dos veces | `knowledge/runbooks/repeated-or-wrong-opener` |
| manda muchos mensajes / me llegó cortado | `knowledge/runbooks/too-many-or-truncated-messages` |
| cero agendas / bajaron las reservas | `knowledge/runbooks/zero-bookings` |
| qué le falta para salir en vivo / deployé y sigue igual | `knowledge/runbooks/not-live-yet` |

## 1. The three calls that settle most cases

1. **`diagnose_agent` (mode `quick`)** first. It checks the wiring in one call: linked
   account, trigger mode, contact limits, properties, workflows. Most "the agent is behaving
   wrong" reports are configuration or automation, not the prompt.
2. **`get_conversation_decisions(conversation_id)`** before forming any opinion about a silent
   or wrong conversation. The platform records *why* nothing happened:
   - `no_response` with detail `NO_RESPONSE` alone: the agent chose silence on a real message.
     Only now is the prompt a suspect.
   - `NO_RESPONSE: last_message_not_user` or a free-text reason such as `awaiting booking`:
     benign, working as designed.
   - `NO_RESPONSE - cot_filter_blocked`: the reasoning-leak filter caught a message; read
     `knowledge/reasoning-leak`, not the silence rules.
   - `contact_limit`: a limit muted this contact. That mute is **permanent** for the contact.
   - `send_failed`: the reply was sent and the channel rejected it. `THREAD_OWNER_MISMATCH`
     means another app (usually ManyChat) owns the Instagram thread; read
     `knowledge/messaging-channels`, section on thread ownership. `MESSAGE_WINDOW_EXPIRED` is
     Meta's 24h window. `INVALID_TOKEN` means reconnect the account with `create_connect_link`.
   - Empty result: also an answer. Nothing suppressed the turn, so the cause is upstream
     (routing, relay, trigger mode).
3. **`get_conversations` / `search_conversations`** to read the transcript. Every message
   carries `status` (`OK`, `PENDING`, `FAILED`) and failed ones carry `send_failure`. A message
   with status `FAILED` never reached the lead, whatever the transcript looks like.

## 2. Rules that keep the diagnosis honest

- **Read the transcript, not the evaluator's properties.** A property is what a classifier
  thought; the transcript is what the agent said.
- **Check what the agent had loaded when it spoke.** `get_agent_config` shows the live prompt
  and version. A fix deployed yesterday does not explain a message from last week.
- **A tool error is a fact to read, not a reason to hand the task back.** Retry idempotent
  reads once, try the alternate tool that surfaces the same fact, then report the literal
  error with one exact next step. Never answer "verificá vos en Ninjo".
- **The prompt is the last suspect for silence** and the first only for wording.

## 3. Fix, verify, close

- Configuration fixes go through the matching tool (`upsert_contact_limit`, `upsert_workflow`,
  `upsert_custom_property`, `update_trigger`, `set_agent_crm_channel`). Read the row back
  after any partial update; several writes are replace, not merge.
- Prompt fixes go through `deploy_agent_sdk` with only the field that changed. On
  `verified: false` or `partial: true`, roll back with `restore_prompt_version`.
- Re-run `diagnose_agent` or re-read the conversation to confirm.
- If no hypothesis fits and the tools genuinely cannot do it, file it with `report_feedback`
  (include ids, what you tested, and the expected behaviour) and tell the operator exactly
  what you filed. Reporting never replaces giving them a concrete answer this turn.
