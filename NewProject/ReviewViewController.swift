//
//  ReviewViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 17/08/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit
import Photos
import SwiftyGif

private let reuseIdentifier = "review_cell"


protocol ReviewDelegate {
    func DeletionScreen(string: String)
}


class ReviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate,VCImageZoomDelegate {
    
    
    @IBOutlet weak var scanningText: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var scanningView : UIView!
    // @IBOutlet weak var scanningView: UIView!
    //@IBOutlet weak var scanningViewHeightConstraint: NSLayoutConstraint!
       @IBOutlet weak var scanningViewHeightConstraint: NSLayoutConstraint!
    
    var scanningOn : Bool = false
    var photoZoomIdentifier : String!
    var photoZoomPosition : Int!
    var photoZoomSelected : Bool!
    @IBOutlet weak var selectedText: UIButton!
    
    @IBOutlet weak var headerText: UILabel!
    typealias CompletionHandler = (_ success:Bool) -> Void
    var asset : PHFetchResult<PHAsset>?
    var deletionAsset : [PHAsset]?
    var dataModel : [ImageModel]?
    var newDataModel : [ImageModel]?
    var deletionSet : [String]?
    var yourCellInterItemSpacing : CGFloat?
    
    var delegate: ReviewDelegate?
    var folderPath : URL?
    var refresh = true
    var allSelected = false
    
    
    @IBOutlet weak var selectAllBtn: UIButton!
    
    var image: UIImage!
    var assetCollection: PHAssetCollection!
    var albumFound : Bool = false
    //var photosAsset: PHFetchResult!
    var assetThumbnailSize:CGSize!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    
    
