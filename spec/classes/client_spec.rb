require 'spec_helper'
describe 'helix::client' do
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
      it { is_expected.to contain_class('helix::client') }
      it { is_expected.to contain_package('helix-cli') }
    end
  end
end
