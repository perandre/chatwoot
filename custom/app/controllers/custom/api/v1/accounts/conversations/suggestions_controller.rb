# Tindre suggests labels and priority instead of Captain's classifier. Tindre gives no score, so `probability` and
# `confidence` are nil; the dashboard reads only the titles and the priority.
module Custom::Api::V1::Accounts::Conversations::SuggestionsController
  def labels
    candidates = Current.account.labels.where.not(title: @conversation.label_list)
    return render json: { labels: [] } if candidates.empty?

    titles = tindre_assist('suggest_labels', labels: candidates.map { |label| { title: label.title, description: label.description } })['labels']
    render json: { labels: titles.map { |title| { title: title, probability: nil } } }
  end

  def priority
    render json: { priority: tindre_assist('suggest_priority')['priority'], confidence: nil }
  end

  private

  def tindre_assist(action, **payload)
    Tindre::AssistClient.new.call(
      action: action,
      conversation_key: "#{Current.account.id}:#{@conversation.display_id}",
      transcript: LlmFormatter::ConversationLlmFormatter.new(@conversation).format,
      **payload
    )
  end
end
