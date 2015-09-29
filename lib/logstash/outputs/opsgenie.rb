# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require 'json'
require "uri"
require "net/http"
require "net/https"

# The OpsGenie output is used to Create, Close, Acknowledge Alerts and Add Note to alerts in OpsGenie.
# For this output to work, your event must contain "opsgenieAction" field and you must configure apiKey field in configuration.
#   If opsgenieAction is "create", event must contain "message" field.
#   For other actions ("close", "acknowledge" or "note"), event must contain "alias" or "alertId" field.
#
# If your event have the following fields (If you use default field names).
#
# Example JSON-encoded event:
#
#     {
#       "message": "alert_message",
#       "@version": "1",
#       "@timestamp": "2015-09-22T11:20:00.250Z",
#       "host": "192.168.1.1",
#       "opsgenieAction": "create",
#       "alias": "alert_alias",
#       "teams": ["teams"],
#       "recipients": "the-recipients",
#       "description": "alert_description",
#       "actions": ["actions"],
#       "source": "alert_source",
#       "tags": ["tags"],
#       "entity": "alert_entity",
#       "user": "alert_owner",
#       "note": "additional_alert_note"
#       "details": {
#           "extra_prop1": "value1",
#           "extra_prop2": "value2"
#       }
#     }
#
# An alert with following properties will be created.
#
#     {
#       "message": "alert_message",
#       "alias": "alert_alias",
#       "teams": ["teams"],
#       "description": "alert_description",
#       "source": "alert_source",
#       "tags": [
#         "tags"
#       ],
#       "recipients": [
#         "the-recipients"
#       ],
#       "details": {
#         "extra_prop1": "value1",
#         "extra_prop2": "value2"
#       },
#       "actions": [
#         "actions"
#       ],
#       "entity": "alert_entity",
#     }
#
# Fields with prefix "Attribute" are the keys of the fields will be extracted from Logstash event.
# For more information about the api requests and their contents,
# please refer to Alert API("https://www.opsgenie.com/docs/web-api/alert-api") support doc.

