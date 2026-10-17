module Airbrake
  class Config
    property project_id : String | Nil
    property project_key : String | Nil
    property endpoint : String = "https://airbrake.io"
    property user_agent : String = "Airbrake Crystal"
    property development_environments : Array(String) = ["development", "test"]
    getter project_id
    getter project_key
    getter endpoint
    getter user_agent
    getter development_environments

    INSTANCE = Config.new

    def initialize
    end

    def uri
      uri = URI.parse(endpoint)
      uri.path = "/api/v3/projects/#{project_id}/notices"
      uri.query = "key=#{project_key}"
      uri
    end
  end
end
