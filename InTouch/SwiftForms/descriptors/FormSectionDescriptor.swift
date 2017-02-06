//
//  FormSectionDescriptor.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 20/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormSectionDescriptor {

    // MARK: Properties
    
    open let headerTitle: String?
    open let footerTitle: String?
    
    open var rows: [FormRowDescriptor] = []
    
    // MARK: Init
    
    public init(headerTitle: String?, footerTitle: String?) {
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
    }
    
    // MARK: Public interface
    
    open func addRow(_ row: FormRowDescriptor) {
        rows.append(row)
    }
    
    open func removeRowAtIndex(_ index: Int) throws {
        guard index >= 0 && index < rows.count - 1 else { throw FormErrorType.rowOutOfIndex }
        rows.remove(at: index)
    }
}
