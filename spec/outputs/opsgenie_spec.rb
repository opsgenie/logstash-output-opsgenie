require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/opsgenie"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::OpsGenie do

  subject {LogStash::Outputs::OpsGenie.new( "apiKey" => "my_api_key" )}
  let(:logger) { subject.logger}

  describe "receive message" do

    it "when opsgenieAction is not specified" do
      expect(logger).to receive(:warn).with("No opsgenie action defined").once
      subject.receive({"message" => "test_alert","@version" => "1","@timestamp" => "2015-09-22T11:20:00.250Z"})
    end

    it "when opsgenieAction is not valid" do
      action = "invalid"
      expect(logger).to receive(:warn).with("Action #{action} does not match any available action, discarding..").once
      subject.receive({"message" => "test_alert","@version" => "1","@timestamp" => "2015-09-22T11:20:00.250Z", "opsgenieAction" => action})
    end

    it "when opsGenieAction is 'create'" do
      event = {"message" => "test_alert", "@version" => "1", "@timestamp" => "2015-09-22T11:20:00.250Z", "opsgenieAction" => "create"}
      expect(logger).to receive(:info).with("processing #{event}").once
      expect(logger).to receive(:info).with("Executing url #{subject.opsGenieBaseUrl}#{subject.createActionUrl}").once
      subject.receive(event)
    end

    it "when opsGenieAction is 'close'" do
      event = {"message" => "test_alert", "@version" => "1", "@timestamp" => "2015-09-22T11:20:00.250Z", "opsgenieAction" => "close"}
      expect(logger).to receive(:info).with("processing #{event}").once
      expect(logger).to receive(:info).with("Executing url #{subject.opsGenieBaseUrl}#{subject.closeActionUrl}").once
      subject.receive(event)
    end

    it "when opsGenieAction is 'acknowledge'" do
      event = {"message" => "test_alert", "@version" => "1", "@timestamp" => "2015-09-22T11:20:00.250Z", "opsgenieAction" => "acknowledge"}
      expect(logger).to receive(:info).with("processing #{event}").once
      expect(logger).to receive(:info).with("Executing url #{subject.opsGenieBaseUrl}#{subject.acknowledgeActionUrl}").once
      subject.receive(event)
    end

    it "when opsGenieAction is 'note'" do
      event = {"message" => "test_alert", "@version" => "1", "@timestamp" => "2015-09-22T11:20:00.250Z", "opsgenieAction" => "note"}
      expect(logger).to receive(:info).with("processing #{event}").once
      expect(logger).to receive(:info).with("Executing url #{subject.opsGenieBaseUrl}#{subject.noteActionUrl}").once
      subject.receive(event)
    end
  end
end
