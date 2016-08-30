require 'spec_helper'

context 'In Container' do
  describe process('haproxy') do
    it { should be_running }
    its(:count) { should eq 3 }
  end

  describe port(443) do
    it { should be_listening }
  end
end
