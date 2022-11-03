require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/opsgenie"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::OpsGenie do

  subject {LogStash::Outputs::OpsGenie.new( "apiKey" => "my_api_key" )}
  let(:logger) { subject.logger}

  describe "receive message" do

    it "warns when opsgenieAction is not specified" do
      expect(logger).to receive(:warn).with("No opsgenie action defined").once

      event_data = {"message" => "test_alert","@version" => "1","@timestamp" => "2015-09-22T11:20:00.250Z"}
      subject.receive(LogStash::Event.new(event_data))
    end

    it "warns when opsgenieAction is not valid" do
      action = "invalid"
      expect(logger).to receive(:warn).with("Action #{action} does not match any available action, discarding..").once

      event_data = {
        "@timestamp" => "2015-09-22T11:20:00.250Z",
        "message" => "test_alert",
        "@version" => "1",
        "opsgenieAction" => action
      }
      subject.receive(LogStash::Event.new(event_data))
    end

    it "logs event when opsGenieAction is 'create'" do
      event_data = {
        "@timestamp" => "2015-09-22T11:20:00.250Z",
        "host" => "my-mac",
        "message" => "test_alert",
        "@version" => "1",
        "opsgenieAction" => "create"
      }
      expect(logger).to receive(:info).with(
        "processing event: #{event_data['@timestamp']} #{event_data['host']} #{event_data['message']}"
      ).once
      expect(logger).to receive(:info).with("Executing url #{subject.opsGenieBaseUrl}").once

      subject.receive(LogStash::Event.new(event_data))
    end

    it "logs event when opsGenieAction is 'close'" do
      event_data = {
        "@timestamp" => "2015-09-22T11:20:00.250Z",
        "host" => "my-mac",
        "message" => "test_alert",
        "@version" => "1",
        "opsgenieAction" => "close"
      }
      expect(logger).to receive(:info).with(
        "processing event: #{event_data['@timestamp']} #{event_data['host']} #{event_data['message']}"
      ).once
      expect(logger).to receive(:info).with(
        "Executing url #{subject.opsGenieBaseUrl}#{subject.closeActionPath}?identifierType=#{subject.identifierType}"
      ).once
      subject.receive(LogStash::Event.new(event_data))
    end

    it "logs event when opsGenieAction is 'acknowledge'" do
      event_data = {
        "@timestamp" => "2015-09-22T11:20:00.250Z",
        "host" => "my-mac",
        "message" => "test_alert",
        "@version" => "1",
        "opsgenieAction" => "acknowledge"
      }
      expect(logger).to receive(:info).with(
        "processing event: #{event_data['@timestamp']} #{event_data['host']} #{event_data['message']}"
      ).once
      expect(logger).to receive(:info).with(
        "Executing url #{subject.opsGenieBaseUrl}#{subject.acknowledgeActionPath}?identifierType=#{subject.identifierType}"
      ).once
      subject.receive(LogStash::Event.new(event_data))
    end

    it "logs event when opsGenieAction is 'note'" do
      event_data = {
        "@timestamp" => "2015-09-22T11:20:00.250Z",
        "host" => "my-mac",
        "message" => "test_alert",
        "@version" => "1",
        "opsgenieAction" => "note"
      }
      expect(logger).to receive(:info).with(
        "processing event: #{event_data['@timestamp']} #{event_data['host']} #{event_data['message']}"
      ).once
      expect(logger).to receive(:info).with(
        "Executing url #{subject.opsGenieBaseUrl}#{subject.noteActionPath}?identifierType=#{subject.identifierType}"
      ).once
      subject.receive(LogStash::Event.new(event_data))
    end
  end
end
