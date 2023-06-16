Pod::Spec.new do |s|
  s.name             = 'ThrottledTask'
  s.version          = '0.1.2'
  s.summary          = 'Execute consecutive calls to long-running tasks just once'
  s.description      = <<-DESC
Execute consecutive calls to long-running tasks just once.
                       DESC
  s.homepage         = 'https://github.com/anconaesselmann/ThrottledTask'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Axel Ancona Esselmann' => 'axel@anconaesselmann.com' }
  s.source           = { :git => 'https://github.com/anconaesselmann/ThrottledTask.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.6'
  s.source_files = 'Sources/ThrottledTask/**/*'
end
