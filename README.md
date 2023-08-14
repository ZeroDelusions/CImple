
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

The main func is `.filters()`. <br>It can apply CIFilters directly onto Image() inside body, on its appearence. If other image passed as parameter, it would be used instead and assigned to Image(). Closure accepts as variadic param `CIFilter...`, so as `[CIFilter]`, and combination of both of them:

```Swift
Image("your-image")
    .filters(/* optionally image here */) {
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
>Make sure to apply `.filters()` before any image modifier, like `.resizable()`, ect.

Beside using func inside view, it can apply filters on variables.

<table>
<tr>
<td>

```Swift
@State var uiImg = UIImage(named: "your-image")

var body: some View {
    Image(uiImage: uiImg!)
        .resizable()
        .scaledToFit()
    
    Button("Apply filters) {
        uiImg = uiImg.filters {
            CIFilter.colorInvert()
        }
    }
}
``` 

</td>
<td>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/ZeroDelusions/CImple/assets/121663433/2a9706ee-1bd0-42f7-8cff-6509a083206c">
  <img alt="Shows an illustrated sun in light color mode and a moon with stars in dark color mode." src="https://user-images.githubusercontent.com/25423296/163456779-a8556205-d0a5-45e2-ac17-42d089e3c3f8.png">
</picture>

</td>
</tr>
</table>

>[!Note]
> hh

