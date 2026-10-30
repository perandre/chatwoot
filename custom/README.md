# custom/ — fork overlay

Fork-specific code lives here so merges from upstream Chatwoot stay conflict-free. Core has two small hooks:

- `config/application.rb` autoloads `custom/app/**`. Modules under `custom/app/**/custom/` extend core classes that call `prepend_mod_with` (same mechanism as `enterprise/`).
- `config/application.rb` also puts `custom/app/views` first on the view path (a view there replaces the core view with the same path) and loads `custom/config/locales/*.yml` for server-rendered strings.
- `vite.config.ts` loads `custom/vite-overrides.ts`: a file at `custom/javascript/<path>` replaces `app/javascript/<path>`. To extend instead of copy, the override imports `<same path>?original`.
- `tailwind.config.js` scans `custom/javascript/**/*.vue` and `custom/app/views/**/*.erb` for classes.

After an upstream merge, check each overridden file against its original for changed props or APIs.

## Tindre in the reply editor (POC)

- `javascript/dashboard/components/widgets/WootWriter/CopilotMenuBar.vue`: the AI menu shows only "Suggest a reply" and "Summarize the conversation".
- `app/controllers/custom/api/v1/accounts/captain/tasks_controller.rb`: those actions (and follow-ups) ask Tindre instead of Captain's LLM.
- `javascript/dashboard/components/widgets/WootWriter/ReplyTopPanel.vue`: the AI menu button shows the Tindre mark (`i-woot-tindre`, defined in `theme/icons.js` and merged in `tailwind.config.js`).
- `javascript/dashboard/components/widgets/conversation/ReplyBoxBanner.vue`: the "handled by the bot" banner on pending conversations shows the Tindre mark.
- `javascript/dashboard/components/widgets/conversation/copilot/CaptainLoader.vue`: the "thinking" animation bounces the Tindre mark.
- `javascript/dashboard/i18n/index.js`: extends core's messages (via `?original`) so the reply editor's AI texts say Tindre instead of Copilot (en, no).
- `app/services/tindre/assist_client.rb`: calls the tindre-chatwoot-bridge Worker (`POST /assist`), which holds the Tindre key. `call` returns the bridge's JSON and raises `Tindre::AssistClient::Error`; `perform` wraps it as `{ message: }` / `{ error: }` for the reply editor.

## Tindre classifies conversations

Behind the `captain_classifier` feature flag (off by default, not a premium feature; the dashboard shows the suggest buttons and the automation "Captain condition" once it is on):

- `app/services/custom/captain/automation_condition_service.rb`: automation rules' Captain conditions are judged by Tindre (bridge action `conditions`), all conditions of a rule in one call. Core still decides when to ask, and any bridge error counts as "condition not met".
- `app/controllers/custom/api/v1/accounts/conversations/suggestions_controller.rb`: the label and priority suggest buttons ask Tindre (`suggest_labels`, `suggest_priority`). Tindre gives no score, so `probability` and `confidence` are `null`; the dashboard does not show them.

Enable for an account: `bundle exec rails runner "Account.find(<id>).enable_features!('captain_classifier')"` (or Super Admin → Accounts → features).

## Tindre answers help-centre searches

- `app/controllers/custom/public/api/v1/portals/search_controller.rb`: `/hc/:slug/:locale/search.json?query=` returns Tindre's answer (bridge action `search`) as `{ answer, no_answer, sources }`; only http(s) sources are passed on. The HTML search page is unchanged.
- `app/views/public/api/v1/portals/search/_search_handler.html.erb`: copy of core's partial plus a box above the article results that fetches that JSON after the page has loaded and hides itself if Tindre has no answer or fails. After an upstream merge, compare its first `<script>` with the core partial.
- `config/locales/en.yml`, `no.yml`: the box's texts.

Every search page load costs one Tindre call; the only rate limit is Rack::Attack's general `req/ip` throttle (`RACK_ATTACK_LIMIT`, default 3000/min per IP).

Env: `TINDRE_ASSIST_URL`, `TINDRE_ASSIST_SECRET` (same value as the Worker's `ASSIST_SECRET`).
