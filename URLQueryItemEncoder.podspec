
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "URLQueryItemEncoder"
  s.version      = "0.1.0"
  s.summary      = "A Swift Encoder for encoding any Encodable value into an array of URLQueryItem."

  s.description  = "A Swift Encoder for encoding any Encodable value into an array of URLQueryItem. As part of the SE-0166, Swift has a foundation for any type to define how its value should be archived. This encoder allows you to encode those value into an array of URLQueryItem which represent that value in one command."

  s.homepage     = "https://github.com/pitiphong-p/URLQueryItemEncoder"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Pitiphong Phongpattranont" => "pitiphong.p@me.com" }
  s.social_media_url   = "http://twitter.com/pitiphong_p"

  s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/pitiphong-p/URLQueryItemEncoder.git", :tag => "#{s.version}" }

  s.source_files  = "URLQueryItemEncoder"

end
