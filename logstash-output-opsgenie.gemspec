Gem::Specification.new do |s|
  s.name = 'flexciton-logstash-output-opsgenie'
  s.version = '1.0.1'
  s.licenses = ["Apache-2.0"]
  s.summary = "Flexciton Logstash Output Opsgenie plugin allows creation, closing, acknowledging and adding notes to alerts in OpsGenie."
  s.description = "Install this gem on your Logstash instance with: $LS_HOME/bin/logstash-plugin install flexciton-logstash-output-opsgenie. Includes retry and silencing mechanism for network errors."
  s.authors = ["Flexciton Ltd, Tomasz Kluczkowski"]
  s.homepage = "https://github.com/flexciton/logstash-output-opsgenie"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency "logstash-codec-plain"
  s.add_development_dependency "logstash-devutils"
end
