//
//  ListCell.swift
//  Searchable
//
//  Created by Wesley Byrne on 8/15/17.
//  Copyright © 2017 WCBMedia. All rights reserved.
//

import Foundation
import AppKit
import CollectionView

extension NSView {
    @discardableResult func addSizeConstraints(_ size: NSSize) -> (width: NSLayoutConstraint?, height: NSLayoutConstraint?) {
        var width: NSLayoutConstraint?
        var height: NSLayoutConstraint?
        
        if size.width > 0 {
            width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.width)
            self.addConstraint(width!)
        }
        if size.height > 0 {
            height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.height)
            self.addConstraint(height!)
        }
        return (width, height)
    }

}


func ==(a: ListCell.SeperatorStyle, b: ListCell.SeperatorStyle) -> Bool {
    switch (a, b) {
    case (.none, .none): return true
    case (.default, .default): return true
    case (.full, .full): return true
    case (.custom(_, _), .custom(_, _)): return true
    default: return false
    }
}

func CGSizeIsEmpty(_ size: CGSize?) -> Bool {
    guard let s = size else { return true }
    if s.width <= 0 || s.height <= 0 { return true }
    return false
}



class ListCell : CollectionViewCell {
    
    let titleLabel = NSTextField(frame: NSZeroRect)
    
    var inset : CGFloat = 12
    //    override var wantsUpdateLayer: Bool { return seperatorStyle == SeperatorStyle.None }
    
    lazy var detailLabel : NSTextField = {
        let label = NSTextField(frame: NSZeroRect)
        label.usesSingleLineMode = true
        label.drawsBackground = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = NSColor.clear
        label.isEditable = false
        label.isSelectable = false
        label.isBordered = false
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    lazy var imageView : NSImageView = {
        let iv =  NSImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var imageSize: CGSize = CGSize.zero
    var seperatorStyle: SeperatorStyle = .default
    var seperatorColor : NSColor = NSColor(white: 0, alpha: 0.05)
    var seperatorWidth: CGFloat = 2
    
    enum SeperatorStyle {
        case none
        case `default`
        case full
        case custom(left: CGFloat, right: CGFloat)
    }
    
    
    enum Style {
        case basic
        case basicImage
        case subtitle
        case subtitleImage
        case titleDetail
        case split
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    var highlightedBackgroundColor : NSColor?
    var restingBackgroundColor: NSColor = NSColor.clear {
        didSet {
            if !self.highlighted {
                self.backgroundColor = restingBackgroundColor
            }
        }
    }
    
    /// If true, highlighting the cell does not change it's appearance
    var disableHighlight : Bool = false
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        
        if disableHighlight { return }
        if highlighted, let hbg = self.highlightedBackgroundColor {
            self.backgroundColor = hbg
        }
        else {
            self.backgroundColor = restingBackgroundColor
        }
        self.needsDisplay = true
    }
    
    init() {
        super.init(frame: NSZeroRect)
        self.addSubview(titleLabel)
        titleLabel.usesSingleLineMode = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.drawsBackground = false
        titleLabel.backgroundColor = NSColor.clear
        titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.isSelectable = false
        
        self.addSubview(titleLabel)
        self.setupForStyle(.basic)
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    var style : Style = .basic {
        didSet {
            if style == oldValue { return }
            self.setupForStyle(style)
        }
    }
    
    
    fileprivate func setupForStyle(_ style: Style) {
        
        self.removeConstraints(self.constraints)
        
        switch style {
        case .basic, .basicImage:
            detailLabel.removeFromSuperview()
            
            titleLabel.alignment = .left
            titleLabel.font = NSFont.systemFont(ofSize:13)
            titleLabel.textColor = NSColor.darkGray
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: titleLabel, attribute: .right, multiplier: 1, constant: inset))
            
            if style == .basicImage {
                let iv = self.imageView
                iv.removeFromSuperview()
                self.addSubview(iv)
                iv.removeConstraints(iv.constraints)
                
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: iv, attribute: .left, multiplier: 1, constant: -inset))
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: iv, attribute: .centerY, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .lessThanOrEqual, toItem: iv, attribute: .top, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: iv, attribute: .bottom, multiplier: 1, constant: 0))
                
