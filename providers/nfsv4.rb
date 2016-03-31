# Cookbook Name:: netapp
# Provider:: nfsv4
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

action :enable do

  # Create API Request.
  netapp_nfs_enable_v4_api = netapp_hash

  netapp_nfs_enable_v4_api[:api_name] = "nfs-service-modify"
  netapp_nfs_enable_v4_api[:resource] = "nfs"
  netapp_nfs_enable_v4_api[:action] = "enable_v4"
  netapp_nfs_enable_v4_api[:svm] = new_resource.name
  netapp_nfs_enable_v4_api[:api_attribute]["is-nfsv40-enabled"] = true
  netapp_nfs_enable_v4_api[:api_attribute]["is-nfsv41-enabled"] = true

  #Create and enable NFS service on the vserver
  invoke(netapp_nfs_enable_v4_api)
  new_resource.updated_by_last_action(true)
end

action :disable do
  # Create API Request.
  netapp_nfs_disable_v4_api = netapp_hash

  netapp_nfs_disable_v4_api[:api_name] = "nfs-service-modify"
  netapp_nfs_disable_v4_api[:resource] = "nfs"
  netapp_nfs_disable_v4_api[:action] = "enable_v4"
  netapp_nfs_disable_v4_api[:svm] = new_resource.name
  netapp_nfs_disable_v4_api[:api_attribute]["is-nfsv40-enabled"] = false
  netapp_nfs_disable_v4_api[:api_attribute]["is-nfsv41-enabled"] = false

  #Create and enable NFS service on the vserver
  invoke(netapp_nfs_disable_v4_api)
  new_resource.updated_by_last_action(true)
end
action :add_rule do

  # validations.
  raise ArgumentError, "Attribute PolicyName is required to append export rules" unless new_resource.policy_name
  raise ArgumentError, "Attribute AccessProtocol is required to append export rules" unless new_resource.access_protocol
  raise ArgumentError, "Attribute Read-Only Rule is required to append export rules" unless new_resource.ro_rule
  raise ArgumentError, "Attribute Read-Write Rule is required to append export rules" unless new_resource.rw_rule

  # Create API Request.
  netapp_nfs_add_rule_api = netapp_hash

  netapp_nfs_add_rule_api[:api_name] = "export-rule-create"
  netapp_nfs_add_rule_api[:resource] = "nfs"
  netapp_nfs_add_rule_api[:action] = "add_rule"
  netapp_nfs_add_rule_api[:svm] = new_resource.name

  # Required Attributes
  netapp_nfs_add_rule_api[:api_attribute]["policy-name"] = new_resource.policy_name 
  netapp_nfs_add_rule_api[:api_attribute]["client-match"] = new_resource.client_match
  netapp_nfs_add_rule_api[:api_attribute]["protocol"]["access-protocol"] = new_resource.access_protocol
  netapp_nfs_add_rule_api[:api_attribute]["ro-rule"]["security-flavor"] = new_resource.ro_rule 
  netapp_nfs_add_rule_api[:api_attribute]["rw-rule"]["security-flavor"] = new_resource.rw_rule 

  #Optional Attributes
  netapp_nfs_add_rule_api[:api_attribute]["rule-index"] = new_resource.rule_index unless new_resource.rule_index.nil? 
  netapp_nfs_add_rule_api[:api_attribute]["anonymous-user-id"] = new_resource.anonymous_user unless new_resource.anonymous_user.nil?
  netapp_nfs_add_rule_api[:api_attribute]["export-chown-mode"] = new_resource.chown_mode unless new_resource.chown_mode.nil?
  netapp_nfs_add_rule_api[:api_attribute]["export-ntfs-unix-security-ops"] = new_resource.ntfs_unix_security_ops unless new_resource.ntfs_unix_security_ops.nil?
  netapp_nfs_add_rule_api[:api_attribute]["is-allow-dev-is-enabled"] = new_resource.allow_dev unless new_resource.allow_dev.nil?
  netapp_nfs_add_rule_api[:api_attribute]["is-allow-set-uid-enabled"] = new_resource.allow_set_uid unless new_resource.allow_set_uid.nil?
  netapp_nfs_add_rule_api[:api_attribute]["super-user-security"]["security-flavor"] = new_resource.root_rule unless new_resource.root_rule.nil?
  # Invoke NetApp API.
  invoke(netapp_nfs_add_rule_api)
  new_resource.updated_by_last_action(true)
