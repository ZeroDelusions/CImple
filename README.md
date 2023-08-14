
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

First thing to know

The main func is `.filters()`:

```Swift
Image("your-image")
    .filters(/* optional image */) {
        // Here you place CIFilters
    }
```
> It can apply CIFilters directly onto Image(). If image passed as parameter, it would use it instead.

### Closure

It accepts:

<table>
<tr>
<td> CIFilter... </td> <td> [CIFilter] </td> <td> [CIFilter] + CIFilter... </td>
</tr>
<tr>
<td> 

```Swift
    .filters() {
        CIFilter.colorInvert()
        CIFilter.gaussianBlur()
    }
```

</td>
<td>

```Swift
    .filters() {
        [
            CIFilter.colorInvert()
            CIFilter.gaussianBlur()
        ]
    }
```

</td>
<td>

```Swift
    .filters() {
        [
            CIFilter.colorInvert()
            CIFilter.gaussianBlur()
        ]
        CIFilter.bloom()
    }
```

</td>
</tr>
</table>



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
