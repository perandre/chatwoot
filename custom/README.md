# custom/ — fork overlay

Fork-specific code lives here so merges from upstream Chatwoot stay conflict-free. Core has two small hooks:

- `config/application.rb` autoloads `custom/app/**`. Modules under `custom/app/**/custom/` extend core classes that call `prepend_mod_with` (same mechanism as `enterprise/`).
- `vite.config.ts` loads `custom/vite-overrides.ts`: a file at `custom/javascript/<path>` replaces `app/javascript/<path>`. To extend instead of copy, the override imports `<same path>?original`.

After an upstream merge, check each overridden file against its original for changed props or APIs.

## Tindre in the reply editor (POC)

- `javascript/dashboard/components/widgets/WootWriter/CopilotMenuBar.vue`: the AI menu shows only "Suggest a reply" and "Summarize the conversation".
- `app/controllers/custom/api/v1/accounts/captain/tasks_controller.rb`: those actions (and follow-ups) ask Tindre instead of Captain's LLM.
- `javascript/dashboard/components/widgets/WootWriter/ReplyTopPanel.vue`: the AI menu button shows the Tindre mark (`i-woot-tindre`, defined in `theme/icons.js` and merged in `tailwind.config.js`).
- `javascript/dashboard/components/widgets/conversation/ReplyBoxBanner.vue`: the "handled by the bot" banner on pending conversations shows the Tindre mark.
- `javascript/dashboard/components/widgets/conversation/copilot/CaptainLoader.vue`: the "thinking" animation bounces the Tindre mark.
- `javascript/dashboard/i18n/index.js`: extends core's messages (via `?original`) so the reply editor's AI texts say Tindre instead of Copilot (en, no).
- `app/services/tindre/assist_client.rb`: calls the tindre-chatwoot-bridge Worker (`POST /assist`), which holds the Tindre key.

Env: `TINDRE_ASSIST_URL`, `TINDRE_ASSIST_SECRET` (same value as the Worker's `ASSIST_SECRET`).
