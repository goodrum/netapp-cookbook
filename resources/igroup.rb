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

attribute :name, :kind_of => String, :required => true, :name_attribute => true #igroup
attribute :type, :kind_of => String, :equal_to => ["iscsi", "fcp", "mixed"]
attribute :svm, :kind_of => String, :required => true
attribute :ostype, :kind_of => String, :required => true

# Optional
attribute :bind_portset, :kind_of => String
attribute :force, :kind_of => [TrueClass, FalseClass]