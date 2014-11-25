Pod::Spec.new do |spec|
  spec.name             = "Nugget"
  spec.version          = "0.0.1"
  spec.summary          = "Collection of utility classes"
  spec.description      = <<-DESC
                        - Convenience collection and collection updates for working with UITableView and UICollectionView
                        DESC

  spec.homepage         = "https://github.com/meiwin/Nugget"
  spec.license          = { :type => "MIT", :file => "LICENSE" }
  spec.author           = { "Meiwin Fu" => "meiwin@blockthirty.com" }
  spec.social_media_url = "https://twitter.com/meiwin"
  spec.platform         = :ios, "7.0"
  spec.source           = { :git => "https://github.com/meiwin/Nugget.git" }
  spec.source_files     = "Nugget/", "Nugget/**/*.{h,m}"
  spec.frameworks       = "UIKit"
  spec.requires_arc     = true
end
