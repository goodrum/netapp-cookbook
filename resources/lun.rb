#
# Author:: Jeremy Goodrum (<jeremy@exospheredata.com>)
# Cookbook Name:: netapp
# Resource:: lun
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

actions :create, :delete
default_action :create

attribute :name, :kind_of => String, :required => true, :name_attribute => true #lun
attribute :volume, :kind_of => String, :required => true
attribute :svm, :kind_of => String, :required => true
attribute :size_mb, :kind_of => Integer, :required => true
attribute :ostype, :kind_of => String, :required => true

#optional parameters
attribute :qtree, :kind_of => String # Requires a valid, existing Qtree in the selected volume
attribute :comment, :kind_of => String
attribute :qos_policy_group, :kind_of => String # Requires a valid, existing QOS Policy Name
attribute :prefix_size, :kind_of => String # Used to configure the offset of the partition start
attribute :space_reservation_enabled, :kind_of => [TrueClass, FalseClass]
attribute :force, :kind_of => [TrueClass, FalseClass]
