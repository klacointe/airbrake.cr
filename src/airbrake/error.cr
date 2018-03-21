require "json"

module Airbrake
  class Error
    STACKFRAME_TEMPLATE = /\A(.+):(\d+):(\d+) in '(.+)'/

    def self.backtrace(exception)
      return unless exception.backtrace?
      (exception.backtrace || [] of String).map do |stackframe|
        if m = stackframe.match(STACKFRAME_TEMPLATE)
          { file: m[1]? || "<crystal>" , line: m[2]?.try(&.to_i) || 0, function: m[4]? || "<file>" }
        else
          { file: "<crystal>", line: 0, function: "<file>" }
        end
      end
    end

    def self.payload(exception, params = {} of String => String)
      JSON.build do |json|
        json.object do
          json.field "notifier" do
            json.object do
              json.field "name", Airbrake.config.user_agent
              json.field "version", Airbrake::VERSION
              json.field "url", "https://github.com/klacointe/airbrake.cr"
            end
          end
          json.field "errors" do
            json.array do
              json.object do
                json.field "type", exception.class.name
                json.field "message", exception.message
                json.field "backtrace", backtrace(exception)
              end
            end
          end
          json.field "context" do
            json.object do
              json.field "language", Crystal::DESCRIPTION
              json.field "build", Crystal::BUILD_DATE
              json.field "commit", Crystal::BUILD_COMMIT
            end
          end
          json.field "environment" do
            json.object do
            end
          end
          json.field "params", params
        end
      end
    end
  end
end
