# Asks Tindre, through the tindre-chatwoot-bridge Worker, for reply suggestions and summaries.
class Tindre::AssistClient
  def perform(**payload)
    response = HTTParty.post(
      ENV.fetch('TINDRE_ASSIST_URL'),
      body: payload.to_json,
      headers: { 'Authorization' => "Bearer #{ENV.fetch('TINDRE_ASSIST_SECRET')}", 'Content-Type' => 'application/json' },
      timeout: 60
    )
    return { error: "Tindre svarte ikke (#{response.code})" } unless response.success?

    { message: response.parsed_response['message'] }
  end
end
