# Cookbook Name:: netapp
# Provider:: export_rule
#
# Copyright:: 2014, Chef Software, Inc <legal@getchef.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include NetApp::Api

# Support “no-operation” mode
def whyrun_supported?
  true
end


action :create do
  # Validate required parameters
  raise ArgumentError, "Attribute SVM is required to create export rules" unless new_resource.svm
  raise ArgumentError, "Attribute PolicyName is required to create export rules" unless new_resource.policy_name
  raise ArgumentError, "Attribute ClientMatch is required to create export rules" unless new_resource.client_match
  raise ArgumentError, "Attribute AccessProtocol is required to create export rules" unless new_resource.access_protocol
  raise ArgumentError, "Attribute Read-Only Rule is required to create export rules" unless new_resource.ro_rule
  raise ArgumentError, "Attribute Read-Write Rule is required to create export rules" unless new_resource.rw_rule

  # Check if the ClientMatch currently exists in RuleIndex.  If found, then
  # return the RuleIndex.  This could be extended later on by allowing an update
  # to be sent to the modify_existing_rule method
  client_check = check_client_match_rule(@new_resource)

  if client_check
    Chef::Log.info "Rule for #{new_resource.client_match} on #{new_resource.svm} exists at rule #{client_check} - nothing to do"
  else
    converge_by("Add rule for #{new_resource.client_match} on #{new_resource.svm}") do
      create_new_rule(@new_resource)
    end
  end

end

action :modify do
  # Validate required parameters
  raise ArgumentError, "Attribute SVM is required to create export rules" unless new_resource.svm
  raise ArgumentError, "Attribute PolicyName is required to modify export rules" unless @new_resource.policy_name
  raise ArgumentError, "Attribute RuleIndex or ClientMatch is required to modify export rules" unless @new_resource.rule_index || @new_resource.client_match

  # NetApp API requires a RuleIndex.  Set the ClientCheck variable to matche RuleIndex if provided
  # or look-up the client_match rule in the export-policy and return a valid RuleIndex.  If no
  # RuleIndex found then log that the resource doesn't exist. Otherwise, process the update.
  client_check = @new_resource.rule_index
  client_check = check_client_match_rule(@new_resource) unless @new_resource.rule_index

  if client_check
    @new_resource.rule_index = client_check
    converge_by("Modify rule for #{new_resource.client_match} on #{new_resource.svm} at rule-index #{@new_resource.rule_index}") do
      modify_existing_rule(@new_resource)
    end
  else
    Chef::Log.info "Rule for #{new_resource.client_match} on #{new_resource.svm} doesn't exist - nothing to do"
  end
end

# Remove an existing Export Policy Rule. 
# WARNING: This will remove access for any host currently mounting
#          NFS storage using this rule index
action :delete do
  # Validate required parameters
  raise ArgumentError, "Attribute SVM is required to create export rules" unless new_resource.svm
  raise ArgumentError, "Attribute PolicyName is required to delete export rules" unless new_resource.policy_name
  raise ArgumentError, "Attribute RuleIndex or ClientMatch is required to delete export rules" unless new_resource.rule_index || new_resource.client_match

  # NetApp API requires a RuleIndex.  Set the ClientCheck variable to matche RuleIndex if provided
  # or look-up the client_match rule in the export-policy and return a valid RuleIndex.  If no
  # RuleIndex found then log that the resource doesn't exist.  Otherwise, process the deletion.
  client_check = ""
  client_check = new_resource.rule_index
  client_check = check_client_match_rule(@new_resource) unless new_resource.rule_index

  if client_check
    @new_resource.rule_index = client_check
    converge_by("Delete rule for #{new_resource.client_match} on #{new_resource.svm} at rule-index #{@new_resource.rule_index}") do
      delete_existing_rule(@new_resource)
    end
  else
    Chef::Log.info "Rule for #{new_resource.client_match} on #{new_resource.svm} doesn't exist - nothing to do"
  end
end


# Custom Method directives for management of resources
#

def check_client_match_rule(resource)
  raise ArgumentError, "Attribute SVM is required to create export rules" unless new_resource.svm
  raise ArgumentError, "Attribute RuleIndex or ClientMatch is required to lookup export rules" unless resource.rule_index || resource.client_match
  # Return Boolean if Client-Match exists as a rule in the Export Policy
  # 
  netapp_get_api = netapp_hash

  netapp_get_api[:api_name] = "export-rule-get-iter"
  netapp_get_api[:resource] = "nfs"
  netapp_get_api[:action] = "check_client_match"
  netapp_get_api[:svm] = resource.svm
  netapp_get_api[:api_attribute]["desired-attributes"]["export-rule-info"]["rule-index"]
  netapp_get_api[:api_attribute]["max-records"] = 1
  netapp_get_api[:api_attribute]["query"]["export-rule-info"]["policy-name"] = resource.policy_name
  netapp_get_api[:api_attribute]["query"]["export-rule-info"]["client-match"] = resource.client_match if resource.client_match
  netapp_get_api[:api_attribute]["query"]["export-rule-info"]["rule-index"] = resource.rule_index if resource.rule_index

  # Check the output to determine if the Client match exists as a rule
  output = return_output(netapp_get_api)
  if output.child_get_int("num-records") == 0 || output.nil?
    return false
  else  
    results = output.child_get("attributes-list").child_get("export-rule-info")
    unless results.child_get_string("rule-index").nil?
      return results.child_get_int("rule-index")
    else
      return false
    end
  end  
