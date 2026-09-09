---
name: wire-automation
description: Wire or repair the automation around a Ninjo agent, which is where most agents fall short. Use when the operator wants the agent to stop after a purchase or booking, to follow up leads that went quiet, to get notified when someone converts, to push a lead into a CRM or webhook, or asks "cómo hago que deje de escribirle a los que ya compraron", "quiero que haga seguimiento a los 2 días", "avisame por WhatsApp cuando alguien agende", "la propiedad se setea pero no pasa nada". Also the mandatory activation kit for a newly created agent.
---

# Wire the automation around an agent

The prompt controls only what the agent **says**. Stopping after a conversion, following up a
stalled lead, alerting the operator, updating a CRM: all of that is a **custom property** that
an evaluator fills from the transcript, consumed by a **contact limit**, a **workflow** or a
**notification**. A property does nothing until something consumes it. Reply in the
operator's language.

## 0. Read the wiring before touching it

- `diagnose_agent` (mode `quick`) lists what exists and what is missing, with the fix tool
  for each finding. Run it first and again at the end.
- `list_custom_properties`, `list_contact_limits`, `list_workflows`,
  `list_custom_notifications`, `list_property_actions` show the current state. Read them
  before writing; several writes are **replace, not merge**, and a partial update can null the
  conditions and leave a rule firing on everyone or on no one.
- Docs: `get_playbook_doc` on `knowledge/custom-properties`, `knowledge/workflows`,
  `knowledge/follow-up-architecture`, `knowledge/property-actions`.

## 1. New agent: the activation kit in one call

`scaffold_agent_activation(agent_id, ...)` creates the terminal conversion property, the
contact limit gated on it, the follow-up for non-converters and the operator notification.
It is idempotent. The one thing it cannot guess is the client's conversion fact (booked a
call, paid, left a phone number): ask, then pass it explicitly. Loop: `diagnose_agent`,
scaffold, `diagnose_agent` again until `complete: true`.

## 2. The rules every property must satisfy

- **Boolean or number, never string**, for anything that gates automation. Text values
  compare unreliably in conditions.
- **`check_until_match` true with the terminal value** on any property that gates a shutdown,
  a follow-up lock or a conversion notification. Otherwise an early `false` freezes forever
  and the later signal never flips it. `upsert_custom_property` defaults a boolean to gated;
  pass `checkUntilMatch: false` explicitly only for a descriptive boolean, on every write.
- **Never ask a property for a fact the platform already stores** (booking link sent, call
  booked through an integration, phone number). Use the native field.
- A terminal conversion such as "call booked" should come from the booking integration, not
  from the transcript, whenever the integration is connected.
- Read the `warning` field in the `upsert_custom_property` response. It says when the tool
  healed an ungated boolean or when the property still cannot drive automation as written.

## 3. Contact limits: the stop switch

- `upsert_contact_limit` gated on the terminal property. When it fires it sets the agent
  inactive **for that contact, permanently**; nothing brings it back. Correct after a purchase
  or booking, wrong after "not right now".
- "The agent never stops messaging converted leads" is usually a frozen property (rule above)
  or a limit gated on a string. Compare the property's values against the transcripts.

## 4. Follow-ups: workflows of type FOLLOW_UP

- `upsert_workflow` with the stage delay and the property conditions that select the lead.
  Gate on data: a lead who booked or bought must be excluded by the terminal property.
- **Meta's 24h window.** On Instagram and Messenger a follow-up can only go out inside 24h
  of the lead's last message; a lead who only commented cannot be followed up at all. On
  WhatsApp, past 24h only an approved template can reach them (`send_whatsapp_template`).
- Multi-stage sequences: each stage needs its own "already sent" guard or the second stage
  fires as soon as the first one has. `templates/follow-up-sequence` is the copy-paste
  skeleton; `knowledge/follow-up-architecture` is the doctrine.
- `get_workflow_activity` shows whether a workflow evaluated, sent, or failed and why.

## 5. Notifications and side effects

- `upsert_custom_notification` gated on the conversion property, to a destination from
  `list_notification_destinations` (`upsert_notification_destination` to add one). A
  notification on a property that nothing fills never arrives.
- A `CUSTOM_NOTIFICATION` only evaluates conversations with an inbound in the last 24h, so it
  cannot re-contact a lead days later. Multi-day re-contact on WhatsApp is a template batch.
- `upsert_property_action` fires a webhook or CRM field update when a property reaches a
  value. For CRM field updates the value source is `trigger_value` or `static`.

## 6. Verify, then say what will happen

After writing, read every row back and state the chain in plain words: "cuando el evaluador
marque `call_booked = true`, el límite de contacto apaga al agente para ese lead y te llega la
notificación a Telegram". If a link in that chain is missing, the operator will find out from
a lead who got messaged after paying; find it now with `diagnose_agent`.
