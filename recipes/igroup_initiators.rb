# Cookbook Name:: netapp
# Recipe:: igroup


netapp_igroup_initiators 'igroup' do
  svm "demo-svm"
  initiator "iqn.1991-05.com.microsoft:win-skmc9bpn92u"

  action :add

end


netapp_igroup_initiators 'del_igroup' do
  svm "demo-svm"
  initiator "iqn.1991-05.com.microsoft:win-skmc9bpn92u"
  force true

  action :remove
end
