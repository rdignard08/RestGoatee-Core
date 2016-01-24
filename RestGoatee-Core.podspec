Pod::Spec.new do |s|
  s.name             = "RestGoatee-Core"
  s.version          = '2.1.2'
  s.license          = 'BSD'
  s.summary          = "An intuitive JSON & XML deserialization and model library"
  s.homepage         = "https://github.com/rdignard08/RestGoatee-Core"

  s.authors          = { "Ryan Dignard" => "conceptuallyflawed@gmail.com" }
  s.source           = { :git => "https://github.com/rdignard08/RestGoatee-Core.git", :tag => s.version }
  s.requires_arc     = true

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.public_header_files = 'RestGoatee-Core/*.h'
  s.source_files = 'RestGoatee-Core'
end
