require 'chef/handler'
require 'chef/handler/graylog/sender/http'
require 'chef/handler/graylog/gelf_event_handler'

class Chef
  class Handler
    module Graylog
      class GelfStartHandler < Chef::Handler
        def initialize(server_uri, config = {})
          @sender = Graylog::Sender::Http.new(server_uri, config)
        end

        def report
          @run_status.events.register(Graylog::GelfEventHandler.new(@sender))
        end
      end
    end
  end
end