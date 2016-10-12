project 'CollectionView'
workspace 'CollectionViews'

use_frameworks!

target 'CollectionView' do
  pod 'JSQDataSourcesKit'
end

# this is for Xcode 8 beta 6, probably want to remove after Xcode 8 releases
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
