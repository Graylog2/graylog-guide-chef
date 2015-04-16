class Chef
  class Handler
    module Graylog
      class GelfMessage
        attr_writer :message, :full_message

        def initialize(node, field_prefix, timestamp = Time.now.to_f)
          @node = node
          @field_prefix = field_prefix
          @timestamp = timestamp
          @version = '1.1'
          @fields = {}
        end

        def add_field(key, value)
          @fields["_#{[@field_prefix, key].compact.join('_')}"] = value
        end

        def to_hash
          hash = {
              'version' => @version,
              'timestamp' => @timestamp,
              'host' => @node.name,
              'short_message' => @message
          }

          hash['full_message'] = @full_message if @full_message

          @fields.merge(hash)
        end
      end
    end
  end
end