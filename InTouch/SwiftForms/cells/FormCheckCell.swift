//
//  FormCheckCell.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 22/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormCheckCell: FormTitleCell {

    // MARK: FormBaseCell
    
    open override func configure() {
        super.configure()
        selectionStyle = .default
        accessoryType = .none
    }
    
    open override func update() {
        super.update()
        
        titleLabel.text = rowDescriptor.title
        
        if rowDescriptor.value == nil {
            rowDescriptor.value = false as NSObject?
        }
        
        accessoryType = (rowDescriptor.value as! Bool) ? .checkmark : .none
    }
    
    open override class func formViewController(_ formViewController: FormViewController, didSelectRow selectedRow: FormBaseCell) {
        
        if let row = selectedRow as? FormCheckCell {
            row.check()
        }
    }
    
    // MARK: Private interface
    
    fileprivate func check() {
        if rowDescriptor.value != nil {
            rowDescriptor.value = !(rowDescriptor.value as! Bool) as NSObject?
        }
        else {
            rowDescriptor.value = true as NSObject?
        }
        accessoryType = (rowDescriptor.value as! Bool) ? .checkmark : .none
    }
}
