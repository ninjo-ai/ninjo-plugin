---
name: report
description: Report on how a Ninjo agent is performing. Use when the operator asks "cómo viene el agente esta semana", "cuántos agendaron", "quiénes reservaron", "armame un dashboard del funnel", "qué contenido trae mejores leads", "qué leads están calientes", or wants a weekly summary, a funnel, a booking list or a comparison between agents. Read-only; never changes the agent.
---

# Report on an agent

Two aggregate tools cover most reports; drop to conversation-level search only for a cut
the aggregates do not have. Reply in the operator's language. Numbers go in a table.

## 1. Pull the data

- `get_agent_metrics(days, min_leads)`: per agent, `leads`, `avg_funnel`, `bookings_sent`,
  `booking_send_rate`, `calls_booked`, `call_book_rate_total`, `pct_funnel_ge_4`,
  `risk_score_0_100`. KPI cards and the risk ranking across agents.
- `get_agent_insights(days)`: `quick_stats` (last 24h), `funnel_transitions` (rate per stage),
  `content_sources` (conversations, qualified leads and bookings per post or ad),
  `hot_leads` (awaiting follow-up), `stalled_by_objection`.
- `list_schedules`: who booked, filterable by status, source, agent and date. Use it for
  "quiénes agendaron"; do not reconstruct bookings from transcripts.
- `search_conversations` with structured filters (`min_funnel`, `has_booking_link`,
  `call_booked`, dates, lead score, nurturing or happy-path score) for a custom stage or a
  keyword table. It has **no message-text search**.
- `search_contacts` for segments by custom property (`custom_properties:
  [{codename, equals_boolean: true}]`), for example everyone who discussed pricing.

Gotchas: `get_agent_metrics` returns `agents: []` when there was no activity in the window,
so widen `days` before concluding zero. In conversation rows `meta.booking_link_sent` and
`meta.call_booked` arrive as strings (`"true"`); `funnel` is a 0 to 5 scale, pick an explicit
threshold. Ad attribution covers Instagram and Facebook referrals only, not click-to-WhatsApp.

## 2. The standard funnel

```
conversations  ->  qualified  ->  link sent  ->  booked or bought
```

| Stage | Source |
|---|---|
| conversations | `get_agent_metrics.leads` or `content_sources[].total_conversations` |
| qualified | `quick_stats.qualified_leads_24h`, or `search_conversations(min_funnel: 2)` |
| link sent | `bookings_sent` / `booking_send_rate` |
| booked or bought | `calls_booked` / `call_book_rate_total`, or `list_schedules` |

## 3. Shape the answer

- A quick question gets a markdown table and two lines of reading: what moved, and the one
  thing worth doing about it.
- "Armame un dashboard" gets a single self-contained HTML artifact: KPI cards on top, funnel
  bars in the middle, a table per content source below, data embedded inline, no external
  fetches. Recipe in `get_playbook_doc` on `knowledge/dashboards`.
- Every finding names the next action and the tool that does it (a stalled objection points
  at `build-agent`; an agent with no bookings and links going out points at the
  `knowledge/runbooks/zero-bookings` runbook; hot leads point at a follow-up in
  `wire-automation`).
- Compare like with like: same window, same `min_leads`, and say when a rate sits on fewer
  than 20 leads.
