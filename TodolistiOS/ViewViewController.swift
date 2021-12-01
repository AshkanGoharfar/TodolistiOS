//
//  ViewViewController.swift
//  TodolistiOS
//
//  Created by Ashkan Goharfar on 9/10/1400 AP.
//

import RealmSwift
import UIKit

class ViewViewController: UIViewController {

    // Is the view list item that we are viewing corrently
    public var item: ToDoListItem?
    
    // We are going to call this function once the item has been deleted and we are goiing to referesh list as it doesnt exist anymore
    public var deletionHandler: (() -> Void)?
    
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    private let realm = try! Realm()
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
    }
    
    @objc private func didTapDelete()
    {
        guard let deletedItem = self.item else{
            return
        }
        realm.beginWrite()
        
        realm.delete(deletedItem)
        
        try! realm.commitWrite()
        
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
