require_relative '../spec_helper'
require_relative '../helpers/matchers'

describe 'netapp::igroup_initiators' do
  context 'without :step_into' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe)}

    it 'creates a new igroup' do
      expect(chef_run).to add_netapp_igroup_initiators('igroup').with(
          svm: "demo-svm",
          initiator: "iqn.1991-05.com.microsoft:win-skmc9bpn92u"
        )
    end

    it 'deletes a igroup' do
      expect(chef_run).to remove_netapp_igroup_initiators('del_igroup').with(
          svm: "demo-svm",
          initiator: "iqn.1991-05.com.microsoft:win-skmc9bpn92u",
          force: true
        )
    end
  end
end