# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Shared' do
  use_frameworks!
  pod 'RealmSwift'
  
  target 'RaisingChildrenRecord' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    inherit! :search_paths
    # pod 'FirebaseUI'
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'Firebase/AdMob'

    target 'RaisingChildrenRecordTests' do
      inherit! :search_paths
    end

    target 'RaisingChildrenRecordUITests' do
      inherit! :search_paths
    end

  end

  target 'RecordCreateIntentExtension' do
    inherit! :search_paths
  end

end
