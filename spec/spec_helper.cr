require "spec"
require "log/spec"
require "http/server"
require "../src/airbrake"

record CapturedRequest, resource : String, body : String

def configure_airbrake(endpoint : String)
  Airbrake.configure do |config|
    config.project_id = "123"
    config.project_key = "secret"
    config.endpoint = endpoint
    config.development_environments = [] of String
  end
end

# Starts a local HTTP server standing in for the Airbrake API and points the
# config at it. Yields the requests it received.
def with_airbrake_server(status = 201, body = %({"id":"42","url":"https://airbrake.io/locate/42"}), &)
  requests = [] of CapturedRequest
  server = HTTP::Server.new do |context|
    requests << CapturedRequest.new(context.request.resource, context.request.body.try(&.gets_to_end) || "")
    context.response.status_code = status
    context.response.print body
  end
  address = server.bind_tcp("127.0.0.1", 0)
  spawn server.listen
  Fiber.yield
  begin
    configure_airbrake("http://127.0.0.1:#{address.port}")
    yield requests
  ensure
    server.close
  end
end

# Returns an endpoint on a port nothing listens on.
def unreachable_endpoint
  server = TCPServer.new("127.0.0.1", 0)
  port = server.local_address.port
  server.close
  "http://127.0.0.1:#{port}"
end
