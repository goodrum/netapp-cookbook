# Cookbook Name:: netapp
# Recipe:: lun


netapp_lun_map 'demo.lun' do
  svm "demo-svm"
  volume "root_vs"
  igroup "demo_igroup"
  
  action :create

end


netapp_lun_map 'del_demo.lun' do
  svm "demo-svm"
  volume "root_vs"
  igroup "demo_igroup"
  force true

  action :delete
end
