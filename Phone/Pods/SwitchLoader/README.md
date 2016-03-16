![Loader](https://github.com/Ekhoo/Loader/blob/master/Source/Asset/Loader.png)

[![Version](https://img.shields.io/cocoapods/v/Loader.svg?style=flat)](http://cocoapods.org/pods/Loader)
[![License](https://img.shields.io/cocoapods/l/Loader.svg?style=flat)](http://cocoapods.org/pods/Loader)
[![Platform](https://img.shields.io/cocoapods/p/Loader.svg?style=flat)](http://cocoapods.org/pods/Loader)
![](https://img.shields.io/badge/Supported-iOS8-4BC51D.svg?style=flat-square)
![](https://img.shields.io/badge/Carthage-unavailable-red.svg?style=flat)
![](https://img.shields.io/badge/Swift 2-compatible-4BC51D.svg?style=flat-square)

Simple and light weight animated switch activity indicator. 

# Demo

![Loader](https://github.com/Ekhoo/Loader/blob/master/Source/Asset/Loader.gif)

# Installation
## Cocoapods
Loader is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Loader", '~> 0.0.1'
```

# Usage
```swift
func myFunc() {
    let loader: Loader = Loader(frame: CGRectMake(0.0, 0.0, 80.0, 40.0))
    
    self.view.addSubView(loader)
    
    loader.startAnimating()
}
```

## Interface
```swift
public func startAnimating() // Animate the switch activity indicator
public func stoptAnimating() // Stop Animating the switch activity indicator
```

# Author
Lucas Ortis:
- me@lucas-ortis.com
- [@LucasEkhoo](https://twitter.com/LucasEkhoo)
- [Linkedin](https://fr.linkedin.com/in/lucasortis)

# License

Inspired from this [Dribbble](https://dribbble.com/shots/2389529-Like-a-preloader) project.
Loader is available under the MIT license. See the LICENSE file for more info.
