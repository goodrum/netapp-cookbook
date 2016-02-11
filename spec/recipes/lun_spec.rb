require_relative '../spec_helper'
require_relative '../helpers/matchers'

describe 'netapp::lun' do
  context 'without :step_into' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe)}

    it 'creates a new lun' do
      expect(chef_run).to create_netapp_lun('demo.lun').with(
          svm: "demo-svm",
          volume: "root_vs",
          size_mb: 100,
          ostype: "windows_2008"
        )
    end

    it 'deletes a lun' do
      expect(chef_run).to delete_netapp_lun('del_demo.lun').with(
          svm: "demo-svm",
          volume: "root_vs",
          force: true
        )
    end
  end
end