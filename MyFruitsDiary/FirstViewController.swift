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
    var roundButton = UIButton()
    
    @IBOutlet weak var loadingView: UIView!
    
    let datePicker = UIDatePicker()

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.roundButton = UIButton(type: .custom)
        self.roundButton.setTitleColor(UIColor.orange, for: .normal)
        self.roundButton.addTarget(self, action: #selector(ButtonClick(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(roundButton)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.dateView.addGestureRecognizer(swipeDown)
        
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
    
    override func viewWillLayoutSubviews() {
        
        roundButton.layer.cornerRadius = roundButton.layer.frame.size.width/2
        roundButton.backgroundColor = UIColor.lightGray
        roundButton.clipsToBounds = true
        roundButton.setImage(UIImage(named:"add.png"), for: .normal)
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            roundButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            roundButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70),
            roundButton.widthAnchor.constraint(equalToConstant: 50),
            roundButton.heightAnchor.constraint(equalToConstant: 50)])
    }
    
    /** Action Handler for button **/
    
    @IBAction func ButtonClick(_ sender: UIButton){
        showDatePick()
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.down {
            print("Swipe Down")
            self.dateTextField.resignFirstResponder()
            self.dateView.isHidden = true
        }
    }
    
    func showDatePick() {
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(FirstViewController.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
        dateTextField.inputView = datePicker
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = UIColor.white
        
        let todayBtn = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(FirstViewController.todayPressed(sender:)))
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(FirstViewController.donePressed(sender:)))
        
        let flexBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/3, height: 40))
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        
        let labelBtn = UIBarButtonItem(customView: label)
        
        toolbar.setItems([todayBtn, flexBtn, labelBtn, doneBtn], animated: true)
        
        dateTextField.inputAccessoryView = toolbar
        
        dateView.isHidden = false;
        dateTextField.becomeFirstResponder()
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatter.string(from: NSDate() as Date)
    }
    
    func donePressed(sender:UIBarButtonItem) {
        let addAlert = UIAlertController(title: "Add Date Entry", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        
        addAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            let task = "entries"
            
            if let date = self.dateTextField.text {
                let params:NSMutableDictionary = ["task":task,"date":date]
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let _ = MobileInterface().getDataFromTask(params)
                    
                    DispatchQueue.main.async {
                        self.dateTextField.resignFirstResponder()
                        self.dateView.isHidden = true
                        
                        self.getUserData()
                    }
                }
            }
        }))
        
        addAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            self.dateTextField.resignFirstResponder()
            self.dateView.isHidden = true
        }))
        
        present(addAlert, animated: true, completion: nil)
    }
    
    func todayPressed(sender:UIBarButtonItem) {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatter.string(from: NSDate() as Date)
        datePicker.date = formatter.date(from: dateTextField.text!)!
    }
    
    func datePickerValueChanged(sender: UIDatePicker) {
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatter.string(from: sender.date)
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
            let alert = UIAlertController(title: "Oops", message: "No fruit entry yet on this date, kindly TAP \"List\" to add items", preferredStyle: UIAlertControllerStyle.alert)
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

