//
//  MasterViewController.swift

// <Grocery-LIst is a simple list appclation for ios 9.3 an above and swift 2.2 an above>
// Copyright (C) <2016>  <DJABHipHop/BAProductions>

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


import UIKit
import CoreData
import Speech
import QuartzCore
class MasterViewController: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate,NSFetchedResultsControllerDelegate,SFSpeechRecognitionTaskDelegate {
    //Cell Font Size for both label PS for simulater use 16 for phone use 20
    var fontSize:CGFloat = 20;
    //Cell Font Size for both label PS for simulater use 16 for phone use 20
    var fontSizeAlert:CGFloat = 15;
    //Cell Font Name for both label PS some font may requir bigger number
    var fontName:String = "Avenir";
    //Row Height PS for simulater use 38 for phone use 48
    var row:CGFloat = 48;
    //iTUNES CONNECT APP ID
    var appID:String = "103929392";
    //Minimum Sessions
    var iMinSessions = 3
    //Minimum Try Again Sessions
    var iTryAgainSessions = 6
    //App name
    var appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    //UIToolBar Spacer
    var spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action:nil)
    //managedObjectContext
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var obtainedResults = [AnyObject]()
    var notes = [Notes]()
    var managedObjectContext: NSManagedObjectContext!
    var deleteButton:UIBarButtonItem!
    var resetbutton:UIBarButtonItem!
    var markAsDoneButton:UIBarButtonItem!
    var addButton:UIBarButtonItem!
    var spechToAddButton:UIBarButtonItem!
    //Speach Things
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        loadeDate()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Add edit button to nav bar
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        //Add insert data button to nav bar
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        spechToAddButton = UIBarButtonItem(image:UIImage(named: "micSmall"), style: .plain, target: self, action: #selector(loadeSpeach(_:)))
        //self.navigationItem.rightBarButtonItems =
        self.navigationItem.setRightBarButtonItems([spechToAddButton,addButton], animated: true)
        //Large Title Setting
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        let attributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: .largeTitle)
            ]as [NSAttributedStringKey : Any]
        navigationController?.navigationBar.largeTitleTextAttributes = attributes
        self.title = "\(appName.localizedWithComment(comment: "Name"))"
        //UITableViewSetting Title Setting
        self.tableView.backgroundColor = UIColor(hexString:"#fffefc")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        self.tableView.separatorColor = UIColor.gray
        self.tableView.layoutMargins = .zero;
        self.tableView?.tableHeaderView = nil
        self.tableView?.tableFooterView = nil
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = row;
        //self.tableView.hideSearchBar()
        //UIToolBar Setting
        //let email = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(sendEmailButtonTapped(_:)))
        resetbutton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetChecks(_:)))
        resetbutton.isAccessibilityElement = true
        resetbutton.accessibilityTraits = UIAccessibilityTraitButton
        resetbutton.accessibilityLabel = "Reset All Item On List"
        markAsDoneButton = UIBarButtonItem(image: UIImage(named: "checkbox-marked-outline"), style: .plain, target: self, action: #selector(markMulitpleRowsAsChecks(_:)))
        markAsDoneButton.isAccessibilityElement = true
        markAsDoneButton.accessibilityTraits = UIAccessibilityTraitButton
        markAsDoneButton.accessibilityLabel = "Mark Selected Items On List As Done"
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMulitypleRows(_:)))
        deleteButton.isAccessibilityElement = true
        deleteButton.accessibilityTraits = UIAccessibilityTraitButton
        deleteButton.accessibilityLabel = "Delete Selected Items From List"
        self.setToolbarItems([resetbutton,spacer], animated: true)
        self.navigationController!.setToolbarHidden(false, animated: false)
        //Rate appclation code
        self.rateMe()
        iMinSessions = 0
        iTryAgainSessions = 6
        UserDefaults.standard.set(false, forKey: "neverRate")
        UserDefaults.standard.set(-1, forKey: "numLaunches")
        //let os = ProcessInfo()
        //print(os.processName.localizedWithComment(comment: "PN"));
        self.tableView.allowsSelection = false
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsSelectionDuringEditing = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.inverted), name: .UIAccessibilityInvertColorsStatusDidChange, object: nil)
    }
    // Invert Color Of App
    @objc func inverted() {
        let color:UIColor = UIColor(hexString:"#39544a")!
        let colorInv:UIColor = UIColor(hexString:"#a44593")!
        let textColor:UIColor = UIColor(hexString:"#ffffff")!
        let textColorInv:UIColor = UIColor(hexString:"#000000")!
        let attributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: .largeTitle)
            ]as [NSAttributedStringKey : Any]
        let attributesInv = [
            NSAttributedStringKey.foregroundColor : UIColor.black,
            NSAttributedStringKey.font : UIFont.preferredFont(forTextStyle: .largeTitle)
            ]as [NSAttributedStringKey : Any]
        if UIAccessibilityIsInvertColorsEnabled() {
            self.navigationController?.navigationBar.barTintColor = colorInv
            self.navigationController?.toolbar.barTintColor = colorInv
            UISwitch.appearance().thumbTintColor = textColorInv
            UISwitch.appearance().onTintColor = colorInv
            self.navigationController?.navigationBar.tintColor = UIColor.black
            self.navigationController?.toolbar.tintColor = UIColor.black
            UISearchBar.appearance().barTintColor = UIColor(hexString:"1f1f1f")
            self.tableView.backgroundColor = UIColor(hexString: "#cfefff")
            navigationController?.navigationBar.largeTitleTextAttributes = attributesInv
        }
        else {
            self.navigationController?.navigationBar.barTintColor = color
            self.navigationController?.toolbar.barTintColor = color
            UISwitch.appearance().thumbTintColor = textColor
            UISwitch.appearance().onTintColor = color
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.toolbar.tintColor = UIColor.white
            UISearchBar.appearance().barTintColor = UIColor(hexString:"f1f1f1")
            self.tableView.backgroundColor = UIColor(hexString: "#fffefc")
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
            
        }
    }
    @objc func loadeSpeach(_ sender: Any) {
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            //var isButtonEnabled = false
            switch authStatus {  //5
            case .authorized:
                //isButtonEnabled = true
                let errorAlert = Alert.basicAlerts(title: "Success", message: "User Allowed access to speech recognition", cancelButton: false, completion: {
                    self.loadeDate()
                })
                self.present(errorAlert, animated:true)
            case .denied:
                //isButtonEnabled = false
                let errorAlert = Alert.basicAlerts(title: "Error", message: "User denied access to speech recognition press ok to open setting", cancelButton: true, completion: {
                    UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                })
                self.present(errorAlert, animated:true)
            case .restricted:
                //isButtonEnabled = false
                let errorAlert = Alert.basicAlerts(title: "Error", message: "Speech recognition restricted on this device", cancelButton: false, completion: {
                })
                self.present(errorAlert, animated:true)
            case .notDetermined:
                //isButtonEnabled = false
                let errorAlert = Alert.basicAlerts(title: "Error", message: "Speech recognition not yet authorized", cancelButton: false, completion: {
                })
                self.present(errorAlert, animated:true)
                print("Speech recognition not yet authorized")
            }
            
//            OperationQueue.main.addOperation() {
//                self.spechToAddButton.isEnabled = isButtonEnabled
//            }
        }
    }
    //Load Date For UITableView
    func loadeDate() {
        let noterequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        do{
            let sortDescriptor = NSSortDescriptor(key: "orderPosition", ascending: true)
            noterequest.sortDescriptors = [sortDescriptor]
            notes = try managedObjectContext.fetch(noterequest)
            self.tableView.reloadData()
        }catch{
            print("error")
        }
    }
    //Exit Editing Mode in App
    func exitEditingMode(){
        super.setEditing(false, animated: true)
        self.tableView.setEditing(false, animated: true)
        self.tableView.endEditing(true)
        self.setToolbarItems([resetbutton,spacer], animated: true)
        navigationItem.rightBarButtonItem = addButton
    }
    //Save Date For UITableView
    func saveData(exitEditMode:Bool){
        do{
            //self.tableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
            try self.managedObjectContext.save()
            if exitEditMode==true {
                exitEditingMode()
            }
            self.loadeDate()
        }catch let error as NSError {
            print(error)
        }
    }
    //Delete Date For UITableView
    func deleteDate(indexPath:IndexPath){
        let noterequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        do{
            notes = try managedObjectContext.fetch(noterequest)
            managedObjectContext.delete(notes[indexPath.row] as NSManagedObject)
            for i in indexPath.row..<self.notes.count {
                self.notes[i].setValue(i-1, forKey: "orderPosition")
                print(self.notes[i].orderPosition)
            }
            saveData(exitEditMode: true)
        }catch let error as NSError {
            print(error)
        }
    }
    // Edit Button Overide
    override func setEditing(_ editing: Bool, animated: Bool){
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        if editing == true || editing == true && (tableView.gestureRecognizers != nil) {
            //], animated: true)
            self.setToolbarItems([resetbutton,spacer,markAsDoneButton,spacer,deleteButton], animated: true)
            //self.navigationItem.rightBarButtonItems = []
            self.navigationItem.setRightBarButtonItems([], animated: true)
            self.tableView.allowsSelection = true
        }else{
            self.setToolbarItems([resetbutton,spacer], animated: true)
            //self.navigationItem.rightBarButtonItems = [spechToAddButton, addButton]
            self.navigationItem.setRightBarButtonItems([spechToAddButton,addButton], animated: true)
            self.tableView.allowsSelection = false
        }
    }
    //rate appclation code
    func rateMe() {
        let neverRate = UserDefaults.standard.bool(forKey: "neverRate")
        var numLaunches = UserDefaults.standard.integer(forKey: "numLaunches") + 1
        
        if (!neverRate && (numLaunches == iMinSessions || numLaunches >= (iMinSessions + iTryAgainSessions + 1)))
        {
            self.showRateMe()
            numLaunches = iMinSessions + 1
        }
        UserDefaults.standard.set(numLaunches, forKey: "numLaunches")
    }
    //Show rate appclation code
    func showRateMe() {
        //AppNAme
        //Show rate appclation code
        let alert = UIAlertController(title: "Rate Us".localizedWithComment(comment: "RU"), message: "Thanks for using ".localizedWithComment(comment:"TFU")+appName.localizedWithComment(comment: "Name"), preferredStyle: UIAlertControllerStyle.alert)
        alert.view.layer.cornerRadius = 20
        alert.view.layer.masksToBounds = true
        alert.view.layer.borderWidth = 1.5
        alert.view.layer.borderColor = UIColor.gray.cgColor
        alert.addAction(UIAlertAction(title: "Rate ".localizedWithComment(comment:"Rate")+appName.localizedWithComment(comment: "Name"), style: UIAlertActionStyle.default, handler: { alertAction in
            //UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/\(self.appID)")!)
            print("itms-apps://itunes.apple.com/app/\(self.appID)")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No Thanks".localizedWithComment(comment:"NT"), style: UIAlertActionStyle.default, handler: { alertAction in
            UserDefaults.standard.set(true, forKey: "neverRate")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Maybe Later".localizedWithComment(comment: "comment:ML"), style: UIAlertActionStyle.default, handler: { alertAction in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //Delete Mulityple Rows
    @objc func deleteMulitypleRows(_ sender: Any) {
        // Unwrap indexPaths to check if rows are selected
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            for indexPath in indexPaths {
                let noterequest: NSFetchRequest<Notes> = Notes.fetchRequest()
                do{
                    notes = try managedObjectContext.fetch(noterequest)
                    if notes.count < 0 {
                        //managedObjectContext.delete((notes[indexPath.row] as NSManagedObject))
                        //saveData()
                    }else{
                        loadeDate()
                        managedObjectContext.delete((notes[indexPath.row] as NSManagedObject))
                        saveData(exitEditMode: true)
                    }
                }catch let error as NSError {
                    print(error)
                }
            }
        }else{
            let noterequest: NSFetchRequest<Notes> = Notes.fetchRequest()
            // Tell the tableView that we deleted the objects.
            let deleteRequest = NSBatchDeleteRequest( fetchRequest: noterequest as! NSFetchRequest<NSFetchRequestResult>)
            do{
                try managedObjectContext.execute(deleteRequest)
                exitEditingMode()
                saveData(exitEditMode: true)
            }catch let error as NSError {//
                print(error)
            }
        }
        self.tableView.setEditing(false, animated: false)
    }
    //Reset list/Clear all checkmarks
    @objc  func resetChecks(_ sender: Any) {
        for i in 0..<tableView.numberOfSections {
            for j in 0..<tableView.numberOfRows(inSection: i) {
                if let cell = tableView.cellForRow(at: NSIndexPath(row: j, section: i) as IndexPath) {
                    cell.accessoryType = .none
                    notes[j].checked = false
                    saveData(exitEditMode: false)
                }else{
                    print("All Rows Reset")
                }
            }
        }
    }
    //Mark Mulitple Rows As Checks
    @objc  func markMulitpleRowsAsChecks(_ sender: Any) {
        if let indexPath = self.tableView.indexPathsForSelectedRows {
            for i in indexPath {
                notes[i.row].checked = true
                saveData(exitEditMode: true)
            }
        }else{
            print("No Rows Selected")
        }
    }
    //    override func tableView(tableView: UITableView,
    //                            willDisplayCell cell: UITableViewCell,
    //                                            forRowAtIndexPath indexPath: NSIndexPath){
    //        cell.separatorInset = UIEdgeInsetsMake(10, 20, 10, 20)
    //        cell.layoutMargins = UIEdgeInsetsMake(10, 20, 10, 20)
    //        cell.preservesSuperviewLayoutMargins = false
    //        //TipInCellAnimator.fadeIn(cell)
    //    }
    
    //need if list has more then one section
    /*override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
     let footerView = UIToolbar(frame: CGRectMake(0, 0, tableView.frame.size.width, 1))
     footerView.barTintColor = hexStringToUIColor("#CFCFCF")
     return footerView
     }
     override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
     {
     let uilbl = UILabel()
     //uilbl.numberOfLines = 0
     //uilbl.lineBreakMode = NSLineBreakMode.ByWordWrapping
     //uilbl.text = "blablabla"
     uilbl.sizeToFit()
     uilbl.backgroundColor =  hexStringToUIColor("#CFCFCF")
     uilbl.text = allNotes[currentNoteIndex].amount
     
     return uilbl
     }*/
    
    //need if uisearchbar is present in list
    /*
     override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
     searchBar.endEditing(true)
     searchBar.resignFirstResponder()
     }
     func searchBarSearchButtonClicked(searchBar: UISearchBar) {
     searchBar.resignFirstResponder()
     }*/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*var customkeyboardView : UIView {
     
     let nib = UINib(nibName: "keyboard", bundle: nil)
     let objects = nib.instantiateWithOwner(self, options: nil)
     let cView = objects[0] as! UIView
     return cView
     }*/
    //Add items to list
    @objc func insertNewObject(_ sender: AnyObject) {
        // If appropriate, configure the new managed object.
        //let indexPath = NSIndexPath(row: 0, section: 0)
        self.tableView.isEditing = false
        //Main UIAlertController
        let alert = UIAlertController(title: "Add Item To".localizedWithComment(comment: "AIT")+firstCharacterLowerCase(sentenceToCap: appName.localizedWithComment(comment: "name")),
                                      message: "",
                                      preferredStyle: .alert)
        let placeHolderColor:UIColor = .darkGray
        alert.view.layer.cornerRadius = 20
        alert.view.layer.masksToBounds = true
        alert.view.layer.borderWidth = 1.5
        alert.view.layer.borderColor = UIColor.gray.cgColor
        //Item UITextField
        let ItemConfigClosure: ((UITextField?) -> Void)! = { text in
            text?.placeholder = "Type Item Name Here".localizedWithComment(comment: "TINH")
            text?.attributedPlaceholder = NSAttributedString(string:"Type Item Name Here".localizedWithComment(comment: "TINHD"),attributes:[NSAttributedStringKey.foregroundColor:placeHolderColor])
            text?.adjustsFontSizeToFitWidth = true
            text?.autocapitalizationType = .words
            text?.autocorrectionType = .yes
            text?.font = UIFont(name: self.fontName, size:self.fontSizeAlert)
            text?.adjustsFontForContentSizeCategory = true
            text?.clearButtonMode = .always
            text?.keyboardType = .alphabet
            text?.isAccessibilityElement = true
            text?.accessibilityTraits = UIAccessibilityTraitNone
            text?.accessibilityLabel = "Item Name"
        }
        alert.addTextField(configurationHandler: ItemConfigClosure)
        //Amount UITextField
        let lb = UIBarButtonItem(title: "LB", style: .plain, target: nil, action: nil)
        let h = UIBarButtonItem(title: "H", style: .plain, target: nil, action: nil)
        let m = UIBarButtonItem(title: "M", style: .plain, target: nil, action: nil)
        let s = UIBarButtonItem(title: "S", style: .plain, target: nil, action: nil)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: (navigationController?.navigationBar.frame.size.height)!))
        toolbar.setItems([self.spacer,lb,self.spacer,h,self.spacer,m,self.spacer,s,self.spacer], animated: false)
        let amountConfigClosure: ((UITextField?) -> Void)! = { text in
            text?.placeholder = "Type Quantity Here".localizedWithComment(comment: "TQH")
            text?.attributedPlaceholder = NSAttributedString(string:"Type Quantity Here".localizedWithComment(comment: "TQHD"),attributes:[NSAttributedStringKey.foregroundColor: placeHolderColor])
            text?.adjustsFontSizeToFitWidth = true
            text?.autocapitalizationType = .none
            text?.autocorrectionType = .no
            text?.font = UIFont(name: self.fontName, size: self.fontSizeAlert)
            text?.adjustsFontForContentSizeCategory = true
            text?.clearButtonMode = .always
            text?.keyboardType = .numberPad
            text?.isAccessibilityElement = true
            text?.accessibilityLabel = "Item Amounr"
            text?.accessibilityTraits = UIAccessibilityTraitNone
            //text.inputView = self.customkeyboardView
            //text.inputView = self.customkeyboardView
            //text.inputAccessoryView = toolbar
        }
        alert.addTextField(configurationHandler: amountConfigClosure)
        //Add Button UIAlertAction
        let add = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
            let tf = (alert.textFields?[0])! as UITextField
            let TFF = noEmoji(text: (tf.text)!)
            let tf2 = (alert.textFields?[1])! as UITextField?
            let TFF2 = noEmojiOrLatter(text: (tf2?.text?.digits)!)
            let noteItem = Notes(context: self.managedObjectContext)
            //DispatchQueue.main.async(){
            if TFF == "" || TFF.isEmpty == true || TFF.trimmingCharacters(in: .whitespaces).isEmpty == true {
                self.loadeDate()
            } else {
                noteItem.note = TFF
                if TFF2 == "" || TFF2 == "1" {
                    noteItem.amount = "1"
                }else{
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .none
                    let newNumber = numberFormatter.number(from:TFF2)
                    noteItem.amount = newNumber?.stringValue
                }
                noteItem.checked = false
                noteItem.orderPosition = Double(self.notes.count)
                self.saveData(exitEditMode: false)
            }
            //}
        })
        add.isAccessibilityElement = true
        add.accessibilityTraits = UIAccessibilityTraitButton
        add.accessibilityLabel = "Add Item"
        //Cancel Button UIAlertAction
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            self.loadeDate()
        }
        cancel.isAccessibilityElement = true
        cancel.accessibilityTraits = UIAccessibilityTraitButton
        cancel.accessibilityLabel = "Cancle"
        alert.addAction(add)
        alert.addAction(cancel)
        //Precent UIAlertController
        self.present(alert, animated:true, completion:nil)
    }
    // MARK: - Table View
    //count of sections in list
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //count of items in list
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    //Render items in list view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        //Clear's Cell Color to UITableView color can be used insted
        cell.backgroundColor = UIColor.clear
        //override margin in UITableView again
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsMake(10, 15, 10, 20)
        cell.layoutMargins = UIEdgeInsetsMake(10, 15, 10, 20)
        //override font and font size for textLabel
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel!.font = UIFont.preferredFont(forTextStyle: .body)
        cell.textLabel!.adjustsFontForContentSizeCategory = true
        
        //override font and font size for detailTextLabel
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.font = UIFont.preferredFont(forTextStyle: .body)
        cell.detailTextLabel!.adjustsFontForContentSizeCategory = true
        //object var
        let object = notes[indexPath.row]
        //override font and font size for detailTextLabel
        cell.textLabel!.text = firstCharacterUpperCase(sentenceToCap: ((object.note?.localizedWithComment(comment:"Note")))!)
        cell.textLabel?.isAccessibilityElement = true
        cell.textLabel?.accessibilityTraits = UIAccessibilityTraitStaticText
        cell.textLabel?.accessibilityLabel = firstCharacterUpperCase(sentenceToCap: ((object.note?.localizedWithComment(comment:"Note")))!)
        //override font and font size for detailTextLabel
        cell.detailTextLabel!.text = firstCharacterUpperCase(sentenceToCap: ((object.amount?.localizedWithComment(comment: "Amount")))!)
        cell.detailTextLabel?.isAccessibilityElement = true
        cell.detailTextLabel?.accessibilityTraits = UIAccessibilityTraitStaticText
        cell.detailTextLabel?.accessibilityLabel = firstCharacterUpperCase(sentenceToCap: ((object.amount?.localizedWithComment(comment: "Amount")))!)
        //override font and font size for detailTextLabel
        cell.detailTextLabel!.textColor = UIColor.darkGray
        //disable seltions for UITableView
        cell.selectionStyle = .blue;
        //override tint coloe for UITableView checkmark
        cell.tintColor = UIColor(hexString:"#7F7F7F")
        if object.checked == true {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    //Make Table Editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //Make Table Sortable
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //Mark or Remove items in list with swipe actions
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //delete item code
        let delete = UITableViewRowAction(style: .normal, title: "Delete".localizedWithComment(comment: "Dlete")) { action, index in
            self.deleteDate(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        //mark item as done code
        let markAsDone = UITableViewRowAction(style: .normal, title: "Mark As Done".localizedWithComment(comment: "MAD")) { action, index in
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                    tableView.isEditing = false
                    self.notes[indexPath.row].checked = false
                    self.saveData(exitEditMode: false)
                } else {
                    tableView.isEditing = false
                    cell.accessoryType = .checkmark
                    self.notes[indexPath.row].checked = true
                    self.tableView.isEditing = false
                    self.saveData(exitEditMode: false)
                }
            }
        }
        markAsDone.backgroundColor = UIColor(hexString:"#0679fa")
        //this code is optional depend on what you doing
        if notes[indexPath.row].checked == true {
            return [delete]
        }else{
            return [delete,markAsDone]
        }
    }
    //Reorder items in list
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        self.loadeDate()
        if fromIndexPath.row > toIndexPath.row {
            for i in toIndexPath.row..<fromIndexPath.row {
                notes[i].setValue(i+1, forKey: "orderPosition")
            }
            notes[fromIndexPath.row].setValue(toIndexPath.row, forKey: "orderPosition")
        }
        if fromIndexPath.row < toIndexPath.row {
            for i in fromIndexPath.row + 1...toIndexPath.row {
                notes[i].setValue(i-1, forKey: "orderPosition")
            }
            notes[fromIndexPath.row].setValue(toIndexPath.row, forKey: "orderPosition")
        }
        saveData(exitEditMode: false)
    }
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    //Remove items from list
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if (editingStyle == .delete) {
                deleteDate(indexPath: indexPath)
                TipInCellAnimator.fadeOut(cell: cell)
                saveData(exitEditMode: true)
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
            }
        }
    }
}

