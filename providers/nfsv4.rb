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

# Support “no-operation” mode
def whyrun_supported?
  true
end

action :enable do

  if check_nfsv4_support(@new_resource)
    converge_by("#{@new_resource.name} is already configured for NFSv4 - nothing to do") do
      Chef::Log.info "#{@new_resource.name} is already configured for NFSv4 - nothing to do"
    end
  else
    converge_by("Enable NFSv4 support on Storage Virtual Machine") do
      enable_nfsv4(@new_resource)
    end
  end

end

action :disable do

  if check_nfsv4_support(@new_resource)
    converge_by("Disable NFSv4 support on Storage Virtual Machine") do
      disable_nfsv4(@new_resource)
    end
  else
    converge_by("#{@new_resource.name} does not support NFSv4 - nothing to do") do
      Chef::Log.info "#{@new_resource.name} does not support NFSv4 - nothing to do"
    end
  end
end


# Custom Method directives for management of resources
#

def check_nfsv4_support(resource)
  # Return Boolean if NFSv4.0 and NFSv4.1 are enabled on the Storage Virtual Machine
  # 
  netapp_get_api = netapp_hash

  netapp_get_api[:api_name] = "nfs-service-get"
  netapp_get_api[:resource] = "nfs"
  netapp_get_api[:action] = "check_services"
  netapp_get_api[:svm] = resource.name
  netapp_get_api[:api_attribute]["desired-attributes"]["nfs-info"]["is-nfsv40-enabled"]
  netapp_get_api[:api_attribute]["desired-attributes"]["nfs-info"]["is-nfsv41-enabled"]

  #Create and enable NFS service on the vserver
  output = return_output(netapp_get_api)
  
  results = output.child_get("attributes").child_get("nfs-info")
  if results.child_get_string("is-nfsv40-enabled") == "true" && results.child_get_string("is-nfsv41-enabled") == "true" 
    return true
  else
    return false
  end  
end

def enable_nfsv4(resource)

  # Create API Request.
  netapp_nfs_enable_v4_api = netapp_hash

  netapp_nfs_enable_v4_api[:api_name] = "nfs-service-modify"
  netapp_nfs_enable_v4_api[:resource] = "nfs"
  netapp_nfs_enable_v4_api[:action] = "enable_v4"
  netapp_nfs_enable_v4_api[:svm] = resource.name
  netapp_nfs_enable_v4_api[:api_attribute]["is-nfsv40-enabled"] = true
  netapp_nfs_enable_v4_api[:api_attribute]["is-nfsv41-enabled"] = true

  #Create and enable NFS service on the vserver
  invoke(netapp_nfs_enable_v4_api)
  resource.updated_by_last_action(true)
end  

def disable_nfsv4(resource)

  # Create API Request.
  netapp_nfs_disable_v4_api = netapp_hash

  netapp_nfs_disable_v4_api[:api_name] = "nfs-service-modify"
  netapp_nfs_disable_v4_api[:resource] = "nfs"
  netapp_nfs_disable_v4_api[:action] = "enable_v4"
  netapp_nfs_disable_v4_api[:svm] = resource.name
  netapp_nfs_disable_v4_api[:api_attribute]["is-nfsv40-enabled"] = false
  netapp_nfs_disable_v4_api[:api_attribute]["is-nfsv41-enabled"] = false

  #Create and enable NFS service on the vserver
  invoke(netapp_nfs_disable_v4_api)
  resource.updated_by_last_action(true)
end  


