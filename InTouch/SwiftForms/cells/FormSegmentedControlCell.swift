//
//  FormSegmentedControlCell.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 21/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormSegmentedControlCell: FormBaseCell {
    
    // MARK: Cell views
    
    open let titleLabel = UILabel()
    open let segmentedControl = UISegmentedControl()
    
    // MARK: Properties
    
    fileprivate var customConstraints: [AnyObject]!
    
    // MARK: FormBaseCell
    
    open override func configure() {
        super.configure()
        
        selectionStyle = .none
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.setContentCompressionResistancePriority(500, for: .horizontal)
        segmentedControl.setContentCompressionResistancePriority(500, for: .horizontal)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(segmentedControl)
        
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        segmentedControl.addTarget(self, action: #selector(FormSegmentedControlCell.valueChanged(_:)), for: .valueChanged)
    }
    
    open override func update() {
        super.update()
        
        titleLabel.text = rowDescriptor.title
        updateSegmentedControl()
        
        var idx = 0
        if rowDescriptor.value != nil {
            if let options = rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as? NSArray {
                for optionValue in options {
                    if optionValue as? NSObject == rowDescriptor.value {
                        segmentedControl.selectedSegmentIndex = idx
                        break
                    }
                    idx += 1
                }
            }
        }
    }
    
    open override func constraintsViews() -> [String : UIView] {
        return ["titleLabel" : titleLabel, "segmentedControl" : segmentedControl]
    }
    
    open override func defaultVisualConstraints() -> [String] {
        
        if titleLabel.text != nil && (titleLabel.text!).characters.count > 0 {
            return ["H:|-16-[titleLabel]-16-[segmentedControl]-16-|"]
        }
        else {
            return ["H:|-16-[segmentedControl]-16-|"]
        }
    }
    
    // MARK: Actions
    
    internal func valueChanged(_ sender: UISegmentedControl) {
        let options = rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as? NSArray
        let optionValue = options?[sender.selectedSegmentIndex] as? NSObject
        rowDescriptor.value = optionValue
    }
    
    // MARK: Private
    
    fileprivate func updateSegmentedControl() {
        segmentedControl.removeAllSegments()
        var idx = 0
        if let options = rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as? NSArray {
            for optionValue in options {
                segmentedControl.insertSegment(withTitle: rowDescriptor.titleForOptionValue(optionValue as! NSObject), at: idx, animated: false)
                idx += 1
            }
        }
    }
}
