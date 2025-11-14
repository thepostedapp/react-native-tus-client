require 'json'
package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNTusClient"
  s.version      = package['version']
  s.summary      = package["description"]
  s.requires_arc = true
  s.license      = package["license"]
  s.homepage     = 'https://github.com/vinzscam/react-native-tus-client'
  s.author       = { "Vincenzo Scamporlino" => "vincenzo@scamporlino.it" }
  s.source       = { :git => "https://github.com/vinzscam/react-native-tus-client", :tag => 'v#{s.version}'}
  s.source_files = 'ios/*.{h,m}'

  s.ios.deployment_target = '12.0'

  s.dependency 'React-Core'
  s.dependency 'TUSKit', '~> 1.4.2'
  
  # IMPORTANT: TUSKit has a bug in TUSFileData.m (line 23) where it uses url.filePathURL
  # instead of url.path. This causes a crash: -[NSURL length]: unrecognized selector sent to instance
  # 
  # To fix this automatically, add the following post_install hook to your Podfile:
  #
  # post_install do |installer|
  #   tus_client_script = File.join(__dir__, '..', 'node_modules', 'react-native-tus-client', 'ios', 'fix_tuskit.sh')
  #   if File.exist?(tus_client_script)
  #     system("PODS_ROOT=#{installer.sandbox.root} #{tus_client_script}")
  #   end
  # end
end
