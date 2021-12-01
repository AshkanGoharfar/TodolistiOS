//
//  EntryViewController.swift
//  TodolistiOS
//
//
// Created by Ashkan Goharfar on 9/10/1400 AP.
// Assignment: Asssignment 5  - TODO List App - Part 2 - App UI
// Date: 2021-12-01
// Group Members:
// Member 1: Ashkan Goharfar - 301206729
// Member 2: Inderjitsingh Darshansingh Labana - 301149169
// Member 3: Ridham Prakashchandra Patel - 301207688
//
import RealmSwift
import UIKit

class EntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var descriptionNote: UITextField!
    
    var hasDueDateSwiftFlag = true
    
    private let realmDB = try! Realm()
    // Once the operation is done and saving the entry, we can all this completion block and new entry is added and the page will refresh itself
    public var afterSaveHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.becomeFirstResponder()
        textField.delegate = self
        
        datePicker.setDate(Date(), animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(pressedSaveTaskButton))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    @IBAction func hasDueDateSwitchEntry(_ sender: UISwitch) {
        if (sender.isOn){
            hasDueDateSwiftFlag = true
            datePicker.isHidden = false
        }
        else{
            hasDueDateSwiftFlag = false
            datePicker.isHidden = true
        }
    }
    
    @IBAction func hasDueDateSwitch(_ sender: UISwitch) {
        if (sender.isOn){
            hasDueDateSwiftFlag = true
            datePicker.isHidden = false
        }
        else{
            hasDueDateSwiftFlag = false
            datePicker.isHidden = true
        }

    }
    
    @objc func pressedSaveTaskButton()
    {
        // if yes, we can continue, otherwise we should
        if let text = textField.text, !text.isEmpty{
            let date = datePicker.date
            print(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;")
            print(date)
            
            realmDB.beginWrite()
            
            let newItem = ToDoListObject()
//            newItem.date = date
            newItem.item = text
            newItem.notes = descriptionNote.text!
            newItem.id = ""
            newItem.isCompleted = false
            if (hasDueDateSwiftFlag == true){
                newItem.hasdueDate = true
                newItem.date = date
            }
            else{
                newItem.hasdueDate = false
                newItem.date = Date(timeIntervalSinceReferenceDate: 0)
            }

            realmDB.add(newItem)
            try! realmDB.commitWrite()
            
            // ? means that the completionhandler is optional
            afterSaveHandler?()
            
            navigationController?.popToRootViewController(animated: true)
        }
        else{
            print("Nothing!")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
