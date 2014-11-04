source 'git@github.com:layerhq/cocoapods-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

dropbox_path = ENV['LAYER_DROPBOX_PATH'] || '~/Dropbox (Layer)'

target 'LayerSample' do
  pod 'SVProgressHUD', :head
  #pod 'LayerKit'
  pod 'LayerKit', git: 'git@github.com:layerhq/LayerKit.git'
  #pod 'LayerKit', path: "#{dropbox_path}/Layer/Builds/iOS/LayerKit-0.8.6"
  #pod 'LayerKit', path: '/Users/blake/Projects/Layer/LayerKit-again'
  pod 'HockeySDK', '~> 3.5.6'
  pod 'LayerUIKit', path: 'LayerUIKit'
  #pod 'LayerUIKit', git: 'git@github.com:layerhq/LayerUIKit'
end

target 'LayerSampleTests' do
  pod 'KIF', '~> 3.0.8'
  pod 'OCMock', '~> 3.1'
  pod 'KIFViewControllerActions', git: 'git@github.com:blakewatters/KIFViewControllerActions.git'
  #pod 'KIFViewControllerActions', '~> 1.0'
  pod 'Expecta', '~> 0.3.0'
  pod 'LYRCountDownLatch', git: 'git@github.com:layerhq/LYRCountDownLatch.git'
end
