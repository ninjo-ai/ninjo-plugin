# ninjo-plugin

Marketplace repository for the **Ninjo** plugin: the Ninjo connector plus operator skills, for
Claude (web, desktop, Claude Code) and, through the same `skills/` folder, the Ninjo app in
ChatGPT. See `plugins/ninjo/README.md`.

```
.claude-plugin/marketplace.json   the marketplace catalog (one plugin: ninjo)
plugins/ninjo/                    the plugin: manifest, .mcp.json, skills/
scripts/build.sh                  zips: dist/ninjo-plugin.zip (Claude) and dist/ninjo-skills.zip (ChatGPT Skills step)
```

Validate before pushing: `claude plugin validate ./plugins/ninjo --strict` and
`claude plugin validate . --strict`.
