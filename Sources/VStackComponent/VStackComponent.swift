//
//  VStackComponent.swift
//
//  Created by Blaise Sarr on 21/03/2022.
//

import UIKit

/// Enumeration used to wrap structures used
/// in VStackComponentView

// swiftlint:disable nesting
public enum VStackComponent {
    /// default alignment of items in the stack
    // `defaultXXXConstraint` Shoould be set to true later
    public enum Alignment {
        case leading(margin: CGFloat = 0, defaultTrailingConstraint: Bool = true)
        case center
        case trailing(margin: CGFloat = 0, defaultLeadingConstraint: Bool = true)
    }

    public struct Style {
        /// Components alignment in the list
        let alignment: Alignment
        
        /// Default spacing for items
        let defaultSpacing: CGFloat
        
        public init(alignment: Alignment, defaultSpacing: CGFloat) {
            self.alignment = alignment
            self.defaultSpacing = defaultSpacing
        }
    }

    /// A dimension for an item, can be width or height
    public enum Dimension {
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

    /// Spacing between items
    public enum Spacing {
        /// Use the default `defaultSpacing` of the global style
        case `default`

        /// Use this case to set an absolute spacing and ignore the global `defaultSpacing`
        case absolute(_ absoluteSpacing: CGFloat)

        /// Use this case to set a relative spacing based on the `defaultSpacing`
        /// `finalSpacing` = `defaultSpacing` + `relativeSpacing`
        case relative(_ relativeSpacing: CGFloat)
        
        /// This a flexible spacing, a spacing which depends on the remaining size and
        /// all other fexible spacing configured
        case flexible(_ factor: CGFloat)
        
        static let none: Spacing = .absolute(0)
    }

    /// Item size, you can specify nil if you don't want
    /// to set constraints for a dimension
    public struct ItemSize {
        let width: Dimension?
        let height: Dimension?
        
        public init(width: Dimension? = nil, height: Dimension? = nil) {
            self.width = width
            self.height = height
        }
        
        public init(size: CGSize) {
            self.init(width: .absolute(size.width), height: .absolute(size.height))
        }
    }

    /// Attribute of a view
    public struct ViewAttributes {
        let size: ItemSize?
        /// nil value means we use the default alignment of the list
        let alignment: Alignment?

        public init(size: ItemSize?, alignment: Alignment? = nil) {
            self.size = size
            self.alignment = alignment
        }
        
        public init(size: CGSize, alignment: Alignment? = nil) {
            self.size = .init(size: size)
            self.alignment = alignment
        }
    }
    
    public enum Item {
        case view(_ view: UIView, attributes: ViewAttributes = .init(size: nil))
        case spacing(_ spacing: Spacing)
    }

    class ItemLayoutInfos {
        let item: Item
        
        /// Used by the next item to set constraints to the previous item
        let bottomAnchor: NSLayoutYAxisAnchor
        
        /// This var will hold other constraints like width, height, center, leading etc... added by the list
        var otherConstraints: [NSLayoutConstraint] = []

        init(item: Item, bottomAnchor: NSLayoutYAxisAnchor) {
            self.item = item
            self.bottomAnchor = bottomAnchor
        }
    }
}
