# Cookbook Name:: netapp
# Provider:: lun
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


action :create do

  #validations.
  raise ArgumentError, "Attribute name is required for lun mapping" unless new_resource.name
  raise ArgumentError, "Attribute svm is required for lun mapping" unless new_resource.svm
  raise ArgumentError, "Attribute volume is required for lun mapping" unless new_resource.volume
  raise ArgumentError, "Attribute igroup is required for lun mapping" unless new_resource.igroup

  # Create API Request.
  netapp_lun_api = netapp_hash

  netapp_lun_api[:api_name] = "lun-map"
  netapp_lun_api[:resource] = "lun"
  netapp_lun_api[:action] = "create"
  netapp_lun_api[:svm] = new_resource.svm
  
  # Configure the expected Lun Path attribute
  new_lun_path = "/vol/#{new_resource.volume}"
  new_lun_path+="/#{new_resource.qtree}" unless new_resource.qtree.nil?
  netapp_lun_api[:api_attribute]["path"] = "#{new_lun_path}/#{new_resource.name}"

  

  netapp_lun_api[:api_attribute]["initiator-group"] = new_resource.igroup

  # Invoke NetApp API.
  resource_update = invoke(netapp_lun_api)
  new_resource.updated_by_last_action(true) if resource_update
end

action :delete do
  #validations.
  raise ArgumentError, "Attribute name is required for lun mapping" unless new_resource.name
  raise ArgumentError, "Attribute svm is required for lun mapping" unless new_resource.svm
  raise ArgumentError, "Attribute volume is required for lun mapping" unless new_resource.volume
  raise ArgumentError, "Attribute igroup is required for lun mapping" unless new_resource.igroup

  # Create API Request.
  netapp_lun_api = netapp_hash

  netapp_lun_api[:api_name] = "lun-unmap"
  netapp_lun_api[:resource] = "lun"
  netapp_lun_api[:action] = "delete"
  netapp_lun_api[:svm] = new_resource.svm

  # Configure the expected Lun Path attribute
  new_lun_path = "/vol/#{new_resource.volume}"
  new_lun_path+="/#{new_resource.qtree}" unless new_resource.qtree.nil?
  netapp_lun_api[:api_attribute]["path"] = "#{new_lun_path}/#{new_resource.name}"
  netapp_lun_api[:api_attribute]["initiator-group"] = new_resource.igroup

  netapp_lun_api[:api_attribute]["force"] = new_resource.force unless new_resource.force.nil?

  # Invoke NetApp API.
  resource_update = invoke(netapp_lun_api)
  new_resource.updated_by_last_action(true) if resource_update
end
