# Cookbook Name:: netapp
# Recipe:: lun


netapp_lun 'demo.lun' do
  svm "demo-svm"
  volume "root_vs"
  size_mb 100
  ostype "windows_2008"

  action :create

end


netapp_lun 'del_demo.lun' do
  svm "demo-svm"
  volume "root_vs"
  force true

  action :delete
end
