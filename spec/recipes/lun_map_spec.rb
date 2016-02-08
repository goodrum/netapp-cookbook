require_relative '../spec_helper'
require_relative '../helpers/matchers'

describe 'netapp::lun_map' do
  context 'without :step_into' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe)}

    it 'creates a new lun mapping' do
      expect(chef_run).to create_netapp_lun_map('demo.lun').with(
          svm: "demo-svm",
          volume: "root_vs",
          igroup: "demo_igroup"
        )
    end

    it 'deletes a lun mapping' do
      expect(chef_run).to delete_netapp_lun_map('del_demo.lun').with(
          svm: "demo-svm",
          volume: "root_vs",
          igroup: "demo_igroup",
          force: true
        )
    end
  end
end