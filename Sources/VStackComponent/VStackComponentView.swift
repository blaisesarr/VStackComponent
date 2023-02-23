//
//  VStackComponentView.swift
//
//  Created by Blaise Sarr on 21/03/2022.
//

import UIKit

private typealias Style = VStackComponent.Style
private typealias Item = VStackComponent.Item
private typealias ViewAttributes = VStackComponent.ViewAttributes
private typealias ItemLayoutInfos = VStackComponent.ItemLayoutInfos
private typealias Spacing = VStackComponent.Spacing

public protocol VStackComponentViewInterface {
    func setItems(_ items: [VStackComponent.Item])
}

/// New vertical list componentView
public final class VStackComponentView: UIView, VStackComponentViewInterface {
    private enum Constant {
        static let animationDuration: TimeInterval = 0.3
    }
    
    private struct FlexibleSpaceInfos {
        let heightAnchor: NSLayoutDimension
        let factor: CGFloat
    }
    
    // MARK: - Properties

    private let style: Style

    private var itemsLayoutInfos: [ItemLayoutInfos] = []
    private var addedLayoutGuides: [UILayoutGuide] = []
    
    /// Helper used during flexible spaces building
    private var previousFlexibleSpaceInfos: FlexibleSpaceInfos?

    // MARK: - Init

    public init(style: VStackComponent.Style) {
        self.style = style
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - VStackComponentViewInterface
    
    public func setItems(_ items: [VStackComponent.Item]) {
        self.clear()
        self.appendItems(items)
    }
    
    // MARK: - Private
    
    private func appendItems(_ items: [Item]) {
        var previousItemBottomAnchor: NSLayoutYAxisAnchor?
        for (index, item) in items.enumerated() {
            let layoutInfos = self.appendItem(item,
                                              previousItemBottomAnchor: previousItemBottomAnchor,
                                              isLasItem: index == items.count - 1)
            previousItemBottomAnchor = layoutInfos.bottomAnchor
            self.itemsLayoutInfos.append(layoutInfos)
        }
        self.previousFlexibleSpaceInfos = nil
    }
    
    private func appendItem(_ item: Item,
                            previousItemBottomAnchor: NSLayoutYAxisAnchor?,
                            isLasItem: Bool) -> ItemLayoutInfos {
        switch item {
        case .view(let view, let attributes):
            return self.appendView(view,
                                   attributes: attributes,
                                   previousItemBottomAnchor: previousItemBottomAnchor,
                                   isLasItem: isLasItem)
        case .spacing(let spacing):
            return self.appendSpacing(spacing,
                                      previousItemBottomAnchor: previousItemBottomAnchor,
                                      isLasItem: isLasItem)
        }
    }
    
    private func appendView(_ view: UIView,
                            attributes: ViewAttributes,
                            previousItemBottomAnchor: NSLayoutYAxisAnchor?,
                            isLasItem: Bool) -> ItemLayoutInfos {
        let viewLayoutInfos = ItemLayoutInfos(item: .view(view, attributes: attributes), bottomAnchor: view.bottomAnchor)
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        viewLayoutInfos.otherConstraints = self.setupLayoutForView(view, attributes: attributes)
        if let previousItemBottomAnchor = previousItemBottomAnchor {
            view.topAnchor.constraint(equalTo: previousItemBottomAnchor).isActive = true
        } else {
            view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        }
        if isLasItem {
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
        return viewLayoutInfos
    }
    
    private func appendSpacing(_ spacing: Spacing,
                               previousItemBottomAnchor: NSLayoutYAxisAnchor?,
                               isLasItem: Bool) -> ItemLayoutInfos {
        let layoutGuide = UILayoutGuide()
        self.addLayoutGuide(layoutGuide)
        self.addedLayoutGuides.append(layoutGuide)
        let spacingLayoutInfos = ItemLayoutInfos(item: .spacing(spacing), bottomAnchor: layoutGuide.bottomAnchor)
        
        switch spacing {
        case .`default`:
            layoutGuide.heightAnchor.constraint(equalToConstant: self.style.defaultSpacing).isActive = true
        case .absolute(let absoluteSpacing):
            layoutGuide.heightAnchor.constraint(equalToConstant: absoluteSpacing).isActive = true
        case .relative(let relativeSpacing):
            layoutGuide.heightAnchor.constraint(equalToConstant: self.style.defaultSpacing + relativeSpacing).isActive = true
        case .flexible(let factor):
            let flexibleSpacingInfos = FlexibleSpaceInfos(heightAnchor: layoutGuide.heightAnchor, factor: factor)
            if let previousFlexibleSpaceInfos = self.previousFlexibleSpaceInfos {
                let multiplier = flexibleSpacingInfos.factor / previousFlexibleSpaceInfos.factor
                flexibleSpacingInfos.heightAnchor.constraint(equalTo: previousFlexibleSpaceInfos.heightAnchor, multiplier: multiplier).isActive = true
            }
            self.previousFlexibleSpaceInfos = flexibleSpacingInfos
        }
        if let previousItemBottomAnchor = previousItemBottomAnchor {
            layoutGuide.topAnchor.constraint(equalTo: previousItemBottomAnchor).isActive = true
        } else {
            layoutGuide.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        }
        if isLasItem {
            layoutGuide.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        
        return spacingLayoutInfos
    }
    
    private func setupLayoutForView(_ view: UIView, attributes: ViewAttributes) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        
        let processConstraint: (NSLayoutConstraint) -> Void = { constraint in
            constraint.isActive = true
            constraints.append(constraint)
        }

        let size = attributes.size
        let alignment = attributes.alignment ?? self.style.alignment

        if let width = size?.width {
            switch width {
            case .fractional(let fractionalWidth):
                processConstraint(view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: fractionalWidth))
            case .absolute(let absoluteWidth):
                processConstraint(view.widthAnchor.constraint(equalToConstant: absoluteWidth))
            case .fill:
                guard case .center = alignment else {
                    fatalError("fill can only be used with a center alignment")
                }
                
                processConstraint(view.widthAnchor.constraint(equalTo: self.widthAnchor))
            case .fillWithMargin(let margin):
                guard case .center = alignment else {
                    fatalError("fillWithMargin can only be used with a center alignment")
                }

                processConstraint(view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin))
            case .minMargin(let minMargin):
                guard case .center = alignment else {
                    fatalError("minMargin can only be used with a center alignment")
                }
                
                processConstraint(view.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: minMargin))
            }
        }

