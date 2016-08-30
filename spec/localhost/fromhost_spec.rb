require 'spec_helper'

# https://gist.github.com/garethr/6579190
# https://github.com/sophsec/ruby-nmap
# https://github.com/vincentbernat/serverspec-example/blob/master/viewer/index.html

context 'From host' do
  # http://wiki.dovecot.org/TestInstallation
  describe command('docker ps') do
    its(:stdout) { should match /#{ENV['DOCKER_IMAGE']}.*docker-entrypoint.* Up/ }
  end
end
