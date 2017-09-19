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
            RecoverPhotos.sharedInstance.save(image: getImageFromPath(imageUrlPath: imageLocation))
            self.deleteFolderContent(folderPath: URL(string: imageLocation)!)
            if(DatabaseManagement.shared.updateRecoveryTransaction(mPath: deletionMap[imagePath]!)==true)
            {
                
            }
            
        }
        
        GoogleAnalytics.shared.sendEvent(category: Constants.trashScreenName, action: Constants.imagesRestore, label: "\(String(describing: deletionSet?.count))")
        
        dataModel=getData()
        collectionView.reloadData()
       // self.navigationController?.popViewController(animated: true)
       // self.dismiss(animated: true, completion: nil)

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
            
            
            DatabaseManagement.shared.deleteContact(mPath: deletionMap[imagePath]!)
                          
        }
        
        GoogleAnalytics.shared.sendEvent(category: Constants.trashScreenName, action: Constants.permanentDeletion, label: "\(String(describing: deletionSet?.count))")

        
        dataModel=getData()
        collectionView.reloadData()
        
        //self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.trashScreenName)
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
        let alert = UIAlertController(title: "Recover Photos", message: "Do you want to permanently delete  \(deletionSet?.count ?? 0) photos?", preferredStyle: UIAlertControllerStyle.alert)
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
        
        yourCellInterItemSpacing=2
        
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout // casting is required because UICollectionViewLayout doesn't offer header pin. Its feature of UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        deletionAsset = [PHAsset]()
        
        // Register cell classes
        // self.collectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        deletePermanently.layer.borderWidth = 1
        deletePermanently.layer.borderColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0xF0F0F0).cgColor//UIColor.gray.cgColor //UIColor.gray.cgColor
        
        restoreBtn.layer.borderWidth = 1
        restoreBtn.layer.borderColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0xF0F0F0).cgColor //UIColor.gray.cgColor
        
        deletionSet=[String]()
        
        dataModel=getData()
        


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
        
        cell.backgroundColor=UIColor.blue
        if let imageView = cell.image{
            
            let filePath = "file://\((dataModel?[indexPath.row].getTrashPath())!)"
            imageView.image = getImageFromPath(imageUrlPath: filePath)
            // imageView.image = getAssetThumbnail(asset: (asset?[indexPath.row])!)
            //imageView.image = load(fileName: (dataModel?[indexPath.row].getPath())!)
            //imageView.image = getImageFromIdentifier(identifier: (dataModel?[indexPath.row].getIdentifier())!)
            // imageView.image = getImage()
        }
        
        
        // Configure the cell
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        /*guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell  else {
         fatalError("The dequeued cell is not an instance of CollectionViewCell.")
         }*/
        
        if let _cell = collectionView.cellForItem(at: indexPath) as? TrashCollectionViewCell {
            let selector=_cell.imageSelection()
            if(selector)
            {
                dataModel?[indexPath.row].setChecked(checked: true)
                deletionSet?.append((dataModel?[indexPath.row].getTrashPath())!)
                deletionMap[(dataModel?[indexPath.row].getTrashPath())!]=(dataModel?[indexPath.row].getIdentifier())!
                //deletionAsset?.append((dataModel?[indexPath.row].getPHAsset())!)
            }
            else
            {
                dataModel?[indexPath.row].setChecked(checked: false)
                deletionSet = deletionSet?.filter { $0 != dataModel?[indexPath.row].getTrashPath() }
                deletionMap.removeValue(forKey: (dataModel?[indexPath.row].getTrashPath())!)
                //deletionAsset = deletionAsset?.filter { $0 != dataModel?[indexPath.row].getPHAsset() }
                //deletionSet?.append((dataModel?[indexPath.row].getIdentifier())!)
            }
        }
        
        
        /* PHPhotoLibrary.shared().performChanges({
         let imageAssetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: [(self.dataModel?[indexPath.row].getIdentifier())!], options: nil)
         PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
         }, completionHandler: {success, error in
         print(success ? "Success" : error )
         })*/
        
        print("clicked")
        return true
    }
    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    /* override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }*/
    
    
    /* override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
     /*let cell = collectionView.cellForItem(at: indexPath)
     
     cell?.backgroundColor = UIColor.cyan*/
     
     guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell  else {
     fatalError("The dequeued cell is not an instance of CollectionViewCell.")
     }
     
     cell.unSelectImage(cell.selection)
     
     
     }*/
    
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "header",
                                                                             for: indexPath) as! CollectionHeader
            headerView.backgroundColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0x1D8C7E)
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
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