                self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: iv, attribute: .right, multiplier: 1, constant: 6))
                if CGSizeIsEmpty(self.imageSize) == false {
                    iv.addSizeConstraints(self.imageSize)
                }
                else {
                    iv.addConstraint(NSLayoutConstraint(item: iv, attribute: .width, relatedBy: .equal, toItem: iv, attribute: .height, multiplier: 1, constant: 0))
                }
            }
            else {
                imageView.removeFromSuperview()
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: titleLabel, attribute: .left, multiplier: 1, constant: -inset))
            }
            
            
        case .subtitle, .subtitleImage:
            
            self.addSubview(detailLabel)
            
            titleLabel.alignment = .left
            titleLabel.font = NSFont.systemFont(ofSize:13)
            titleLabel.textColor = NSColor.darkGray
            
            detailLabel.alignment = .left
            detailLabel.font = NSFont.systemFont(ofSize: 13)
            detailLabel.textColor = NSColor.gray
            
            self.titleLabel.setContentCompressionResistancePriority(200, for: .horizontal)
            self.detailLabel.setContentCompressionResistancePriority(200, for: .horizontal)
            
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: titleLabel, attribute: .right, multiplier: 1, constant: inset))
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .lastBaseline, multiplier: 1, constant: 1))
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: detailLabel, attribute: .right, multiplier: 1, constant: inset))
            self.addConstraint(NSLayoutConstraint(item: detailLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: detailLabel, attribute: .left, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: detailLabel, attribute: .right, multiplier: 1, constant: 0))
            
            if style == .subtitleImage {
                let iv = self.imageView
                self.addSubview(iv)
                iv.removeConstraints(iv.constraints)
                
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: iv, attribute: .left, multiplier: 1, constant: -inset))
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: iv, attribute: .centerY, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .lessThanOrEqual, toItem: iv, attribute: .top, multiplier: 1, constant: 0))
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: iv, attribute: .bottom, multiplier: 1, constant: 0))
                
                self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: iv, attribute: .right, multiplier: 1, constant: 6))
                if CGSizeIsEmpty(self.imageSize) == false {
                    iv.addSizeConstraints(self.imageSize)
                }
                else {
                    iv.addConstraint(NSLayoutConstraint(item: iv, attribute: .width, relatedBy: .equal, toItem: iv, attribute: .height, multiplier: 1, constant: 0))
                }
            }
            else {
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: titleLabel, attribute: .left, multiplier: 1, constant: -inset))
            }
            
        case .split:
            imageView.removeFromSuperview()
            
            self.addSubview(detailLabel)
            
            titleLabel.alignment = .left
            titleLabel.font = NSFont.systemFont(ofSize:11)
            titleLabel.textColor = NSColor.gray
            
            detailLabel.alignment = .right
            detailLabel.font = NSFont.systemFont(ofSize:11)
            detailLabel.textColor = NSColor.darkGray
            
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: titleLabel, attribute: .left, multiplier: 1, constant: -inset))
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: titleLabel, attribute: .centerY, multiplier: 1, constant: 0))
            
            
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: detailLabel, attribute: .centerY, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: detailLabel, attribute: .right, multiplier: 1, constant: inset))
            
            self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: detailLabel, attribute: .left, multiplier: 1, constant: -2))
            
            self.titleLabel.setContentCompressionResistancePriority(400, for: .horizontal)
            self.detailLabel.setContentCompressionResistancePriority(350, for: .horizontal)
            
            
        case .titleDetail:
            
            imageView.removeFromSuperview()
            self.addSubview(detailLabel)
            
            titleLabel.alignment = .right
            titleLabel.font = NSFont.systemFont(ofSize:11)
            titleLabel.textColor = NSColor.lightGray
            
            detailLabel.alignment = .left
            detailLabel.font = NSFont.systemFont(ofSize:12)
            detailLabel.textColor = NSColor.darkGray
            
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: titleLabel, attribute: .left, multiplier: 1, constant: -inset))
            if #available(OSX 10.11, *) {
                self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .firstBaseline, relatedBy: .equal, toItem: detailLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
            } else {
                self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: detailLabel, attribute: .centerY, multiplier: 1, constant: 0))
            }
            self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
            
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: detailLabel, attribute: .right, multiplier: 1, constant: inset))
            self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: detailLabel, attribute: .centerY, multiplier: 1, constant: 0))
            
            self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: detailLabel, attribute: .left, multiplier: 1, constant: -4))
            
            self.titleLabel.setContentCompressionResistancePriority(400, for: .horizontal)
            self.detailLabel.setContentCompressionResistancePriority(400, for: .horizontal)
            
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if (highlighted && !disableHighlight) || seperatorStyle == .none {
            return
        }
        
        let ctx = NSGraphicsContext.current()?.cgContext
        switch seperatorStyle {
            
        case .full:
            ctx?.move(to: CGPoint(x: 0, y: 0))
            ctx?.addLine(to: CGPoint(x: self.bounds.maxX, y: 0))
            
        case let .custom(left, right):
            ctx?.move(to: CGPoint(x: left, y: 0))
            ctx?.addLine(to: CGPoint(x: self.bounds.maxX - right, y: 0))
        default:
            ctx?.move(to: CGPoint(x: self.titleLabel.frame.minX, y: 0))
            ctx?.addLine(to: CGPoint(x: self.bounds.maxX, y: 0))
        }
        
        ctx?.setStrokeColor(self.seperatorColor.cgColor)
        ctx?.setLineWidth(self.seperatorWidth)
        
        ctx?.strokePath()
        NSGraphicsContext.restoreGraphicsState()
    }
    
    
    
}
