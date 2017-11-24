//
//  RecoverPhotos.swift
//  NewProject
//
//  Created by Shashank Tiwari on 06/09/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import Foundation
import Photos


class RecoverPhotos: NSObject {
        static let albumName = "WhatsApp"
        static let sharedInstance = RecoverPhotos()
        typealias CompletionHandler = (_ success:Bool, _ changedIdentifier : String) -> Void
        
        var assetCollection: PHAssetCollection!
        
        override init() {
            super.init()
            
            if let assetCollection = fetchAssetCollectionForAlbum() {
                self.assetCollection = assetCollection
                return
            }
            
            if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
                PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                    ()
                })
            }
            
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                self.createAlbum()
            } else {
                PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
            }
        }
        
        func requestAuthorizationHandler(status: PHAuthorizationStatus) {
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
                print("trying again to create the album")
                self.createAlbum()
            } else {
                print("should really prompt the user to let them know it's failed")
            }
        }
        
        func createAlbum() {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: RecoverPhotos.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    print("error \(error)")
                }
            }
        }
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", RecoverPhotos.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return collection.firstObject
            }
            return nil
        }
        
    func save(image: UIImage , identifier : String) -> String? {
            if assetCollection == nil {
                return ""                         // if there was an error upstream, skip the save
            }
            var localIdentifier = ""
            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                let enumeration: NSArray = [assetPlaceHolder!]
                albumChangeRequest!.addAssets(enumeration)
                

               localIdentifier = (assetPlaceHolder?.localIdentifier)!
                
            }, completionHandler: { (success,error) -> Void in
                
                // Using GCD
                
              
                
//                DatabaseManagement.shared.serialQueue.sync() {
                    if(success && DatabaseManagement.shared.updateRecoveryTransaction(mPath: identifier , identifier : localIdentifier)==true)
                    {
                        
                    }
               // }
                
                
                //let x=assetPlaceHolder?.localIdentifier
            })
            
            return ""
        }
}
