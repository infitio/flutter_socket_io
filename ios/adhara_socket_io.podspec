#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'adhara_socket_io'
  s.version          = '0.0.1'
  s.summary          = 'socket.io for flutter by adhara'
  s.description      = <<-DESC
socket.io for flutter by adhara
                       DESC
  s.homepage         = 'https://github.com/infitio/flutter_socket_io/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rohit' => 'rr.16566@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Socket.IO-Client-Swift'
  s.dependency 'Starscream'

  s.swift_version = '5.0'
  s.ios.deployment_target = '9.0'
end
