# Ninjo plugin

The Ninjo connector (cortex-gateway MCP, OAuth) plus five operator skills that load on their
own when the conversation matches:

| Skill | Fires on |
|---|---|
| `debug-agent` | a symptom: "el agente no responde", "mirá esta conversación", "no me llegan las notificaciones" |
| `build-agent` | creating or iterating an agent's prompt and SDK |
| `wire-automation` | contact limits, follow-ups, notifications, properties; the activation kit for a new agent |
| `connect-channels` | Instagram, WhatsApp, ManyChat, CRM and booking connections; thread ownership |
| `report` | metrics, funnels, booking lists, dashboards |

Every skill is written for the MCP surface only: no files, no scripts. Deeper material is
fetched with `get_playbook_doc` from the published playbook.

## Install

**Claude (Pro, Max, Team, Enterprise).** Customize > Plugins > Browse > "+" > Add from a
repository > `ninjo-ai/ninjo-plugin` > Sync, then install **Ninjo** and sign in to the Ninjo
connector when prompted. Skills need code execution enabled (Settings > Capabilities).

**Claude Code.** `claude plugin marketplace add ninjo-ai/ninjo-plugin` then
`claude plugin install ninjo@ninjo`.

**ChatGPT.** The same `skills/` folder is uploaded in the Skills step of the Ninjo app
submission on the OpenAI plugin portal (`scripts/build.sh` produces the zip).
