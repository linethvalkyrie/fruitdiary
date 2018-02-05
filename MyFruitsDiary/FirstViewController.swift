//
//  FirstViewController.swift
//  MyFruitsDiary
//
//  Created by Dan Allan Bray Santos on 02/02/2018.
//  Copyright © 2018 Dan Allan Bray Santos. All rights reserved.
//

import UIKit
import braySdkframework

class FruitsTableViewCell: UITableViewCell {
    @IBOutlet var fruitsType: UILabel!
    @IBOutlet var fruitCount: UILabel!
    @IBOutlet var vitaminCount: UILabel!
    @IBOutlet var fruitImage: UIImageView!
    @IBOutlet var loadIcon: UIActivityIndicatorView!
}

class FirstViewController: UITableViewController {
    
    
    var collapseDetailViewController: Bool = false
    let kHeaderSectionTag: Int = 6900;
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var sectionItems: Array<Any> = []
    var sectionNames: Array<Any> = []
    var vitaminCo: Array<Any> = []
    var fruitProfile: Array<Any> = []
    
    @IBOutlet weak var loadingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getFruitData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(_ sender: Any) {
        let date : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todaysDate = dateFormatter.string(from: date)
        let task = "entries"
        
        let params:NSMutableDictionary = ["task":task,"date":todaysDate]
        
        DispatchQueue.global(qos: .userInitiated).async {
            let res = MobileInterface().getDataFromTask(params)
            
            DispatchQueue.main.async {
                print(res)
                
                if let message = res["message"] {
                    let alert = UIAlertController(title: todaysDate, message: message as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                self.getFruitData()
            }
        }
    }
    
    var dataArray: Array<Dictionary<String,Any>> = []
    var itemsArray: Array<Dictionary<String,Any>> = []
    var selectedEntry: Array<Dictionary<String,Any>> = []
    
    func downloadImage(imageName:String, cell:FruitsTableViewCell) {
        
        var imageDirectory:String = ""
        
        if let filterIndex = itemsArray.index(where: {$0["type"] as! String == imageName}) {
            print(filterIndex)
            imageDirectory = imageName
        }
        else {
            print("Item not found")
        }
        
        let url = URL(string:"https://fruitdiary.test.themobilelife.com/images/" + imageDirectory + ".png")
        
        let session = URLSession(configuration: .default)
        
        let downloadPicTask = session.dataTask(with: url!) { (data, response, error) in
            if let e = error {
                print("Error downloading picture: \(e)")
            } else {
                if let res = response as? HTTPURLResponse {
                    if let imageData = data {
                        print(res)
                        cell.fruitImage.image = UIImage(data: imageData)
                        cell.loadIcon.isHidden = true;
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
    
    func getFruitData() {
        fruitProfile.removeAll()
        vitaminCo.removeAll()
//        loadingView.isHidden = false;
        
        let task = "fruit"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.itemsArray = MobileInterface().getDataFromTaskOnly(task as NSString) as! Array<Dictionary<String,Any>>
            
            DispatchQueue.main.async {
                for dict:Dictionary<String,Any> in self.itemsArray {
                    if (dict.count > 0) {
                        
                        self.fruitProfile.append(dict)
                        
                        if let vitCount = dict["vitamins"] {
                            
                            //                    print(vitCount)
                            self.vitaminCo.append(vitCount)
                            
                            
                        }
                    }
                }
                
                self.getUserData()
            }
        }
    }
    
    func getUserData() {
        sectionItems.removeAll()
        sectionNames.removeAll()
        let task = "entries"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.dataArray = MobileInterface().getDataFromTaskOnly(task as NSString) as! Array<Dictionary<String, Any>>
            
            DispatchQueue.main.async {
                for dict:Dictionary<String,Any> in self.dataArray {
                    if (dict.count > 0) {
                        //                sectionNames.append(dict["date"] as! String)
                        
                        if let secNames = dict["date"], let secItems = dict["fruit"] {
                            //print(secNames)
                            self.sectionNames.append(secNames)
                            
                            //print(secItems)
                            self.sectionItems.append(secItems)
                        }
                    }
                }
//                self.loadingView.isHidden = true;
                
                self.tableView.reloadData()
            }
        }
    }
    
    // ---------------------------------
    // MARK: UITABLEVIEW METHODS
    // ---------------------------------
    override func numberOfSections(in tableView: UITableView) -> Int {
        if sectionNames.count > 0 {
            tableView.backgroundView = nil
            return sectionNames.count
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel;
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = self.sectionItems[section] as! NSArray
            return arrayOfItems.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.sectionNames.count != 0) {
            return self.sectionNames[section] as? String
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //recast your view as a UITableViewHeaderFooterView
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
//        header.contentView.backgroundColor = UIColor.colorWithHexString(hexStr: "#408000")
        header.contentView.backgroundColor = UIColor.black
        header.textLabel?.textColor = UIColor.white
        
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.view.frame.size
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 18, height: 18));
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.tag = kHeaderSectionTag + section
        header.addSubview(theImageView)
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(FirstViewController.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "fruits") as! FruitsTableViewCell
        let section = self.sectionItems[indexPath.section] as! Array<Dictionary<String,Any>>
        
        cell.backgroundColor = UIColor.lightGray
        
        
        if (cell.loadIcon.isHidden) {
            cell.loadIcon.isHidden = true;
        }

        if let fType = section[indexPath.row]["fruitType"], let fCount = section[indexPath.row]["amount"] {
            //            print(fType)
            cell.fruitsType.textColor = UIColor.black
            cell.fruitsType.text = "item: " + String(describing:fType)
            
            //            print(fCount)
            cell.fruitCount.textColor = UIColor.black
            cell.fruitCount.text = "item count: " + String(describing:fCount)
            
            
            if let filterIndex = itemsArray.index(where: {$0["type"] as! String == fType as! String}) {
                print(fType)
                cell.vitaminCount.textColor = UIColor.black
                cell.vitaminCount.text = "vitamin count: " + String(describing:vitaminCo[filterIndex])
            }
            else {
                print("Item not found")
            }
            
            downloadImage(imageName: fType as! String, cell: cell)
            
            
        }

        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Expand / Collapse Methods
    
    func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        let headerView = sender.view as! UITableViewHeaderFooterView
        let section    = headerView.tag
        let eImageView = headerView.viewWithTag(kHeaderSectionTag + section) as? UIImageView
        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
            tableViewExpandSection(section, imageView: eImageView!)
        } else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section, imageView: eImageView!)
            } else {
                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
                tableViewExpandSection(section, imageView: eImageView!)
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        self.expandedSectionHeaderNumber = -1;
        if (sectionData.count == 0) {
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.tableView!.beginUpdates()
            self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        if (sectionData.count == 0) {
            let alert = UIAlertController(title: "Oops", message: "No fruits was added on this date", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.expandedSectionHeaderNumber = -1;
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.tableView!.beginUpdates()
            self.tableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
        }
    }

    // MARK: - Segues
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showDetail" {
              
                if let destinationNavCon = segue.destination as? UINavigationController{
                    if let destinationViewCon = destinationNavCon.viewControllers[0] as? EditDetailsVIewController {
                        destinationViewCon.data = dataArray
                        destinationViewCon.itemData = itemsArray
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
    
    // MARK: - UISplitViewControllerDelegate
    
//    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
//        return true
//    }
}

