Pod::Spec.new do |s|
  s.name                  = "sbp_framework"
  s.version               = "1.0.0"
  s.summary               = "СДК предоставляет функционал для перенаправления пользователя для оплаты по СБП."
  s.homepage              = "https://github.com/Raiffeisen-DGTL/payform-sdk-ios"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "Raiffeisen-DGTL" => " pr@raiffeisen.ru" }
  s.platform              = :ios
  s.ios.deployment_target = "13.0"
  s.source                = { :git => "https://github.com/Raiffeisen-DGTL/payform-sdk-ios.git", :tag => s.version }
  s.source_files          = "Sources/sbp_framework/**/*.{swift, h}"
  s.resource_bundles      = { 'sbp_framework' => ['Sources/sbp_framework/Resources/*.xib', 'Sources/sbp_framework/**/*.strings'] }
  s.exclude_files      = 'Sources/sbp_framework/extensions/SPM+Bundle+Extensions.swift'
  s.swift_version         = '5.0'
end
