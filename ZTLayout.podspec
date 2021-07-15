
Pod::Spec.new do |s|

  s.name         = "ZTLayout"
  s.version      = "0.0.1"
  s.summary      = "敏思达"

  s.homepage     = "https://github.com/Tian-0v0/ZTLayout"
  s.source       = { :git => "git@github.com:Tian-0v0/ZTLayout.git", :tag => s.version }
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "T_T" => "zt_zhang@protonmail.com" }
  s.platform     = :ios, "10.0"
  s.source_files = "ZTLayout/ZTLayout/*.swift"
  s.framework    = "Foundation"
  s.requires_arc = true
  
  s.dependency 'ZTProject'
end
