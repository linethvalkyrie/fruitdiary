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
    @IBOutlet var fruitImage: UIImageView!
    @IBOutlet var loadIcon: UIActivityIndicatorView!
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var loadingActivityView: UIView!
    @IBOutlet weak var entryListTbl: UITableView!
    
    let imageCache = NSCache<AnyObject, AnyObject>.sharedInstance
    
    var collapseDetailViewController: Bool = false
    let kHeaderSectionTag: Int = 6900;
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var sectionItems: Array<Any> = []
    var sectionNames: Array<Any> = []
    var dateString : String!
    
    @IBOutlet weak var loadingView: UIView!
    
    let datepicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        entryListTbl.delegate = self
        entryListTbl.dataSource = self
        
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dateChanged(_ datePicker: UIDatePicker) {
        print("DATE :: \(datePicker.date)")
    }
    
    @IBAction func showDatePicker(_ sender: UIButton) {
        let datePicker = UIDatePicker()//Date picker
        datePicker.frame = CGRect(x: 0, y: 100, width: 320, height: 216)
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 5
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let popoverView = UIView()
        popoverView.backgroundColor = UIColor.clear
        popoverView.addSubview(datePicker)
        // here you can add tool bar with done and cancel buttons if required
        
        let popoverViewController = UIViewController()
        popoverViewController.view = popoverView
        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 216)
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = CGSize(width: 320, height: 216)
        popoverViewController.popoverPresentationController?.sourceView = sender // source button
        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
        self.present(popoverViewController, animated: true, completion: nil)
    }
    
//    func layout(){
//        let floaty = Floaty()
//        let currentWindow = UIApplication.shared.keyWindow
//        let fab = floaty(frame: CGRect(x: CGFloat(self.view.frame.size.width - 80), y: CGFloat(self.view.frame.size.height - 180), width: CGFloat(50), height: CGFloat(50)))
//        fab.buttonColor = UIColor().HexToColor(hexString: accentColor)
//        fab.plusColor = UIColor.white;
//        fab.addItem(self.globalObjectCatalogProduct.languageBundle.localizedString(forKey: "sharetoother", value: "", table: nil), icon: UIImage(named: "icShare")){ item in
//            self.sharetoOther();
//        }
//        fab.addItem(self.globalObjectCatalogProduct.languageBundle.localizedString(forKey: "addyourreview", value: "", table: nil), icon: UIImage(named: "ic_add_review")){ item in
//            self.performSegue(withIdentifier: "addReviewSegue", sender: self)
//        }
//        fab.addItem(self.globalObjectCatalogProduct.languageBundle.localizedString(forKey: "addtowishlist", value: "", table: nil), icon: UIImage(named: "ic_wishlist_pdf")){ item in
//            self.addToWishlist();
//        }
//        
//        fab.fabDelegate = self
//        fab.tag = 1300;
//        currentWindow?.addSubview(fab)
//    }
    
    func insertNewObject(_ sender: Any) {
        
//        let date : Date = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let todaysDate = dateFormatter.string(from: date)
//        let task = "entries"
//        
//        let params:NSMutableDictionary = ["task":task,"date":todaysDate]
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            let res = MobileInterface().getDataFromTask(params)
//            
//            DispatchQueue.main.async {
//                print(res)
//                
//                if let message = res["message"] {
//                    let alert = UIAlertController(title: todaysDate, message: message as? String, preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//                
//                self.getUserData()
//            }
//        }
    }
    
    var dataArray: Array<Dictionary<String,Any>> = []
    var itemsArray: Array<Dictionary<String,Any>> = []
    
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
        
        if let _ = url {
            let cacheImage = imageCache.object(forKey:imageDirectory as NSString)
            
            if cacheImage != nil {
                cell.fruitImage.image = cacheImage as? UIImage
                
                if cell.fruitImage.image != nil {
                    cell.loadIcon.isHidden = true;
                }
                
                cell.fruitImage.isHidden = false;
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
                                cell.fruitImage.image = imageToCache
                                
                                if url != nil {
                                    self.imageCache.setObject(imageToCache!, forKey: imageDirectory as NSString, cost:1)
                                }
                                
                                if cell.fruitImage.image != nil {
                                    cell.loadIcon.isHidden = true;
                                }
                                
                                cell.fruitImage.isHidden = false;
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
    
    func getFruitData() {
        
        let task = "fruit"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.itemsArray = MobileInterface().getDataFromTaskOnly(task as NSString) as! Array<Dictionary<String,Any>>
            
            DispatchQueue.main.async {
                print(self.itemsArray)
                self.entryListTbl.reloadData()
                self.loadingActivityView.isHidden = true;
            }
        }
    }
    
    func getUserData() {
//        loadingActivityView.isHidden = true;
        
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
                self.getFruitData()
            }
        }
    }
    
    // ---------------------------------
    // MARK: UITABLEVIEW METHODS
    // ---------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {
        if sectionNames.count > 0 {
            entryListTbl.backgroundView = nil
            return sectionNames.count
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            entryListTbl.backgroundView = messageLabel;
        }
        return 0
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = sectionItems[section] as! NSArray
            return arrayOfItems.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (sectionNames.count != 0) {
            return sectionNames[section] as? String
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //recast your view as a UITableViewHeaderFooterView
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
//        header.contentView.backgroundColor = UIColor.colorWithHexString(hexStr: "#408000")
        header.contentView.backgroundColor = UIColor.black
        header.textLabel?.textColor = UIColor.white
        
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.view.frame.size
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 20, width: 18, height: 18));
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.tag = kHeaderSectionTag + section
        header.addSubview(theImageView)
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(FirstViewController.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = entryListTbl.dequeueReusableCell(withIdentifier: "entryListCell") as! FruitsTableViewCell
        let section = sectionItems[indexPath.section] as! Array<Dictionary<String,Any>>
        
        cell.backgroundColor = UIColor.black
        
        
        cell.loadIcon.isHidden = false;
        cell.fruitImage.isHidden = true;

        if let fType = section[indexPath.row]["fruitType"], let fCount = section[indexPath.row]["amount"] {
            //            print(fType)
            cell.fruitsType.textColor = UIColor.white
            cell.fruitsType.text = "item: " + String(describing:fType)
            
            //            print(fCount)
            cell.fruitCount.textColor = UIColor.white
            cell.fruitCount.text = "item count: " + String(describing:fCount)
            
            downloadImage(imageName: fType as! String, cell: cell)
        }

        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        entryListTbl.deselectRow(at: indexPath, animated: true)
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
            self.entryListTbl!.beginUpdates()
            self.entryListTbl!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.entryListTbl!.endUpdates()
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
            self.entryListTbl!.beginUpdates()
            self.entryListTbl!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.entryListTbl!.endUpdates()
        }
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
              
            if let destinationNavCon = segue.destination as? UINavigationController{
                if let _ = destinationNavCon.viewControllers[0] as? EditDetailsVIewController {
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

