# Cookbook Name:: netapp
# Provider:: export_policy
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

action :create do

  # Create API Request.
  netapp_export_policy_api = netapp_hash

  netapp_export_policy_api[:api_name] = "export-policy-create"
  netapp_export_policy_api[:resource] = "nfs"
  netapp_export_policy_api[:action] = "create"
  netapp_export_policy_api[:svm] = new_resource.svm
  netapp_export_policy_api[:api_attribute]["policy-name"] = new_resource.name

  #Create and enable NFS service on the vserver
  invoke(netapp_export_policy_api)
  new_resource.updated_by_last_action(true)
end

action :disable do
  # Create API Request.
  netapp_export_policy_api = netapp_hash

  netapp_export_policy_api[:api_name] = "export-policy-destroy"
  netapp_export_policy_api[:resource] = "nfs"
  netapp_export_policy_api[:action] = "delete"
  netapp_export_policy_api[:svm] = new_resource.svm
  netapp_export_policy_api[:api_attribute]["policy-name"] = new_resource.name

  #Create and enable NFS service on the vserver
  invoke(netapp_export_policy_api)
  new_resource.updated_by_last_action(true)
end