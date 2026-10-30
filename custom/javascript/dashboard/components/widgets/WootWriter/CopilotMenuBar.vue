<script setup>
// Tindre version of the reply editor's AI menu: only the two actions Tindre answers
// (see custom/app/controllers/custom/api/v1/accounts/captain/tasks_controller.rb).
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useMapGetter } from 'dashboard/composables/store';
import { REPLY_EDITOR_MODES } from 'dashboard/components/widgets/WootWriter/constants';
import Button from 'dashboard/components-next/button/Button.vue';
import DropdownBody from 'next/dropdown-menu/base/DropdownBody.vue';

const props = defineProps({
  conversationId: {
    type: Number,
    default: null,
  },
});

const emit = defineEmits(['executeCopilotAction']);

const { t } = useI18n();
const replyMode = useMapGetter('draftMessages/getReplyEditorMode');

const menuItems = computed(() => {
  if (!props.conversationId) return [];

  const items = [];
  if (replyMode.value === REPLY_EDITOR_MODES.REPLY) {
    items.push({
      label: t('INTEGRATION_SETTINGS.OPEN_AI.REPLY_OPTIONS.SUGGESTION'),
      key: 'reply_suggestion',
      icon: 'i-fluent-chat-sparkle-16-regular',
    });
  }
  items.push({
    label: t('INTEGRATION_SETTINGS.OPEN_AI.REPLY_OPTIONS.SUMMARIZE'),
    key: 'summarize',
    icon: 'i-fluent-text-bullet-list-square-sparkle-32-regular',
  });
  return items;
});
</script>

<template>
  <DropdownBody class="min-w-56 z-50 [&>ul]:gap-3 [&>ul]:px-4 [&>ul]:py-3.5">
    <div class="flex flex-col items-start gap-3">
      <Button
        v-for="item in menuItems"
        :key="item.key"
        :label="item.label"
        :icon="item.icon"
        slate
        link
        sm
        class="hover:!no-underline text-n-slate-12 font-normal text-xs w-full !justify-start"
        @click="emit('executeCopilotAction', item.key)"
      />
    </div>
  </DropdownBody>
</template>
