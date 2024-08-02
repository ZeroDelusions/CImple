
# CImple

CImple is a SwiftUI package designed to simplify the usage of Core Image filters (CIFilters) within your SwiftUI projects. It provides a set of convenient extensions and utility functions that make it easy to apply and chain CIFilters to images in a declarative and intuitive way.






## Features

- Easy to understand syntax
- Custom infix operators
- Live update of image applying filters


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
```

It's possible to use flow statements inside `.filters()` closure:

```Swift
Image("your-image")
    .filters() {
        if applyFilters {
            // ...
        } else {
             // ...
        }
    }
```

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
    
    Button("Apply filters") {
        uiImg = uiImg?.filters {
            CIFilter.colorInvert()
        }
    }
}
``` 

</td>
<td>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/a498745f-9d0f-4498-8647-69ab5a6909d3">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/0af0fe02-9929-4832-8f34-d9c6f9a08417">
  <img src="https://github.com/user-attachments/assets/a498745f-9d0f-4498-8647-69ab5a6909d3">
</picture>
</td>
</tr>

</table>

>[!Warning]
>Applying filters that 'extend' size of image, like `.gaussianBlur()`, `.bloom()`, ect, on `@State` and assign it to itself will result in gradual decrease of image, like in case of 
>```Swift
>@State var uiImg = UIImage(named: "your-image")
>//...
>uiImg = uiImg?.filters() {
>    CIFilter.gaussianBlur()
>}
>```

### Filter parameters

Parameters are applied by using `.params()` as extension to CIFilter. List of keys you can find on <a href="https://developer.apple.com/documentation/coreimage/cifilter/filter_parameter_keys">official Apple website</a>

```Swift
CIFilter.bloom().params([
    kCIInputImageKey: invertAndBlur,
    kCIInputIntensityKey: 0.5,
    kCIInputRadiusKey: 20
])
```

>[!Note]
>`kCIInputImageKey` passed to filter will override input for `.filters()` or `.chain()` funcs.

### Chaining syntax

CImple provides more advanced syntax for cases when it's needed to 'save' result of CIFilters for later usage. `.chain()` function works by the same rules as `.filters()`

```Swift
uiImg = CImple().filters() {
    let invertAndBlur = uiImg.chain() {
        CIFilter.colorInvert()
        CIFilter.gaussianBlur()
    }
    let bloom = invertAndBlur.chain() {
        CIFilter.bloom().params([
            kCIInputIntensityKey: 0.5,
            kCIInputRadiusKey: 20
        ])
    } 
    return bloom
}
```

>[!Note]
>Result of chain could also be used as parameter for singular filter outside of chain. Then there is no need for `return`
> ```Swift
>   //...
>   CIFilter.bloom().params([
>       kCIInputImageKey: invertAndBlur,
>       kCIInputIntensityKey: 0.5,
>       kCIInputRadiusKey: 20
>   ])
>}
>```

### Custom operators

<table>
<tr>
<td>Operator</td>
<td>Functionality</td>
</tr>

<tr>
<td>=></td>
<td>

Apply `CIFilter` or `[CIFilter]` to image, returns `UIImage` (lhs: background, rhs: input) \
`image => [CIFilter.colorInvert(), CIFilter.gaussianBlur()]`

</td>
</tr>

<tr>
<td>=>></td>
<td>

Apply `CIFilter` or `[CIFilter]` to image, returns input type (lhs: background, rhs: input) \
`image => [CIFilter.colorInvert(), CIFilter.gaussianBlur()]`

</td>
</tr>

<tr>
<td>+</td>
<td>

Combine two images using `.sourceOverCompositing()` (lhs: background, rhs: input) \
`image = image + uiImage`

</td>
</tr>

<tr>
<td>-</td>
<td>

Combine two images using `.sourceOutCompositing()` (lhs: background, rhs: input) \
`image = image - uiImage`

</td>
</tr>

<tr>
<td><+></td>
<td>

Combine two images using `.sourceAtopCompositing()` (lhs: background, rhs: input) \
`image = image <+> uiImage`

</td>
</tr>

<tr>
<td><-></td>
<td>

Combine two images using `.sourceInCompositing()` (lhs: background, rhs: input) \
`image = image <-> uiImage`

</td>
</tr>
</table>

