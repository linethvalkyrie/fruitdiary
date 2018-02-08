//
//  DetailsViewController.swift
//  MyFruitsDiary
//
//  Created by Dan Allan Bray Santos on 04/02/2018.
//  Copyright © 2018 Dan Allan Bray Santos. All rights reserved.
//

import UIKit
import Foundation

extension NSCache {
    class var sharedInstance: NSCache<NSString, AnyObject> {
        let cache = NSCache<NSString, AnyObject>()
        return cache
    }
}

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
    
    let imageCache = NSCache<AnyObject, AnyObject>.sharedInstance
    
    var itemData: Array<Dictionary<String,Any>> = []
    var entryData: Array<Dictionary<String,Any>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissView))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.title = "Add Fruit on Entry: " + entryDate
        
        getFruitData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: {
            self.entryData.removeAll()
            self.itemData.removeAll()
        })
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
        
        if let _ = url {
            let cacheImage = imageCache.object(forKey:imageName as NSString)
            
            if cacheImage != nil {
                cell.fImage.image = cacheImage as? UIImage
                
                if cell.fImage.image != nil {
                    cell.loadIcon.isHidden = true;
                }
                
                cell.fImage.isHidden = false;
            }
            else {
                let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
                    if let e = error {
                        print("Error downloading picture: \(e)")
                    } else {
                        if let res = response as? HTTPURLResponse {
                            if let imageData = data {
                                
                                let imageToCache = UIImage(data: imageData)
                                
                                print(res)
                                cell.fImage.image = imageToCache
                                
                                if url != nil {
                                    self.imageCache.setObject(imageToCache!, forKey: imageName as NSString, cost:1)
                                }
                                
                                if cell.fImage.image != nil {
                                    cell.loadIcon.isHidden = true;
                                }
                                
                                cell.fImage.isHidden = false;
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
        }
    }
    
    // ---------------------------------
    // MARK: UITABLEVIEW METHODS
    // ---------------------------------
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemData.count > 0 {
            tableView.backgroundView = nil
            return itemData.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryFruit") as! SelectionViewCell
        
        let items = self.itemData[indexPath.row]
        
        cell.loadIcon.isHidden = false
        cell.fImage.isHidden = true
        
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
