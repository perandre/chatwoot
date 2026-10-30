# Asks Tindre through the tindre-chatwoot-bridge Worker. `call` returns the bridge's parsed JSON and raises Error
# when the bridge cannot be reached or answers with a failure; `perform` wraps it for the reply editor's `{ message: }`.
class Tindre::AssistClient
  class Error < StandardError; end

  def call(**payload)
    response = HTTParty.post(
      ENV.fetch('TINDRE_ASSIST_URL'),
      body: payload.to_json,
      headers: { 'Authorization' => "Bearer #{ENV.fetch('TINDRE_ASSIST_SECRET')}", 'Content-Type' => 'application/json' },
      timeout: 60
    )
    raise Error, "Tindre svarte ikke (#{response.code})" unless response.success?

    body = response.parsed_response
    raise Error, 'Tindre svarte med et ugyldig svar' unless body.is_a?(Hash)

    body
  rescue HTTParty::Error, Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError, JSON::ParserError => e
    raise Error, e.message
  end

  def perform(**payload)
    { message: call(**payload)['message'] }
  rescue Error => e
    { error: e.message }
  end
end
