# Change Log

## Next Version

### Added

### Fixed

### Updated

### Removed

## 1.1.6

### Hotfix

- Revert "Refactored Validator"

## 1.1.5

### Hotfix

- Revert "Refactored HostList (#42)"

## 1.1.4

### Added

- Added about screen presenter tests (#37)

### Fixed

- Fixed CGSize.inversed name
- Fixed crashes
- Fixed memory leaks

### Updated

- Refactored Validator
- Replaced guard let statements with Swift 5.7 sugar
- Updated Gemfile.lock, Fastfile
- Sorted import statements
- Refactored HostList (#42)
- BundleInfoSeeds - moved bracket (#43)

### Removed

- Removed Resolver (#40)
- Removed unused code, fixed codestyle

## 1.1.3

### Added

- Added AboutScreen tests (#34)
- Added WakeOnLanServiceMock target (#33)

### Fixed

- Fixed multicast networking (#39)
- Fixed MainScreen message (#35)

### Updated

- Updated swift-templates
- Refactored WOLService. Added tests (#36)

### Removed

- Removed strings file headers

## 1.1.2

### Added

- Added Siri Intent and DB migration to app group
- Added swift-templates submodule
- Added AutoMockable for CoreDataService
- Added WakeOnLanServiceProtocol
- Added FileManagerProtocol

### Fixed

- Fixed tests
- Disabled Bitcode
- Fixed autogenerated_files.sh
- Fixed typo
- Fixed SharedProtocolsAndModels package structure
- Fixed warnings

### Updated

- Updated dependencies
- Updated project.yml
- Split WakeOnLanService into extensions
- Updated development keys

### Removed

- Removed Generamba templates
- Removed Package.resolved files

## 1.0.6

### Fixed

- Fixed keyboard for IP address @Dm94st

[Commits](https://github.com/tr1ckyf0x/wakeonlan-ios/compare/v1.0.5...1.0.6)

## 1.0.5

### Added

### Fixed

- Fixed slow rendering issue on host icon screen @Dm94st
- Fixed text input issues @Dm94st
- Fixed Swiftgen and Swiftlint paths @tr1ckyf0x

### Updated

- Updated packages @Dm94st @tr1ckyf0x

[Commits](https://github.com/tr1ckyf0x/wakeonlan-ios/compare/v1.0.4...1.0.5)