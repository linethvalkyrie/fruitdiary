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
}

class EditDetailsVIewController: UITableViewController {
    
    var itemData: Array<Dictionary<String,Any>> = []
    var itData: Array<Dictionary<String,Any>> = [] {
        didSet{
            itemData = itData
        }
    }
    
    var entryData: Array<Dictionary<String,Any>> = []
    var data: Array<Dictionary<String,Any>> = [] {
        didSet{
            entryData = data
        }
    }
    
    var entryDate: Array<Any> = []
    var entryId: Array<Any> = []
    var entryFruit: Array<Any> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissView))
        
        navigationItem.rightBarButtonItem = editButtonItem
        
//        defineData()
        
//        print(objects)
    }
    
    func defineData() {
        
        for dic:Dictionary<String,Any> in entryData {
            if let eDate = dic["date"], let eId = dic["id"], let eFruit = dic["fruit"] {
                entryDate.append(eDate)
                
                entryId.append(eId)
                
                entryFruit.append(eFruit)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        defineData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: {
           self.entryData.removeAll()
        });
    }
    
    
    // ---------------------------------
    // MARK: UITABLEVIEW METHODS
    // ---------------------------------
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryId.count
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
        }
        else {
            cell.entryId.text = "no data"
            
            cell.entryDate.text = "no data"
            
            cell.passDate = "no data"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteItem = String(describing:entryId[indexPath.row])
            
            entryId.remove(at: indexPath.row)
            
            DispatchQueue.global(qos: .userInitiated).async {
                let task = "entry/" + deleteItem
                
                let result = MobileInterface().deleteDataFromTaskOnly(task as NSString)
                
                
                DispatchQueue.main.async {
                    if (self.entryId.count > 0) {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                    else {
                        
                    }
//                    print(result)
                }
                
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "entryFruit" {
            
            if let destinationNavCon = segue.destination as? UINavigationController{
                if let destinationViewCon = destinationNavCon.viewControllers[0] as? DetailsViewController {
                    destinationViewCon.data = itemData
                    let indexPath = tableView.indexPathForSelectedRow
                    let selectedCell = tableView.cellForRow(at: indexPath!) as! EntryTableViewCell
                    destinationViewCon.entryDate = (selectedCell.passDate)!
                    destinationViewCon.entryData = entryData
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
