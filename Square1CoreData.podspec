Pod::Spec.new do |s|

  s.name         = "Square1CoreData"
  s.version      = "1.0.1"
  s.summary      = "A collection of tools used in our Swift projects"
  s.description  = "A handy collection of helpers for dealing with CoreData"
  s.homepage     = "https://github.com/square1-io/Square1-iOS-CoreData"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = "Square1"
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/square1-io/Square1-iOS-CoreData.git", :tag => s.version }
  s.source_files  = "Source", "Source/**/*.swift"

end
