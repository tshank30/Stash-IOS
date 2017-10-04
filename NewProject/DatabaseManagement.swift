//
//  DatabaseManagement.swift
//  NewProject
//
//  Created by Shashank Tiwari on 25/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import Foundation
import SQLite
import Photos

class DatabaseManagement
{
    static let teamId = Expression<Int64>("teamid")
    private let  TAG = "DbUpdate";
    public  let IMAGES_TB = "Images";
    public  let PATH = Expression<String>("Path");
    public  let IMAGE_PATH = Expression<String>("ImagePath");
    public  let RESPONSE_STATUS = Expression<String>("ResponseStatus");
    public  let ACTION_STATUS = Expression<String>("ActionStatus");
    public  let FILE_SIZE = Expression<String>("FileSize");
    public  let SCORE = Expression<String>("Score");
    public  let IMAGE_TYPE = Expression<String>("ImageType");
    public  let HIT_COUNT = Expression<String>("Hit");
    public  let ANALYSER_TYPE = Expression<String>("Analyser");
    public  let LAST_MODIFIED_DATE = Expression<String>("LastModifiedDate");
    public  let TRASH_PATH = Expression<String>("TrashPath");
    public  let IMAGE_TAGS = Expression<String>("Tags");
    var images: Table?
    
    static let shared:DatabaseManagement=DatabaseManagement()
    private let db:Connection?
    
    private init()
    {
        let path=NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do{
            db=try Connection("\(path)/ishop.sqlite3")
            print("Database is open")
            // create table
        }
        catch{
            db=nil
            print("Unable to open database")
        }
    }
    
    
    
    func createDataBase()
    {
        
        images = Table("Images")
        do{
            try db?.run((images?.create(ifNotExists: true) { t in     // CREATE TABLE "users" (
                t.column(PATH) //     "id" INTEGER PRIMARY KEY NOT NULL,
                t.column(IMAGE_PATH)
                t.column(RESPONSE_STATUS)  //     "email" TEXT UNIQUE NOT NULL,
                t.column(ACTION_STATUS)
                t.column(FILE_SIZE)
                t.column(SCORE)
                t.column(IMAGE_TYPE)
                t.column(HIT_COUNT)
                t.column(LAST_MODIFIED_DATE)
                t.column(IMAGE_TAGS)
                t.column(TRASH_PATH)
                })!)
            print("Table Created")

        }
        catch{
             print("Table not Created")
        }
    }
    
    func isPathPresent(mPath: String) -> Bool
    {
        do
        {
            let contact = self.images?.filter(IMAGE_PATH == mPath)
            //db!.run(contact?.count)
            for user in try (db?.prepare(contact!))! {
                print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
                return true
            }
            
        }catch{
            print("Image already present in DB")
            return false
        }
        
        return false
    }

    
    func isPresent(mPath: String) -> Bool
    {
        do
        {
            let contact = self.images?.filter(PATH == mPath)
            //db!.run(contact?.count)
            for user in try (db?.prepare(contact!))! {
                print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
                return true
            }
            
        }catch{
            print("Image already present in DB")
            return false
        }
        
        return false
    }

    
    
    func insertImage(img : ImageModel)
    {
        if(isPresent(mPath: img.getPath().path)==false)
        {
            let query = images?.insert(self.IMAGE_PATH <- img.getPath().path, self.PATH <- img.getPath().path, self.RESPONSE_STATUS <- "\(img.getResponseStatus())",self.TRASH_PATH <- "",self.ACTION_STATUS <- "",self.FILE_SIZE <- "",self.SCORE <- "",self.IMAGE_TYPE <- "",self.HIT_COUNT <- "",self.LAST_MODIFIED_DATE <- "",self.IMAGE_TAGS<-"")
            do{
                let rowid = try db?.run(query!)
                print(rowid ?? "" ," Row insertion")
            }
            catch{
                print("Error info: \(error)")
            }
        }
        else
        {
            print("image already present")
        }
        
    }
    
