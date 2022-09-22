# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'Example' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Example
  pod 'QiscusCore', :git => 'https://github.com/qiscus/QiscusCore-iOS.git', :branch => 'handle-double-message'

    # 3rd party
  pod 'SDWebImage', '5.12.0'
  pod 'SimpleImageViewer', :git => 'https://github.com/ariefnurputranto/SimpleImageViewer'
  pod 'SwiftyJSON'
  pod 'Alamofire', '4.9'
  pod 'AlamofireImage', '3.6.0'
  pod 'UICircularProgressRing', :git => 'https://github.com/luispadron/UICircularProgressRing'
  pod 'XLPagerTabStrip', '~> 9.0'
  pod 'ExpandingMenu', '~> 0.4'
  pod 'BottomPopup', '0.5.1'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Installations'
  pod 'iRecordView'
  pod 'MobileVLCKit', '~>3.3.0'
  pod 'SDWebImageWebPCoder'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
      end
    end
  end

  
  
end
