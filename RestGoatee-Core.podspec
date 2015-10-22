Pod::Spec.new do |s|
  s.name             = "RestGoatee-Core"
  s.version          = '1.2.1'
  s.summary          = "An intuitive JSON & XML deserialization library"
  s.homepage         = "https://github.com/rdignard08/RestGoatee-Core"
  s.license          = 'BSD'
  s.author           = { "Ryan Dignard" => "conceptuallyflawed@gmail.com" }
  s.source           = { :git => "https://github.com/rdignard08/RestGoatee-Core.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'RestGoatee-Core'
end
