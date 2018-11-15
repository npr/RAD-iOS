Pod::Spec.new do |s|
  s.name          = "RAD"
  s.version       = "1.0.0"
  s.summary       = "The RAD SDK is a great starting place to learn more about how a RAD implementation might work in your client app."

  s.description   = "Remote Audio Data (RAD) measures podcast listening across a range of participating clients and platforms, aggregating the data in a publishers’ analytics endpoint. RAD is not intended to replace download statistics as a point of measurement for the on-demand audio industry, but is designed to provide data on listening events to complement this download statistics.

  RAD will allow publishers to receive organized, enhanced listening metrics on editorial and sponsorship and advertising messages they care about. It reduces the need for each platform to have a detailed analytics dashboard and allows for information to be aggregated in a third-party location. RAD does not track specific user behavior; instead, RAD uses a session ID combined with IP addresses. The SDK was created to be lightweight and configurable to your application."

  s.homepage      = "https://n.pr/RADspec"
  s.license       = { :type => "Apache License Version 2.0", :file => "LICENSE" }
  s.author        = { "NPR" => "remoteaudiodata@npr.org" }
  s.platform      = :ios, "10.0"
  s.source        = { :git => "https://github.com/npr/RAD-iOS.git", :tag => "#{s.version}" }
  s.source_files  = "RAD/**/*.{h,m, swift}"
  s.resource      = "RAD/Model/RADDatabaseModel.xcdatamodeld"
  s.frameworks    = "Foundation", "AVFoundation", "CoreMedia", "CoreData"
  s.dependency "ReachabilitySwift"
  s.swift_version = "4.2"
end
