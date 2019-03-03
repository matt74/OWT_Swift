# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'OWT_Swift' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for OWT_Swift
  pod 'AFNetworking', '~> 3.2'

  target 'OWT_SwiftTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'OWT_SwiftUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.2'
        end
    end
  end

end
