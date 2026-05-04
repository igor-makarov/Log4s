Pod::Spec.new do |s|
  s.name         = "Log4s"
  s.version      = "1.6.0"
  s.summary      = "A logging library written in swift."

  s.description  = <<-DESC
                   Log4s is a logging library similar in philosophy to log4j.
                   It is meant to be :

                   * very simple to use for simple cases
                   * extensively configurable for less simple cases

                   DESC

  s.homepage     = "http://github.com/igor-makarov/Log4s"
  
  s.license      = { :type => "Apache v2.0", :file => "LICENSE" }

  s.authors       = { "Igor Makarov" => "igormaka@gmail.com",
                      "Jerome Duquennoy" => "jerome@duquennoy.fr" }

  s.ios.deployment_target = "12.0"
  s.watchos.deployment_target = "4.0"
  s.osx.deployment_target = "10.13"
  s.swift_versions = ['4.0', '4.1', '4.2', '5.0']

  s.module_name = 'Log4swift'

  s.source       = { :git => "https://github.com/igor-makarov/Log4s", :tag => "#{s.version}" }

  s.source_files = "Log4swift", "Log4swift/**/*.{swift,h,m}"

  s.public_header_files = ["Log4swift/log4swift.h"]
end
