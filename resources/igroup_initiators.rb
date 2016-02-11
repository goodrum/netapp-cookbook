# Author:: Jeremy Goodrum (<jeremy@exospheredata.com>)
# Cookbook Name:: netapp
# Resource:: igroup_initiators
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

actions :add, :remove
default_action :add

attribute :name, :kind_of => String, :required => true, :name_attribute => true #igroup
attribute :initiator, :kind_of => String, :required => true
attribute :svm, :kind_of => String, :required => true

# Optional
attribute :force, :kind_of => [TrueClass, FalseClass]