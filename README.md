# Flexciton Logstash Output OpsGenie Plugin

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

This version is forked from: https://github.com/opsgenie/logstash-output-opsgenie
All kudos goes to the original authors.

`flexciton-logstash-output-opsgenie` improvements:
- Add error handling on network errors. Previously the pipeline in `Logstash` would simply crash and cause `Logstash` to go down or stop processing logs completely. Now it will retry certain errors or log a warning and silence the exception.
- Fix all tests. Tests were broken since 2017 changes to adjust to new Opsgenie API. Now they pass.

### Install and Run Flexciton Logstash Output OpsGenie in Logstash

Flexciton Logstash Output OpsGenie plugin is available in [RubyGems.org](https://rubygems.org/gems/flexciton-logstash-output-opsgenie)

- `Logstash 5.4+`
```sh
bin/logstash-plugin install flexciton-logstash-output-opsgenie
```
- `Other Versions`
```sh
bin/plugin install flexciton-logstash-output-opsgenie
```

- OpsGenie has an integration with Logstash. To use the plugin you need to add a [Logstash Integration](https://app.opsgenie.com/integration?add=Logstash) in OpsGenie and obtain the API Key.

- You may use plugins like [Mutate](https://www.elastic.co/guide/en/logstash/current/plugins-filters-mutate.html) to populate the fields which will be used in [flexciton-logstash-output-opsgenie](https://github.com/flexciton/logstash-output-opsgenie).
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

- Add the following configuration to your configuration file and populate `apiKey` field with your Logstash Integration API Key

NOTE: despite the integration document in Atlassian shows that api key should be wrapped in quotes (`"apiKey"`) - this is not the case. Use `apiKey` as shown below please.

```sh
output {
	opsgenie {
		apiKey => "logstash_integration_api_key"
	}
}
```
- Run Logstash.

For more information about OpsGenie Logstash Integration, please refer to [integration guide](https://docs.opsgenie.com/docs/logstash-integration).
