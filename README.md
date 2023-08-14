
# CImple

CImple is a SwiftUI package designed to simplify the usage of Core Image filters (CIFilters) within your SwiftUI projects. It provides a set of convenient extensions and utility functions that make it easy to apply and chain CIFilters to images in a declarative and intuitive way.

<table>
<tr> <td>CImple</td> <td>CIFilter (CIFilterBuiltins)</td> </tr>

<tr> 
<td>

```Swift
Image("inputImage")
    .filters() {
        CIFilter.colorInvert()
        CIFilter.gaussianBlur().params([
         kCIInputRadiusKey: 20
    ])
    CIFilter.bloom().params([
        kCIInputIntensityKey: 0.5,
        kCIInputRadiusKey: 10
    ])
}
```

</td> 
<td>

```Swift
Image(uiImage: uiImg!)
    .onAppear {
        let ciImage = CIImage(image: uiImg!)
        
        let invertFilter = CIFilter.colorInvert()
        invertFilter.inputImage = ciImage
        guard let invertOutput = invertFilter.outputImage else {
            return
        }
        
        let gaussianFilter = CIFilter.gaussianBlur()
        gaussianFilter.inputImage = invertOutput
        gaussianFilter.radius = 20
        guard let gaussianOutput = gaussianFilter.outputImage else {
            return
        }
        
        let bloomFilter = CIFilter.bloom()
        bloomFilter.inputImage = invertOutput
        bloomFilter.intensity = 0.5
        bloomFilter.radius = 10
        guard let bloomOutput = bloomFilter.outputImage else {
            return
        }
        
        guard let cgImage = CIContext(options: nil).createCGImage(bloomOutput, from: bloomOutput.extent) else {
            return
        }
        
        uiImg = UIImage(cgImage: cgImage)
    }
```

</td> 
</tr>

</table>




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
