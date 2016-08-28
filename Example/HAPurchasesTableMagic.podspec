Pod::Spec.new do |s|
  s.name         = "HAPurchasesTableMagic"
  s.version      = "0.0.1"
  s.summary      = "HAPurchasesTableMagic is a magic class for automated manage app-purchase for iOS 8 >"
 
  s.homepage         = "https://github.com/litoarias/HAPurchasesTableMagic.git"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.authors          = { "litoarias" => "lito.arias.cervero@gmail.com" }
  s.social_media_url = 'https://github.com/litoarias/HAPurchasesTableMagic'
 
  s.requires_arc     = true
  s.ios.deployment_target = '8.0'
  s.source           = { :git => "https://github.com/litoarias/HAPurchasesTableMagic.git", :tag => "0.0.1" }
  s.source_files     = "HAPurchasesTableMagic"
  s.requires_arc     = true

  s.ios.frameworks = 'StoreKit'
  s.dependency 'AvePurchaseButton', '~> 1.0.3'
  s.dependency 'MKStoreKit'


end