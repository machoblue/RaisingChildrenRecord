# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
abstract_target 'All' do

  pod 'Firebase/Core'
  pod 'RealmSwift'

  target 'RaisingChildrenRecord' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    pod 'FirebaseUI'

    target 'RaisingChildrenRecordTests' do
      inherit! :search_paths
    end

    target 'RaisingChildrenRecordUITests' do
      inherit! :search_paths
    end

  end

  target 'RecordCreateIntentExtension' do
    use_frameworks!
    pod 'RealmSwift'
  end

  target 'Shared' do
    use_frameworks!
    pod 'RealmSwift'
  end

end
