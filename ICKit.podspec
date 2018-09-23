#
# Be sure to run `pod lib lint ICKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ICKit'
  s.version          = '0.2.6'
  s.summary          = 'A common useful dev pack.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/IvanChan/ICKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '_ivanC' => 'aintivanc@icloud.com' }
  s.source           = { :git => 'https://github.com/IvanChan/ICKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
 s.swift_version = '4.1'

  s.ios.deployment_target = '8.0'

    s.default_subspec = 'Core'

    s.subspec 'Core' do |core|
    core.source_files = 'ICKit/Classes/**/*'
    core.exclude_files = 'ICKit/Classes/ICRes/**/*'

    core.dependency 'ICFoundation'
    end

    s.subspec 'ICRes' do |icres|
    icres.source_files = 'ICKit/Classes/ICRes/**/*'

    icres.dependency 'ICKit/Core'
    icres.dependency 'ICResourceKit'
    end

  # s.resource_bundles = {
  #   'ICKit' => ['ICKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
