---
name: wrap-up
description: Close a work session by saving what was learned to the agency memory. Use when the person ends the session or the day - "cerremos el día", "listo por hoy", "terminamos", "cerramos", "guardá lo que aprendimos", "wrap up", "end of day" - or after a long session with corrections. Proposes the rules, decisions and fixes from this session in one list, saves them on the person's OK, and leaves a short handover. The other half of morning-check.
---

# Wrap-up

What you save here is what tomorrow's sessions start from: `get_standing_rules` returns it and
morning-check plans with it. Save little and save well. A wrong or vague rule costs more than a
missing one. Reply in the person's language.

If `save_learnings` is not available (agency memory not enabled), skip to step 4.

## 1. Collect from this session only

Go back over the conversation and pick out:

- **Rules and corrections** the person stated or implied: "nunca…", "de ahora en más…", "eso no,
  así", or an output they rejected and redid.
- **Decisions** about a client, person, channel or setting, with the reason when one was given.
- **Retired facts**: something that stopped being true, and what replaces it.
- **Fixes** to a Ninjo agent (only if the session changed one): what was failing and what you
  changed.

Skip what is already recorded. Every change made through the Ninjo tools is logged on its own,
so do not save "I updated the prompt of X". Save the reason behind it, if the person gave one
that will matter again.

Never save task lists, client fees or billing, passwords, tokens, or personal data about leads.

## 2. Write each item so it works out of context

One rule per item. Each item names who or what it applies to, and states the rule rather than
the story:

- Good: "Viana: los reportes muestran ventas cerradas y leads calificados, no solo leads."
- Bad: "Hoy Jessy dijo que el reporte estaba mal."

For each item, decide whether it applies to the whole agency (how the platform behaves,
conventions every member follows) or only to this person or client.

## 3. Confirm, then save

Show the list in one message: the agency-wide items first, then the personal ones. Ask for one
OK. Apply any edits the person makes. Then:

- `save_learnings(items=[…], agency_wide=true)` for the agency-wide items.
- `save_learnings(items=[…])` for the rest.
- For agent fixes: `record_fix` (status `applied` if the fix is live, `proposed` if it is not).
  If this session confirmed an earlier fix with real conversations, `update_fix` it to
  `verified`, or to `failed` if it did not hold.
- If a lead conversation showed a failure worth re-testing, `save_scenario` with the lead's
  messages and what a good answer does.

If nothing in the session is worth saving, say so in one line and save nothing.

## 4. Handover

End with at most 3 lines: what was finished, what is still open and who has it, and the first
thing to do next session. Do not save this handover to memory. Tomorrow's morning-check
rebuilds the day from the calendar, the mail and the memory.
