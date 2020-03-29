# frozen_string_literal: true

module CodeWithSense
  class MailCheck < Padrino::Application
    disable :sessions
    disable :protect_from_csrf

    set :checker, MailProvider.new
    set :read_me, 'https://github.com/nikhgupta/mail_provider'

    get :api, '/', with: :str, provides: :json do
      data = search_provider_with_sanitized_errors(params[:str])
      status data.delete(:http_code) || 200
      data.to_json
    end

    private

    def assign_category(score, _free, _disposable)
      return :professional if score.nil?
      return :unsure if score.zero?

      score.positive? ? :free : :disposable
    end

    def search_provider(str)
      str  = Base64.decode64(str)
      data = settings.checker.check str, summarize: true
      data[:read_more] = settings.read_me
      data[:status] = assign_category(*data.values_at(:score, :free, :disposable))
      data
    end

    def search_provider_with_sanitized_errors(str)
      search_provider(str)
    rescue Encoding::UndefinedConversionError
      { http_code: 400, error: 'Invalid string. Did you base64 your query?' }
    rescue MailProvider::DomainParsingError => e
      { http_code: 400, error: "Domain Parsing - #{e.message}" }
    rescue MailProvider::TrieLoadError
      { http_code: 500, error: 'Problem loading entries. Please, try later.' }
    end
  end
end
