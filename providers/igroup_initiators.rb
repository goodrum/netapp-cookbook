# Cookbook Name:: netapp
# Provider:: igroup_initiators
#
# Copyright:: 2016, Exosphere Data, Inc <legal@exospheredata.com>
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


action :add do

  #validations.
  raise ArgumentError, "Attribute name is required to add an igroup initiator" unless new_resource.name
  raise ArgumentError, "Attribute svm is required to add an igroup initiator" unless new_resource.svm
  raise ArgumentError, "Attribute initiator is required to add an igroup initiator" unless new_resource.initiator

  # Create API Request.
  netapp_igroup_api = netapp_hash

  netapp_igroup_api[:api_name] = "igroup-add"
  netapp_igroup_api[:resource] = "igroup"
  netapp_igroup_api[:action] = "add"
  netapp_igroup_api[:svm] = new_resource.svm
  netapp_igroup_api[:api_attribute]["initiator-group-name"] = new_resource.name
  netapp_igroup_api[:api_attribute]["initiator"] = new_resource.initiator

  # Invoke NetApp API.
  resource_update = invoke(netapp_igroup_api)
  new_resource.updated_by_last_action(true) if resource_update
end

action :remove do
  #validations.
  raise ArgumentError, "Attribute name is required to remove an igroup initiator" unless new_resource.name
  raise ArgumentError, "Attribute svm is required to remove an igroup initiator" unless new_resource.svm
  raise ArgumentError, "Attribute initiator is required to remove an igroup initiator" unless new_resource.initiator

  # Create API Request.
  netapp_igroup_api = netapp_hash

  netapp_igroup_api[:api_name] = "igroup-destroy"
  netapp_igroup_api[:resource] = "igroup"
  netapp_igroup_api[:action] = "delete"
  netapp_igroup_api[:svm] = new_resource.svm
  netapp_igroup_api[:api_attribute]["initiator-group-name"] = new_resource.name
  netapp_igroup_api[:api_attribute]["initiator"] = new_resource.initiator
  netapp_igroup_api[:api_attribute]["force"] = new_resource.force unless new_resource.force.nil?

  # Invoke NetApp API.
  resource_update = invoke(netapp_igroup_api)
  new_resource.updated_by_last_action(true) if resource_update
end
