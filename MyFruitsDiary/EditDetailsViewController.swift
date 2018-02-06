//
//  EditDetailsViewController.swift
//  MyFruitsDiary
//
//  Created by Dan Allan Bray Santos on 03/02/2018.
//  Copyright © 2018 Dan Allan Bray Santos. All rights reserved.
//

import UIKit
import braySdkframework

class EntryTableViewCell: UITableViewCell {
    @IBOutlet var entryId: UILabel!
    @IBOutlet var entryDate: UILabel!
    var passDate: String!
    var passEntryId: String!
}

class EditDetailsVIewController: UITableViewController {
    
    var entryData: Array<Dictionary<String,Any>> = []
    
    var entryDate: Array<Any> = []
    var entryId: Array<Any> = []
    var entryFruit: Array<Any> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissView))
        
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: {
//            self.entryData.removeAll()
        });
    }
    
    func getUserData() {
        self.entryData.removeAll()
        self.entryDate.removeAll()
        self.entryId.removeAll()
        self.entryFruit.removeAll()
        
        let task = "entries"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.entryData = MobileInterface().getDataFromTaskOnly(task as NSString) as! Array<Dictionary<String, Any>>
            
            DispatchQueue.main.async {
                for dic:Dictionary<String,Any> in self.entryData {
                    
                    if let eDate = dic["date"], let eId = dic["id"], let eFruit = dic["fruit"] {
                        self.entryDate.append(eDate)
                        
                        self.entryId.append(eId)
                        
                        self.entryFruit.append(eFruit)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    // ---------------------------------
    // MARK: UITABLEVIEW METHODS
    // ---------------------------------
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if entryId.count > 0 {
            tableView.backgroundView = nil
            return entryId.count
        }
        else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            tableView.backgroundView = messageLabel;
        }
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell") as! EntryTableViewCell
        
        let items = self.entryData[indexPath.row]
        
        if let eId = items["id"], let eDate = items["date"] {
            cell.entryId.text = "Id: " + String(describing:eId)
            
            cell.entryDate.text = "Date: " + String(describing:eDate)
            
            cell.passDate = String(describing:eDate)
            
            cell.passEntryId = String(describing:eId)
        }
        else {
            cell.entryId.text = "no data"
            
            cell.entryDate.text = "no data"
            
            cell.passDate = "no data"
            
            cell.passEntryId = "no data"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let refreshAlert = UIAlertController(title: "Delete Entry", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let deleteItem = String(describing:self.entryId[indexPath.row])
                
                self.entryId.remove(at: indexPath.row)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let task = "entry/" + deleteItem
                    
                    let _ = MobileInterface().deleteDataFromTaskOnly(task as NSString)
                    
                    DispatchQueue.main.async {
                        if (self.entryId.count > 0) {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                    
                }
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "entryFruit" {
            
            if let destinationNavCon = segue.destination as? UINavigationController{
                if let destinationViewCon = destinationNavCon.viewControllers[0] as? DetailsViewController {
                    let indexPath = tableView.indexPathForSelectedRow
                    let selectedCell = tableView.cellForRow(at: indexPath!) as! EntryTableViewCell
                    destinationViewCon.entryDate = (selectedCell.passDate)!
                    destinationViewCon.entryId = selectedCell.passEntryId
                }
                else {
                    print("no view controller captured")
                }
            }
            else {
                print("Data not passed")
            }
        }
        else {
            print("no segue captured")
        }
    }
}
