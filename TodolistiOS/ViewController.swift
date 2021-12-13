//
//  ViewController.swift
//  TodolistiOS
//
// Created by Ashkan Goharfar on 9/10/1400 AP.
// Assignment: Asssignment 6  - TODO List App - Part 3 - App UI
// Date: 2021-12-09
// Group Members:
// Member 1: Ashkan Goharfar - 301206729
// Member 2: Inderjitsingh Darshansingh Labana - 301149169
// Member 3: Ridham Prakashchandra Patel - 301207688
//


/**
 * This assignment aims to craete an iOS app for to do list in which when we press + button new task should be added to the Realm database and also all of the CRUD operations should work perfectly therefore we can delete or edit the tasks using swipes. In this regard, we have implemented a swipe of right to left to show delete and taskStatus buttons with their functionalities and also we have created a swipe of left to right to show blue edit button with its functionality.
 */



import RealmSwift
import UIKit

/**
 * Create To do list object for database and other purposes as it includes a tasks parameters like name of the task, description of the task and etc.
 */
class ToDoListObject: Object {
    @objc dynamic var item: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var id: String = ""
    @objc dynamic var notes: String = ""
    @objc dynamic var hasdueDate: Bool = false
    @objc dynamic var isCompleted: Bool = false
}

class ViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    public var afterSwitchHandler: (() -> Void)?
    public var deletionHandler: (() -> Void)?

    private let realmDB = try! Realm()
    private var data = [ToDoListObject]()
    private var indexPathList = [IndexPath]()
    public var switchTaskIsComplete = false
    public var indexPathRow = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        data = realmDB.objects(ToDoListObject.self).map({ $0 })
        table.reloadData()
        switchTaskIsComplete = false
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    /**
     * This function aims to create a swipe of right to left to show delete and taskStatus buttons and after pressing the taskStatus button if the task is pending it changes to completed or if is completed it changes to pending. If we use long swipe the task wil be deleted and remove from database.
     */

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

           // delete
           let deleteSwipe = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
           completionHandler(true)
           self.realmDB.beginWrite()
           self.realmDB.delete(self.data[indexPath.row])
           try! self.realmDB.commitWrite()

           // we use ? because the function is optional
           self.deletionHandler?()

          self.data.remove(at: indexPath.row)
          self.table.deleteRows(at: [indexPath], with: .automatic)
       }
       deleteSwipe.image = UIImage(systemName: "trash")
       deleteSwipe.backgroundColor = .red

       // switch
       let switchSwipe = UIContextualAction(style: .normal, title: "TaskStatus") { (action, view, completionHandler) in
           completionHandler(true)
           if (self.data[indexPath.row].isCompleted == false){
               try! self.realmDB.write{
                   self.data[indexPath.row].isCompleted = true
               }
               self.afterSwitchHandler?()
               if let cell = self.table.cellForRow(at: indexPath) as? UITableViewCell{
                   cell.detailTextLabel?.text = "Completed"
               }
           }
           else{
               try! self.realmDB.write{
                   self.data[indexPath.row].isCompleted = false
               }
               self.afterSwitchHandler?()
               if let cell = self.table.cellForRow(at: indexPath) as? UITableViewCell{
                   cell.detailTextLabel?.text = "Pending"
               }
           }
       }
       switchSwipe.backgroundColor = .yellow

       // swipe
       let swipeRightToLeft = UISwipeActionsConfiguration(actions: [deleteSwipe, switchSwipe])

       return swipeRightToLeft

     }

    
    /**
     * This function aims to create a swipe of left to right to show blue edit button and after pressing the edit button navigate to edit screen.
     */
     func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

         let editSwipe = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
         completionHandler(true)
             let item = self.data[indexPath.row]
             
             guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "edit") as? EditViewController else {
                 return
             }
             vc.item = item
             vc.deletionHandler = { [weak self] in
                 self?.refresh()
             }
             vc.afterEditHandler = { [weak self] in
                 self?.refresh()
             }
             
             vc.navigationItem.largeTitleDisplayMode = .never
             vc.title = item.item
             self.navigationController?.pushViewController(vc, animated: true)
       }
         editSwipe.image = UIImage(systemName: "pencil")
         editSwipe.backgroundColor = .blue
       
       // swipe
       let swipeLeftToRight = UISwipeActionsConfiguration(actions: [editSwipe])
       
       return swipeLeftToRight
     }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indexPathRow = indexPath.row
        indexPathList.append(indexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = data[indexPath.row].item
        
        if (data[indexPath.row].isCompleted == true) {
            cell?.detailTextLabel?.text = "Completed"
        }
        else if (data[indexPath.row].isCompleted == false){
            cell?.detailTextLabel?.text = "Pending"
        }

        
        
        
        
        
        
//        // Code to add switch in Table cell
//        let switchView = UISwitch(frame: .zero)
//        switchView.tag = indexPath.row
//        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
//
//        if (data[indexPath.row].isCompleted == true) {
//            cell?.detailTextLabel?.text = "Completed"
//            switchView.setOn(true, animated: true)
//        }
//        else if (data[indexPath.row].isCompleted == false){
//            cell?.detailTextLabel?.text = "Pending"
//            switchView.setOn(false, animated: true)
//        }
//        if (data[indexPath.row].isCompleted == true) {
//            cell?.detailTextLabel?.text = "Completed"
//        }
//        else if (data[indexPath.row].isCompleted == false){
//            cell?.detailTextLabel?.text = "Pending"
//        }
//        cell!.accessoryView = switchView
        return cell!
    }

    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let item = data[indexPath.row]
//
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "edit") as? EditViewController else {
//            return
//        }
//        vc.item = item
//        vc.deletionHandler = { [weak self] in
//            self?.refresh()
//        }
//        vc.afterEditHandler = { [weak self] in
//            self?.refresh()
//        }
//
//        vc.navigationItem.largeTitleDisplayMode = .never
//        vc.title = item.item
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    @IBAction func pressedAddNewTaskButton()
    {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "enter") as? EntryViewController else {
            return
        }
        vc.afterSaveHandler = { [weak self] in
            self?.refresh()
        }
        vc.title = "New Task"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // This function will give all of data from Realm database and will reload our tableview
    func refresh()
    {
        // Update the data according to the database
        data = realmDB.objects(ToDoListObject.self).map({ $0 })
        table.reloadData()
    }

    @objc func switchChanged(_ sender: UISwitch) {
        indexPathRow = sender.tag
        if (sender.isOn){
            try! realmDB.write{
                data[indexPathRow].isCompleted = true
            }
            afterSwitchHandler?()
            if let cell = table.cellForRow(at: indexPathList[indexPathRow]) as? UITableViewCell{
                cell.detailTextLabel?.text = "Completed"
            }
        }
        else{
            try! realmDB.write{
                data[indexPathRow].isCompleted = false
            }
            afterSwitchHandler?()
            if let cell = table.cellForRow(at: indexPathList[indexPathRow]) as? UITableViewCell{
                cell.detailTextLabel?.text = "Pending"
            }
        }
        print(data[indexPathRow].isCompleted)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

