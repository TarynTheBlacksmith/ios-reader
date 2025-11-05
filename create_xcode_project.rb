#!/usr/bin/env ruby
require 'xcodeproj'
require 'json'

project = Xcodeproj::Project.new('ResonateApp.xcodeproj')

# Create target
target = project.new_target(:application, 'ResonateApp', :ios, '17.0')

# Create main group structure
app_group = project.main_group.new_group('ResonateApp')
models_group = app_group.new_group('Models')
views_group = app_group.new_group('Views')
viewmodels_group = app_group.new_group('ViewModels')
services_group = app_group.new_group('Services')
resources_group = app_group.new_group('Resources')

# Add subgroups for Views
story_list_group = views_group.new_group('StoryList')
editor_group = views_group.new_group('Editor')
presentation_group = views_group.new_group('Presentation')

# Add files - App
app_files = Dir.glob('ResonateApp/App/*.swift')
app_files.each do |file|
  file_ref = app_group.new_file(file)
  target.add_file_references([file_ref])
end

# Add files - Models
model_files = Dir.glob('ResonateApp/Models/*.swift')
model_files.each do |file|
  file_ref = models_group.new_file(file)
  target.add_file_references([file_ref])
end

# Add files - ViewModels
viewmodel_files = Dir.glob('ResonateApp/ViewModels/*.swift')
viewmodel_files.each do |file|
  file_ref = viewmodels_group.new_file(file)
  target.add_file_references([file_ref])
end

# Add files - Services
service_files = Dir.glob('ResonateApp/Services/*.swift')
service_files.each do |file|
  file_ref = services_group.new_file(file)
  target.add_file_references([file_ref])
end

# Add files - Views/StoryList
story_list_files = Dir.glob('ResonateApp/Views/StoryList/*.swift')
story_list_files.each do |file|
  file_ref = story_list_group.new_file(file)
  target.add_file_references([file_ref])
end

# Add files - Views/Editor
editor_files = Dir.glob('ResonateApp/Views/Editor/*.swift')
editor_files.each do |file|
  file_ref = editor_group.new_file(file)
  target.add_file_references([file_ref])
end

# Add files - Views/Presentation
presentation_files = Dir.glob('ResonateApp/Views/Presentation/*.swift')
presentation_files.each do |file|
  file_ref = presentation_group.new_file(file)
  target.add_file_references([file_ref])
end

# Note: Info.plist should be referenced in build settings, not added as a file reference

# Configure build settings
target.build_configurations.each do |config|
  config.build_settings['PRODUCT_NAME'] = 'ResonateApp'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.resonate.app'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2' # iPhone and iPad
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  config.build_settings['INFOPLIST_FILE'] = 'ResonateApp/Resources/Info.plist'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = config.name == 'Debug' ? '-Onone' : '-O'
  config.build_settings['ENABLE_BITCODE'] = 'NO'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
end

# Create Assets.xcassets if it doesn't exist
assets_path = 'ResonateApp/Resources/Assets.xcassets'
unless Dir.exist?(assets_path)
  Dir.mkdir(assets_path) unless Dir.exist?('ResonateApp/Resources')
  Dir.mkdir(assets_path)

  # Create AppIcon.appiconset
  appicon_path = File.join(assets_path, 'AppIcon.appiconset')
  Dir.mkdir(appicon_path)

  File.write(File.join(appicon_path, 'Contents.json'), {
    "images" => [
      {
        "idiom" => "universal",
        "platform" => "ios",
        "size" => "1024x1024"
      }
    ],
    "info" => {
      "author" => "xcode",
      "version" => 1
    }
  }.to_json)
end

# Add Assets.xcassets to resources
assets_ref = resources_group.new_file(assets_path)
target.add_resources([assets_ref])

project.save

puts "✅ Created ResonateApp.xcodeproj"
puts "📁 Added #{app_files.length + model_files.length + viewmodel_files.length + service_files.length + story_list_files.length + editor_files.length + presentation_files.length} Swift files"
puts "🚀 Ready to build!"
