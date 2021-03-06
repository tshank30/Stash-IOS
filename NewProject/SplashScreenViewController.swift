//
//  SplashViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 17/08/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit
import Photos

import CoreData

class SplashViewController: UIViewController {
    
    var asset : [PHAsset]?
    var images : [ImageModel]?
    var queue:OperationQueue? = nil
    static var logsPath : URL?
    var trashPath : String?
    //let myGroup = DispatchGroup()
    var semaphore : DispatchSemaphore?
    var fileseizeSemaphore : DispatchSemaphore?
    
    var request=0;
    var present=false
    //var allImages : [String]!
    
    var allImagesDictionary : [String : Int]!
    var allImagesDictionaryForDatabase : [String : Int]!
    
    var myOpQueue : OperationQueue!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0x1D8C7E)
        GoogleAnalytics.shared.signInGoogleAnalytics(custDimKey: Constants.runCount, custDimVal: Preferences.shared.setRunCountPreference())
        
        
        myOpQueue = OperationQueue()
        myOpQueue.maxConcurrentOperationCount = 4
        
        semaphore = DispatchSemaphore(value: 0)
        
        Preferences.shared.setFirstTimeSplashCounter()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("Memory warning")
        // Dispose of any resources that can be recreated.
    }
    
    
    func afterPermissionTask()
    {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        SplashViewController.logsPath = documentsPath.appendingPathComponent("Trash")
        
        trashPath=SplashViewController.logsPath?.path
        print("Trash Path : ",SplashViewController.logsPath!)
        
        
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        print("TrashPath : ",trashPath)
        if fileManager.fileExists(atPath: (trashPath)!, isDirectory:&isDir) {
            if isDir.boolValue {
                print("file exists and is a directory")
            } else {
                print("file exists and is not a directory")
            }
        } else {
            // file does not exist
            print("file does not exist")
            
            do {
                try FileManager.default.createDirectory(atPath: SplashViewController.logsPath!.path, withIntermediateDirectories: true, attributes: nil)
                print("Trash folder created")
                saveDirectory(diresctoryPath: (SplashViewController.logsPath?.path)!)
                
                
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
            
        }
        
        performDeletionAfterTenDays()
        
        queue = OperationQueue()
        queue?.maxConcurrentOperationCount = 1;
        
        
        let urlWhats = "whatsapp://send?phone=+918826756265&abid=12354&text=Hello"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                DispatchQueue.main.async (execute: {
                    
                    let dateFormatter = DateFormatter()
                    let requestedComponent: Set<Calendar.Component> = [.year,.month,.day,.hour,.minute,.second]
                    let userCalendar = Calendar.current
                    
                    
                    dateFormatter.dateFormat = "ddMMyyhhmmss"
                    let timeRightNow  = Date()
                    let timeRightNowResult = dateFormatter.string(from: timeRightNow)
                    
                    if UIApplication.shared.canOpenURL(whatsappURL) {
                        
                        DispatchQueue.global(qos:.background).async {
                            self.asset=self.getAssetsFromAlbum(albumName: "WhatsApp")
                            self.scanGalleryImageAlso(operation: "WhatsApp")
                        }
                        
                        
                    } else {
                        
                        DispatchQueue.global(qos:.background).async {
                            //self.asset=self.getAssetsFromAlbum(albumName: "Gallery")
                            self.scanGalleryImageAlso(operation: "Gallery")
                            print("Install Whatsapp")
                        }
                        
                    }
                    
                    let timePrevious  = Preferences.shared.getDayTimePreference()
                    let startTime = dateFormatter.date(from: timePrevious)
                    
                    let timeRightNow2  = Date()
                    let timeRightNowResult2 = dateFormatter.string(from: timeRightNow2)
                    
                    if timeRightNow2 != nil {
                        
                        let timeDifference = userCalendar.dateComponents(requestedComponent, from: timeRightNow, to: timeRightNow2)
                        
                        print("execution time",timeDifference.second)
                    }
                    
                })
            }
        }
        
    }
    
    lazy var downloadsInProgress = [NSIndexPath:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func getAssetsFromAlbum(albumName: String) -> [PHAsset] {
        
        var fetchAll=false
        let options = PHFetchOptions()
        // Bug from Apple since 9.1, use workaround
        //options.predicate = NSPredicate(format: "title = %@", albumName)
        options.sortDescriptors = [ NSSortDescriptor(key: "pixelWidth", ascending: true)  ]
        
        //var collection: PHFetchResult<AnyObject>
        //let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        
        var collection: PHFetchResult<AnyObject>!
        
        
        var j=0
        var openView=true
        
        if(albumName != "WhatsApp")
        {
            fetchAll=true
            collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil) as! PHFetchResult<AnyObject>
        }
        else{
            collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil) as! PHFetchResult<AnyObject>
        }
        
        
        //allImagesDictionary.removeAll()
        allImagesDictionary = DatabaseManagement.shared.getAllImagesDictionary()
        allImagesDictionaryForDatabase = allImagesDictionary
        // }
        
        print("total images \(allImagesDictionary?.count)")
         print("total images database \(allImagesDictionaryForDatabase?.count)")
        
        
        // DispatchSemaphore(value: 0)
        
        print("Photo count",collection.count)
        if( collection.count > 0)
        {
            
            var assets = [PHAsset]()
            for k in 0 ..< collection.count {
                let obj:AnyObject! = collection.object(at: k)
                
                if(albumName == "WhatsApp" && Preferences.shared.getFirstTimeInsertionPreference())
                {
                    break
                }
                
                print("album name \(obj)")
                
                if (obj.title == albumName  || fetchAll ) {
                    if let assCollection = obj as? PHAssetCollection {
                        let results = PHAsset.fetchAssets(in: assCollection, options: options)
                        
                        
                        print("enumeration started")
                        results.enumerateObjects({ (obj, index, stop) in
                            
                            if let asset = obj as? PHAsset {
                                
                                if asset.mediaType == .image{
                                    assets.append(asset)
                                    
                                    
                                    //assets.index(of: asset)
                                    
                                    j=j+1
                                    print("Identifier gallery",asset.localIdentifier)
                                    let img=ImageModel()
                                    //img.setPath(mPath: imgURL)
                                    img.setPath(mPath:  URL(string: "https://www.apple.com")!)
                                    img.setIdentifier(identifier: asset.localIdentifier)
                                    img.setChecked(checked: false)
                                    img.setResponseStatus(mResponseStatus: 0)
                                    img.setActionStatus(status: 0)
                                    //img.setFileSize()
                                    
                                    
                                    
                                    //DatabaseManagement.shared.serialQueue.sync() {
                                    
                                    if let index = self.allImagesDictionary.index(forKey: img.getIdentifier())
                                    {
                                       
                                        if let index = self.allImagesDictionaryForDatabase.index(forKey: img.getIdentifier())
                                        {
                                            self.allImagesDictionaryForDatabase.removeValue(forKey: img.getIdentifier())
                                        }
                                        
                                        self.allImagesDictionary.removeValue(forKey: img.getIdentifier())
                                        
                                        print("total after removal")
                                        print("total images  \(self.allImagesDictionary?.count)")
                                        print("total images database \(self.allImagesDictionaryForDatabase?.count)")
                                        
                                        if(self.allImagesDictionary[img.getIdentifier()] == -1)
                                        {
                                            self.myOpQueue.addOperation{
                                                
                                                self.UploadRequest(image: self.getAssetThumbnail(asset: asset),mPath : img.getIdentifier(),filename: "image \(j)")
                                                
                                                
                                            }
                                        }
                                        
                                    }
                                    else{
                                        
                                         print("image inserted")
                                        
                                        
                                        
                                        DatabaseManagement.shared.insertImageWithIdentifier(img: img)
                                        
                                        print("total after insertion")
                                        print("total images  \(self.allImagesDictionary?.count)")
                                        print("total images database \(self.allImagesDictionaryForDatabase?.count)")
                                        
                                        
                                        self.allImagesDictionary[img.getIdentifier()] = -1
                                        
                                        self.myOpQueue.addOperation{
                                            
                                            self.UploadRequest(image: self.getAssetThumbnail(asset: asset),mPath : img.getIdentifier(),filename: "image \(j)")
                                            
                                            
                                        }
                                    }
                                    
                                    
                                    
                                    // }
                                    
                                    print("enumeration")
                                    
                                }
                                
                            }
                            
                            print("enumeration asset")
                            
                            
                        })
                        
                  
                        print("enumeration returning asset")
                        
                        
                        
                        
                    }
                }
                
                if(albumName == "WhatsApp" )
                {
                    Preferences.shared.setFirstTimeInsertionPreference()
                }
                
            }
            
        
            
            DispatchQueue.main.async { // 2
    
                print("Total Photos",  self.asset?.count ?? "No Photos in whatsapp")
                
                print("Photos added", j)
                if(openView && j==assets.count)
                {
                    if(albumName != "WhatsApp")
                    {
                        
                        
                        DatabaseManagement.shared.deleteImageDictionary(mPath : self.allImagesDictionary!)
                        self.allImagesDictionary?.removeAll()
                        openView=false
                        
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                        
                        self.performSegue(withIdentifier: "HomeScreen", sender: nil)
                    }
                }
                
            }
            
            
            
            
            
            
            return assets
        }
        else{
            
            if(albumName != "WhatsApp")
            {
                DispatchQueue.main.async {
                    
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                    
                    self.performSegue(withIdentifier: "HomeScreen", sender: nil)
                }
            }
        }
        print("returning empty asset")
        return [PHAsset]()
    }
    
    
    
    func scanGalleryImageAlso(operation : String)
    {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "pixelWidth", ascending: true)  ]
        let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        //let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        var seguePerformed = false
        
        var j=0
        
        // DatabaseManagement.shared.serialQueue.sync() {
        //allImagesDictionary=DatabaseManagement.shared.getAllImagesDictionary();
        //  }
        
        if(operation == "Gallery")
        {
            allImagesDictionary = DatabaseManagement.shared.getAllImagesDictionary()
            allImagesDictionaryForDatabase = allImagesDictionary
        }
        
        print("total images \(allImagesDictionary?.count)")
        
        print("Photo count",collection.count)
        if( collection.count > 0)
        {
            var assets = [PHAsset]()
            for k in 0 ..< collection.count {
                let obj:AnyObject! = collection.object(at: k)
       
                print("album name \(obj)")
   
                if let assCollection = obj as? PHAssetCollection {
                    let results = PHAsset.fetchAssets(in: assCollection, options: options)
                    
                    
                    print("enumeration started")
                    results.enumerateObjects({ (obj, index, stop) in
                        
                        if let asset = obj as? PHAsset {
                            
                            if asset.mediaType == .image{
                                assets.append(asset)
                                
                                
                                //assets.index(of: asset)
                                
                                j=j+1
                                print("Identifier gallery",asset.localIdentifier)
                                let img=ImageModel()
                                //img.setPath(mPath: imgURL)
                                img.setPath(mPath:  URL(string: "https://www.apple.com")!)
                                img.setIdentifier(identifier: asset.localIdentifier)
                                img.setChecked(checked: false)
                                img.setResponseStatus(mResponseStatus: 0)
                                img.setActionStatus(status: 0)
                                //img.setFileSize()
                                
    
                                
                                if let index = self.allImagesDictionary.index(forKey: asset.localIdentifier)
                                {
                                    
                                    print("image not inserted whatsapp ",j ,self.allImagesDictionary[img.getIdentifier()] ?? "nothing in dictionary")
                                    
                                    if(self.allImagesDictionary[img.getIdentifier()] == -1)
                                    {
                                        self.myOpQueue.addOperation{
                                            
                                            self.UploadRequest(image: self.getAssetThumbnail(asset: asset),mPath : img.getIdentifier(),filename: "image \(j)")
                                            
                                        }
                                    }
                                    
                                    if let index = self.allImagesDictionaryForDatabase.index(forKey: img.getIdentifier())
                                    {
                                        self.allImagesDictionaryForDatabase.removeValue(forKey: img.getIdentifier())
                                    }
                                    
                                    self.allImagesDictionary.removeValue(forKey: img.getIdentifier())
                                    
                                    print("total after removal")
                                    print("total images  \(self.allImagesDictionary?.count)")
                                    print("total images database \(self.allImagesDictionaryForDatabase?.count)")
                                    
                                    print("database dictionary \(self.allImagesDictionaryForDatabase.count) && dictionary \(self.allImagesDictionary.count)")
                                    
                                  
                                    
                                }
                                else{
                                    
                                    self.allImagesDictionary[img.getIdentifier()] = -1
                                    
                                     DatabaseManagement.shared.insertImageWithIdentifier(img: img)
                                    
                                    print("total after insertion")
                                    print("total images  \(self.allImagesDictionary?.count)")
                                    print("total images database \(self.allImagesDictionaryForDatabase?.count)")
                                    
                                     print("image inserted whatsapp ",j)
                                    self.myOpQueue.addOperation{
                                        
                                        self.UploadRequest(image: self.getAssetThumbnail(asset: asset),mPath : img.getIdentifier(),filename: "image \(j)")
                                        
                                    }
                                }
                                
                                if(self.allImagesDictionary[asset.localIdentifier] == -1)
                                {
                                    self.myOpQueue.addOperation{
                                        
                                        self.UploadRequest(image: self.getAssetThumbnail(asset: asset),mPath : img.getIdentifier(),filename: "image \(j)")
                                        
                                    }
                                }
                                
                                if(j>=50 && !seguePerformed)
                                {
                                    seguePerformed=true
                                    DispatchQueue.main.async {
                                        
                                        self.navigationController?.popViewController(animated: true)
                                        self.dismiss(animated: true, completion: nil)
                                        
                                        self.performSegue(withIdentifier: "HomeScreen", sender: nil)
                                    }
                                }
                                
                                print("enumeration")
                                
                            }
                            
                        }
                        
                        print("enumeration asset")
                        
                        
                    })
                    
                    print("enumeration returning asset")
                    
                    
                    
                    
                }
                
            }
            
            
        }
        
        //  DatabaseManagement.shared.serialQueue.sync() {
        DatabaseManagement.shared.deleteImageDictionary(mPath : self.allImagesDictionaryForDatabase!)
        //  }
        self.allImagesDictionary?.removeAll()
        
        if(!seguePerformed)
        {
            DispatchQueue.main.async { // 2
                
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
                
                self.performSegue(withIdentifier: "HomeScreen", sender: nil)
                
            }
        }
        
        
    }
    
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            print("Photos : Authorized")
            
            self.afterPermissionTask()
            
            break
        //handle authorized status
        case .denied, .restricted :
            print("Photos : denied, restricted")
            
            
            
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    print("Photos : Authorized")
                    GoogleAnalytics.shared.sendEvent(category: Constants.permission, action: Constants.photosPermissionCustom, label: "given")
                    
                    self.afterPermissionTask()
                    
                    break
                //handle authorized status
                case .denied, .restricted :
                    
                    print("Photos : denied, restricted")
                    self.alertToEncouragePhotoLibraryAccessWhenApplicationStarts(first: true)
                    break
                    
                //handle denied status
                case .notDetermined:
                    // ask for permissions
                    
                    print("Photos : not determined")                }
            }
            
            break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            
            print("Photos : not determined")
            GoogleAnalytics.shared.sendEvent(category: Constants.permission, action: Constants.photosPermissionSystem, label: "fired")
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    
                    self.afterPermissionTask()
                    
                    GoogleAnalytics.shared.sendEvent(category: Constants.permission, action: Constants.photosPermissionSystem, label: "given")
                    
                    print("Photos : Authorized")
                    break
                //handle authorized status
                case .denied, .restricted :
                    print("Photos : denied, restricted")
                    
                    self.alertToEncouragePhotoLibraryAccessWhenApplicationStarts(first: true)
                    break
                //handle denied status
                case .notDetermined:
                    // ask for permissions
                    print("Photos : not determined")                }
            }
        }
    }
    
    func alertToEncouragePhotoLibraryAccessWhenApplicationStarts(first : Bool)
    {
        //Photo Library not available - Alert
        
        if(first)
        {
            GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.photosPermissionScreenOnce)
            GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.photosPermissionScreen)
        }
        else
        {
            GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.photosPermissionScreen)
        }
        GoogleAnalytics.shared.sendEvent(category: Constants.permission, action: Constants.photosPermissionCustom, label: "fired")
        
        let cameraUnavailableAlertController = UIAlertController (title: "Require Photo Library Access", message: "\nWe never collect any personal data and respect privacy. Allow Photos Library Permission to clear WhatsApp Junk Photos", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Give Permission", style: .default) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                //GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.photosPermmisionSettingScreen)
                
                GoogleAnalytics.shared.sendEvent(category: Constants.permission, action: Constants.photosPermissionSettings, label: "fired")
                
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
                
            }
        }
        //let cancelAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        cameraUnavailableAlertController.addAction(UIAlertAction(title: "Nope, keep junk on phone", style: .destructive, handler: { action in
            switch action.style{
                
            case .default:
                print("default")
                self.alertToEncouragePhotoLibraryAccessWhenApplicationStarts(first: false)
                break
            case .cancel:
                print("cancel")
                break
            case .destructive:
                print("destructive")
                break
                
            }
        }))
        
        cameraUnavailableAlertController.addAction(settingsAction)
        
        
        
        self.present(cameraUnavailableAlertController , animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        checkPhotoLibraryPermission()
        
    }
    
    func UploadRequest(image : UIImage, mPath : String, filename :String)     {
        var url : NSURL?
        
        url = NSURL(string:"http://223.165.30.63:8002/")
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        if (image == nil)
        {
            return
        }
        
        let image_data = UIImagePNGRepresentation(image)
        
        // print("",image_data?.count)
        
        // request.setValue("\(image_data?.count)", forHTTPHeaderField: "Content-Length")
        
        if(image_data == nil)
        {
            return
        }
        
        
        let body = NSMutableData()
        
        let fname = filename
        let mimetype = "image/png"
        let file = "upload_file"
        
        //define the data post parameter
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(file)\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        
        
        request.httpBody = body as Data
        
        let session = URLSession.shared
        
        session.configuration.timeoutIntervalForRequest = 120
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            guard let _ = data ,let _:NSData = data! as NSData, let _:URLResponse = response, error == nil else {
                print(error.debugDescription+"error")
                self.semaphore?.signal()
                return
            }
            
            
            do {
                if let tempData = data, let tempJson = try JSONSerialization.jsonObject(with: tempData) as? [String: Any], let tempBlogs = tempJson[filename] as? [Any] {
                    
                    print("junktag :",tempBlogs[0])
                    
                    let junkTag = tempBlogs[0] as! Int
                    
                    if(junkTag == 1)
                    {
                        print("Image is Junk")
                        //  DatabaseManagement.shared.serialQueue.sync() {
                        do{
                            print("UpdateIdentifier",mPath)
                            let result = try DatabaseManagement.shared.updateImageInDB(mPath : mPath, responseStatus : "1",actionStatus : "1")
                            print("junk insertion :", result)
                        }
                        catch{
                            print(error.localizedDescription)
                        }
                        
                        //  }
                    }
                    else{
                        print("Image is not Junk")
                        //   DatabaseManagement.shared.serialQueue.sync() {
                        do
                        {
                            print("UpdateIdentifier",mPath)
                            let result =  try DatabaseManagement.shared.updateImageInDB(mPath : mPath, responseStatus : "1",actionStatus : "-1")
                            print("non junk insertion :", result)
                        }
                        catch{
                            print(error.localizedDescription)
                        }
                        
                        ///  }
                    }
                    
                    
                    tempBlogs.forEach({ (item) in
                        print("\(type(of: item)) Hello App: \(item)")
                    })
                }
                else{
                    print("nothing")
                }
                
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            self.semaphore?.signal()
        }
        
        
        task.resume()
        
        semaphore?.wait()
        
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func getDirectory() -> String
    {
        let preferences = UserDefaults.standard
        
        let currentLevelKey = "TrashPath"
        
        if preferences.object(forKey: currentLevelKey) == nil {
            //  Doesn't exist
            return ""
        } else {
            return preferences.string(forKey: currentLevelKey)!
        }
    }
    
    
    func saveDirectory(diresctoryPath : String)
    {
        let preferences = UserDefaults.standard
        
        let currentLevelKey = "TrashPath"
        
        preferences.set(diresctoryPath, forKey : currentLevelKey)
        //let currentLevel =
        // preferences.setInteger(currentLevel, forKey: currentLevelKey)
        
        //  Save to disk
        let didSave = preferences.synchronize()
        
        if didSave {
            //  Couldn't save (I've never seen this happen in real world testing)
            print("preference saved")
        }
        else{
            print("preference not saved")
        }
        
    }
    
    
    func performDeletionAfterTenDays()
    {
        
        let filemanager:FileManager = FileManager()
        let files = filemanager.enumerator(atPath: (SplashViewController.logsPath!.path))
        while let file = files?.nextObject() {
            print("Trash images :",file)
            
            var isDir : ObjCBool = false
            
            
            let fileManager1 = FileManager.default
            if fileManager1.fileExists(atPath: ("\(SplashViewController.logsPath!.path)/\(file)") ,isDirectory:&isDir)
            {
                if isDir.boolValue {
                    print(file , ": file exists and is a directory")
                    
                    let dateFormatter = DateFormatter()
                    let requestedComponent: Set<Calendar.Component> = [.month,.day,.hour,.minute,.second]
                    let userCalendar = Calendar.current
                    dateFormatter.dateFormat = "ddMMyyhhmmss"
                    
                    let startTime = dateFormatter.date(from: "\(file)")
                    let endTime  = Date()
                    let timeDifference = userCalendar.dateComponents(requestedComponent, from: startTime!, to: endTime)
                    
                    print("Year : ",timeDifference.year," month : ",timeDifference.month," days : ",timeDifference.day)
                    
                    let imageLocation = "file://\(SplashViewController.logsPath!.path)/\(file)"
                    
                    if let year = timeDifference.year { // If casting, use, eg, if let var = abc as? NSString
                        // variableName will be abc, unwrapped
                        if(year>=0)
                        {
                            self.deleteFolderContent(folderPath: URL(string: imageLocation)!)
                        }
                        
                    } else if let month = timeDifference.month {
                        // abc is nil
                        if(month>0)
                        {
                            self.deleteFolderContent(folderPath: URL(string: imageLocation)!)
                        }
                    }
                    else if let days = timeDifference.day
                    {
                        if(days > 10)
                        {
                            self.deleteFolderContent(folderPath: URL(string: imageLocation)!)
                        }
                    }
                    
                } else {
                    print(file , ": file exists and is not a directory")
                }
                
            }
            else
            {
                print("file not exists : ","file://"+(String(SplashViewController.logsPath!.path+"/"+String(describing: file)))!)
            }
        }
        
        /*let fileManager = FileManager.default
         var isDir : ObjCBool = false
         print("TrashPath : ",trashPath)
         if fileManager.fileExists(atPath: (trashPath)!, isDirectory:&isDir) {
         if isDir.boolValue {
         print("file exists and is a directory")
         } else {
         print("file exists and is not a directory")
         }
         }*/
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
    
    func getSizeFromIdentifier(identifier : String) -> Int64
    {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)[0]
        let resources = PHAssetResource.assetResources(for: assets) // your PHAsset
        
        var sizeOnDisk: Int64? = 0
        
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
            
            print("Imagesize resourse \(sizeOnDisk!)")
        }
        let size=sizeOnDisk!
        return size
        
    }
    
}
