# Tindre judges a rule's Captain conditions instead of Jev. Core's `perform` still gates on the feature flag and the
# transcript, keys answers by the condition's index and turns any error into "unmet"; only the question and its answer change.
module Custom::Captain::AutomationConditionService
  private

  def question(condition)
    condition['values'].first
  end

  def ask(descriptions)
    answers = Tindre::AssistClient.new.call(
      action: 'conditions',
      conversation_key: "#{conversation.account_id}:#{conversation.display_id}",
      transcript: LlmFormatter::ConversationLlmFormatter.new(conversation).format,
      conditions: descriptions,
      latest_message: (latest_message[:text] if message)
    )['answers']
    raise ::Captain::AutomationConditionService::Error, 'Tindre returned an invalid response' unless answers.is_a?(Hash)

    answers
  rescue Tindre::AssistClient::Error => e
    raise ::Captain::AutomationConditionService::Error, e.message
  end

  def met?(condition, answer)
    raise ::Captain::AutomationConditionService::Error, 'Tindre returned an incomplete answer' unless [true, false].include?(answer)

    condition['filter_operator'] == 'detects' ? answer : !answer
  end
end
