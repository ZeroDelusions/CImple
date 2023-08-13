
# CImple

CImple is a SwiftUI package for simplifying CIFilter usage.




## Features

- Different 
- Live previews
- Fullscreen mode
- Cross platform


## Begin using

In **Xcode:**

File → Swift Packages → Add Package Dependency: https://github.com/ZeroDelusions/CImple.git

In **Swift Packages:**

```Swift
.package(url: "https://github.com/ZeroDelusions/CImple.git", from: "0.0.1")
```

Then add into your SwiftUI project:

```Swift
import CImple
```
## Documentation

With CImple, you have a variety of options to choose from for implementing the usage of CIFilters.

The main and basic way is to use:

```Swift
.filters() {
    // Here you place CIFilters
}
```

<p align="center">
  Yexyyx
</p>

```Swift
struct ContentView: View {
    var body: some View {
        Image("your-image")
            .filters() {

            }
    }
}
```
