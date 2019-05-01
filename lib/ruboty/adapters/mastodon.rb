require 'lru_redux'
require 'mastodon'
require 'json'

module Ruboty
  module Adapters
    class Mastodon < Base
      env :MASTODON_BASE_URL, 'Base URL of your mastodon server'
      env :MASTODON_BEARER_TOKEN, 'API token of your mastodon account'
      env :MASTODON_IGNORE_BOT_MESSAGE, 'Ignroe bot user message', optional: true

      def run
        init
        connect
      end

      def say(message)
        rest_client.create_status(message[:body])
      end

      protected

      def init
        cache.clear
        account = rest_client.verify_credentials

        ENV['RUBOTY_NAME'] ||= account.username
      end

      def connect
        Thread.new do
          loop do
            begin
              streaming_client.stream('public/local') do |data|
                receive(data)
              end
            rescue => e
              Ruboty.logger.error(e)
            end
            sleep 10
          end
        end

        loop do
          begin
            streaming_client.user do |data|
              receive(data)
            end
          rescue => e
            Ruboty.logger.error(e)
          end
          sleep 10
        end
      end

      def receive(data)
        case data
        when ::Mastodon::Notification
          on_status(data.status) if data.type == 'mention'
        when ::Mastodon::Status
          on_status(data)
        end
      end

      def on_status(status)
        return if cache[status.id]

        cache[status.id] = 1

        return if status.account.bot? && ENV['MASTODON_IGNORE_BOT_MESSAGE']

        message = {
          body: status.content.gsub(/<.+?>/, ''),
          from: status.account.acct,
          status: status,
          account: status.account
        }
        Ruboty.logger.debug(status)

        robot.receive(message)
      end

      def rest_client
        @rest_client ||= ::Mastodon::REST::Client.new(
          base_url: ENV['MASTODON_BASE_URL'],
          bearer_token: ENV['MASTODON_BEARER_TOKEN']
        )
      end

      def streaming_client
        @streaming_client ||= ::Mastodon::Streaming::Client.new(
          base_url: ENV['MASTODON_BASE_URL'],
          bearer_token: ENV['MASTODON_BEARER_TOKEN']
        )
      end

      def cache
        @cache ||= LruRedux::Cache.new(20)
      end
    end
  end
end
