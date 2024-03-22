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

Package architecture_linter helps you to keep your project right order. You can specify many rules (described below)
that will be checked for suggestions and displayed in form of useful lints in your favorite IDE.

## Installation

```sh
$ dart pub add --dev architecture_linter

# or for a Flutter package
$ flutter pub add --dev architecture_linter
```

## OR

add it manually to `pubspec.yaml`

```yaml
dev_dependencies:
  architecture_linter: ^0.1.0
```

and then run

```sh
$ dart pub get

# or for a Flutter package
$ flutter pub get
```

## Add plugin to analyzer

Add this fragment to `analysis_option.yaml` so analyzer can use plugin:

```yaml

analyzer:
  plugins:
    - architecture_linter
```

## Basic configuration

Add configuration to `analysis_options.yaml` file. You can start with predefined one:

```YAML
architecture_linter:
  excludes:
    - "**.g.dart"

  lint_severity: warning

  layers:
    - &infrastructureLayer
      name: "Infrastructure"
      path: "(infrastructure)"
    - &domainLayer
      name: "Domain"
      path: "(domain)"
    - &presentationLayer
      name: "Presentation"
      path: "(presentation)"
    - &useCaseLayer
      name: "Domain/UseCases"
      path: "(domain/use_cases)"
    - &utils
      name: "Utils"
      path: "(utils)"
    - &repository
      name: "repository"
      path: "(repository)"

  layers_config:
    - layer: *repository
      severity: error

  banned_imports:
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

## Configuring lint severity:

To change lint severity for whole plugin add `lint_severity` entry in `analysis_options.yaml` under `architecture_linter`
with one of three values:

- `info`
- `warning`
- `error`

For example:
```YAML
lint_severity: error
```

You can also configure severity for lower level layer which is under already defined banned layer 


For example:

```YAML
  lint_severity: warning

  layers:
    - &domainLayer
      name: "Domain"
      path: "(domain)"
    - &presentationLayer
      name: "Presentation"
      path: "(presentation)"
    - &repository
      name: "repository"
      path: "(repository)"
    - &useCaseLayer
      name: "Domain/UseCases"
      path: "(domain/use_cases)"

  layers_config:
    - layer: *repository
      severity: error
    - layer: *infrastructureLayer
      severity: error
  
  banned_imports:
    - layer: *presentationLayer
      banned:
        - *domainLayer
    - layer: *useCaseLayer
      # You can also ban same origin layers
      banned:
        - *domainLayer
    - layer: *infrastructureLayer
      # You can also specify severity per layer
      severity: info
      banned:
        - *domainLayer
```
With this configuration, if `repository` under `domain` folder has been imported to `presentationLayer`
the lint would be displayed as `error`.

An import of any file from `domain` to `infrastructureLayer` will result in lint alert of
severity `info` despite of `layers_config` setting.

## CLI:

Package also supports CLI, run it with: 

```sh
$ dart run architecture_linter:analyzer analyze lib 

# or for a Flutter package
$ flutter pub run architecture_linter:analyzer analyze lib
```
You can also configure severity for which analyzer will have `exit code 2`, for example:

```sh
# Defaults to warning 
$ dart run architecture_linter:analyzer analyze lib --set-exit-on-severity-level=info

```
Then analyzer will exit with `code 2` when `info` or higher level inconsistencies (`error`, `warning`) have been found. 
