<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->
# architecture_linter

Package architecture_linter helps you to keep your project right order. You can specify many rules (described below) that will be checked for suggestions and displayed in form of useful lints in your favorite IDE. 

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

Add configuration to `analysis_options.yaml` file. You can start with predefined one:
```YAML
architecture_linter:
  layers:
    - &infrastructureLayer
      name: "Infrastructure"
      pathRegex:
        source: "(infrastructure)"
    - &domainLayer
      name: "Domain"
      pathRegex:
        source: "(domain)"
    - &presentationLayer
      name: "Presentation"
      pathRegex:
        source: "(presentation)"
    - &useCaseLayer
      name: "Domain/UseCases"
      pathRegex:
        source: "(domain/use_cases)"
    - &utils
      name: "Utils"
      pathRegex:
        source: "(utils)"
    - &infrastructureLayer
      name: "Infrastructure"
      pathRegex:
        source: "(infrastructure)"

  bannedImports:
    - layer: *domainLayer
      banned:
        - *presentationLayer
        - *useCaseLayer
        - *infrastructureLayer
    - layer: *presentationLayer
      banned:
        - *infrastructureLayer
    - layer: *infrastructureLayer
      banned:
        - *useCaseLayer
        - *presentationLayer
    - layer: *useCaseLayer
      banned:
        - *presentationLayer
        - *infrastructureLayer
```

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