class LogStash::Outputs::OpsGenie < LogStash::Outputs::Base

  config_name "opsgenie"

  # OpsGenie Logstash Integration API Key
  config :apiKey, :validate => :string, :required => true

  # Host of opsgenie api, normally you should not need to change this field.
  config :opsGenieBaseUrl, :validate => :string, :required => false, :default => 'https://api.opsgenie.com'

  # Url will be used to create alerts in OpsGenie
  config :createActionUrl, :validate => :string, :required => false, :default =>'/v1/json/alert'

  # Url will be used to close alerts in OpsGenie
  config :closeActionUrl, :validate => :string, :required => false, :default =>'/v1/json/alert/close'

  # Url will be used to acknowledge alerts in OpsGenie
  config :acknowledgeActionUrl, :validate => :string, :required => false, :default =>'/v1/json/alert/acknowledge'

  # Url will be used to add notes to alerts in OpsGenie
  config :noteActionUrl, :validate => :string, :required => false, :default =>'/v1/json/alert/note'


  # The value of this field holds the name of the action will be executed in OpsGenie.
  # This field must be in Event object. Should be one of "create", "close", "acknowledge" or "note". Other values will be discarded.
  config :actionAttribute, :validate => :string, :required => false, :default => 'opsgenieAction'

  # The value of this field holds the Id of the alert that actions will be executed.
  # One of "alertId" or "alias" field must be in Event object, except from "create" action
  config :alertIdAttribute, :validate => :string, :required => false, :default => 'alertId'

  # The value of this field holds the alias of the alert that actions will be executed.
  # One of "alertId" or "alias" field must be in Event object, except from "create" action
  config :aliasAttribute, :validate => :string, :required => false, :default => 'alias'

  # The value of this field holds the alert text.
  config :messageAttribute, :validate => :string, :required => false, :default => 'message'

  # The value of this field holds the list of team names which will be responsible for the alert.
  config :teamsAttribute, :validate => :string, :required => false, :default => 'teams'

  # The value of this field holds the detailed description of the alert.
  config :descriptionAttribute, :validate => :string, :required => false, :default => 'description'

  # The value of this field holds the optional user, group, schedule or escalation names to calculate which users will receive the notifications of the alert.
  config :recipientsAttribute, :validate => :string, :required => false, :default => 'recipients'

  # The value of this field holds the comma separated list of actions that can be executed on the alert.
  config :actionsAttribute, :validate => :string, :required => false, :default => 'actions'

  # The value of this field holds the source of alert. By default, it will be assigned to IP address of incoming request.
  config :sourceAttribute, :validate => :string, :required => false, :default => 'source'

  # The value of this field holds the comma separated list of labels attached to the alert.
  config :tagsAttribute, :validate => :string, :required => false, :default => 'tags'

  # The value of this field holds the set of user defined properties. This will be specified as a nested JSON map
  config :detailsAttribute, :validate => :string, :required => false, :default => 'details'

  # The value of this field holds the entity the alert is related to.
  config :entityAttribute, :validate => :string, :required => false, :default => 'entity'

  # The value of this field holds the default owner of the execution. If user is not specified, owner of account will be used.
  config :userAttribute, :validate => :string, :required => false, :default => 'user'

  # The value of this field holds the additional alert note.
  config :noteAttribute, :validate => :string, :required => false, :default => 'note'

  public
  def register
  end # def register

  public
  def populateAliasOrId(event, params)
    alertAlias = event[@aliasAttribute] if event[@aliasAttribute]
    if alertAlias == nil then
      alertId = event[@alertIdAttribute] if event[@alertIdAttribute]
      if !(alertId == nil) then
        params['alertId'] = alertId;
      end
    else
      params['alias'] = alertAlias
    end
  end#def populateAliasOrId

  public
  def executePost(uri, params)
    if not uri == nil then
      @logger.info("Executing url #{uri}")
      url = URI(uri)
      http = Net::HTTP.new(url.host, url.port)
      if url.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Post.new(url.path)
      request.body = params.to_json
      response = http.request(request)
      body = response.body
      body = JSON.parse(body)
      @logger.warn("Executed [#{uri}]. Response:[#{body}]")
    end
  end#def executePost

  public
  def receive(event)
    return unless output?(event)
    @logger.info("processing #{event}")
    opsGenieAction = event[@actionAttribute] if event[@actionAttribute]
    if opsGenieAction then
      params = { :apiKey => @apiKey}
      case opsGenieAction.downcase
      when "create"
        uri = "#{@opsGenieBaseUrl}#{@createActionUrl}"
        params = populateCreateAlertContent(params,event)
      when "close"
        uri = "#{@opsGenieBaseUrl}#{@closeActionUrl}"
      when "acknowledge"
        uri = "#{@opsGenieBaseUrl}#{@acknowledgeActionUrl}"
      when "note"
        uri = "#{@opsGenieBaseUrl}#{@noteActionUrl}"
      else
        @logger.warn("Action #{opsGenieAction} does not match any available action, discarding..")
          return
      end

      populateCommonContent(params, event)
      executePost(uri, params)
    else
      @logger.warn("No opsgenie action defined")
      return
    end
  end # def receive

  private
  def populateCreateAlertContent(params,event)
    params['message'] = event[@messageAttribute] if event[@messageAttribute]
    params['teams'] = event[@teamsAttribute] if event[@teamsAttribute]
    params['description'] = event[@descriptionAttribute] if event[@descriptionAttribute]
    params['recipients'] = event[@recipientsAttribute] if event[@recipientsAttribute]
    params['actions'] = event[@actionsAttribute] if event[@actionsAttribute]
    params['tags'] = event[@tagsAttribute] if event[@tagsAttribute]
    params['entity'] = event[@entityAttribute] if event[@entityAttribute]
    params['details'] = event[@detailsAttribute] if event[@detailsAttribute]
    return params
  end

  private
  def populateCommonContent(params,event)
    populateAliasOrId(event, params)
    params['source'] = event[@sourceAttribute] if event[@sourceAttribute]
    params['user'] = event[@userAttribute] if event[@userAttribute]
    params['note'] = event[@noteAttribute] if event[@noteAttribute]
  end

end # class LogStash::Outputs::OpsGenie