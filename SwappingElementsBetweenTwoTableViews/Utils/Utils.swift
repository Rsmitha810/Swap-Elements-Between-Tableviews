//
//  Utils.swift
//  AssignmentOnTableViews
//
//  Created by Smitha Ramamurthy on 20/03/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

import Foundation
import Cocoa

class ErrorHandling {
    internal enum Errors: Error {
        case EmptyDataError
        case IndexOutOfBoundError
        case RowRetrievalError(index: Int)
    }

    class func showError(error: Errors) {
        var errorMsg: String = ""
        var errorTitle: String = ""
        switch error {
        case .EmptyDataError:
            errorTitle = "EmptyDataError"
            errorMsg = "No Data to be displayed"
        case .IndexOutOfBoundError:
            errorTitle = "IndexOutOfBoundError"
            errorMsg = "Array Index out of bound"
        case .RowRetrievalError(let index):
            errorTitle = "RowRetrievalError"
            errorMsg = "Could not retrieve required row at index \(index)"
        }
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = errorTitle
        alert.informativeText = errorMsg
        alert.runModal()
    }
}


