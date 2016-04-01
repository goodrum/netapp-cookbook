#
# Author:: Jeremy Goodrum (<chef@exospheredata.com>)
# Cookbook Name:: netapp
# Resource:: export_rule
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

actions :create, :modify, :delete
default_action :create

# Required Attributes
attribute :svm, :kind_of => String, :required => true
attribute :policy_name, :required => true, :kind_of => String

#Required for :create, :modify, :delete
attribute :client_match, :kind_of => String #For Modify and Delete, can be substituted with RuleIndex

#Required for :create
attribute :ro_rule, :kind_of => String, :equal_to => ["any", "none","never","krb5","krb5i","ntlm","sys"]
attribute :rw_rule, :kind_of => String, :equal_to => ["any", "none","never","krb5","krb5i","ntlm","sys"]
attribute :access_protocol, :kind_of => String, :equal_to => ["any", "nfs2","nfs3","nfs","cifs","nfs4","flexcache"]

#Required for :modify, :delete
attribute :rule_index, :kind_of => Integer #Can be substitued with ClientMatch

#Optional
attribute :anonymous_user, :kind_of => String
attribute :chown_mode, :kind_of => String, :equal_to => ["restricted", "unrestricted"], :default => "restricted"
attribute :ntfs_unix_security_ops, :kind_of => String, :equal_to => ["ignore", "fail"], :default => "fail"
attribute :allow_dev, :kind_of => [TrueClass, FalseClass]
attribute :allow_set_uid, :kind_of => [TrueClass, FalseClass]
attribute :root_rule, :kind_of => String, :equal_to => ["any", "none","never","krb5","krb5i","ntlm","sys"]