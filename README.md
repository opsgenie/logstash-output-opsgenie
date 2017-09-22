# OpsGenie Logstash Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

### Install and Run OpsGenie Output Plugin in Logstash

OpsGenie Logstash Output plugin is available in [RubyGems.org](https://rubygems.org/gems/logstash-output-opsgenie)

- `Logstash 5.4+`
```sh
bin/logstash-plugin install logstash-output-opsgenie
```
- `Other Versions`
```sh
bin/plugin install logstash-output-opsgenie
```

- OpsGenie has an integration with Logstash. To use the plugin you need to add a [Logstash Integration](https://app.opsgenie.com/integration?add=Logstash) in OpsGenie and obtain the API Key.

- You may use plugins like [Mutate](https://www.elastic.co/guide/en/logstash/current/plugins-filters-mutate.html) to populate the fields which will be used in [logstash-output-opsgenie](https://github.com/opsgenie/logstash-output-opsgenie).
```filter {
  mutate{
    add_field => {
        "opsgenieAction" => "create"
        "alias" => "neo123"
        "description" => "Every alert needs a description"
        "actions" => ["Restart", "AnExampleAction"]
	"tags" => ["OverwriteQuietHours","Critical"]
	"[details][prop1]"=> "val1"
        "[details][prop2]" => "val2"
        "entity" => "An example entity"
        "priority" => "P4"
	"source" => "custom source"
	"user" => "custom user"
	"note" => "alert is created"
        }
    }
    ruby {
 	 code => "event.set('teams', [{'name' => 'Integration'}, {'name' => 'Platform'}])"
    }
}
```

- Add the following configuration to your configuration file and populate "apiKey" field with your Logstash Integration API Key
```sh
output {
	opsgenie {
		"apiKey" => "logstash_integration_api_key"
	}
}
```
- Run Logstash.

For more information about OpsGenie Logstash Integration, please refer to [integration guide](https://docs.opsgenie.com/docs/logstash-integration).
