//
//  EditViewController.swift
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

class EditViewController: UIViewController {

    // Is the view list item that we are viewing corrently
    public var item: ToDoListObject?
    
    var hasDueDateSwitchFlag = true
    var isCompletedFlag = false
    // We are going to call this function once the item has been deleted and we are goiing to referesh list as it doesnt exist anymore
    public var deletionHandler: (() -> Void)?
    
    public var afterEditHandler: (() -> Void)?
    
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var isCompletedLabel: UILabel!
//    @IBOutlet var noteDescriptionLabel: UILabel!
    
//    @IBOutlet var textField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var descriptionNote: UITextField!
    
    private let realmDB = try! Realm()
    // Take date object formatting to string and we use static in order to create it one time and store minimum size in memory
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemLabel.text = item?.item
        dateLabel.text = Self.dateFormatter.string(from: item!.date)
        if (item?.isCompleted == true) {
            isCompletedLabel.text = "Completed"
        }
        else{
            isCompletedLabel.text = "Pending"
        }
        descriptionNote.text = item?.notes
        datePicker.setDate(Date(), animated: true)
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
        

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveEdit))
    }
    
    
    @IBAction func hasDueDateSwitchEdits(_ sender: UISwitch) {
        if (sender.isOn){
            hasDueDateSwitchFlag = true
            datePicker.isHidden = false
        }
        else{
            hasDueDateSwitchFlag = false
            datePicker.isHidden = true
        }
    }

    @IBAction func isCompletedSwitchs(_ sender: UISwitch) {
            if (sender.isOn){
                isCompletedFlag = true
                try! realmDB.write {
                    item?.isCompleted = true
                }
                isCompletedLabel.text = "Completed"
            }
            else{
                isCompletedFlag = false
                try! realmDB.write {
                    item?.isCompleted = false
                }
                isCompletedLabel.text = "Pending"
            }
    }
    
    @objc private func didTapSaveEdit()
    {
        if let text = itemLabel.text, !text.isEmpty{
            let date = datePicker.date
            
            try! realmDB.write {
                item?.notes = descriptionNote.text!
                item?.id = ""
                
                if (hasDueDateSwitchFlag == true){
                    item?.hasdueDate = true
                    item?.date = date
                }
                else{
                    item?.hasdueDate = false
                    item?.date = Date(timeIntervalSinceReferenceDate: 0)
                }
                if (isCompletedFlag == true){
                    item?.isCompleted = true
                }
                else{
                    item?.isCompleted = false
                }
            }
            
            // ? means that the completionhandler is optional
            afterEditHandler?()
            
            navigationController?.popToRootViewController(animated: true)
        }
        else{
            print("Nothing!")
        }
        
        

    }
    
    @objc private func didTapDelete()
    {
        guard let deletedItem = self.item else{
            return
        }
        realmDB.beginWrite()
        realmDB.delete(deletedItem)
        try! realmDB.commitWrite()
        
        // we use ? because the function is optional
        deletionHandler?()
        navigationController?.popToRootViewController(animated: true)

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
