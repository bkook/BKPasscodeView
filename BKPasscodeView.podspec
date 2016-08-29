Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "BKPasscodeView"
  s.version      = "0.2.3"
  s.summary      = "Customizable passcode view controller for iOS."
  s.description  = "It supports for setting, changing and authenticating a passcode. Simple numeric passcode or normal passcode can be used."
  s.homepage     = "https://github.com/bkook/BKPasscodeView"
  s.screenshots  = "https://raw.githubusercontent.com/bkook/BKPasscodeView/master/Screenshots/passcode_01.png", "https://raw.githubusercontent.com/bkook/BKPasscodeView/master/Screenshots/passcode_02.png"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = "Byungkook Jang"
  s.social_media_url   = "http://twitter.com/bkook"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.platform     = :ios, "5.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source       = { :git => "https://github.com/bkook/BKPasscodeView.git", :tag => s.version.to_s }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "BKPasscodeView/**/*.{h,m}"
  s.exclude_files = "Pods"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true
  s.dependency "AFViewShaker", "~> 0.0"

end
