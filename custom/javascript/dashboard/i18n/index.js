// Fork override of dashboard/i18n: core messages plus the fork's text changes below.
// The reply editor's AI is Tindre here, so it never says "Copilot".
import messages from 'dashboard/i18n/index.js?original';

const overrides = {
  en: {
    INTEGRATION_SETTINGS: {
      OPEN_AI: {
        REPLY_OPTIONS: {
          SUGGESTION: 'Suggest a reply with Tindre',
          SUMMARIZE: 'Summarize with Tindre',
        },
      },
    },
    CONVERSATION: {
      FOOTER: {
        COPILOT_MSG_INPUT:
          'Ask Tindre to change the reply, or ask anything else... Press enter to send',
      },
      REPLYBOX: { COPILOT_THINKING: 'Tindre is thinking' },
    },
  },
  no: {
    INTEGRATION_SETTINGS: {
      OPEN_AI: {
        REPLY_OPTIONS: {
          SUGGESTION: 'Foreslå svar med Tindre',
          SUMMARIZE: 'Oppsummer med Tindre',
        },
      },
    },
    CONVERSATION: {
      FOOTER: {
        COPILOT_MSG_INPUT:
          'Be Tindre endre svaret, eller spør om noe annet... Trykk enter for å sende',
      },
      REPLYBOX: { COPILOT_THINKING: 'Tindre tenker' },
    },
  },
};

const merge = (base, extra) => ({
  ...base,
  ...Object.fromEntries(
    Object.entries(extra).map(([key, value]) => [
      key,
      typeof value === 'object' ? merge(base[key] ?? {}, value) : value,
    ])
  ),
});

export default merge(messages, overrides);
