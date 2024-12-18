A command line tool that lets you import **internal** Swift objects into Objective-C in Frameworks.  

Table of Contents
-----------------

- [Problem](#problem)
- [Solution](#solution)
- [How to use it](#how-to-use-it)
- [How `h-codegen` works](#how-h-codegen-works)
- [Important](#important)
- [Limitations](#limitations)

Problem
----------------

You can work with types declared in Swift from within the Objective-C code in your project by importing an Xcode-generated header file. For an **App Target** the generated header contains interfaces for Swift declarations marked with the public, open and internal modifier. However for a **Framework Target** only declarations marked with the public or open modifier appear in the generated header, because the generated header is part of the framework’s public interface.  
  
The lack of access to Swift types from Objective-C complicates working with mixed Swift/Objective-C frameworks.  
Perhaps in the future we will see a [solution](https://github.com/swiftlang/swift/issues/47797) for this problem, but for now...


Solution
-----------------------------

 Internal methods and properties declared within a class that inherits from an Objective-C class are accessible to the Objective-C runtime. However, they’re inaccessible at compile time.

To help the compiler recognize them, we can write headers manually; however, this creates the risk of encountering an «unrecognized selector» due to incorrect headers. Our approach is to generate headers automatically. In fact, this is what Xcode does with the -Swift.h.


How to use it?
---------------------

#### 1) Macros

At first drop `InteroperabilityMacro.h` in your project. This file contains macros for the generated headers.  

#### 2) Command line tool
Use `h-codegen` as a command line tool.  
   
Download the release or сheck out and build `h-codegen` manually on macOS
 ```
$ git clone ...
$ cd ...
$ swift build -c release
 ```  
   
**WARNING:** Since `h-codegen` update Xcode project, itt does not recommend to use it as a Build Phase  

CLI contains 2 subcommands: `codegen` (default) and `compare`.  

#### 2.1) `codegen` command

Generates Objective-C headers from Swift files.  
  
You should provide:
- path to workspace (`--workspace`) or project (`--project`), but not both
- SDK name or Xcode target (`--sdk`)
- path to code directory (`--directory`)
- destination directory where to generate files (`--destination`)  
  
Optionally you can provide:
- build scheme (`--scheme`). Defaults to `--sdk`
- prefix for generated .h files (`--prefix`) 
- skip adding generated files into .xcodeproj (`--gen-only`)  

#### 2.2) `compare` command

Checks the correctness of the generated headers (typically it is useful for CI).  
  
You should provide:
- path to workspace (`--workspace`) or project (`--project`), but not both
- SDK name or Xcode target (`--sdk`)
- path to code directory (`--directory`)
- path to directory with headers that needs to checked (`--headers`)

Optionally you can provide:
- build scheme (`--scheme`). By default takes from the `--sdk`
- prefix. Should be the same as for the generated headers (`--prefix`)  
  
For more information use `h-codegen --help`


How `h-codegen` works?
---------------------
  
`h-codegen` analyzes Swift files and generates the -Swift.h using the standard swiftc compiler and then parses the resulting -Swift.h header into separate files. For each Swift file in a project `h-codegen` creates a corresponding .h file with prefix and the same name.  
  
You can see the result in HCodegenDemo


Important
-------------------

#### 1) Objective-C and external dependencies

`h-codegen` knows about Swift files and objects, but it doesn't know about Objective-C and external dependencies. To handle this there are some `h-codegen` actions: `header` and `framework`.  
  
Use the `h-codegen:header:...` action to specify an import header. And the `h-codegen:framework:...` action for a framework.
```
// h-codegen:header:SomeObjectiveCProtocol.h
// h-codegen:framework:MapKit

@objc(MYMapViewController)
final class MapViewController: MKMapViewDelegate, SomeObjectiveCProtocol { }
```
  
#### 2) Prefix overriding

Typically you want to add prefix for each header file name. But sometimes you might want to avoid this, for example, in files with extensions (UIView+Constraints.h) or you may want to override prefix. For this, you can use `h-codegen:prefix:...` action.


Limitations
-------------------

- All Swift file names must be unique because `h-codegen` places all headers flat in the destination directory
- Xcode imports Swift objects even if they just inherit from NSObject. But for the `h-codegen` you should add @objc or @objcMembers to an object, that you want to import
- Destination directory should not contains other files
- `h-codegen` works only with xcodeproj or xcworkspace
