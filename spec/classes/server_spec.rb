require 'spec_helper'
describe 'helix::server' do
  context 'testing with Redhat 6' do
    let(:facts) do
      {
        osfamily: 'RedHat',
       operatingsystem: 'RedHat',
       operatingsystemmajrelease: '6'
      }
    end

    context 'with required params only' do
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('helix::server') }
      it { is_expected.to contain_package('helix-p4d') }
    end
  end
end
