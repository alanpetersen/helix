require 'spec_helper_acceptance'

describe 'helix::broker class' do
  context 'with required parameters only, non ssl' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
include helix::broker

$commands = [
'command: .*
{
    action  = reject;
    message = "Server down for maintenance. Back soon";
}',
'command: opened
{
    flags  = -a;
    user   = tony;
    action = pass;
}'
]

helix::broker_instance { 'broker1':
  p4brokerport   => '1667',
  p4brokertarget => 'localhost:1666',
  commands       => $commands,
}

EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('/usr/sbin/p4broker -V') do
      its(:stdout) { is_expected.to match(%r{Perforce - The Fast Software Configuration Management System}) }
    end

    describe port(1667) do
      it { is_expected.to be_listening }
    end
  end

  context 'with required parameters only, ssl enabled' do
    pp = <<-EOS
include helix::broker

helix::broker_instance { 'broker2':
p4brokerport   => 'ssl::4667',
p4brokertarget => 'localhost:1666',
}

EOS
    it {
      apply_manifest(pp, catch_failures: true)
    }

    describe port(4667) do
      it { is_expected.to be_listening }
    end
  end
end
