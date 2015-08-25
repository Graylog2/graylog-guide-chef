# Chef::Handler::Graylog

This gem provides a `Chef::Handler` that subscribes to various Chef runtime
events.

All captured events will be sent to a Graylog server via GELF HTTP.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chef-handler-graylog'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chef-handler-graylog

## Requirements

A Graylog server with a running GELF HTTP input is required to receive events
sent by this plugin.

## Usage

The gem includes a Chef start handler and needs to be configured in the `client.rb`
configuration. Make sure to wrap the initialization in a begin/rescue block
to avoid killing the Chef client due to errors.

```ruby
begin
  require 'chef/handler/graylog/gelf_start_handler'

  # IP address and port of the GELF HTTP input on your Graylog server.
  graylog_server_url = 'http://10.0.2.2:12201/gelf'
  options = {}

  start_handlers << Chef::Handler::Graylog::GelfStartHandler.new(graylog_server_url, options)
rescue Object => e
  Chef::Log.error("Loading Graylog start handler failed: #{e.message}")
end
```

### Available Options

* `:timeout` - The timeout for the GELF HTTP requests in seconds. (default: `1`)
  Make sure to choose a small timeout because the plugin might try to send a
  lot of HTTP requests. A big timeout will slow down the Chef run in case of
  an error while sending the events.
* `:ssl_verify_mode` - Can either be set to `:verify_peer` or `:verify_none`. (default: `:verify_peer`)
* `:ssl_ca_path` - Directory that holds the certificate authority. (default: `nil`)
* `:ssl_ca_file` - File that holds the certificate authority. (default: `nil`)
* `:ssl_client_cert` - Client certificate used for authentication. (default: `nil`)
* `:ssl_client_key` - Client key used for authentication. (default: `nil`)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/Graylog2/graylog-guide-chef/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
