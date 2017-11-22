//
//  StashCoreData.swift
//  NewProject
//
//  Created by Shashank Tiwari on 10/11/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import Foundation
import CoreData
import Photos

class DatabaseManagement
{
    static let shared:DatabaseManagement=DatabaseManagement()
    private var managedObjectContext: NSManagedObjectContext;
    
    public var serialQueue :DispatchQueue
    
    
    //    responsestatus ->
    //    scanned = 1
    //    not sanned = 0
    //    trash = 2
    //    recovered = 3
    
    //    actionStatus ->
    //    junk = 1
    //    not junk = -1
    //    ignored = 2
    
    private init()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        serialQueue = DispatchQueue(label: "stash.coredata.queue")
    }
    
//    func getQueue()->DispatchQueue
//    {
//        return serialQueue
//    }
    
    
    func getNotScannedAssets() -> [ImageModel]
    {
        var images = [ImageModel]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "responsestatus = '0'")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "filesize", ascending: true)]
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            print(result)
            
            if (result.count > 0) {
                
                for user in result
                {
                    let person = user as! NSManagedObject
                    print("Table  - \(person)")
                    
                    let img = ImageModel(
                        mPath: URL(string: String(describing: person.value(forKey: "imagepath")))!,
                        mResponseStatus: Int(String(describing: person.value(forKey: "responsestatus")!))!,
                        mTrashPath: String(describing: person.value(forKey: "trashpath")),
                        identifier : String(describing: person.value(forKey: "path")!))
                    
                   // print("filesize \(person.value(forKey: "filesize")!)")
                    
                    print("fetchasset \(img.getIdentifier())")
                    img.setPHAsset(asset: PHAsset.fetchAssets(withLocalIdentifiers: [img.getIdentifier()], options: nil)[0])
                    if let size=person.value(forKey: "filesize")
                    {
                        img.setFileSize(fileSize: Int64(String(describing: size))!)
                        print("filesize \(size)")
                    }
                    images.append(img)
                }
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return images
    }
    
    
    func getTotalImageCount() -> Int {
        
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
//
//        // Create Entity Description
//        let entityDescription = NSEntityDescription.entity(forEntityName: "Images", in: self.managedObjectContext)
//
//        // Configure Fetch Request
//        fetchRequest.entity = entityDescription
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "responsestatus = '3' OR responsestatus = '0' OR responsestatus = '1'")
        
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            print(result)
            
            return result.count
            
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return 0
        }
    }
    
    
    func isPresent(mPath: String) -> Bool
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "path = '\(mPath)'")
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            print(result)
            
            if (result.count > 0) {
                return true
            }
            else
            {
                return false
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return false
        }
    }
    
    func updateFileSize(fileSize: Int64,mPath : String) -> Bool
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Images")
        let predicate = NSPredicate(format: "path = '\(mPath)'")
        fetchRequest.predicate = predicate
        
        do
        {
            let test = try self.managedObjectContext.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(String(fileSize), forKey: "filesize")
                //objectUpdate.setValue(actionStatus, forKey: "actionstatus")
                
                do{
                    try self.managedObjectContext.save()
                    return true
                }
                catch
                {
                    print(error)
                    return false
                }
            }
        }
        catch
        {
            print(error)
            return false
        }
        
        return false
        
    }
    
    
    func insertImageWithIdentifier(img : ImageModel) -> Bool{
        
        if(!isPresent(mPath: img.getIdentifier()))
        {
            let managedContext = managedObjectContext
            //NSPersistentStoreCoordinator.viewContext as! NSManagedObjectContext
            
            // 2
            let entity =
                NSEntityDescription.entity(forEntityName: "Images",
                                           in: managedContext)!
            
            let person = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            print("identifier",img.getIdentifier())
            print("path ",String(describing: img.getPath()))
            print("response status ",String(describing: img.getResponseStatus()))
            print("Trash Path ",img.getTrashPath())
            print("action status ",String(describing:img.getActionStatus()))
            
            
            // 3
            person.setValue(img.getIdentifier(), forKeyPath: "path")
            person.setValue(String(describing: img.getPath()), forKeyPath: "imagepath")
            person.setValue(String(describing: img.getResponseStatus()), forKeyPath: "responsestatus")
            person.setValue(img.getTrashPath(), forKeyPath: "trashpath")
            person.setValue(String(describing:img.getActionStatus()), forKeyPath: "actionstatus")
            person.setValue(String(getSizeFromIdentifier(identifier: img.getIdentifier())), forKeyPath: "filesize")
            
            
           // person.isInserted
            // 4
//            if !person.isInserted {
//                managedContext.insert(person)
//                print("inserted")
//            }
//            else{
//                 print("not inserted")
//            }
            
            do {
                try managedContext.save()
                //people.append(person)
                return true
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
                return false
            }
            
        }
        else{
            
            print("Image already present")
            return false
        }
    }
    
    func updateImageInDB(mPath: String,responseStatus : String, actionStatus : String) -> Bool
    {
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Images")
        let predicate = NSPredicate(format: "path = '\(mPath)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try self.managedObjectContext.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(responseStatus, forKey: "responsestatus")
                objectUpdate.setValue(actionStatus, forKey: "actionstatus")
                
                do{
                    try self.managedObjectContext.save()
                    return true
                }
                catch
                {
                    print(error)
                    return false
                }
            }
        }
        catch
        {
            print(error)
            return false
        }
        
        return false
    }
    
    func isScannedWithIdentifier(identifier: String) -> Bool
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "path = '\(identifier)'")
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            print(result)
            
            if (result.count > 0) {
                
                for user in result
                {
                    let person = user as! NSManagedObject
                    
                    print("Table  - \(person)")
                    
                    if let first = person.value(forKey: "responsestatus") {
                        print("Table Path \(first)")
                        if(Int(String(describing: first)) == 0 )
                        {
                            print("RESPONSE_STATUS","-1")
                            return false
                        }
                        else
                        {
                            print("RESPONSE_STATUS","1")
                            return true
                        }
                        
                    }
                    else{
                        print("identifier not present in DB")
                        return false
                    }
                    break
                }
                
                return false
            }
            else
            {
                return false
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return false
        }
    }
    
    func getJunkImages() -> [ImageModel] {
        
        var images = [ImageModel]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "responsestatus = '1' AND actionstatus = '1'")
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            print(result)
            
            if (result.count > 0) {
                
                for user in result
                {
                    let person = user as! NSManagedObject
                    
                    print("Table  - \(person)")
                    
                    let img = ImageModel(
                        mPath: URL(string: String(describing: person.value(forKey: "imagepath")))!,
                        mResponseStatus: Int(String(describing: person.value(forKey: "responsestatus")!))!,
                        mTrashPath: String(describing: person.value(forKey: "trashpath")),
                        identifier : String(describing: person.value(forKey: "path")!))
                    
                    print("fetchasset \(img.getIdentifier())")
                    
                    img.setPHAsset(asset: PHAsset.fetchAssets(withLocalIdentifiers: [img.getIdentifier()], options: nil)[0])
                    
                    images.append(img)
                    
                    print(person.value(forKey: "path") ?? "no path")
                    
                }
                // print("2 - \(person)")
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return images
        
    }
    
    func getJunkImagesCount() -> Int {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "responsestatus = '1' AND actionstatus = '1'")
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            print(result)
            
            return result.count
            
            
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            
            return 0
        }
        
        
    }
    //
    
    func getTrashImages() -> [ImageModel] {
        
        var images = [ImageModel]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "responsestatus = '2' AND actionstatus = '1'")
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            print(result)
            
            if (result.count > 0) {
                
                for user in result
                {
                    let person = user as! NSManagedObject
                    
                    print("Table  - \(person)")
                    
                    let identifier=String(describing: person.value(forKey: "trashpath")!)
                    
                    let img = ImageModel(
                        mPath: URL(string: String(describing: person.value(forKey: "imagepath")))!,
                        mResponseStatus: Int(String(describing: person.value(forKey: "responsestatus")!))!,
                        mTrashPath:((SplashViewController.logsPath?.appendingPathComponent(identifier))?.path)!, identifier : String(describing: person.value(forKey: "path")!))
                    
                   
                   // img.setPHAsset(asset: PHAsset.fetchAssets(withLocalIdentifiers: [img.getIdentifier()] , options: nil)[0])
                    
                        images.append(img)
                    
                    print(person.value(forKey: "path"))
                    
                }
                // print("2 - \(person)")
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return images
        
    }
    
    func getAllImages() -> [String]
    {
        var images = [String]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "responsestatus = '0' OR responsestatus = '1' OR responsestatus = '3'")
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            print(result)
            
            if (result.count > 0) {
                
                for user in result
                {
                    let person = user as! NSManagedObject
                    
                    print("Table  - \(person)")
                    
                    //                    let img = ImageModel(
                    //                        mPath: URL(string: String(person.value(forKey: "imagepath")))!,
                    //                        mResponseStatus: Int(String(person.value(forKey: "responsestatus")))!,
                    //                        mTrashPath: String(person.value(forKey: "trashpath")) ,
                    //                        identifier : String(person.value(forKey: "path")))
                    //
                    //                    img.setPHAsset(asset: PHAsset.fetchAssets(withLocalIdentifiers: person.value(forKey: "path"), options: nil)[0])
                    //
                    images.append(String(describing: person.value(forKey: "path")!))
                    
                    print("identifiers \(person.value(forKey: "path")!)")
                }
                // print("2 - \(person)")
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return images
        
    }
    
    
    func getScannedImages() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "responsestatus = '1' OR responsestatus = '3'")
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            print(result)
            
            return result.count
            
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return 0
        }
    }
    
    func deleteContact(mPath: String) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        fetchRequest.predicate = NSPredicate(format: "path = '\(mPath)'")
        
        do {
            
            if let result = try? self.managedObjectContext.fetch(fetchRequest) {
                for object in result {
                    self.managedObjectContext.delete(object as! NSManagedObject)
                    return true
                }
            }
            
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    func deleteContacts(mPath: [String]) -> Bool {
        do {
            
            for identifier in mPath
            {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
                fetchRequest.predicate = NSPredicate(format: "path = '\(identifier)'")
                
                do {
                    
                    if let result = try? self.managedObjectContext.fetch(fetchRequest) {
                        for object in result {
                            self.managedObjectContext.delete(object as! NSManagedObject)
                            
                        }
                    }
                    
                } catch {
                    print("Delete failed")
                }
                
            }
            
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    
    func updateTrashTransaction(mPath: String,trashPath : String) -> Bool
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Images")
        let predicate = NSPredicate(format: "path = '\(mPath)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try self.managedObjectContext.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue(trashPath, forKey: "trashpath")                
                do{
                    try self.managedObjectContext.save()
                    return true
                }
                catch
                {
                    print(error)
                    return false
                }
            }
        }
        catch
        {
            print(error)
            return false
        }
        return false
    }
    
    func updateRecoveryTransaction(mPath: String , identifier : String) -> Bool
    {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Images")
        let predicate = NSPredicate(format: "path = '\(mPath)'")
        fetchRequest.predicate = predicate
        do
        {
            let test = try self.managedObjectContext.fetch(fetchRequest)
            if test.count == 1
            {
                let objectUpdate = test[0] as! NSManagedObject
                objectUpdate.setValue("3", forKey: "responsestatus")
                objectUpdate.setValue(identifier, forKey: "path")
                do{
                    try self.managedObjectContext.save()
                    return true
                }
                catch
                {
                    print(error)
                    return false
                }
            }
        }
        catch
        {
            print(error)
            return false
        }
        
        return false
    }
    
    func finishTrashTransaction(mPath: [String]) -> Bool
    {
        var returnVal : Bool = true
        for identifier in mPath
        {
            let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Images")
            let predicate = NSPredicate(format: "path = '\(identifier)'")
            fetchRequest.predicate = predicate
            do
            {
                let test = try self.managedObjectContext.fetch(fetchRequest)
                if test.count == 1
                {
                    let objectUpdate = test[0] as! NSManagedObject
                    objectUpdate.setValue("2", forKey: "responsestatus")
                    
                    do{
                        try self.managedObjectContext.save()
                        
                        if(returnVal)
                        {
                            returnVal = true
                        }
                    }
                    catch
                    {
                        print(error.localizedDescription)
                        returnVal = false
                    }
                }
            }
            catch
            {
                print(error)
                returnVal = false
            }
            
        }
        return returnVal
        
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