    func insertImageWithIdentifier(img : ImageModel)
    {
        if(isPresent(mPath: img.getIdentifier())==false)
        {
            let query = images?.insert(self.IMAGE_PATH <- img.getPath().path, self.PATH <- img.getIdentifier(), self.RESPONSE_STATUS <- "\(img.getResponseStatus())",self.TRASH_PATH <- "",self.ACTION_STATUS <- "\(img.getActionStatus())",self.FILE_SIZE <- "",self.SCORE <- "",self.IMAGE_TYPE <- "",self.HIT_COUNT <- "",self.LAST_MODIFIED_DATE <- "",self.IMAGE_TAGS<-"")
            do{
                let rowid = try db?.run(query!)
                print(rowid ?? "" ," Row insertion")
            }
            catch{
                print("Error info: \(error)")
            }
        }
        else
        {
            print("image already present")
        }
        
    }
    
    
    func updateImageInDB(mPath: String,responseStatus : String, actionStatus : String) -> Bool
    {
        do
        {
            let contact = self.images?.filter(PATH == mPath)
            //db!.run(contact?.count)
            
            try db?.run((contact?.update(RESPONSE_STATUS <- responseStatus,ACTION_STATUS <- actionStatus))!)
            return true
           /* for user in try (db?.prepare(contact!))! {
                print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
                return true
            }*/
            
        }catch{
            print("Image already present in DB")
            return false
        }
        return false
    }
    
    func updateImageInDBUsingPath(mPath: String,responseStatus : String, actionStatus : String) -> Bool
    {
        do
        {
            let contact = self.images?.filter(PATH == mPath)
            //db!.run(contact?.count)
            
            try db?.run((contact?.update(RESPONSE_STATUS <- responseStatus,ACTION_STATUS <- actionStatus))!)
            return true
            /* for user in try (db?.prepare(contact!))! {
             print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
             // id: 1, name: Optional("Alice"), email: alice@mac.com
             return true
             }*/
            
        }catch{
            print("Error updating the status")
            return false
        }
        return false
    }
    
    
    func isScanned(mPath: String) -> Bool
    {
        do
        {
            let contact = self.images?.filter(PATH == mPath)
            //db!.run(contact?.count)
            
            for user in try (db?.prepare(contact!))! {
                print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
                
                if(Int(user[RESPONSE_STATUS]) == 1)
                {
                    print("RESPONSE_STATUS","1")
                    return true
                }
                else
                {
                    print("RESPONSE_STATUS","-1")
                    return false
                }
            }
            /* for user in try (db?.prepare(contact!))! {
             print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
             // id: 1, name: Optional("Alice"), email: alice@mac.com
             return true
             }*/
            
        }catch{
            
            print("error : No image in db with \(mPath)")
            return false
        }
        return false
    }
    
    func isScannedWithIdentifier(identifier: String) -> Bool
    {
        do
        {
            let contact = self.images?.filter(PATH == identifier)
            //db!.run(contact?.count)
            
            for user in try (db?.prepare(contact!))! {
                print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
                
                if(Int(user[RESPONSE_STATUS]) == 1)
                {
                    print("RESPONSE_STATUS","1")
                    return true
                }
                else
                {
                    print("RESPONSE_STATUS","-1")
                    return false
                }
            }
            /* for user in try (db?.prepare(contact!))! {
             print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
             // id: 1, name: Optional("Alice"), email: alice@mac.com
             return true
             }*/
            
        }catch{
            
            print("error : No image in db with \(identifier)")
            return false
        }
        return false
    }
    
    
    
    func getContacts() -> [ImageModel] {
        var images = [ImageModel]()
        
        do {
            for contact in try db!.prepare(self.images!) {
                if(Int(contact[RESPONSE_STATUS]) == 1  && Int(contact[ACTION_STATUS]) == 1)
                {
                    let img = ImageModel(
                        mPath: URL(string: contact[PATH])!,
                        mResponseStatus: Int(contact[RESPONSE_STATUS])!,
                        mTrashPath: contact[TRASH_PATH],
                        identifier : contact[PATH])
                    
                    //img.setChecked(checked: true)
                    
                     img.setPHAsset(asset: PHAsset.fetchAssets(withLocalIdentifiers: [contact[PATH]], options: nil)[0])
                    
                    images.append(img)
                   
                    print(contact[PATH])
                }
               // deleteContact(mPath: contact[PATH])
            }
        } catch {
            print("Select failed")
        }
        
        return images
    }
    
    
    func getIdentifiers() -> [String] {
        var images = [String]()
        
        do {
            for contact in try db!.prepare(self.images!) {
                if(Int(contact[RESPONSE_STATUS]) != 2 && Int(contact[ACTION_STATUS]) == 1)
                {
                    
                    images.append(contact[PATH])
                    
                    print(contact[PATH])
                }
                // deleteContact(mPath: contact[PATH])
            }
        } catch {
            print("Select failed")
        }
        
        return images
    }
    
