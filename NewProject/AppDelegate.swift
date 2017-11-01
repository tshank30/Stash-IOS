//
//  AppDelegate.swift
//  NewProject
//
//  Created by Shashank Tiwari on 07/04/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit
import Photos
import UserNotifications
//import He

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var asset : [PHAsset]?
    var images : [ImageModel]?
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        UINavigationBar.appearance().barTintColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0xFFFFFF)
        DatabaseManagement.shared.createDataBase()
        
        
        registerBackgroundTask()
        
        registerLocal()
        
        
        switch UIApplication.shared.applicationState {
        case .active:
            // resultsLabel.text = resultMessage
            print("Active")
        case .background:
            print("App is backgrounded. Next number = (in background)")
            print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
        case .inactive:
            print("InActive")
            break
        }
        
        return true
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        
    }
    
    
    
    func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
                                
                                
                                
                                asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { (eidtingInput, info) in
                                    if let input = eidtingInput, let imgURL = input.fullSizeImageURL {
                                        // imgURL 
                                        print(imgURL)
                                        let img=ImageModel()
                                        img.setPath(mPath: imgURL)
                                        img.setIdentifier(identifier: asset.localIdentifier)
                                        img.setChecked(checked: false)
                                        img.setResponseStatus(mResponseStatus: 0)
                                        
                                        print("total images in DB ",self.images?.count ?? "nothing in DB")
                                        DatabaseManagement.shared.insertImageWithIdentifier(img: img)
                                        
                                        if(DatabaseManagement.shared.isScannedWithIdentifier(identifier: img.getIdentifier()) == false)
                                        {
                                            self.UploadRequest(image: self.getAssetThumbnail(asset: asset),mPath : img.getIdentifier())
                                        }
                                    }
                                }
                                
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
    
    
    func UploadRequest(image : UIImage, mPath : String)
    {
        let url = NSURL(string: "http://akshit92.pythonanywhere.com/")
        
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
            //self.resultsLabel.text = dataString! as String
            
        }
        
        task.resume()
        
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
    
    
}