        if let height = size?.height {
            switch height {
            case .fractional(let fractionalHeight):
                processConstraint(view.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: fractionalHeight))
            case .absolute(let absoluteHeight):
                processConstraint(view.heightAnchor.constraint(equalToConstant: absoluteHeight))
            case .fill:
                processConstraint(view.heightAnchor.constraint(equalTo: self.heightAnchor))
            case .fillWithMargin:
                fatalError("fillWithMargin can only be used for width")
            case .minMargin:
                fatalError("minMargin can only be used for width")
            }
        }

        switch alignment {
        case .leading(let margin, let defaultTrailingConstraint):
            processConstraint(view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin))
            if defaultTrailingConstraint {
                processConstraint(view.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -margin))
            }
        case .center:
            processConstraint(view.centerXAnchor.constraint(equalTo: self.centerXAnchor))
        case .trailing(let margin, let defaultLeadingConstraint):
            processConstraint(view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margin))
            if defaultLeadingConstraint {
                processConstraint(view.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: margin))
            }
        }
        
        return constraints
    }

    func clear() {
        self.itemsLayoutInfos.forEach { layoutInfos in
            layoutInfos.otherConstraints.forEach { constraint in
                constraint.isActive = false
            }
        }
        self.subviews.forEach { $0.removeFromSuperview() }
        self.addedLayoutGuides.forEach { self.removeLayoutGuide($0) }
        self.itemsLayoutInfos = []
        self.addedLayoutGuides = []
        self.previousFlexibleSpaceInfos = nil
    }
}
