NetApp Cookbook
===============

The NetApp cookbook manages Clustered Data ONTAP clusters using the NetApp Manageability SDK. Both cluster-wide and Storage Virtual Machine (SVM, formerly known as Vservers) specific operations are supported.

The NetApp cookbook may also be used to manage the `netapp_role`, `netapp_volume`, and `netapp_qtree` resources on Cloud ONTAP on Amazon Web Services.

Requirements
------------
#### NetApp Manageability SDK Library v5.0

You may download it from [NetApp](http://mysupport.netapp.com/NOW/cgi-bin/software?product=NetApp+Manageability+SDK&platform=All+Platforms) after you have created an account on [NetApp NOW](https://support.netapp.com/eservice/public/now.do)

- Save the NetApp SDK to this NetApp cookbook in the "libraries" dir.

- Update the NaServer.rb to specify the path of NaElement. Replace the line:
` require NaElement
`
With -
` require File.dirname(__FILE__) + "/NaElement"
`

NetApp connection
-----------------
The ZAPI connection is made over HTTP or HTTPS, with a user account that exists on the NetApp storage cluster. If you specify an account that only has SVM administration privileges (rather than cluster administration privileges), some features of the NetApp cookbook will not work. The connection settings are managed by attributes in the cookbook but are also exposed in Common attributes for the NetApp resources.

    ['netapp']['url'] = 'https://root:secret@pfiler01.example.com/svm01'

or

    ['netapp']['https'] boolean, default is 'true'.
    ['netapp']['user'] string
    ['netapp']['password'] string
    ['netapp']['fqdn'] string
    ['netapp']['vserver'] string
    ['netapp']['asup'] boolean, default is 'true'.
or _Optional_ - **Encrypted Data Bag**

    ['netapp']['fqdn'] string
    ['netapp']['passwords']['secret_path'] string, Encrypted Data Bag key
    ['netapp']['secret_credentials'] string, Data bag item name. **Data Bag name must be _netapp_**
    ['netapp']['https'] boolean, default is 'true'.
    ['netapp']['vserver'] string
    ['netapp']['asup'] boolean, default is 'true'.

The ASUP option, if set to 'true', will cause a log message to be sent to the storage cluster. This log message will be included in ASUP bundles that are sent back to NetApp, if configured to do so on the system. If ASUP is not enabled on the system or on the attribute listed above, no log message will be sent to NetApp.

Storage Virtual Machine authentication
-----------------
 Support for direct Storage Virtual Machine (SVM) connections can be added by replacing the FQDN attribute with the SVM Management Interface (LIF) address.  Otherwise, the node attribute _vserver_ is used to pass-thru calls from the Cluster Management interface.

**_vserver_ is not a required attribute when connecting directly to the Storage Virtual Machine**

NetApp Resources
================

Common Attributes
-----------------
In addition to those provided by Chef itself (`ignore_failure`, `retries`, `retry_delay`, etc.), the connection attribute(s) are exposed all NetApp Resources even though they are typically set by attributes.

Common Actions
--------------
The `:nothing` action is provided by Chef for all Resources for use with notifications and subscriptions.

netapp_user
-----------
Cluster management of user creation, modification and deletion.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the user

### Attributes ###
This resource has the following attributes:

* `name` User name. Required
* `password` Required for non-snmp users
* `application` Name of the application. Possible values: 'console', 'http', 'ontapi', 'rsh', 'snmp', 'sp', 'ssh', 'telnet'
* `comment`
* `role` Array of roles
* `snmpv3-login-info` SNMPv3 user login information for 'usm' authentication method
* `vserver` Name of vserver
* `authentication` Authentication method for the application. Possible values: 'community', 'password', 'publickey', 'domain', 'nsswitch' and 'usm'

### Example ###

````ruby
netapp_user "clogeny" do
  vserver "my-vserver"
  role "admin"
  application "ontapi"
  authentication "password"
  password "my-password1"
  action :create
end
````

````ruby
netapp_user "clogeny" do
  vserver "my-vserver"
  application "ontapi"
  authentication "password"
  action :delete
end
````

netapp_group
------------
Cluster management of group creation, modification and deletion.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the group

### Attributes ###
This resource has the following attributes:

* `name` string, name attribute. Required
* `comment` string.
* `roles` Array of roles for this group.

### Example ###

````ruby
netapp_group 'admins' do
  comments 'keep the trains on time'
  roles ['security']
  action :create
end
````

````ruby
netapp_group 'read-only' do
  action :delete
end
````

netapp_role
-----------
Cluster management of role creation, modification and deletion.

The `netapp_role` resource may be used to manage roles on Cloud ONTAP instances as well.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the role

### Attributes ###
This resource has the following attributes:

* `name` Name attribute. Required
* `svm` Name of vserver. Required
* `command_directory` The command or command directory to which the role has an access. Required
* `access_level` Access level for the role. Possible values: 'none', 'readonly', 'all'. The default value is 'all'.
* `return_record` If set to true, returns the security login role on successful creation. Default: false
* `role_query` Example: The command is 'volume show' and the query is '-volume vol1'

### Example ###

````ruby
netapp_role 'security' do
  svm 'my-vserver'
  command_directory 'volume'
  action :create
end
````

````ruby
netapp_role 'superusers' do
  svm 'my-vserver'
  command_directory 'DEFAULT'
  action :delete
end
````

netapp_feature
--------------
Cluster management of NetApp features by license. See API docs for "license-v2".

### Actions ###
This resource has the following action:

* `:enable` Default. Ensures the NetApp provides this feature.

### Attributes ###
This resource has the following attributes:

* `codes` Array, license code when adding a package. 24 or 48 uppercase alpha only characters.

### Example ###

````ruby
netapp_feature 'iscsi' do
  codes ['ABCDEFGHIJKLMNOPQRSTUVWX']
  action :enable
end
````

netapp_svm
----------
Cluster-level management of a data Storage Virtual Machines (SVMs). SVM-level management is done through other resources. After the cluster setup, a cluster administrator must create data SVMs and add volumes to these SVMs to facilitate data access from the cluster. A cluster must have at least one data SVM to serve data to its clients.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the svm

### Attributes ###
This resource has the following attributes:

* `name` name attribute. Required. SVM names can contain a period (.), a hyphen (-), or an underscore (_), but must not start with a hyphen, period, or number. The maximum number of characters allowed in SVM names is 47.
* `nsswitch` Required.
* `volume` Required
* `aggregate` Required. Aggregate on which you want to create the root volume for the SVM. The default aggregate name is used if you do not specify one.
* `security` Required. Determines the type of permissions that can be used to control data access to a volume. Default is `unix`.
* `comment`
* `is_repository_vserver`
* `language` If you do not specify the language, the default language `C.UTF-8` or `POSIX.UTF-8` is used.???
* `nmswitch`
* `quota_policy`
* `return_record`
* `snapshot_policy`

### Example ###

````ruby
netapp_svm "example-svm" do
  security "unix"
  aggregate "aggr1"
  volume "vol1"
  nsswitch ["nis"]
  action :create
end
````

netapp_volume
-------------
SVM-management of volume creation, modification and deletion including auto-increment, snapshot schedules and volume options.

The `netapp_volume` resource provisions additional volumes on Cloud ONTAP instances. It Creates the volume on an existing aggregate that has sufficient free space.

### Actions ###
This resource has the following actions:

* `:create` Default.
* `:delete` Removes the volume

### Attributes ###
This resource has the following attributes:

* `name` string, name attribute. Volume name. Required.
* `svm` string. Name of managed SVM. Required
* `aggregate` string. Required
* `size` string (1-9kmgt). Required

### Example ###

````ruby
netapp_volume '/foo' do
  svm 'vs1.example.com'
  aggregate 'aggr1'
  size '5t'
  action :create
end
````

````ruby
netapp_volume 'bar' do
  action :delete
end
````

netapp_lif
----------
SVM-management of logical interface (LIF) creation, modification and deletion.

### Actions ###
This resource has the following actions:

* `:create` Default. Ensures the lif is in this state.
* `:delete` Removes the lif

### Attributes ###
This resource has the following attributes:

* `name` name attribute. LIF name. Required
* `svm` Name of managed SVM. Required
* `address`
* `administrative_status` valid values "up", "down", "unknown"
* `comment`
* `data_protocols`
* `dns_domain_name`
* `failover_group`
* `failover_policy` valid values "nextavail", "priority", "disabled"
* `firewall_policy`
* `home_node`
* `home_port`
* `is_auto_revert`
* `is_ipv4_link_local`
* `listen_for_dns_query`
* `netmask`
* `netmask_length`
* `return_record`
* `role` valid values "undef", "cluster", "data", "node_mgmt", "intercluster", "cluster_mgmt"
* `routing_group_name`
* `use_failover_group` valid values "system_defined", "disabled", "enabled"
*

### Example ###

````ruby
netapp_lif 'private' do
  svm 'vs1.example.com'
  action :create
end
````

````ruby
netapp_lif 'public' do
  action :delete
end
````

netapp_iscsi
----------
SVM-management of iSCSI target creation, modification and deletion.

### Actions ###
This resource has the following actions:

* `:create` Default. Creates iSCSI service.
* `:delete` Removes the target

### Attributes ###
This resource has the following attributes:

* `svm` Name of managed SVM. Required
* `alias`
* `node`
* `start` True or False. True by default.

### Example ###

````ruby
netapp_iscsi 'foo' do
  svm 'vs1.example.com'
  action :create
end
````

````ruby
netapp_iscsi 'bar' do
  action :delete
end
````

netapp_nfs
----------
SVM-management of NFS export rule creation, modification and deletion including NFS export security. Rule changes are persistent.

You do not need to enter any information to configure NFS on the SVM. The NFS configuration is created when you specify the protocol value as `nfs`.

### Actions ###
This resource has the following actions:

* `:create` Default. Ensures the NFS export is in this state.
* `:delete` Removes the NFS export

### Attributes ###
This resource has the following attributes:
* `pathname` string, name attribute. Required
* `svm` string. Name of managed SVM. Required
* `security_rules` hash. Access block information for lists of hosts.

### Example ###

````ruby
netapp_nfs '/vol/vol0' do
  svm 'vs1.example.com'
  action :create
end
````

````ruby
netapp_export '/vol/vol1' do
  svm 'vs1.example.com'
  action :delete
end
````

netapp_nfsv4
----------
SVM-management of NFSv4 services on the selected Storage Virtual Machine.

You do not need to enter any information to configure NFS on the SVM. The NFS configuration is created when you specify the protocol value as `nfs`.

### Actions ###
This resource has the following actions:

* `:enable` Default. Ensures that the Storage Virtual Machine is running NFSv4.0 and NFSv4.1 services.
* `:disable` Disables and Stops NFSv4.0 and NFSv4.1 services on the Storage Virtual Machine

### Attributes ###
This resource has the following attributes:
* `svm` string, name attribute. Name of managed SVM. Required

### Example ###

````ruby
netapp_nfsv4 'vs1.example.com' do
  action :enable
end
````

````ruby
netapp_nfsv4 'vs1.example.com' do
  action :disable
end
````

netapp_export_policy
----------
Management of Export Policies for Storage Virtual Machines

### Actions ###
This resource has the following actions:

* `:create` Default. Ensures that an Export Policy exists.
* `:delete` Removes the Export Policy

### Attributes ###
This resource has the following attributes:
* `policy_name` string, name attribute. Required
* `svm` string. Name of managed SVM. Required

### Example ###

````ruby
netapp_export_policy 'my_nfs_export' do
  svm 'vs1.example.com'
  action :create
end
````

````ruby
netapp_export_policy 'my_nfs_export' do
  svm 'vs1.example.com'
  action :delete
end
````

netapp_export_rule
----------
Management of Export Rules and Client Matches for Export Policies within a Storage Virtual Machine

### Actions ###
This resource has the following actions:

* `:create` Default. Ensures that an Export Rule exists in the Policy
* `:modify` Changes or updates an Export Rule in the Policy
* `:delete` Removes the Export Rule from the Policy

### Attributes ###
This resource has the following attributes:

######Required Attributes######

* `policy_name` string. **Required**
* `svm` string. Name of managed SVM. **Required**

######Required for :create, :modify, :delete######

* `client_match` string. **Required for :create, :modify, :delete** _(For Modify and Delete, can be substituted with RuleIndex)_

###### Required for :create ######

* `ro_rule` string. ReadOnly authentication model. **Required for :create** _(Valid options ["any", "none","never","krb5","krb5i","ntlm","sys"] )_
* `rw_rule` string. ReadWrite authentication model. **Required for :create** _(Valid options ["any", "none","never","krb5","krb5i","ntlm","sys"] )_
* `access_protocol` string. Network Access Protocol. **Required for :create** _(Valid options ["any", "nfs2","nfs3","nfs","cifs","nfs4","flexcache"] )_

###### Required for :modify, :delete ######

* `rule_index` string. **Required for :modify, :delete** _(For Modify and Delete, can be substituted with ClientMatch)_

###### Optional Attributes ######

* `anonymous_user` string. Unix user mapping for anonymous access.
* `chown_mode` string. Default _restricted_ _(Valid options ["restricted", "unrestricted"] )_
* `ntfs_unix_security_ops` string. Default fail _(Valid options ["ignore", "fail"] )_
* `allow_dev` boolean. 
* `allow_set_uid` boolean. 
* `root_rule` string. Root authentication model. _(Valid options ["any", "none","never","krb5","krb5i","ntlm","sys"] )_


### Example ###

````ruby
netapp_export_rule "Create rule for 10.0.0.0/24" do
  svm "vs1.example.com"
  policy_name "my_nfs_export"
  client_match "10.0.0.0/24"
  access_protocol "nfs"
  ro_rule "sys"
  rw_rule "sys"
  root_rule "sys"
    action :create
end
````

````ruby
netapp_export_rule "Modify rule for 10.0.0.0/24" do
  svm "vs1.example.com"
  policy_name "my_nfs_export"
  client_match "10.0.0.0/24"
  root_rule "none"
    action :modify
end
````

````ruby
netapp_export_rule "Delete rule for 10.0.0.0/24" do
  svm "vs1.example.com"
  policy_name "my_nfs_export"
  client_match "10.0.0.0/24"
    action :delete
end
````

netapp_qtree
------------
SVM-management of qtree creation, modification and deletion. Qtrees are a special subdirectory of the root of a volume that acts as a virtual subvolume with special attributes.

The `netapp_qtree` resource may be used to create logically defined file system on Cloud ONTAP instances.

### Actions ###
This resource has the following actions:

* `:create` Default. Ensures the QTree is in this state.
* `:delete` Removes the QTree

### Attributes ###
This resource has the following attributes:

* `name` name attribute. The path of the qtree, relative to the volume. Required
* `svm` Name of managed SVM. Required
* `volume` Name of the volume on which to create the qtree. Required.
* `export_policy` Export policy of the qtree. If this input is not specified, the qtree will inherit the export policy of the parent volume.
* `mode` The file permission bits of the qtree, similar to UNIX permission bits. If this argument is missing, the permissions of the volume is used.
* `oplocks` Opportunistic locks mode of the qtree. Possible values: "enabled", "disabled". Default value is the oplock mode of the volume.
* `security` Security style of the qtree. Possible values: "unix", "ntfs", or "mixed". Default value is the security style of the volume.
* `force` True or false

### Example ###

````ruby
netapp_qtree '/share' do
  svm 'vs1.example.com'
  volume '/foo'
  action :create
end
````

````ruby
netapp_role '/bar' do
  svm 'vs1.example.com'
  volume '/foo'
  action :delete
end
````

netapp_lun
------------
SVM-management of lun creation, modification and deletion. Luns are a special file type created in a volume that acts as a virtual SCSI device for SAN (ISCSI and FCP) connected hosts.

### Actions ###
This resource has the following actions:

* `:create` Default. Ensures the Lun is in this state.
* `:delete` Removes the Lun

### Attributes ###
This resource has the following attributes:

* `name` name attribute. The name of the Lun. **Required**
* `svm` Name of managed SVM. **Required**
* `volume` Name of the volume in which to create the Lun. **Required**.
* `qtree` Name of the selected volume qtree in which to create the Lun.
* `size_mb` Actual size of the Lun in Megabytes *(MB)*. **Required**
* `ostype` SAN host version to which the Lun will be connected.  **Required**
* `comment` Description text for the Lun. 
* `qos_policy_group` Existing QOS Policy to apply to the Lun. 
* `prefix_size` Manual offset for the Lun's starting partition. Advance user feature
* `space_reservation_enabled` True or False. If true then the Lun will consume 100% of the space on disk,
otherwise the size consumed on disk is directly related to the amount of data in the Lun.
* `force` True or false

### Example ###

````ruby
netapp_lun 'data.lun' do
  svm 'vs1.example.com'
  volume 'foo'
  size_mb 1024
  ostype 'windows_2008'
  action :create
end
````

````ruby
netapp_lun 'data.lun' do
  svm 'vs1.example.com'
  volume 'foo'
  action :delete
end
````

netapp_lun_map
------------
SVM-management of lun mapping and unmapping to initiator groups. Luns are a special file type created in a volume that acts as a virtual SCSI device for SAN (ISCSI and FCP) connected hosts.

### Actions ###
This resource has the following actions:

* `:create` Default. Ensures the Lun Mapping is in this state.
* `:delete` Removes the Lun Mapping

### Attributes ###
This resource has the following attributes:

* `name` name attribute. The name of the Lun. **Required**
* `igroup` existing initiator group to which the Lun should be mapped. **Required**
* `svm` Name of managed SVM. **Required**
* `volume` Name of the volume in which to create the Lun. **Required**.
* `qtree` Name of the selected volume qtree in which to create the Lun.
* `lun_id` Lun identification number. Default will choose the next lowest number starting with 0
* `force` True or false

### Example ###

````ruby
netapp_lun_map 'data.lun' do
  svm 'vs1.example.com'
  volume 'foo'
  igroup 'windows_host'
  action :create
end
````

````ruby
netapp_lun_map 'data.lun' do
  svm 'vs1.example.com'
  volume 'foo'
  igroup 'windows_host'
  action :delete
end
````

netapp_igroup
------------
SVM-management of initiator group (igroup) creation, modification and deletion. Igroups allow for the mapping of Host intiators to NetApp Luns for use with SAN protocols (ISCSI and FCP).

### Actions ###
This resource has the following actions:

* `:create` Default. Ensures the Igroup is in this state.
* `:delete` Removes the Igroup

### Attributes ###
This resource has the following attributes:

* `name` name attribute. The name of the Lun. **Required**
* `type` ["iscsi", "fcp", "mixed"] .**Required**
* `svm` Name of managed SVM. **Required**
* `ostype` SAN host version to which the Lun will be connected.  **Required**
* `bind_portset` Existing Igroup Portset name
* `force` True or false

### Example ###

````ruby
netapp_igroup 'windows_host' do
  svm 'vs1.example.com'
  type 'iscsi'
  ostype 'windows'
  action :create
end
````

````ruby
netapp_igroup 'windows_host' do
  svm 'vs1.example.com'
  action :delete
end
````

netapp_igroup_initiators
------------
SVM-management of initiators in an initiator group (igroup) addition and removal. Igroups allow for the mapping of Host intiators to NetApp Luns for use with SAN protocols (ISCSI and FCP).

### Actions ###
This resource has the following actions:

* `:add` Default. Ensures the Initiator is associated with the Igroup
* `:remove` Removes the Initiator from the Igroup

### Attributes ###
This resource has the following attributes:

* `name` name attribute. The name of the Lun. **Required**
* `initiator` Initiator address (IQN for ISCSI or WWPN for FCP) .**Required**
* `svm` Name of managed SVM. **Required**
* `force` True or false

### Example ###

````ruby
netapp_igroup_initiators 'windows_host' do
  svm 'vs1.example.com'
  initiator 'iqn.XXXXXXXXXX'
  action :create
end
````

````ruby
netapp_igroup_initiators 'windows_host' do
  svm 'vs1.example.com'
  initiator 'iqn.XXXXXXXXXX'
  force true
  action :delete
end
````


Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Authors:: Arjun Hariharan (Arjun.Hariharan@Clogeny.com)

```text
Copyright 2014 Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