    func getTrashImages() -> [ImageModel] {
        var images = [ImageModel]()
        
        do {
            for contact in try db!.prepare(self.images!) {
                if(Int(contact[RESPONSE_STATUS]) == 2 && Int(contact[ACTION_STATUS]) == 1)
                {
                    images.append(ImageModel(
                        mPath: URL(string: contact[PATH])!,
                        mResponseStatus: Int(contact[RESPONSE_STATUS])!,
                        mTrashPath: (SplashViewController.logsPath?.appendingPathComponent(contact[TRASH_PATH]).path)!,
                        identifier : contact[PATH]))
                    
                    print(contact[PATH])
                }
                // deleteContact(mPath: contact[PATH])
            }
        } catch {
            print("Select failed")
        }
        
        return images
    }
    
    func getScannedImages() -> Int {
        var images = 0
        
        do {
            for contact in try db!.prepare(self.images!) {
                if(Int(contact[RESPONSE_STATUS]) == 1)
                {
                    images=images+1
                }
                else if(Int(contact[RESPONSE_STATUS]) == 2)
                {
                    images=images+1
                }
                else if(Int(contact[RESPONSE_STATUS]) == 3)
                {
                    images=images+1
                }
                // deleteContact(mPath: contact[PATH])
            }
        } catch {
            print("Select failed")
        }
        
        return images
    }

    
    
    func getTotalImageCount() -> Int {
        
        do {
            var x=0
            
            for contact in try db!.prepare(self.images!) {
               
                x=x+1
                // deleteContact(mPath: contact[PATH])
            }
            
            return x
        } catch {
            print("Select failed")
        }
        
        return 0
    }
    
    
    
    func deleteContact(mPath: String) -> Bool {
        do {
            
            //let result = db.executeQuery("SELECT COUNT(*) FROM myTable", withArgumentsInArray: [])
            
            
            let contact = self.images?.filter(PATH == mPath)
            //db!.run(contact?.count)
            for user in try (db?.prepare(contact!))! {
                print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
            }            //rows.
            
            let x = try db!.run((contact?.delete())!)
            print("Deletion done",x)
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    func deleteContacts(mPath: [String]) -> Bool {
        do {
            
            //let result = db.executeQuery("SELECT COUNT(*) FROM myTable", withArgumentsInArray: [])
            
            for identifier in mPath
            {
                let contact = self.images?.filter(PATH == identifier)
                //db!.run(contact?.count)
                for user in try (db?.prepare(contact!))! {
                    print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
                    // id: 1, name: Optional("Alice"), email: alice@mac.com
                }            //rows.
            
                let x = try db!.run((contact?.delete())!)
                print("Deletion done",x)
            
            }
            
            return true
        } catch {
            print("Delete failed")
        }
        return false
    }
    
    
//    responsestatus ->
//    scanned = 1
//    not sanned = 0
//    trash = 2
//    recovered = 3
    
    //    actionStatus ->
    //    junk = 1
    //    not junk = -1
    //    ignored = 2

    
    func updateTrashTransaction(mPath: String,trashPath : String) -> Bool
    {
        do
        {
            let contact = self.images?.filter(PATH == mPath)
            //db!.run(contact?.count)
            
            try db?.run((contact?.update(TRASH_PATH <- trashPath))!)
            return true
            /* for user in try (db?.prepare(contact!))! {
             print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
             // id: 1, name: Optional("Alice"), email: alice@mac.com
             return true
             }*/
            
        }catch{
            print("Image already present in DB")
            return false
        }
        return false
    }
    
    
    func updateRecoveryTransaction(mPath: String , identifier : String) -> Bool
    {
        do
        {
            let contact = self.images?.filter(PATH == mPath)
            //db!.run(contact?.count)
            
            try db?.run((contact?.update(RESPONSE_STATUS <- "3", PATH <- identifier))!)
            return true
            /* for user in try (db?.prepare(contact!))! {
             print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
             // id: 1, name: Optional("Alice"), email: alice@mac.com
             return true
             }*/
            
        }catch{
            print("Image already present in DB")
            return false
        }
        return false
    }
    
    func finishTrashTransaction(mPath: [String]) -> Bool
    {
        do
        {
            for identifier in mPath
            {
                let contact = self.images?.filter(PATH == identifier)
                //db!.run(contact?.count)
            
                try db?.run((contact?.update(RESPONSE_STATUS <- "2"))!)
                
            
            }
            return true
            
        }catch{
            print("Trash Transation finished")
            return false
        }
        return false
    }
    
}
