[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?color=ff69b4)](https://github.com/blaisesarr/VStackComponent/blob/main/LICENCE)

# VStackComponent

A `UIKit` component that can be used to easily arrange items in a stack and which provide various options like `flexible` for flexible space depending on available space which is very useful sometimes.

Here is an example:

```swift
import VStackComponent

let vStackComponent = VStackComponentView(style: .init(alignment: .center, defaultSpacing: 0))

let items: [VStackComponent.Item] = [
    .spacing(.flexible(1)),
    .view(self.logoImageView),
    .spacing(.flexible(3)),
    .view(self.titleLabel,
          attributes: .init(
            size: .init(width: .fillWithMargin(20), height: nil),
            alignment: .trailing(margin: 5)
          )
         ),
    .spacing(.absolute(20)),
    .view(self.verifyButton,
          attributes: .init(
            size: .init(width: .fillWithMargin(20), height: nil),
            alignment: .trailing(margin: 5)
          )
         ),
    .spacing(.flexible(2))
]

vStackComponent.setItems(items)
```

In this example, when adding a space item, we have `.flexible(1)` items which allow us to create flexible spaces, `.flexible(2)` will have 2 times more space than `.flexible(1)`. we also have `.absolute(20)` which are absolute spaces.

All available spaces are defined here:

```swift
enum Spacing {
    /// Use the default `defaultSpacing` of the global style
    case `default`

    /// Use this case to set an absolute spacing and ignore the global `defaultSpacing`
    case absolute(_ absoluteSpacing: CGFloat)

    /// Use this case to set a relative spacing based on the `defaultSpacing`
    /// `finalSpacing` = `defaultSpacing` + `relativeSpacing`
    case relative(_ relativeSpacing: CGFloat)
    
    /// This a flexible spacing, a spacing which depends on the remaining space and
    /// all other fexible spacing configured
    case flexible(_ factor: CGFloat)
    
    static let none: Spacing = .absolute(0)
}
```

When adding an item, you can specify attributes like `size` and `alignment`.

A Dimension (for `width` or `height`) can be specified with a very simple syntax with one of the following values or nil if there is no dimension to specify:

```swift
/// A dimension for an item, can be width or height
enum Dimension {
    /// The dimension is computed as a fraction of the list dimension
    /// 1.0 means the list size and 0.5 means the half of the list size
    case fractional(_ fractionalDimension: CGFloat)

    /// The absolute value of the dimension
    case absolute(_ absoluteDimension: CGFloat)

    /// Fill means the list size, equivalent to `fractional(1.0)`
    case fill

    /// Can only be used when alignment is `center`. View will use the component size with the specified margin for each side.
    case fillWithMargin(_ margin: CGFloat)
    
    /// This will add a greaterThanOrEquaTo constraint (or lessThat)
    case minMargin(_ minMargin: CGFloat)
}
```
