# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end

target 'StreakTasks' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for StreakTasks
  pod 'KYCircularProgress'
  pod 'SCLAlertView'
  pod 'FontAwesome.swift'
  pod 'SwiftForms'
  pod 'SwiftyStoreKit'
  pod 'paper-onboarding'
  pod 'SwiftyJSON'
end

target 'StreakTasksWidgets' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  inherit! :search_paths
  use_frameworks!

  # Pods for StreakTasksWidgets

end
