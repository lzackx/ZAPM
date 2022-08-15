#
# Be sure to run `pod lib lint ZAPM.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = "ZAPM"
  s.version = "1.0.0"
  s.summary = "APM implementation."
  s.description = <<-DESC
APM implementation.
                       DESC
  s.homepage = "https://github.com/lZackx/ZAPM"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "lZackx" => "lzackx@lzackx.com" }
  s.source = { :git => "https://github.com/lZackx/ZAPM.git", :tag => s.version.to_s }
  s.ios.deployment_target = "9.0"
  s.default_subspecs = 'Core'

  s.subspec "Core" do |ss|
    ss.source_files = "ZAPM/Classes/Core/**/*"
    ss.dependency "YYModel"
  end

  s.subspec "Network" do |ss|
    ss.source_files = [
      "ZAPM/Classes/Network/**/*",
    ]
    ss.dependency "ZAPM/Core"
    ss.dependency "Zcurl"
    ss.dependency "ZNetDiagnosis"
  end
end
