//
//  NSButton+CreateCustomButton.swift
//  AssignmentOnTableViews
//
//  Created by Smitha Ramamurthy on 19/03/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

import Cocoa

extension NSButton {

    convenience init(image: String, target: Any, action: Selector, ofSize size: CGSize, withTag tag: Int) {
        self.init()
        if let image = NSImage(named: NSImage.Name(rawValue: image)) {
            self.image = image
            self.isBordered = false
            self.setButtonType(.momentaryChange)
        } else {
            self.image = NSImage()
            self.isBordered = true
            self.setButtonType(.pushOnPushOff)
        }
        self.target = target as AnyObject
        self.action = action
        self.imageScaling = .scaleProportionallyDown
        var buttonframe = self.frame
        buttonframe.size = size
        self.frame = buttonframe
        self.tag = tag
    }
}
