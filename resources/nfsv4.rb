#
# Author:: Jeremy Goodrum (<chef@exospheredata.com>)
# Cookbook Name:: netapp
# Resource:: nfsv4
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

actions :enable, :disable, :add_rule, :modify_rule, :delete_rule
default_action :enable

attribute :svm, :kind_of => String, :required => true, :name_attribute => true

attribute :anonymous_user, :kind_of => String
attribute :client_match, :required => true, :kind_of => String
attribute :chown_mode, :kind_of => String, :equal_to => ["restricted", "unrestricted"], :default => "restricted"
attribute :ntfs_unix_security_ops, :kind_of => String, :equal_to => ["ignore", "fail"], :default => "fail"
attribute :allow_dev, :kind_of => [TrueClass, FalseClass]
attribute :allow_set_uid, :kind_of => [TrueClass, FalseClass]
attribute :policy_name, :required => true, :kind_of => String
attribute :rule_index, :kind_of => Integer
attribute :access_protocol, :required => true, :kind_of => String, :equal_to => ["any", "nfs2","nfs3","nfs","cifs","nfs4","flexcache"]
attribute :ro_rule, :required => true, :kind_of => String, :equal_to => ["any", "none","never","krb5","krb5i","ntlm","sys"]
attribute :rw_rule, :required => true, :kind_of => String, :equal_to => ["any", "none","never","krb5","krb5i","ntlm","sys"]
attribute :root_rule, :kind_of => String, :equal_to => ["any", "none","never","krb5","krb5i","ntlm","sys"]