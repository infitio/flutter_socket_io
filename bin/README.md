## Code generation to keep platform constants in sync

There are many platform constants that need to be sync on dart side and platform side.
Following are the constants that are being generated:
1. codec types
2. platform method and event names
3. serializable property names for serialization and de-serialization

#### Generating files

```bash
cd bin
dart codegen.dart
```

#### Template format

A straight forward templates creating using dart string interpolation:

#### Template and Context files

source template files are available in `bin/templates`
 and source context data in `bin/codegencontext.dart`.


#### Generated files

These files are generated/modified upon code generation

1. `lib/src/generated/platformconstants.dart` for use in Flutter/Dart
2. `android/src/main/java/com/infitio/adharasocketio/generated/PlatformConstants.java` for use in Android/Java
3. `ios/Classes/codec/AdharaSocketIoPlatformConstants.h` for use in iOS/Objective-C
4. `ios/Classes/codec/AdharaSocketIoPlatformConstants.m` for use in iOS/Objective-C

#### When would I need to run code generation?

When any of the below need to be added/updated
1. A new codec type - required when a new top level serializable object is required (ex: `ErrorInfo` and `ClientOptions`)
2. Platform and event names - when implementing a new method in `MethodChannel` or new event in `EventChannel`
3. A new object needs to be serialized (either top-level, or nested)


#### What should I do after running code generation?

1. Test that everything still works
2. Commit changes to the template(s)
3. Commit changes to the generate files
