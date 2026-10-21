---
name: morning-check
description: Start the work day from the agency's memory. Use when the person opens the day or asks what is on their plate - "buenos días", "arranquemos el día", "qué tengo hoy", "revisión de la mañana", "morning check", "qué quedó pendiente", "en qué me enfoco hoy". Reads the standing rules and past work first, then today's meetings, client mail and messages (when those connectors are on) and any agents with open fixes, and returns one short plan for today with the rule that applies to each item. Read-only until the person teaches a rule.
---

# Morning check

The point of this check is that it **starts from what the agency already taught you**. Every
item in the plan shows the standing rule or past decision behind it, so a rule taught today
visibly changes tomorrow's run. Reply in the person's language. Keep the plan short.

## 1. Load memory first, before anything else

1. `get_standing_rules`. These are the agency's shared rules plus this person's own. Follow
   them for the whole session. The newest-dated line wins.
2. If the tool is missing or says memory is not enabled, say so in one line ("la memoria de
   agencia no está activa en esta cuenta, sigo sin ella") and continue without steps 1.3 and 4.
3. `recall` with "pendientes compromisos esta semana" plus the person's name. This finds what
   was decided and changed in recent sessions.

## 2. Gather today, only from connectors that are on

Skip any source that is not connected, without comment. Never ask the person to connect
something in the middle of the check.

- **Calendar.** Today's meetings. For each client meeting, note what needs preparing.
- **Mail.** Client messages from the last 24 h still waiting on an answer. Mark the urgent
  ones. Draft only, never send.
- **Slack or chat.** Mentions and direct messages still waiting on an answer.
- **Ninjo agents.** Run this step only if `list_agents` returns agents. Call `get_agent_journal`
  for open fixes (proposed or applied) and `get_agent_metrics(days=1)` for anything that
  dropped. A fix still proposed after a week is an item.

For every client, person or agent that comes up, call `recall` with its name before you plan
the item. Past decisions about that client override your defaults.

## 3. The plan

One list, most urgent first. At most 7 items. Each item takes one line:

```
1. [Cliente] what to do today, and by when. (rule or memory it follows)
```

- Put the rule in the parenthesis, in a few words: "(regla: correos solo borrador)" or
  "(memoria 14-oct: Viana reporta leads calificados, no leads)". Leave it empty only when
  nothing in memory applies.
- If a rule changes what you would otherwise do, say so in the item, for example: "reporte
  de Viana: ventas cerradas y leads calificados, no solo leads".
- Below the list, add one line for anything waiting on someone else.
- Offer to start the first item. Do not start it unasked.

## 4. Teach a rule

When the person corrects the plan or states a rule ("de ahora en más…", "nunca…", "eso ya no
va, ahora es…"):

1. Restate it as one rule that names the client, person or system it applies to.
2. Ask in one line whether it is for everyone in the agency or only for this person.
3. On their OK, call `save_learnings`, with `agency_wide: true` if it is for everyone.
4. Re-plan the affected items right away, so the person sees the rule applied.

Save rules and decisions only. Never save the day's task list, client fees, passwords or
tokens.
