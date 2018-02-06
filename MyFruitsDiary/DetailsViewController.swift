//
//  DetailsViewController.swift
//  MyFruitsDiary
//
//  Created by Dan Allan Bray Santos on 04/02/2018.
//  Copyright © 2018 Dan Allan Bray Santos. All rights reserved.
//

import UIKit
import braySdkframework

class SelectionViewCell: UITableViewCell {
    @IBOutlet var fId: UILabel!
    @IBOutlet var fType: UILabel!
    @IBOutlet var fVit: UILabel!
    @IBOutlet var fConsumed: UILabel!
    @IBOutlet var fImage: UIImageView!
    @IBOutlet var loadIcon: UIActivityIndicatorView!
}

class DetailsViewController: UITableViewController {
    
    var entryDate = String()
    var selectedDate = String() {
        didSet{
            entryDate = selectedDate
        }
    }
    
    var entryId = String()
    var selectedEntryId = String() {
        didSet{
            entryId = selectedEntryId
        }
    }
    
    var itemData: Array<Dictionary<String,Any>> = []
    var data: Array<Dictionary<String,Any>> = [] {
        didSet{
            itemData = data
        }
    }
    
    var entryData: Array<Dictionary<String,Any>> = []
    var dataE: Array<Dictionary<String,Any>> = [] {
        didSet{
            entryData = dataE
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissView))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Add Fruit on Entry: " + entryDate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getFruitData() {
        
        let task = "fruit"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.itemData = MobileInterface().getDataFromTaskOnly(task as NSString) as! Array<Dictionary<String,Any>>
            
            DispatchQueue.main.async {
                self.getUserData()
            }
        }
    }
    
    func getUserData() {
        let task = "entries"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.entryData = MobileInterface().getDataFromTaskOnly(task as NSString) as! Array<Dictionary<String, Any>>
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func downloadImage(imageName:String, cell:SelectionViewCell) {
        
        let url = URL(string:"https://fruitdiary.test.themobilelife.com/images/" + imageName + ".png")
        
        let session = URLSession(configuration: .default)
        
        let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                if let res = response as? HTTPURLResponse {
                    if let imageData = data {
                        print(res)
                        cell.fImage.image = UIImage(data: imageData)
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
    }
    
    // ---------------------------------
    // MARK: UITABLEVIEW METHODS
    // ---------------------------------
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryFruit") as! SelectionViewCell
        
        let items = self.itemData[indexPath.row]
        
        if let eId = items["id"], let eType = items["type"], let eVit = items["vitamins"]  {
            cell.fId.text = "Id: " + String(describing:eId)
            cell.fType.text = "Type: " + String(describing:eType)
            cell.fVit.text = "Vitamin count: " + String(describing:eVit)
            cell.fConsumed.text = ""
            
            for d: [String:Any] in entryData {
                if entryDate == d["date"] as! String
                {
                    for fruitData: [String:Any] in d["fruit"] as! Array<[String:Any]>{
                        if fruitData["fruitType"] as! String == String(describing:eType) {
                            print("EXIST")
                            cell.fConsumed.text = "Consumed: \(fruitData["amount"] as! Int)"
                        }
                    }
                }
//                print("this: \(d)")
            }
            
            
            downloadImage(imageName: String(describing:eType), cell: cell)
        }
        else {
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let items = self.itemData[indexPath.row]
        
        var tField: UITextField!
        
        if let eId = items["id"], let eType = items["type"] {
            
            
            func configurationTextField(textField: UITextField!)
            {
                print("generating the TextField")
                textField.placeholder = "Enter amount consumed"
                textField.keyboardType = .numberPad
                tField = textField
            }
            
            func handleCancel(alertView: UIAlertAction!)
            {
                print("Cancelled !!")
            }
            
            let alert = UIAlertController(title: "Add \(eType)", message: "", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: configurationTextField)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:handleCancel))
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler:{ (UIAlertAction) in
                print("Done !!")
                
                print("Item : \(String(describing: tField.text))")
                
                if let amountVal = tField.text {
                    
                    let task = "entry/\(self.entryId)/fruit/\(eId)?amount=\(amountVal)"
                    
                    let params:NSMutableDictionary = ["task":task]
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        let result = MobileInterface().getDataFromTask(params)
                        
                        DispatchQueue.main.async {
                            print(result)
                            self.getFruitData()
                        }
                    }
                }
                
            }))
            self.present(alert, animated: true, completion: {
                print("completion block")
            })

        }
        
    }
}
