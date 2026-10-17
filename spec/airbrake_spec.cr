require "./spec_helper"

describe Airbrake do
  describe ".notify" do
    it "sends the notice and returns the parsed response" do
      with_airbrake_server do |requests|
        response = Airbrake.notify(Exception.new("boom"), {"user" => "1"})

        response.should eq({"id" => "42", "url" => "https://airbrake.io/locate/42"})
        requests.size.should eq(1)
        requests.first.resource.should eq("/api/v3/projects/123/notices?key=secret")
        payload = JSON.parse(requests.first.body)
        payload["errors"][0]["message"].as_s.should eq("boom")
        payload["params"]["user"].as_s.should eq("1")
      end
    end

    it "returns nil when the response is not JSON" do
      with_airbrake_server(status: 200, body: "<html>Bad Gateway</html>") do
        Airbrake.notify(Exception.new("boom")).should be_nil
      end
    end

    it "returns nil when the response is an error" do
      with_airbrake_server(status: 503, body: %({"message":"unavailable"})) do
        Airbrake.notify(Exception.new("boom")).should be_nil
      end
    end

    it "does not send anything in development environments" do
      with_airbrake_server do |requests|
        Airbrake.config.development_environments = [ENV.fetch("CRYSTAL_ENV", "development")]

        Airbrake.notify(Exception.new("boom")).should be_nil
        requests.should be_empty
      end
    end
  end

  describe ".handle" do
    it "returns the block value" do
      with_airbrake_server do |requests|
        Airbrake.handle { 1 }.should eq(1)
        requests.should be_empty
      end
    end

    it "notifies and re-raises the original exception" do
      with_airbrake_server do |requests|
        expect_raises(Exception, "boom") { Airbrake.handle { raise "boom" } }
        requests.size.should eq(1)
      end
    end

    it "re-raises the original exception when Airbrake replies with garbage" do
      with_airbrake_server(status: 200, body: "<html>Bad Gateway</html>") do
        expect_raises(Exception, "boom") { Airbrake.handle { raise "boom" } }
      end
    end

    it "re-raises the original exception and logs when Airbrake is unreachable" do
      configure_airbrake(unreachable_endpoint)

      Log.capture("airbrake") do |logs|
        expect_raises(Exception, "boom") { Airbrake.handle { raise "boom" } }
        logs.check(:warn, "Failed to notify Airbrake")
      end
    end
  end
end
