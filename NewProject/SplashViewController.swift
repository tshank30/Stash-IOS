//
//  SplashViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 17/08/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit
import Photos
import UserNotifications

class SplashViewController: UIViewController {

    var asset : [PHAsset]?
    var images : [ImageModel]?
    var queue:OperationQueue? = nil
    static var logsPath : URL?
    var trashPath : String?
    let myGroup = DispatchGroup()
    var semaphore : DispatchSemaphore?
    var request=0;
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0x1D8C7E)
        GoogleAnalytics.shared.signInGoogleAnalytics(custDimKey: Constants.runCount, custDimVal: Preferences.shared.setRunCountPreference())
       
        
//        let content = UNMutableNotificationContent()
//        content.title = "Don't forget"
//        content.body = "Buy some milk"
//        content.sound = UNNotificationSound.default()
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300,
//                                                        repeats: false)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        self.asset=self.getAssetsFromAlbum(albumName: "WhatsApp")
        
        

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
        
        let options = PHFetchOptions()
        // Bug from Apple since 9.1, use workaround
        //options.predicate = NSPredicate(format: "title = %@", albumName)
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
        
        let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        var j=0
        var openView=true
        
        
        let myOpQueue = OperationQueue()
        myOpQueue.maxConcurrentOperationCount = 4

        semaphore = DispatchSemaphore(value: 0) // DispatchSemaphore(value: 0)
        
        
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
                                
                                asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (eidtingInput, info) in
                                    if let input = eidtingInput, let imgURL = input.fullSizeImageURL {
                                        // imgURL
                                        
                                       // DispatchQueue.global(qos: .userInitiated).async { // 1
                                            j=j+1
                                            print(imgURL)
                                            let img=ImageModel()
                                            img.setPath(mPath: imgURL)
                                            img.setIdentifier(identifier: asset.localIdentifier)
                                            img.setChecked(checked: false)
                                            img.setResponseStatus(mResponseStatus: 0)
                                            img.setActionStatus(status: 0)
                                            
                                            print("total images in DB ",self.images?.count ?? "nothing in DB")
                                            DatabaseManagement.shared.insertImageWithIdentifier(img: img)
                                            
                                            if(DatabaseManagement.shared.isScannedWithIdentifier(identifier: img.getIdentifier()) == false)
                                            {
                                                
                                                    self.myGroup.enter()
                                            
                                                myOpQueue.addOperation{
                                                
                                                    self.UploadRequest(image: self.getAssetThumbnail(asset: asset),mPath : img.getIdentifier())
                                                
                                                }
                                                
                                    
                                                
                                            }
                                            
                                            
                                            
                                            //self.asset=self.getAssetsFromAlbum(albumName: "WhatsApp")
                                            /*let overlayImage = self.faceOverlayImageFromImage(self.image)*/
                                            
                                            DispatchQueue.main.async { // 2
                                                //self.fadeInNewImage(overlayImage) // 3
                                                print("Total Photos",  self.asset?.count ?? "No Photos in whatsapp")
                                                
                                                print("Photos added", j)
                                                if(openView && j==assets.count)
                                                {
                                                    openView=false
                                                    self.dismiss(animated: true, completion: nil)
                                                    
                                                    self.performSegue(withIdentifier: "HomeScreen", sender: nil)
                                             
                                                    
                                                }
                                               
                                                
                                                
                                            }
                                        }
                                        
                                       
                                    }
                                }
                                
                            }
                            
                        //}
                    })
                    
                   myGroup.notify(queue: .main) {
                        print("Finished all requests.")
                    }

                    //initalaizeUrls(assets: assets)
                    return assets
                }
            }
        }
        return [PHAsset]()
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
            
            //GoogleAnalytics.shared.sendEvent(category: Constants.permission, action: Constants.photosPermission, label: Constants.fired)
            
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    print("Photos : Authorized")
                    
                    self.afterPermissionTask()
                    
                    break
                //handle authorized status
                case .denied, .restricted :
                    
                    print("Photos : denied, restricted")
                    
                    self.alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
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
             GoogleAnalytics.shared.sendEvent(category: Constants.permission, action: Constants.photosPermission, label: Constants.fired)
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    
                    self.afterPermissionTask()

                    GoogleAnalytics.shared.sendEvent(category: Constants.permission, action: Constants.photosPermission, label: Constants.granted)
                    
                    print("Photos : Authorized")
                    break
                //handle authorized status
                case .denied, .restricted :
                    print("Photos : denied, restricted")
                   
                    self.alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
                    break
                //handle denied status
                case .notDetermined:
                    // ask for permissions
                    print("Photos : not determined")                }
            }
        }
    }
    
    func alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
    {
        //Photo Library not available - Alert
        
        GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.photosPermissionScreen)
        GoogleAnalytics.shared.sendEvent(category: Constants.permission, action: Constants.photosPermission, label: Constants.fired)
        
        let cameraUnavailableAlertController = UIAlertController (title: "Photo Library Unavailable", message: "Please check to see if device settings doesn't allow photo library access", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
            if let url = settingsUrl {
                GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.photosPermmisionSettingScreen)
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        //let cancelAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(settingsAction)
        
        cameraUnavailableAlertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            switch action.style{
                
            case .default:
                print("default")
                self.alertToEncouragePhotoLibraryAccessWhenApplicationStarts()
                break
            case .cancel:
                print("cancel")
                break
            case .destructive:
                print("destructive")
                break
                
            }
        }))
        
    
        self.present(cameraUnavailableAlertController , animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    
        checkPhotoLibraryPermission()
        
    }
    
    func UploadRequest(image : UIImage, mPath : String)     {
        var url : NSURL?
       
        if(self.request==0)
        {
             url = NSURL(string: "http://ankit182.pythonanywhere.com/polls/")
            self.request=1
        }
        else if(self.request==1)
        {
             url = NSURL(string: "http://dean96633.pythonanywhere.com/polls/")
            self.request=2
        }
        else if(self.request==2)
        {
             url = NSURL(string: "http://akshit92.pythonanywhere.com/")
            self.request=3
        }
        else if(self.request==3)
        {
             url = NSURL(string: "http://aki92.pythonanywhere.com/")
            self.request=0
        }
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
        
        
        if(image_data == nil)
        {
            return
        }
        
        
        let body = NSMutableData()
        
        let fname = "test.png"
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

        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            guard let _ = data ,let _:NSData = data! as NSData, let _:URLResponse = response, error == nil else {
                print(error.debugDescription+"error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString ?? "No Data")
            
            let fullNameArr=dataString?.components(separatedBy: " ")
            if((fullNameArr?.count)!>3)
            {
                let result = DatabaseManagement.shared.updateImageInDB(mPath : mPath, responseStatus : "1",actionStatus : "1")
                print("junk insertion :", result)
                
            }
            else{
                let result = DatabaseManagement.shared.updateImageInDB(mPath : mPath, responseStatus : "1",actionStatus : "-1")
                print("non junk insertion :", result)
                
            }
            
            self.semaphore?.signal()
            //semaphore.wait
            
            //self.resultsLabel.text = dataString! as String
            
        }
        
        task.resume()
        
        semaphore?.wait()
        
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
    
}
