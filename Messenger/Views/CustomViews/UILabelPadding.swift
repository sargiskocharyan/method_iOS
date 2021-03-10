//
//  UILabelPadding.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit


    class UILabelPadding: UILabel {

        let padding = UIEdgeInsets(top: 4, left: 13, bottom: 4, right: 13)
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: padding))
        }

        override var intrinsicContentSize : CGSize {
            let superContentSize = super.intrinsicContentSize
            let width = superContentSize.width + padding.left + padding.right
            let heigth = superContentSize.height + padding.top + padding.bottom
            return CGSize(width: width, height: heigth)
        }

        
    }

class PaddingLabel: UILabel {
    var textEdgeInsets = UIEdgeInsets.zero {
            didSet { invalidateIntrinsicContentSize() }
        }
        
        open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
            let insetRect = bounds.inset(by: textEdgeInsets)
            let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
            let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
            return textRect.inset(by: invertedInsets)
        }
        
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: textEdgeInsets))
        }
        
        @IBInspectable
        var paddingLeft: CGFloat {
            set { textEdgeInsets.left = newValue }
            get { return textEdgeInsets.left }
        }
        
        @IBInspectable
        var paddingRight: CGFloat {
            set { textEdgeInsets.right = newValue }
            get { return textEdgeInsets.right }
        }
        
        @IBInspectable
        var paddingTop: CGFloat {
            set { textEdgeInsets.top = newValue }
            get { return textEdgeInsets.top }
        }
        
        @IBInspectable
        var paddingBottom: CGFloat {
            set { textEdgeInsets.bottom = newValue }
            get { return textEdgeInsets.bottom }
        }

}

