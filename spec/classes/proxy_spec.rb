require 'spec_helper'
describe 'helix::proxy' do

  context 'testing with Redhat 6' do
    let(:facts) {{
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemmajrelease => '6'
    }}

    context 'with required params only' do
      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('helix::proxy') }
      it { is_expected.to contain_package('helix-proxy') }
    end

  end

end