end


def create_new_rule(resource)

  # Create API Request.
  netapp_nfs_add_rule_api = netapp_hash

  netapp_nfs_add_rule_api[:api_name] = "export-rule-create"
  netapp_nfs_add_rule_api[:resource] = "nfs"
  netapp_nfs_add_rule_api[:action] = "add_rule"
  netapp_nfs_add_rule_api[:svm] = resource.svm

  # Required Attributes
  netapp_nfs_add_rule_api[:api_attribute]["policy-name"] = resource.policy_name 
  netapp_nfs_add_rule_api[:api_attribute]["client-match"] = resource.client_match
  netapp_nfs_add_rule_api[:api_attribute]["protocol"]["access-protocol"] = resource.access_protocol
  netapp_nfs_add_rule_api[:api_attribute]["ro-rule"]["security-flavor"] = resource.ro_rule 
  netapp_nfs_add_rule_api[:api_attribute]["rw-rule"]["security-flavor"] = resource.rw_rule 

  #Optional Attributes
  netapp_nfs_add_rule_api[:api_attribute]["rule-index"] = resource.rule_index unless resource.rule_index.nil? 
  netapp_nfs_add_rule_api[:api_attribute]["anonymous-user-id"] = resource.anonymous_user unless resource.anonymous_user.nil?
  netapp_nfs_add_rule_api[:api_attribute]["export-chown-mode"] = resource.chown_mode unless resource.chown_mode.nil?
  netapp_nfs_add_rule_api[:api_attribute]["export-ntfs-unix-security-ops"] = resource.ntfs_unix_security_ops unless resource.ntfs_unix_security_ops.nil?
  netapp_nfs_add_rule_api[:api_attribute]["is-allow-dev-is-enabled"] = resource.allow_dev unless resource.allow_dev.nil?
  netapp_nfs_add_rule_api[:api_attribute]["is-allow-set-uid-enabled"] = resource.allow_set_uid unless resource.allow_set_uid.nil?
  netapp_nfs_add_rule_api[:api_attribute]["super-user-security"]["security-flavor"] = resource.root_rule unless resource.root_rule.nil?
  # Invoke NetApp API.
  invoke(netapp_nfs_add_rule_api)
  resource.updated_by_last_action(true)
end  

def modify_existing_rule(resource)

  # Create API Request.
  netapp_nfs_mod_rule_api = netapp_hash

  netapp_nfs_mod_rule_api[:api_name] = "export-rule-modify"
  netapp_nfs_mod_rule_api[:resource] = "nfs"
  netapp_nfs_mod_rule_api[:action] = "modify_rule"
  netapp_nfs_mod_rule_api[:svm] = resource.svm

  # Required Attributes
  netapp_nfs_mod_rule_api[:api_attribute]["policy-name"] = resource.policy_name 
  netapp_nfs_mod_rule_api[:api_attribute]["rule-index"] = resource.rule_index

  #Optional Attributes
  netapp_nfs_mod_rule_api[:api_attribute]["client-match"] = resource.client_match unless resource.client_match.nil? 
  netapp_nfs_mod_rule_api[:api_attribute]["protocol"]["access-protocol"] = resource.access_protocol unless resource.access_protocol.nil? 
  netapp_nfs_mod_rule_api[:api_attribute]["ro-rule"]["security-flavor"] = resource.ro_rule  unless resource.ro_rule.nil? 
  netapp_nfs_mod_rule_api[:api_attribute]["rw-rule"]["security-flavor"] = resource.rw_rule  unless resource.rw_rule.nil? 
  netapp_nfs_mod_rule_api[:api_attribute]["anonymous-user-id"] = resource.anonymous_user unless resource.anonymous_user.nil?
  netapp_nfs_mod_rule_api[:api_attribute]["export-chown-mode"] = resource.chown_mode unless resource.chown_mode.nil?
  netapp_nfs_mod_rule_api[:api_attribute]["export-ntfs-unix-security-ops"] = resource.ntfs_unix_security_ops unless resource.ntfs_unix_security_ops.nil?
  netapp_nfs_mod_rule_api[:api_attribute]["is-allow-dev-is-enabled"] = resource.allow_dev unless resource.allow_dev.nil?
  netapp_nfs_mod_rule_api[:api_attribute]["is-allow-set-uid-enabled"] = resource.allow_set_uid unless resource.allow_set_uid.nil?
  netapp_nfs_mod_rule_api[:api_attribute]["super-user-security"]["security-flavor"] = resource.root_rule unless resource.root_rule.nil?
  # Invoke NetApp API.
  invoke(netapp_nfs_mod_rule_api)
  resource.updated_by_last_action(true)
end  

def delete_existing_rule(resource)

  # Create API Request.
  netapp_nfs_del_rule_api = netapp_hash

  netapp_nfs_del_rule_api[:api_name] = "export-rule-destroy"
  netapp_nfs_del_rule_api[:resource] = "nfs"
  netapp_nfs_del_rule_api[:action] = "delete_rule"
  netapp_nfs_del_rule_api[:svm] = resource.svm

  # Required Attributes
  netapp_nfs_del_rule_api[:api_attribute]["policy-name"] = resource.policy_name 
  netapp_nfs_del_rule_api[:api_attribute]["rule-index"] = resource.rule_index
  # Invoke NetApp API.
  invoke(netapp_nfs_del_rule_api)
  resource.updated_by_last_action(true)
end  

