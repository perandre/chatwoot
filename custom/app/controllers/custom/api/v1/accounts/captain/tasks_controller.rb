module Custom::Api::V1::Accounts::Captain::TasksController
  def reply_suggestion
    render_result(tindre_assist('reply_suggestion', transcript: tindre_transcript))
  end

  def summarize
    render_result(tindre_assist('summarize', transcript: tindre_transcript))
  end

  def follow_up
    render_result(tindre_assist('follow_up', message: params[:message]))
  end

  private

  def tindre_assist(action, **payload)
    result = Tindre::AssistClient.new.perform(action: action, conversation_key: tindre_conversation_key, **payload)
    result.merge(follow_up_context: { 'source' => 'tindre' })
  end

  def tindre_conversation_key
    "#{Current.account.id}:#{params[:conversation_display_id]}"
  end

  def tindre_transcript
    conversation = Current.account.conversations.find_by!(display_id: params[:conversation_display_id])
    LlmFormatter::ConversationLlmFormatter.new(conversation).format
  end
end
