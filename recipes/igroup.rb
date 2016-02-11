# Cookbook Name:: netapp
# Recipe:: igroup


netapp_igroup 'igroup' do
  svm "demo-svm"
  type "iscsi"
  ostype "windows"

  action :create

end


netapp_igroup 'del_igroup' do
  svm "demo-svm"
  force true

  action :delete
end
