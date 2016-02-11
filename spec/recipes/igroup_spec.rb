require_relative '../spec_helper'
require_relative '../helpers/matchers'

describe 'netapp::igroup' do
  context 'without :step_into' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe)}

    it 'creates a new igroup' do
      expect(chef_run).to create_netapp_igroup('igroup').with(
          svm: "demo-svm",
          type: "iscsi",
          ostype: "windows"
        )
    end

    it 'deletes a igroup' do
      expect(chef_run).to delete_netapp_igroup('del_igroup').with(
          svm: "demo-svm",
          force: true
        )
    end
  end
end