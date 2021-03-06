//
//  TrashViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 04/09/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "trash_cell"

class TrashViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout  {
    
    var asset : [PHAsset]?
    var deletionAsset : [PHAsset]?
    var dataModel : [ImageModel]?
    var deletionSet : [String]?
    var yourCellInterItemSpacing : CGFloat?
    var deletionMap = [String: String]()
    
    
    @IBOutlet weak var restoreBtn: UIButton!
    @IBOutlet weak var deletePermanently: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    /*@IBAction func backButton(_ sender: Any) {
     
     navigationController?.popViewController(animated: true)
     dismiss(animated: true, completion: nil)
     
     }*/
    
    @IBAction func deletePermanently(_ sender: Any) {
        
        if((deletionSet?.count)!>0)
        {
            permanentDeletionAlert()
        }
        else{
            let alert = UIAlertController(title: "Select Photos", message: "Please select some photos", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func recoverPhotos(_ sender: UIButton) {
        
        if((deletionSet?.count)!>0)
        {
            showRecoveryAlert()
        }
        else{
            let alert = UIAlertController(title: "Select Photos", message: "Please select some photos", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    //"file://\((dataModel?[indexPath.row].getTrashPath())!)"
    
    func recoverImages()
    {
        for imagePath in deletionSet!
        {
            print("file://\(imagePath)")
            let imageLocation = "file://\(imagePath)"
            RecoverPhotos.sharedInstance.save(image: getImageFromPath(imageUrlPath: imageLocation), identifier : deletionMap[imagePath]! )
            self.deleteFolderContent(folderPath: URL(string: imageLocation)!)
            //            if(DatabaseManagement.shared.updateRecoveryTransaction(mPath: deletionMap[imagePath]!)==true)
            //            {
            //
            //            }
            
        }
        
        
        
        if((Preferences.shared.getFirstTimeSplashCounter()==2 && !Preferences.shared.getFromTrashBtnLanding()) || (Preferences.shared.getFirstTimeSplashCounter()==1 && Preferences.shared.getFromTrashBtnLanding()))
        {
            GoogleAnalytics.shared.sendEvent(category: Constants.trashScreenCat, action: Constants.imagesRestoredFirstTime, label : "" , value: NSNumber(value : (deletionSet?.count)!))
        }
        else{
            GoogleAnalytics.shared.sendEvent(category: Constants.trashScreenCat, action: Constants.imagesRestored, label:"", value: NSNumber(value : (deletionSet?.count)!))
        }
        
        deletionSet?.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
         
            self.dataModel=self.getData()
            self.collectionView.reloadData()
            
        })
        
    }
    
    func deleteImages()
    {
        for imagePath in deletionSet!
        {
            print("file://\(imagePath)")
            let imageLocation = "file://\(imagePath)"
            //RecoverPhotos.sharedInstance.save(image: getImageFromPath(imageUrlPath: imageLocation))
            self.deleteFolderContent(folderPath: URL(string: imageLocation)!)
            //if(DatabaseManagement.shared.updateRecoveryTransaction(mPath: deletionMap[imagePath]!)==true)
            
            //  DatabaseManagement.shared.serialQueue.sync {
            DatabaseManagement.shared.deleteContact(mPath: deletionMap[imagePath]!)
            //  }
            
            
        }
        
        if((Preferences.shared.getFirstTimeSplashCounter()==2 &&  !Preferences.shared.getFromTrashBtnLanding()) || (Preferences.shared.getFirstTimeSplashCounter()==1 &&  Preferences.shared.getFromTrashBtnLanding()))
        {
           GoogleAnalytics.shared.sendEvent(category: Constants.trashScreenCat, action: Constants.permanentDeletionFirstTime, label : "" , value: NSNumber(value : (deletionSet?.count)!))
        }
        else{
            GoogleAnalytics.shared.sendEvent(category: Constants.trashScreenCat, action: Constants.permanentDeletion, label : "" , value: NSNumber(value : (deletionSet?.count)!))
        }
        
        deletionSet?.removeAll()
        //   DatabaseManagement.shared.serialQueue.sync {
        dataModel=getData()
        collectionView.reloadData()
        //  }
        
        //self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.trashScreenName)
        
        if(((Preferences.shared.getFirstTimeSplashCounter()==2 &&  !Preferences.shared.getFromTrashBtnLanding()) || (Preferences.shared.getFirstTimeSplashCounter()==1 &&  Preferences.shared.getFromTrashBtnLanding()))  && !Preferences.shared.getFirstTimeTrashScreenGaPreference())
        {
            GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.trashScreenNameFirstTime)
            Preferences.shared.setFirstTimeTrashScreenGaPreference()
        }
        else
        {
          GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.trashScreenName)
        }
        
        GoogleAnalytics.shared.sendEvent(category: Constants.trashScreenCat, action: "landing", label : "")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Preferences.shared.setFromTrashBtnLanding(landing: false)
    }
    
    
    func showRecoveryAlert()
    {
        let alert = UIAlertController(title: "Recover Photos", message: "Do you want to recover \(deletionSet?.count ?? 0) photos?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
                
            case .default:
                print("default")
                self.recoverImages()
                
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }
        }))
        
        
    }
    
    func permanentDeletionAlert()
    {
        let alert = UIAlertController(title: "Delete Photos", message: "Do you want to permanently delete  \(deletionSet?.count ?? 0) photos?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
                
            case .default:
                print("default")
                self.deleteImages()
                
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }
        }))
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout // casting is required because UICollectionViewLayout doesn't offer header pin. Its feature of UICollectionViewFlowLayout
        //        layout?.sectionHeadersPinToVisibleBounds = true
        
        yourCellInterItemSpacing=3
        
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout // casting is
        layout?.minimumLineSpacing = 4
        collectionView!.collectionViewLayout = layout!
        
        self.navigationController?.navigationBar.tintColor = UIColor.init(red:35/255.0, green:199/255.0, blue:149/255.0, alpha: 1.0)
        
        deletionAsset = [PHAsset]()
        
        // Register cell classes
        // self.collectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        deletePermanently.layer.borderWidth = 1
        deletePermanently.layer.borderColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0xF0F0F0).cgColor//UIColor.gray.cgColor //UIColor.gray.cgColor
        
        restoreBtn.layer.borderWidth = 1
        restoreBtn.layer.borderColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0xF0F0F0).cgColor //UIColor.gray.cgColor
        
        deletionSet=[String]()
        
        //   DatabaseManagement.shared.serialQueue.sync {
        dataModel=getData()
        //  }
        
        self.restoreBtn.layer.cornerRadius = 8
        self.deletePermanently.layer.cornerRadius = 8
        
       

        
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width/3 - yourCellInterItemSpacing!, height: collectionView.bounds.size.width/3 - yourCellInterItemSpacing!)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataModel!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TrashCollectionViewCell  else {
            fatalError("The dequeued cell is not an instance of CollectionViewCell.")
        }
        
        if(dataModel?[indexPath.row].getChecked())!
        {
            cell.checkBox.image =  UIImage(named:"checked.png")
            cell.opaqueView.isHidden=true
        }
        else
        {
            cell.checkBox.image = UIImage(named:"partial_checked.png")
            cell.opaqueView.isHidden=false
        }
        
        
        if let imageView = cell.image{
            let filePath = "file://\((dataModel?[indexPath.row].getTrashPath())!)"
            imageView.image = getImageFromPath(imageUrlPath: filePath)
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if let _cell = collectionView.cellForItem(at: indexPath) as? TrashCollectionViewCell {
            let selector=_cell.imageSelection()
            if(selector)
            {
                dataModel?[indexPath.row].setChecked(checked: true)
                deletionSet?.append((dataModel?[indexPath.row].getTrashPath())!)
                deletionMap[(dataModel?[indexPath.row].getTrashPath())!]=(dataModel?[indexPath.row].getIdentifier())!
                
            }
            else
            {
                dataModel?[indexPath.row].setChecked(checked: false)
                deletionSet = deletionSet?.filter { $0 != dataModel?[indexPath.row].getTrashPath() }
                deletionMap.removeValue(forKey: (dataModel?[indexPath.row].getTrashPath())!)
            
            }
        }
        
        print("clicked")
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TrashHeader", for: indexPath) as! TrashHeaderReusableView
            
            //headerView.backgroundColor = UIColor.blue;
            return headerView
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TrashFooter", for: indexPath) as! UICollectionReusableView
            
            return footerView
            
        default:  fatalError("Unexpected element kind")
        }
    }
    
    func getData() -> [ImageModel]?
    {
        dataModel=DatabaseManagement.shared.getTrashImages()
        return dataModel
    }
    
    
    func getImageFromPath(imageUrlPath : String) -> UIImage
    {
        
        //let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let fileURL = URL(string: imageUrlPath)
            let imageData = try Data(contentsOf: fileURL!)
            return UIImage(data: imageData)!
        } catch {
            print("Error loading image : \(error)")
        }
        return UIImage()
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func deleteFolderContent(folderPath : URL)
    {
        // Create a FileManager instance
        
        let fileManager = FileManager.default
        
        // Delete 'subfolder' folder
        
        do {
            try fileManager.removeItem(atPath: folderPath.path)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
        print(folderPath.path)
        let filemanager:FileManager = FileManager()
        let files = filemanager.enumerator(atPath: (SplashViewController.logsPath!.path))
        while let file = files?.nextObject() {
            print("Trash images :",file)
            
        }
        
    }
    
}
