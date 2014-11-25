Pod::Spec.new do |spec|
  spec.name             = "Nugget"
  spec.version          = "0.0.1"
  spec.summary          = "Collection of utility classes"
  spec.description      = <<-DESC
                        - Convenience collection and collection updates for working with UITableView and UICollectionView
                        DESC

  spec.homepage         = "https://github.com/meiwin/Nugget"
  spec.screenshots      = "https://github.com/Flipboard/FLAnimatedImage/raw/master/images/flanimatedimage-demo-player.gif"
  spec.license          = { :type => "MIT", :file => "LICENSE" }
  spec.author           = { "Raphael Schaad" => "raphael.schaad@gmail.com" }
  spec.social_media_url = "https://twitter.com/raphaelschaad"
  spec.platform         = :ios, "5.0"
  spec.source           = { :git => "https://github.com/Flipboard/FLAnimatedImage.git", :tag => "1.0.1" }
  spec.source_files     = "FLAnimatedImageDemo/FLAnimatedImage", "FLAnimatedImageDemo/FLAnimatedImage/**/*.{h,m}"
  spec.frameworks       = "QuartzCore", "ImageIO", "MobileCoreServices", "CoreGraphics"
  spec.requires_arc     = true
end
