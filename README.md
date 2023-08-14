
# CImple

CImple is a SwiftUI package designed to simplify the usage of Core Image filters (CIFilters) within your SwiftUI projects. It provides a set of convenient extensions and utility functions that make it easy to apply and chain CIFilters to images in a declarative and intuitive way.






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

First thing to know

The main func is `.filters()`. <br>It can apply CIFilters directly onto Image() inside body. If other image passed as parameter, it would be used instead. Closure accepts as variadic param `CIFilter...`, so as `[CIFilter]`, and combination of both of them:

```Swift
Image("your-image")
    .filters(/* optional image here */) {
        [
            CIFilter.colorInvert(),
            CIFilter.gaussianBlur()
        ]
        CIFilter.bloom()
        CIFilter.vignette()
        // ...
    }
    .resizable()
    .scaledToFit()
```

>[!Note]
>Make sure to apply filters before any image modifier.
>```.filter() {
>CIFilter.colorInvert() 
>}
>```

Beside using func inside view, it can apply filters on variables.

```Swift
@State var uiImg = UIImage(named: "your-image")

var body: some View {
    Image(uiImage: uiImg!)

}
```

### Closure

It accepts:





Or addressed by calling `CImple()` struct:

```Swift
struct ContentView: View {
    var body: some View {
        Image("your-image")
            .filters() {

            }
    }
}
```