end

action :modify_rule do

  # validations.
  raise ArgumentError, "Attribute PolicyName is required to modify export rules" unless new_resource.policy_name
  raise ArgumentError, "Attribute RuleInxe is required to modify export rules" unless new_resource.rule_index
  raise ArgumentError, "Attribute Read-Only Rule is required to append export rules" unless new_resource.ro_rule
  raise ArgumentError, "Attribute Read-Write Rule is required to append export rules" unless new_resource.rw_rule

  # Create API Request.
  netapp_nfs_add_rule_api = netapp_hash

  netapp_nfs_add_rule_api[:api_name] = "export-rule-modify"
  netapp_nfs_add_rule_api[:resource] = "nfs"
  netapp_nfs_add_rule_api[:action] = "modify_rule"
  netapp_nfs_add_rule_api[:svm] = new_resource.name

  # Required Attributes
  netapp_nfs_add_rule_api[:api_attribute]["policy-name"] = new_resource.policy_name 
  netapp_nfs_add_rule_api[:api_attribute]["rule-index"] = new_resource.rule_index

  #Optional Attributes
  netapp_nfs_add_rule_api[:api_attribute]["client-match"] = new_resource.client_match unless new_resource.client_match.nil? 
  netapp_nfs_add_rule_api[:api_attribute]["protocol"]["access-protocol"] = new_resource.access_protocol unless new_resource.access_protocol.nil? 
  netapp_nfs_add_rule_api[:api_attribute]["ro-rule"]["security-flavor"] = new_resource.ro_rule  unless new_resource.ro_rule.nil? 
  netapp_nfs_add_rule_api[:api_attribute]["rw-rule"]["security-flavor"] = new_resource.rw_rule  unless new_resource.rw_rule.nil? 
  netapp_nfs_add_rule_api[:api_attribute]["anonymous-user-id"] = new_resource.anonymous_user unless new_resource.anonymous_user.nil?
  netapp_nfs_add_rule_api[:api_attribute]["export-chown-mode"] = new_resource.chown_mode unless new_resource.chown_mode.nil?
  netapp_nfs_add_rule_api[:api_attribute]["export-ntfs-unix-security-ops"] = new_resource.ntfs_unix_security_ops unless new_resource.ntfs_unix_security_ops.nil?
  netapp_nfs_add_rule_api[:api_attribute]["is-allow-dev-is-enabled"] = new_resource.allow_dev unless new_resource.allow_dev.nil?
  netapp_nfs_add_rule_api[:api_attribute]["is-allow-set-uid-enabled"] = new_resource.allow_set_uid unless new_resource.allow_set_uid.nil?
  netapp_nfs_add_rule_api[:api_attribute]["super-user-security"]["security-flavor"] = new_resource.root_rule unless new_resource.root_rule.nil?
  # Invoke NetApp API.
  invoke(netapp_nfs_add_rule_api)
  new_resource.updated_by_last_action(true)
end

# Remove an existing Export Policy Rule. 
# WARNING: This will remove access for any host currently mounting
#          NFS storage using this rule index
action :delete_rule do

  # validations.
  raise ArgumentError, "Attribute PolicyName is required to delete export rules" unless new_resource.policy_name
  raise ArgumentError, "Attribute RuleInxe is required to modify export rules" unless new_resource.rule_index

  # Create API Request.
  netapp_nfs_add_rule_api = netapp_hash

  netapp_nfs_add_rule_api[:api_name] = "export-rule-destroy"
  netapp_nfs_add_rule_api[:resource] = "nfs"
  netapp_nfs_add_rule_api[:action] = "delete_rule"
  netapp_nfs_add_rule_api[:svm] = new_resource.name

  # Required Attributes
  netapp_nfs_add_rule_api[:api_attribute]["policy-name"] = new_resource.policy_name 
  netapp_nfs_add_rule_api[:api_attribute]["rule-index"] = new_resource.rule_index
  # Invoke NetApp API.
  invoke(netapp_nfs_add_rule_api)
  new_resource.updated_by_last_action(true)
end