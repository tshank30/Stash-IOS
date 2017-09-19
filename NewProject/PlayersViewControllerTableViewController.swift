//
//  PlayersViewControllerTableViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 18/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit
import Photos




class PlayersViewControllerTableViewController: UITableViewController {

    var players = [Player]()
    var images = [UIImage]()
    var photo : UIImage?
    var asset : [PHAsset]?
    var url : [URL]?
    var someDict =  [URL: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // self.url = [URL](repeating: URL(string : "nil")!, count: results.count)
        
        let myString = "Hello, World!"
        print(myString)
        
        url=[URL]()
        
        
                
        let player1=Player(name:"Bill Evans", game:"Tic-Tac-Toe", rating: 4)
        let player2=Player(name: "Oscar Peterson", game: "Spin the Bottle", rating: 5)
        let player3=Player(name: "Dave Brubeck", game: "Texas Hold 'em Poker", rating: 2)
        players.append(player1)
        players.append(player2)
        players.append(player3)
        
        asset=getAssetsFromAlbum(albumName: "WhatsApp")
        
        print("Total Photos",  asset?.count ?? "No Photos in whatsapp")
        
        //FetchCustomAlbumPhotos()
        
        
        
                // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        let myString = "memory warning"
        print(myString)
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return asset!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as? PlayerCellTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        
        cell.playerImage.image=getAssetThumbnail(asset: (asset?[indexPath.row])!)

        /*cell.playerImage.translatesAutoresizingMaskIntoConstraints = false;
        //let image    = UIImage(contentsOfFile:(url?[indexPath.row].path)!)
        
        if let data = NSData(contentsOfFile:(url?[indexPath.row].path)!) {
            cell.playerImage.image=UIImage(data: data as Data)!
            print("NSData present",indexPath.row)
        }
        else{
            cell.playerImage.image=nil
        }*/
       
        //cell.playerName.text=url?[indexPath.row].path
        
     
        return cell

    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
        
        for k in 0 ..< collection.count {
            let obj:AnyObject! = collection.object(at: k)
            if obj.title == albumName {
                if let assCollection = obj as? PHAssetCollection {
                    let results = PHAsset.fetchAssets(in: assCollection, options: options)
                    var assets = [PHAsset]()
                    
                    results.enumerateObjects({ (obj, index, stop) in
                        
                        if let asset = obj as? PHAsset {
                            assets.append(asset)
                            
                        }
                    })
                    
                    //initalaizeUrls(assets: assets)
                    return assets
                }
            }
        }
        return [PHAsset]()
    }
    
    func initalaizeUrls(assets : [PHAsset])
    {
        
        let x=assets.count;
        var y=0;
        for asset in assets
        {
            PHImageManager.default().requestImageData(for: asset, options: PHImageRequestOptions(), resultHandler:
            {
                    (imagedata, dataUTI, orientation, info) in
                    if info!.keys.contains(NSString(string: "PHImageFileURLKey"))
                    {
                            let path = info![NSString(string: "PHImageFileURLKey")] as! NSURL
                            print(path, asset.mediaType.rawValue )
    
                            self.url?.append(path.absoluteURL!)
                            y=y+1
                        print(x,"to reload",y)
                       // if(y==x)
                       // {
                            self.tableView.reloadData()
                            print("reload table view")
                            //self.refresher.endRefreshing()
                       // }
                            //self.url?.insert(path.absoluteURL!)
                            //let image    = UIImage(contentsOfFile:(path.absoluteURL?.path)!)
                            //cell.playerImage.image=image
                            //cell.playerName.text = path.absoluteURL?.absoluteString
                    }
            })
        }
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
    
    
  }
