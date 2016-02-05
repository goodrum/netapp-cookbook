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
  raise ArgumentError, "Attribute name is required for lun creation" unless new_resource.name
  raise ArgumentError, "Attribute svm is required for lun creation" unless new_resource.svm
  raise ArgumentError, "Attribute volume is required for lun creation" unless new_resource.volume
  raise ArgumentError, "Attribute size_mb is required for lun creation" unless new_resource.size_mb
  raise ArgumentError, "Attribute ostype is required for lun creation" unless new_resource.ostype

  # Create API Request.
  netapp_lun_api = netapp_hash

  netapp_lun_api[:api_name] = "lun-create-by-size"
  netapp_lun_api[:resource] = "lun"
  netapp_lun_api[:action] = "create"
  netapp_lun_api[:svm] = new_resource.svm
  
  # Configure the expected Lun Path attribute
  new_lun_path = "/vol/#{new_resource.volume}"
  new_lun_path+="/#{new_resource.qtree}" unless new_resource.qtree.nil?
  netapp_lun_api[:api_attribute]["path"] = "#{new_lun_path}/#{new_resource.name}"

  # Lun Size and Type

  # We need to convert the value sent into MegaBytes
  new_resource.size_mb = new_resource.size_mb * 1024 * 1024

  netapp_lun_api[:api_attribute]["size"] = new_resource.size_mb
  netapp_lun_api[:api_attribute]["ostype"] = new_resource.ostype

  # Optional Attributes
  netapp_lun_api[:api_attribute]["comment"] = new_resource.comment unless new_resource.comment.nil?
  netapp_lun_api[:api_attribute]["space-reservation-enabled"] = false || new_resource.space_reservation_enabled.nil?
  netapp_lun_api[:api_attribute]["qos-policy-group"] = new_resource.qos_policy_group unless new_resource.qos_policy_group.nil?
  netapp_lun_api[:api_attribute]["prefix-size"] = new_resource.prefix_size unless new_resource.prefix_size.nil?



  # Invoke NetApp API.
  resource_update = invoke(netapp_lun_api)
  new_resource.updated_by_last_action(true) if resource_update
end

action :delete do

  # Create API Request.
  netapp_lun_api = netapp_hash

  netapp_lun_api[:api_name] = "lun-delete"
  netapp_lun_api[:resource] = "lun"
  netapp_lun_api[:action] = "delete"
  netapp_lun_api[:svm] = new_resource.svm
  netapp_lun_api[:api_attribute]["lun"] = new_resource.name
  netapp_lun_api[:api_attribute]["force"] = new_resource.force unless new_resource.force.nil?

  # Invoke NetApp API.
  resource_update = invoke(netapp_lun_api)
  new_resource.updated_by_last_action(true) if resource_update
end
