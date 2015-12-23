require 'spec_helper_acceptance'

describe 'helix::broker class' do
  context 'with required parameters only' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
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
  p4brokerport   => 'ssl::1667',
  p4brokertarget => 'localhost:1666',
  commands       => $commands,
}

EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe command('/usr/sbin/p4broker -V') do
      its(:stdout) { should match /Perforce - The Fast Software Configuration Management System/ }
    end

    describe port(1667) do
      it { should be_listening }
    end

  end
end
