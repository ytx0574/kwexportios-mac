platform:macos, '10.13'
use_frameworks!


def commonPods
  pod 'FMDB'
end

target 'kuwo_export' do
  commonPods
end

#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        target.build_configurations.each do |config|
#            # Needed for building for simulator on M1 Macs
#            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
#        end
#    end
#end
