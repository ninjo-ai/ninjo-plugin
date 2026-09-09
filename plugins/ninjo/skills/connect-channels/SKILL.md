---
name: connect-channels
description: Connect or repair the channels and integrations a Ninjo agent answers through, including Instagram, Facebook, WhatsApp, ManyChat, GoHighLevel, HubSpot, Kommo and Calendly. Use when the operator asks "cómo conecto mi Instagram", "cómo conecto el WhatsApp del negocio", "conectá GoHighLevel", "el agente está activo pero no le llegan los DMs", "ManyChat recibe pero el agente no contesta", "el primer mensaje sale y el segundo falla", or asks which agent owns which inbox.
---

# Connect channels and integrations

Everything here runs through connect links and status reads. **Never ask the operator for a
password, an API key or a token**; none of these flows needs a credential typed to you. The one
key that exists (ManyChat) is typed by the operator into Ninjo, never through the model. Reply
in the operator's language.

## 0. Read what the agent answers today

`list_agent_channels(agent_id)` is the one unified view. Each channel has a `source`:

- `direct`: a Meta account (Instagram, WhatsApp, Messenger) connected straight in Ninjo. The
  agent owns that inbox.
- `crm`: a relay. A CRM (GoHighLevel, Kommo, HubSpot, Airtable) or a ManyChat connection
  forwards messages in and the agent answers only those. A `crm` row with `channel_type:
  UNKNOWN` is ManyChat.

**A relay channel with no assigned agent never replies.** "ManyChat (or GHL) receives the
messages but the agent stays silent" is almost always `agent_id` null on that connection:
`list_crm_connections`, then `set_agent_crm_channel`.

`list_connected_accounts` shows the Meta accounts; `diagnose_agent` flags an active agent with
no linked account, which means DMs never reach it.

## 1. The link flow (Meta, CRM, booking)

1. `create_connect_link(provider)` returns a single-use URL that lasts a few minutes.
   Providers: Meta accounts, `gohighlevel_crm`, `hubspot_crm`, `kommo_crm`,
   `gohighlevel_booking`, `calendly`.
2. Hand the URL to the operator. Do not open it yourself. If it expires, mint another.
3. The operator authorizes at the provider.
4. `get_connection_status`. **Read `setup_complete`, not `connected`**, and act on
   `pending_step`: `authorize_with_connect_link` (send another link), `reconnect` (link with
   `reconnect: true`), `select_calendars` (`list_booking_calendars` then
   `set_booking_calendars`), `enable_integration_in_studio`, `paste_api_key_in_studio`
   (ManyChat only), or `null` when genuinely done.

GoHighLevel appears twice and they are different things: the CRM sync (contacts and
opportunities) and the booking integration (tracking scheduled calls). Ask which one before
sending a link. Booking is fail-closed: until calendars are selected, no booking is tracked.

## 2. Link the agent to the inbox

A connected account is not enough. The agent must be linked to it (`set_connected_account`)
and active (`set_agent_status`). Trigger mode decides which DMs reach it: all DMs, or only
those matching a keyword or comment trigger (`list_triggers`). "Active but silent on every
conversation" is the `knowledge/runbooks/agent-not-answering` runbook, hypotheses 1 to 4.

## 3. Instagram with two apps on the same inbox

Meta lets several apps subscribe to one Instagram inbox but only **one app owns each DM
thread**. If ManyChat (or another tool) already answers DMs on that account, Ninjo's replies
are rejected: `get_conversation_decisions` shows `send_failed` with `THREAD_OWNER_MISMATCH`,
and the message shows `status: FAILED` in the transcript. Typical shape: the private reply to a
comment goes out, then every follow-on message fails. Fixes, in order of preference:

1. Make Ninjo the only app answering DMs on that account (remove the other app's DM
   subscription in Meta, or turn off its DM automations).
2. Or relay through the CRM/ManyChat instead of connecting Instagram directly: create the
   channel, confirm the connection has an `agent_id` via `list_crm_connections`, then unlink
   the direct Instagram account.

Other `send_failed` codes: `MESSAGE_WINDOW_EXPIRED` is Meta's 24h window (a follow-up, not a
connection problem); `INVALID_TOKEN` means reconnect the account with `create_connect_link`.
Full doc: `get_playbook_doc` on `knowledge/messaging-channels`.

## 4. WhatsApp

A WhatsApp Business account connects like any Meta account. Past 24h of silence only an
approved template can reach a lead: `list_whatsapp_templates`,
`preview_whatsapp_template_recipients` (read `pendingUnsentCount`; a send delivers to every
unsent row of that template, not only the ids you pass), then `send_whatsapp_template`.
`ok: true` means queued, not delivered; confirm in the conversation.

## 5. Reference

`get_playbook_doc` on `knowledge/connecting-integrations` (the full provider table, the
ManyChat webhook contract, CRM field mappings) and `knowledge/messaging-channels`. If a
provider is not in the table, the tools cannot connect it; say so plainly and, if it is a real
gap, file it with `report_feedback`.
