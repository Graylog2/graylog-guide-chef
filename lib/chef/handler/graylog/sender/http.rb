require 'chef/http/basic_client'
require 'chef/handler/graylog/version'
require 'ostruct'

class Chef
	class Handler
		module Graylog
			module Sender
				class Http < Chef::HTTP::BasicClient
					class GraylogSSLPolicy < Chef::HTTP::DefaultSSLPolicy
						def self.apply_to(http_client, config)
							new(http_client, config).apply
							http_client
						end

						def initialize(http_client, config)
							@config = config # Needs to be set BEFORE calling super to avoid nil error in #config.
							super(http_client)
						end

						def config
							conf = {
								:ssl_verify_mode => @config["set_verify_mode"] || :verify_peer, # available: :verify_peer, :verify_none
								:ssl_ca_path => @config["ssl_ca_path"],
								:ssl_ca_file => @config["ssl_ca_file"],
								:ssl_client_cert => @config["ssl_client_cert"],
								:ssl_client_key => @config["ssl_client_key"],
							}
							OpenStruct.new conf
						end
					end

				def initialize(url, config = {})
					@config = config # Needs to be set BEFORE calling super to avoid nil error in #config.
					super(URI.parse(url), :ssl_policy => GraylogSSLPolicy)
				end

				def config
					# Using a small timeout by default because there could be lots of HTTP requests.
					{:rest_timeout => @config[:timeout] || 1}
				end

				def configure_ssl(http_client)
					http_client.use_ssl = true
					ssl_policy.apply_to(http_client, @config)
				end

				def send_payload(message)
					request(:POST, url, JSON.dump(message.to_hash), 'X-Graylog-Chef-Handler-Version' => Graylog::VERSION)
					rescue => e
						Chef::Log.error("[#{self.class}] Sending GELF message failed: #{e.message}")
					end
				end
			end
		end
	end
end
