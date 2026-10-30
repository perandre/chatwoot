# The search page (HTML) is unchanged; its JSON form (`/hc/:slug/:locale/search.json?query=`) answers the query with
# Tindre. The page loads that answer after rendering (custom/app/views/.../search/_search_handler.html.erb), so a slow
# Tindre never holds up the article results.
module Custom::Public::Api::V1::Portals::SearchController
  def self.prepended(base)
    base.rescue_from Tindre::AssistClient::Error do |error|
      ChatwootExceptionTracker.new(error, account: @portal.account).capture_exception
      head :bad_gateway
    end
  end

  def index
    return super unless request.format.json?

    query = params[:query].to_s.strip
    return head :unprocessable_entity if query.blank?

    result = Tindre::AssistClient.new.call(action: 'search', query: query, locale: params[:locale])
    # Sources become links on a public page, so only web links are passed on.
    sources = Array(result['sources']).select { |source| source['url'].to_s.start_with?('https://', 'http://') }
    render json: result.slice('answer', 'no_answer').merge('sources' => sources)
  end
end