    //    a. No of images on screen for first time
    //    b. No of images Suggested
    //    c. No of images selected
    //    d. No of images deleted
    //    e. Total no of images
    
    
    @IBAction func selectUnselectAll(_ sender: Any) {
        
        selectAll(select: !allSelected)
    }
    
    
    @IBAction func deleteImages(_ sender: Any) {
        
        GoogleAnalytics.shared.sendEvent(category: Constants.reviewScreenName, action: Constants.NoOfImagesSelected, label: "\(String(describing: deletionSet?.count))")
        
        
        if((deletionSet?.count)!>0)
        {
            
            GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.deleteConfirmationScreenName)
            
            
            
            printTime()
            //copyImagesToTrash(asset: deletionAsset!)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.copyImagesToTrash(asset: self.deletionAsset!, completionHandler: { (success) -> Void in
                    
                    // When download completes,control flow goes here.
                    if success {
                        
                        GoogleAnalytics.shared.sendEvent(category: Constants.reviewScreenName, action: Constants.NoOfImagesDeleted, label: "\(String(describing: self.deletionSet?.count))")
                        // download success
                        PHPhotoLibrary.shared().performChanges({
                            let imageAssetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: self.deletionSet!, options: nil)
                            PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
                        }, completionHandler: {success, error in
                            print(success ? "Success" : error )
                            if(success)
                            {
                                //DatabaseManagement.shared.deleteContacts(mPath: self.deletionSet!)
                                
                                 DatabaseManagement.shared.serialQueue.sync() {
                                DatabaseManagement.shared.finishTrashTransaction(mPath: self.deletionSet!)
                                }
                                DispatchQueue.main.async {
                                    // Update UI
                                    //self.navigationController?.popViewController(animated: true)
                                    
                                    //self.dismiss(animated: true, completion: nil)
                                    
                                    //                    self.navigationController?.popViewController(animated: false)
                                    //
                                    //                    self.delegate?.DeletionScreen(string: "Sent from ReviewController")
                                    
                                    
                                    var viewControllersArray = self.navigationController?.viewControllers
                                    viewControllersArray?.removeLast()
                                    
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "DeletingScreen") as! DeletionViewController
                                    //            self.present(controller, animated: true, completion: nil)
                                    controller.deletionNumber=self.deletionSet?.count
                                    
                                    //            let reviewViewC = ReviewViewController()
                                    
                                    viewControllersArray?.append(controller)
                                    
                                    self.navigationController?.setViewControllers(viewControllersArray!, animated: true)
                                    
                                    
                                }
                                
                            }
                            else{
                                self.deleteFolderContent(folderPath: self.folderPath!)
                            }
                        })
                        
                        
                    } else {
                        // download fail
                        
                        let alert = UIAlertController(title: "Error", message: "Error Occured, Please try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                })
                
            }
        }
        else{
            let alert = UIAlertController(title: "Select Photos", message: "Please select some photos", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.reviewScreenName)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleAnalytics.shared.signInGoogleAnalytics(custDimKey: Constants.reviewScreen, custDimVal: String(describing : Preferences.shared.setReviewScreenPreference))
        
       
        
        yourCellInterItemSpacing=3
        
       
        
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout // casting is
        layout?.minimumLineSpacing = 4
        collectionView!.collectionViewLayout = layout!
        
        deletionAsset = [PHAsset]()
        
        self.navigationController?.navigationBar.tintColor = UIColor.init(red:35/255.0, green:199/255.0, blue:149/255.0, alpha: 1.0)
        
        deletionSet=[String]()
        dataModel=[ImageModel]()
        DatabaseManagement.shared.serialQueue.sync() {
        newDataModel=getData()
        }
        
         DatabaseManagement.shared.serialQueue.sync() {
        if(DatabaseManagement.shared.getScannedImages() != DatabaseManagement.shared.getTotalImageCount())
        {
            refreshScreen()
            scanningOn=true
        }
        else
        {
            scanningViewHeightConstraint.constant = 0
            scanningOn=false
            if(newDataModel?.count==0)
            {
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        }
        
        self.deleteBtn.layer.cornerRadius = 8
        
        selectAll(select: true)
        
        print("Total Photos",  asset?.count ?? "No Photos in whatsapp")
        
        
        // Do any additional setup after loading the view.
        
        GoogleAnalytics.shared.sendEvent(category: Constants.reviewScreenName, action: Constants.imagesVisibleOnReviewScreen, label: "\(String(describing: newDataModel?.count))")
        
        GoogleAnalytics.shared.sendEvent(category: Constants.reviewScreenName, action: Constants.imagesSuggestedOnReviewScreen, label: "\(String(describing: newDataModel?.count))")
        
        
        if(Preferences.shared.getFirstTimePreference()==false)
        {
             DatabaseManagement.shared.serialQueue.sync() {
            GoogleAnalytics.shared.sendEvent(category: Constants.reviewScreenName, action: Constants.totalNoOfImages, label: "\(DatabaseManagement.shared.getTotalImageCount())")
            }
            GoogleAnalytics.shared.sendEvent(category: Constants.reviewScreenName, action: Constants.imagesVisibleOnReviewScreenfirst, label: "\(String(describing: newDataModel?.count))")
            
            Preferences.shared.setfistTimePreference()
        }
        
        //updateHeader()
        
        updateTitle()
        updateHeader()
        
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ReviewViewController.handleLongPress(gestureRecognizer:)))
        
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
        
        
        
    }
    
    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        
        if (gestureRecognizer.state != UIGestureRecognizerState.ended){
            return
        }
        
        let p = gestureRecognizer.location(in: self.collectionView)
        
        if let indexPath : NSIndexPath = (self.collectionView?.indexPathForItem(at: p))! as NSIndexPath{
            //do whatever you need to do
            print("Long Pressed")
            photoZoomIdentifier = dataModel?[indexPath.row].getIdentifier()
            photoZoomPosition = indexPath.row
            photoZoomSelected = dataModel?[indexPath.row].getChecked()
            performSegue(withIdentifier: "PhotoZoom", sender: nil)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    func updateTitle()
    {
        self.collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        refresh=false
    }
    
    
    func refreshScreen()
    {
        
        print("Refresh Recycler")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            
            DispatchQueue.global(qos:.background).async {
                DatabaseManagement.shared.serialQueue.sync() {
                self.newDataModel=self.getData()
                }
                self.dataModel=self.newDataModel
                 var scannedImages=0
                 DatabaseManagement.shared.serialQueue.sync() {
                    scannedImages=DatabaseManagement.shared.getScannedImages()
                }
                 var totalImages=0
                 DatabaseManagement.shared.serialQueue.sync() {
                 totalImages=DatabaseManagement.shared.getTotalImageCount()
                }
                
                 DatabaseManagement.shared.serialQueue.sync() {
                DispatchQueue.main.async(execute:{
                    self.selectOrDeselectAll(select: true)
                    
                    //self.updateHeader()
                    self.updateTitle()
                   
                    if(self.deletionSet?.count == self.dataModel?.count)
                    {
                        self.allSelected=true
                    }
                    else{
                        self.allSelected=false
                    }
                    
                    self.scanningText.text="Scanning images in background (\(scannedImages)/\(totalImages))"
                    
                    
                    self.checkUncheckAllBtn()
                    
                    if(scannedImages==totalImages)
                    {
                        self.refresh=false
                        self.scanningViewHeightConstraint.constant = 0
                        self.scanningOn=false
                        
                        if(self.dataModel?.count==0)
                        {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else
                    {
                        self.scanningOn=true
                    }
                    
                     self.collectionView.reloadData()
                    if(self.refresh==true)
                    {
                        self.refreshScreen()
                    }
                })
            }
            }
            //self.dataModel=self.getData()
            
            
            
           
            
        
            
        })
    }
    
    func updateHeader()
    {
        
        //headerText.text = "\(deletionSet?.count ?? 0) Photos Selected"
        //headerText.text = "\(dataModel?.count ?? 0) Junk Photos Found"
        self.title = "\(deletionSet?.count ?? 0) Photos Selected"
        //self.title.
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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ReviewCollectionViewCell  else {
            fatalError("The dequeued cell is not an instance of CollectionViewCell.")
        }
        
        
        
        if(dataModel?[indexPath.row].getChecked())!
        {
            cell.checkBox.image = UIImage(named:"checked")
            cell.opaqueView.isHidden=true
        }
        else
        {
            cell.checkBox.image = UIImage(named:"partial_checked")
            cell.opaqueView.isHidden=false
        }
        
        //cell.backgroundColor=UIColor.blue
        if let imageView = cell.image{
            imageView.image = getImageFromIdentifier(identifier: (dataModel?[indexPath.row].getIdentifier())!)
        }
        
        
        // Configure the cell
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    /* override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }*/
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HCollectionReusableView
            
            headerView.headerText.text = "\(dataModel?.count ?? 0) Junk Images"
            
//            if(scanningOn)
//            {
//                headerView.scanningViewHeight.constant=30
//            }
//            else{
//                headerView.scanningViewHeight.constant=0
//            }
            //headerView.backgroundColor = UIColor.blue;
            return headerView
            
            //        case UICollectionElementKindSectionFooter:
            //            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as! UICollectionReusableView
            //
            //            footerView.backgroundColor = UIColor.gray;
            //            return footerView
            
        default:  fatalError("Unexpected element kind")
        }
    }
    
    
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        /*guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell  else {
         fatalError("The dequeued cell is not an instance of CollectionViewCell.")
         }*/
        
        if let _cell = collectionView.cellForItem(at: indexPath) as? ReviewCollectionViewCell {
            let selector=_cell.imageSelection()
            if(selector)
            {
                dataModel?[indexPath.row].setChecked(checked: true)
                deletionSet?.append((dataModel?[indexPath.row].getIdentifier())!)
                deletionAsset?.append((dataModel?[indexPath.row].getPHAsset())!)
            }
            else
            {
                dataModel?[indexPath.row].setChecked(checked: false)
                deletionSet = deletionSet?.filter { $0 != dataModel?[indexPath.row].getIdentifier() }
                deletionAsset = deletionAsset?.filter { $0 != dataModel?[indexPath.row].getPHAsset() }
                //deletionSet?.append((dataModel?[indexPath.row].getIdentifier())!)
            }
        }
        //        else if let _cell = collectionView.cellForItem(at: indexPath) as? HCollectionReusableView {
        //
        //            _cell.headerText.text = "\(dataModel?.count ?? 0) Junk Photos Found"
        //        }
        
        
        /* PHPhotoLibrary.shared().performChanges({
         let imageAssetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: [(self.dataModel?[indexPath.row].getIdentifier())!], options: nil)
         PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
         }, completionHandler: {success, error in
         print(success ? "Success" : error )
         })*/
        //updateTitle()
        updateHeader()
        
        checkUncheckAllBtn()
        
        print("clicked")
        return true
    }
    
    
    
    
    
    
    func getAssetsFromAlbum(albumName: String) -> [PHAsset] {
        
        let options = PHFetchOptions()
        // Bug from Apple since 9.1, use workaround
        //options.predicate = NSPredicate(format: "title = %@", albumName)
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
        
        let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        for k in 0 ..< collection.count {
            let obj:AnyObject! = collection.object(at: k)
            if obj.title == albumName {
                if let assCollection = obj as? PHAssetCollection {
                    let results = PHAsset.fetchAssets(in: assCollection, options: options)
                    var assets = [PHAsset]()
                    
                    results.enumerateObjects({ (obj, index, stop) in
                        
                        if let asset = obj as? PHAsset {
                            
                            if asset.mediaType == .image{
                                assets.append(asset)
                                
                                
                            }
                            
                        }
                    })
                    
                    //initalaizeUrls(assets: assets)
                    return assets
                }
            }
        }
        return [PHAsset]()
    }
    
    
    func getData() -> [ImageModel]?
    {
        
        dataModel=DatabaseManagement.shared.getJunkImages()
        
        
        return dataModel
        
    }
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func load(fileName: URL) -> UIImage? {
        //let fileURL = fileName//documentsUrl.appendingPathComponent(fileName)
        let filePATH = "file://" + fileName.path//documentsUrl.appendingPathComponent(fileName)
        let fileURL = URL(string: filePATH)
        do {
            let imageData = try Data(contentsOf:fileURL!)
            return UIImage(data: imageData)
            //let filePath="file://"+fileName.path;
            //return UIImage(contentsOfFile: filePath)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    func getImageFromIdentifier(identifier : String) -> UIImage
    {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = assets.firstObject
            else
        {
            fatalError("no asset")
        }
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    
    
    func getImage() -> UIImage?
    {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("IMG_1848.JPG")
            let image    = UIImage(contentsOfFile: imageURL.path)
            return image
            
            // Do whatever you want with the image
        }
        return nil
    }
    
    
    
    
    
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    
    func createDeletionDirectory(folderName : URL) -> Bool
    {
        do {
            try FileManager.default.createDirectory(atPath: folderName.path, withIntermediateDirectories: true, attributes: nil)
            print("Trash folder created")
            //saveDirectory(diresctoryPath: (SplashViewController.logsPath?.path)!)
            
            return true
            
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
            return false
            
        }
        
    }
    
    
    func printTime() {
        
        let dateFormatter = DateFormatter()
        let requestedComponent: Set<Calendar.Component> = [.month,.day,.hour,.minute,.second]
        let userCalendar = Calendar.current
        
        
        dateFormatter.dateFormat = "ddMMyyhhmmss"
        let endTime  = Date()
        let startTime = dateFormatter.date(from: "251216000000")
        let timeDifference = userCalendar.dateComponents(requestedComponent, from: startTime!, to: endTime)
        
        print("month : ",timeDifference.month," days : ",timeDifference.day)
        
        //dateLabelOutlet.text = "\(timeDifference.month) Months \(timeDifference.day) Days \(timeDifference.minute) Minutes \(timeDifference.second) Seconds"
    }
    
    
    func copyImagesToTrash(asset: [PHAsset],completionHandler: CompletionHandler)
    {
        let date = Date()
        var flag = false
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyhhmmss"
        let result = formatter.string(from: date)
        print("Today's date : ",result)
        folderPath=(SplashViewController.logsPath?.appendingPathComponent(result))!
        createDeletionDirectory(folderName: folderPath!)
        
        print(deletionAsset?.count)
        
        var k=0
        
        for delAsset in deletionAsset! {
            
            let imageName="Image000"+String(k)+".JPG"
            let targetImgeURL = folderPath?.appendingPathComponent(imageName).path
            
            let trashPath=result+"/"+imageName
            
            DatabaseManagement.shared.serialQueue.sync {
                _ = DatabaseManagement.shared.updateTrashTransaction(mPath: (deletionSet?[k])!, trashPath: trashPath)
            }
            
            print("Trash path updated in DB ",result)
            
            k=k+1
            let phManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true; // do it if you want things running in background thread
            phManager.requestImageData(for: delAsset, options: options)
            {   imageData,dataUTI,orientation,info in
                
                if let newData:NSData = imageData as! NSData
                {
                    try! newData.write(toFile: targetImgeURL!, atomically: true)
                    print(targetImgeURL)
                    print("Image moved")
                    if FileManager.default.fileExists(atPath: targetImgeURL!) {
                        print("File exist")
                    }
                    flag = true
                    
                }
            }
            
        }
        
        
        print(folderPath?.path)
        let filemanager:FileManager = FileManager()
        let files = filemanager.enumerator(atPath: (SplashViewController.logsPath!.path))
        while let file = files?.nextObject() {
            print("Trash images :",file)
            
        }
        
        completionHandler(flag)
        
    }
    
    
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
    
    
    func selectOrDeselectAll(select : Bool)
    {
        //deletionSet?.removeAll()
        //deletionAsset?.removeAll()
        
        for img in newDataModel!
        {
            
            
            if(dataModel?.contains{$0 === img} == false)
            {
                print("datamodeldonotcontails checked")
                img.setChecked(checked: true)
                deletionSet?.append((img.getIdentifier()))
                deletionAsset?.append((img.getPHAsset()))
            }
            else if(dataModel?.contains{$0 === img} == true &&  deletionSet?.contains{$0 == img.getIdentifier()} == true)
            {
                print("datamodelcontains checked")
                img.setChecked(checked: true)
            }
            else{
                print(dataModel?.contains{$0 === img})
                print("datamodelcontains previously unchecked")
                img.setChecked(checked: false)
            }
            
            
        }
        
        //checkUncheckAllBtn()
        collectionView.reloadData()
        //updateTitle()
        updateHeader()
        
    }
    
    
    
    func selectAll(select : Bool)
    {
        deletionSet?.removeAll()
        deletionAsset?.removeAll()
        
        for img in newDataModel!
        {
            img.setChecked(checked: select)
            
            if(select==true)
            {
                deletionSet?.append(img.getIdentifier())
                deletionAsset?.append(img.getPHAsset())
            }
            
        }
        
        if(select == true)
        {
            allSelected=true
        }
        else
        {
            allSelected=false
        }
        
        checkUncheckAllBtn()
        collectionView.reloadData()
        //updateTitle()
        updateHeader()
        
    }
    
    
    func checkUncheckAllBtn()
    {
        if(self.deletionSet?.count == self.dataModel?.count)
        {
            allSelected=true
            selectAllBtn.setImage(UIImage(named: "checked.png"), for: UIControlState.normal)
        }
        else if(self.deletionSet?.count == 0)
        {
            allSelected=false
            selectAllBtn.setImage(UIImage(named: "none_selected.png"), for: UIControlState.normal)
        }
        else{
            allSelected=false
            selectAllBtn.setImage(UIImage(named: "select_all_checked.png"), for: UIControlState.normal)
        }
        
        selectedText.setTitle("\((self.deletionSet?.count)!) Selected", for: .normal)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ImageZoomViewController {
            destination.delegate = self
            destination.identifier = photoZoomIdentifier
            destination.position = photoZoomPosition
            destination.selected = photoZoomSelected
        }
        
        
    }
    
    func selectImage(string: Int, selected : Bool) {
        // print(string)
        
        
        if(selected)
        {
            dataModel?[string].setChecked(checked: true)
            deletionSet?.append((dataModel?[string].getIdentifier())!)
            deletionAsset?.append((dataModel?[string].getPHAsset())!)
        }
        else
        {
            dataModel?[string].setChecked(checked: false)
            deletionSet = deletionSet?.filter { $0 != dataModel?[string].getIdentifier() }
            deletionAsset = deletionAsset?.filter { $0 != dataModel?[string].getPHAsset() }
            //deletionSet?.append((dataModel?[indexPath.row].getIdentifier())!)
        }
        
        
        updateHeader()
        checkUncheckAllBtn()
        
        self.collectionView.reloadData()
        
        
        
    }
    
    
}
