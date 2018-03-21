//
//  ViewController.swift
//  AssignmentOnTableViews
//
//  Created by Smitha Ramamurthy on 12/03/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

import Cocoa

struct Constants {
    static let defaultIndex = (-2, -2)
    static let imageName = "Remove"
    static let disabledRow: CGFloat = 0.3
    static let enabledRow: CGFloat = 1.0
}

class ViewController: NSViewController {
    
    //MARK: - Variables
    @objc dynamic var employees: [Employee] = []
    @objc dynamic var selectedEmployees: [Employee] = []
    
    @IBOutlet var initialArrayController: NSArrayController!
    @IBOutlet var finalArrayController: NSArrayController!
    @IBOutlet weak var initialTableView: NSTableView!
    @IBOutlet weak var finalTableView: NSTableView!
    
    var selectedIndices: [IndexSet.Element] = []
    var highlightedRow: (index: Int, indexInInitialTable: Int) = Constants.defaultIndex //Give a default value
    let buttonTag = 1111
    
    //MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let data = employeeData else {
            ErrorHandling.showError(error: .EmptyDataError)
            return
        }
        employees = Employee.decode(data: data)
        
        //Add a tracking area for the mouse events to be detected
        let trackingArea = NSTrackingArea(rect: view.bounds,
                                          options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved],
                                          owner: self,
                                          userInfo: nil)
        finalTableView.addTrackingArea(trackingArea)
        
        //Set the double click action methid for initialTableView
        initialTableView.doubleAction = #selector(ViewController.addEmployees)
    }
    
    //MARK: - IB Actions
    @IBAction func addSelectedEmployeesToSecondTable(_ sender: NSButton) {
        addEmployees()
    }
    
    @IBAction func clearAll(_ sender: NSButton) {
        refreshUI(clearAll: true)
        selectedEmployees = []
        selectedIndices = []
        finalArrayController.content = nil
    }
    
    //MARK: - Helper methods
    @objc func addEmployees() {
        selectedIndices.append(contentsOf: addObjects(from: initialArrayController, to: finalArrayController))
        refreshUI()
    }
    
    /// Function to remove the row on which delete button was clicked and makes the same row available in initialTableView for selection
    @objc func removeRowAtIndex() {
        let mouseHoveredRow = highlightedRow
        updateRowAtIndex(highlightedRow.index, shouldAddButton: false)
        finalArrayController.remove(atArrangedObjectIndex: mouseHoveredRow.index)
        selectedIndices.remove(at: selectedIndices.index(of: mouseHoveredRow.indexInInitialTable)!)
        refreshUI()
    }
    
    /// Function to change the alphaValue property of selected tableView rows
    func updateSelectedCells(withAlphaValue alpha: CGFloat) {
        selectedIndices.forEach { initialTableView?.rowView(atRow: $0, makeIfNecessary: false)?.alphaValue = alpha }
    }
    
    func refreshUI(clearAll: Bool = false) {
        initialTableView.reloadData()
        finalTableView.reloadData()
        finalArrayController.setSelectedObjects([])
        initialArrayController.setSelectedObjects([])
        DispatchQueue.main.async {
            self.updateSelectedCells(withAlphaValue: clearAll ? Constants.enabledRow : Constants.disabledRow)
        }
    }
    
    /// Function to update the row highlight and Remove button depending on mouse pointer location on tableView
    /// - Parameter index: Index of the row that needs to show Remove button
    /// - Parameter add: A boolean value that indicates whether to add button or remove it
    /// - Returns: Nothing
    func updateRowAtIndex(_ index: Int, shouldAddButton add: Bool) {
        //An index of -1 indicates row is not available for that mouse pointer location, hence no row can be selected
        guard index > -1 else { return }
        
        //Get the rowView of the tableView which mouse pointer is hovering on
        guard let rowView = finalTableView.view(atColumn: 2, row: index, makeIfNecessary: false) else {
            ErrorHandling.showError(error: .RowRetrievalError(index: index))
            return
        }
        
        if add {
            //check if the remove button is already added
            guard let _ = rowView.viewWithTag(buttonTag) else {
                //If the button is not added, then create one
                let selector = #selector(ViewController.removeRowAtIndex)
                let button = NSButton(image: Constants.imageName,
                                      target: self,
                                      action: selector,
                                      ofSize: rowView.frame.size,
                                      withTag: buttonTag)
                rowView.addSubview(button)
                return
            }
        } else {
            if highlightedRow.index > -1, let button = rowView.viewWithTag(buttonTag) {
                button.removeFromSuperview()
                highlightedRow = Constants.defaultIndex
            }
        }
    }
    
    /// Function to add selected objects from sourceArrayController to destinationArrayController
    /// - Parameter source: ArrayController from which objects need to be added
    /// - Parameter destination: ArrayController to which objects will be added
    /// - Returns: Indices which were added
    func addObjects(from source: NSArrayController, to destination: NSArrayController) -> IndexSet {
        let selectedPeople: [Any] = source.selectedObjects
        let selectedIndices = source.selectionIndexes
        destination.add(contentsOf: selectedPeople)
        source.removeSelectedObjects(selectedPeople) //deselect rows
        return selectedIndices
    }
}

//MARK: - Extension for TableViewDelegate methods
extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return !selectedIndices.contains(row)
    }
}

//MARK: - Extension for Mouse Events
extension ViewController {
    override func mouseExited(with event: NSEvent) {
        updateRowAtIndex(highlightedRow.index, shouldAddButton: false)
        finalTableView.selectRowIndexes([], byExtendingSelection: false)
    }
    
    override func mouseMoved(with event: NSEvent) {
        let location = finalTableView.convert(event.locationInWindow, from: self.view)
        let row = finalTableView.row(at: location) //Get the row at the mouse pointer location
        
        //if the location has a valid row
        if row != -1 {
            if highlightedRow.index != row { //If at least one row is selected
                updateRowAtIndex(highlightedRow.index, shouldAddButton: false)
            }
            highlightedRow.index = row
            highlightedRow.indexInInitialTable = selectedIndices[row] //Keep a copy of which row is selected
            
            view.window?.makeFirstResponder(finalTableView)
            finalTableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
            finalArrayController.setSelectionIndex(row)
            updateRowAtIndex(row, shouldAddButton: true)
        } else { //Remove the button if location does not have a valid row
            updateRowAtIndex(highlightedRow.index, shouldAddButton: false)
        }
    }
}
