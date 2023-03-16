require 'spec_helper_acceptance'

describe 'helix::proxy class' do
  context 'with required parameters only' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
include helix::proxy

helix::proxy_instance { 'proxy1':
  p4proxyport    => '1668',
  p4proxytarget  => 'localhost:1666',
}

EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('/usr/sbin/p4p -V') do
      its(:stdout) { is_expected.to match(%r{Perforce - The Fast Software Configuration Management System}) }
    end

    describe port(1668) do
      it { is_expected.to be_listening }
    end
  end
end
