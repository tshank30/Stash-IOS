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

class DatabaseManagement1
{
    static let teamId = Expression<Int64>("teamid")
    private let TAG = "DbUpdate";
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
    
    public static let shared:DatabaseManagement1=DatabaseManagement1()
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
    
    
    func tableExists(tableName: String) -> Bool {
        do{
            let exists  = try db!.scalar(
            "SELECT EXISTS(SELECT name FROM Images WHERE name = ?)", tableName
            ) as! Bool
            return exists
        }
        catch{
            return false
        }
    }
    
    func createDataBase() //done
    {
        
        if(!tableExists(tableName: "Images"))
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
    }
    
   
    
    
    func isPresent(mPath: String) -> Bool //done
    {
        do
        {
            for user in try (db?.prepare("SELECT * FROM Images WHERE Path = '\(mPath)'"))! {
                // print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
                print("identifier present",mPath)
                return true
                // id: Optional(2), email: Optional("betty@icloud.com")
                // id: Optional(3), email: Optional("cathy@icloud.com")
            }
            //try db?.execute("SELECT * FROM Images WHERE Path='\(mPath)'")
            
        }catch{
            print("identifier error ",error.localizedDescription)
            print("Image already present in DB")
            print("identifier not present",mPath)
            return false
        }
        
        return false
    }
    
    
    
    
    
    func insertImageWithIdentifier(img : ImageModel) -> Bool //done
    {
        if(isPresent(mPath: img.getIdentifier())==false)
        {
            let query = images?.insert(self.IMAGE_PATH <- img.getPath().path, self.PATH <- img.getIdentifier(), self.RESPONSE_STATUS <- "\(img.getResponseStatus())",self.TRASH_PATH <- "",self.ACTION_STATUS <- "\(img.getActionStatus())",self.FILE_SIZE <- "",self.SCORE <- "",self.IMAGE_TYPE <- "",self.HIT_COUNT <- "",self.LAST_MODIFIED_DATE <- "",self.IMAGE_TAGS<-"")
            do
            {
                let rowid = try db?.run(query!)
                print(rowid ?? "" ," Row insertion")
                return false
            }
            catch{
                print("Error info: \(error)")
                return false
            }
        }
        else
        {
            print("image already present")
            return true
        }
        
    }
    
    
    func updateImageInDB(mPath: String,responseStatus : String, actionStatus : String) -> Bool  //done
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
    

    
    func isScannedWithIdentifier(identifier: String) -> Bool  //done
    {
        do
        {
            let contact = self.images?.filter(PATH == identifier)
            //db!.run(contact?.count)
            
            for user in try (db?.prepare(contact!))! {
                print("id: \(user[PATH]), name: \(user[RESPONSE_STATUS]), email: \(user[TRASH_PATH])")
                // id: 1, name: Optional("Alice"), email: alice@mac.com
                
                if(Int(user[RESPONSE_STATUS]) == 0 )
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
    
    
    
    func getJunkImages() -> [ImageModel] { //done
        
        let dateFormatter = DateFormatter()
        let requestedComponent: Set<Calendar.Component> = [.year,.month,.day,.hour,.minute,.second]
        let userCalendar = Calendar.current
        
        
        dateFormatter.dateFormat = "ddMMyyhhmmss"
        let timeRightNow  = Date()
        let timeRightNowResult = dateFormatter.string(from: timeRightNow)
        
        
        
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
        
        
        let timePrevious  = Preferences.shared.getDayTimePreference()
        let startTime = dateFormatter.date(from: timePrevious)
        
        let timeRightNow2  = Date()
        let timeRightNowResult2 = dateFormatter.string(from: timeRightNow2)
        
        if timeRightNow2 != nil {
            
            let timeDifference = userCalendar.dateComponents(requestedComponent, from: timeRightNow, to: timeRightNow2)
            
            print("execution time",timeDifference.second)
        }
        return images
    }
    
    
    
    func getTrashImages() -> [ImageModel] { //done
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
    
    func getAllImages() -> [String] { //done
        var images = [String]()
        
        do {
            for contact in try db!.prepare(self.images!) {
                if(Int(contact[RESPONSE_STATUS]) != 2)
                {
                    images.append(contact[PATH])
                    print("Identifier",contact[PATH], "\n")
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
                    //                else if(Int(contact[RESPONSE_STATUS]) == 2)
                    //                {
                    //                    images=images+1
                    //                }
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
    
    
    
    func getTotalImageCount() -> Int { //done
        
        do {
            var x=0
            
            for contact in try db!.prepare(self.images!) {
                
                if(Int(contact[RESPONSE_STATUS]) != 2)
                {
                    x=x+1
                }
                
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
