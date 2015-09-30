# OpsGenie Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

### Install and Run OpsGenie Output Plugin in Logstash

OpsGenie Logstash Output plugin is available in [RubyGems.org](https://rubygems.org/gems/logstash-output-opsgenie)

- Install plugin
```sh
bin/plugin install logstash-output-opsgenie
```

- OpsGenie has Logstash Integration. To use the plugin you need to add a [Logstash Integration](https://app.opsgenie.com/integration?add=Logstash) in OpsGenie and obtain the API Key.
- Add the following configuration to your configuration file and populate "apiKey" field with your Logstash Integration API Key
```sh
output {
	opsgenie {
		"apiKey" => "logstash_integration_api_key"
	}
}
```
- Run Logstash.

For more information about OpsGenie Logstash Integration, please refer to [support document](https://www.opsgenie.com/docs/integrations/logstash-integration).