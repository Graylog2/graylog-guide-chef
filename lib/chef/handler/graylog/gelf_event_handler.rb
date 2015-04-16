require 'time'
require 'chef/log'
require 'chef/event_dispatch/base'
require 'chef/handler/graylog/gelf_message'

class Chef
  class Handler
    module Graylog
      class GelfEventHandler < Chef::EventDispatch::Base
        def initialize(sender)
          @sender = sender
          @run_status = nil
        end

        def run_started(run_status)
          @run_status = run_status
        rescue Object => e
          log_error(__method__.downcase, e)
        end

        def run_completed(node)
          message = new_message(node, 'run_completed')

          message.message = "Chef run succeeded on node #{node.name}"

          add_common_run_status_fields(message)

          @sender.send_payload(message)
        rescue Object => e
          log_error(__method__.downcase, e)
        end

        def run_failed(exception)
          message = new_message(@run_status.node, 'run_failed')

          message.message = "Chef run failed on node #{@run_status.node.name}"

          add_common_run_status_fields(message)

          message.add_field('error_message', exception.to_s)
          message.add_field('error_type', exception.class)
          message.add_field('error_backtrace', Array(@run_status.backtrace).join("\n"))

          @sender.send_payload(message)
        rescue Object => e
          log_error(__method__.downcase, e)
        end

        def resource_updated(resource, action)
          message = new_message(resource.node, 'resource_updated')

          message.message = "Resource updated: #{resource.resource_name}"

          message.add_field('resource_action', Array(resource.action).join(','))
          message.add_field('resource_identity', resource.identity)
          message.add_field('resource_name', resource.resource_name)
          message.add_field('resource_cookbook_name', resource.cookbook_name)
          message.add_field('resource_cookbook_version', resource.cookbook_version.version)
          message.add_field('resource_recipe_name', resource.recipe_name)
          message.add_field('resource_declared_type', resource.declared_type)
          message.add_field('resource_defined_at', resource.defined_at)
          message.add_field('resource_duration', resource.elapsed_time)

          @sender.send_payload(message)
        rescue Object => e
          log_error(__method__.downcase, e)
        end

        private

        def new_message(node, event_name)
          Graylog::GelfMessage.new(node, 'chef').tap do |message|
            message.add_field('run_id', run_id)
            message.add_field('event_name', event_name)
            message.add_field('node_name', node.name)
            message.add_field('node_environment', node.environment)
            message.add_field('node_roles', Array(node.run_list.role_names).join(','))
            message.add_field('node_recipes', Array(node.run_list.recipe_names).join(','))
          end
        end

        def add_common_run_status_fields(message)
          message.add_field('run_start_time', to_iso8601(@run_status.start_time))
          message.add_field('run_end_time', to_iso8601(@run_status.end_time))
          message.add_field('run_elapsed_time', @run_status.elapsed_time)
          message.add_field('run_total_resources', @run_status.all_resources.size)
          message.add_field('run_updated_resources', @run_status.updated_resources.size)
          message.add_field('run_cookbooks', @run_status.run_context.cookbook_collection.keys.sort.join(','))
        end

        def log_error(event, e)
          Chef::Log.error("#{self.class}##{event} failed: #{e}")
        end

        def run_id
          @run_status.nil? ? nil : @run_status.run_id
        end

        def to_iso8601(time)
          time.utc.iso8601(3)
        rescue
          nil
        end
      end
    end
  end
end