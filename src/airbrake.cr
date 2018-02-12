require "./airbrake/*"

module Airbrake

  def self.handle(&block)
    begin
      yield
    rescue ex
      notify(ex)
      raise ex
    end
  end

  def self.notify(exception)
    check_config!
    response = HTTP::Client.post(
      Airbrake.config.uri,
      headers: HTTP::Headers{
        "Content-Type" => "application/json",
        "User-Agent" => Airbrake.config.user_agent
      },
      body: Airbrake::Error.payload(exception)
    )
    Hash(String, String).from_json(response.body)
  end

  def self.configure
    yield Config::INSTANCE
  end

  def self.config
    Config::INSTANCE
  end

  def self.check_config!
    unless [config.project_id, config.project_key].all?
      raise Airbrake::Exception.new("Invalid Config. :project_id and :project_key are required")
    end
  end
end
