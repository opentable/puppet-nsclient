require 'spec_helper'

describe 'nsclient', :type => :class do

  let(:facts) { {
      :osfamily  => 'Windows'
  } }
  let(:params) {{
      :package_source_location => 'http://files.nsclient.org/stable',
      :package_name            => 'NSCP-0.4.1.101-x64.msi',
      :download_destination    => 'c:\\temp'
  }}

  it { should contain_class('nsclient::install').that_comes_before('nsclient::service') }


  context 'using params defaults' do
    it { should contain_class('nsclient') }
    it { should contain_download_file('NSCP-Installer').with(
      'url'                   => 'http://files.nsclient.org/stable/NSCP-0.4.1.101-x64.msi',
      'destination_directory' => 'c:\temp'
    )}
    it { should contain_package('NSCP-0.4.1.101-x64.msi').with(
      'ensure'   => 'installed',
      'provider' => 'windows',
      'source'   => 'c:\temp\NSCP-0.4.1.101-x64.msi',
      'require'  => 'Download_file[NSCP-Installer]'
    )}
    it { should contain_service('nscp').with_ensure('running') }
#
  end

  context 'using proxy server' do
    let(:params) {{
        :proxy_server => 'http://myproxyserver.net:3128',
    }}
    it { should contain_download_file('NSCP-Installer').with(
      'proxyaddress'          => 'http://myproxyserver.net:3128'
    )}
#
  end

  context 'installing a custom version' do

    let(:params) {{
      :package_source           => 'NSCP-Custom-build.msi',
      :package_name             => 'NSClient++ (x64)',
      :package_source_location  => 'http://myproxy.com:8080'
    }}

    it { should contain_package('NSClient++ (x64)').with(
      'ensure'   => 'installed',
      'provider' => 'windows',
      'source'   => 'c:\temp\NSCP-Custom-build.msi',
      'require'  => 'Download_file[NSCP-Installer]'
    )}

  end


  context 'when trying to install on Ubuntu' do
    let(:facts) { {:osfamily => 'Ubuntu'} }
    it do
      expect {
        should contain_class('nsclient')
      }.to raise_error(Puppet::Error, /This module only works on Windows based systems./)
    end
  end

  context 'with service_state set to stopped' do
    let(:params) { {'service_state' => 'stopped'} }

    it { should contain_service('nscp').with_ensure('stopped') }
  end

  context 'with service_enable set to false' do
    let(:params) { {'service_enable' => 'false'} }

    it { should contain_service('nscp').with_enable('false') }
  end

  context 'with service_enable set to true' do
    let(:params) { {'service_enable' => 'true'} }

    it { should contain_service('nscp').with_enable('true') }
  end

  context 'when single value array of allowed hosts' do
    let(:params) {{ 'allowed_hosts' => ['172.16.0.3'], 'service_state' => 'running', 'service_enable' => 'true' }}

    it { should contain_file('C:\Program Files\NSClient++\nsclient.ini').with_content(/allowed hosts = 172\.16\.0\.3/) }
  end

  context 'when passing an array of allowed hosts' do
    let(:params) {{ 'allowed_hosts' => ['10.21.0.0/22','10.21.4.0/22'], 'service_state' => 'running', 'service_enable' => 'true' }}

    it { should contain_file('C:\Program Files\NSClient++\nsclient.ini').with_content(/allowed hosts = 10\.21\.0\.0\/22,10\.21\.4\.0\/22/) }
  end

  context 'when passing an incorrect proxy server url should fail' do
    let(:params) {{
        :proxy_server => 'htt://proxyserver.net:3128'
    }}

    it { should compile.and_raise_error(/ERROR: You must enter a proxy url in a valid format i\.e\. http:\/\/proxy\.net:3128/) }
  end

end
