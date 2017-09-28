//
//  CollectionViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 24/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"


class CollectionViewController: UICollectionViewController{

    
    var asset : [PHAsset]?
    var dataModel : [ImageModel]?
    @IBOutlet weak var collection: UICollectionView!
    
    @IBAction func onBackPressed(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        
      // self.collectionView!.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout // casting is required because UICollectionViewLayout doesn't offer header pin. Its feature of UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        // Register cell classes
       // self.collectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        asset=getAssetsFromAlbum(albumName: "WhatsApp")
        
        dataModel=getData()
        
        
        print("Total Photos",  asset?.count ?? "No Photos in whatsapp")
        
        
        
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData()
    {
        self.collection.reloadData()
       //self.tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataModel!.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell  else {
            fatalError("The dequeued cell is not an instance of CollectionViewCell.")
        }
        
    
        cell.backgroundColor=UIColor.blue
        if let imageView = cell.newImage{
            
                        
           // imageView.image = getAssetThumbnail(asset: (asset?[indexPath.row])!)
            //imageView.image = load(fileName: (dataModel?[indexPath.row].getPath())!)
            imageView.image = getImageFromIdentifier(identifier: (dataModel?[indexPath.row].getIdentifier())!)
           // imageView.image = getImage()
        }
        
        
        // Configure the cell
        
        return cell
    }

    // MARK: UICollectionViewDelegate


    // Uncomment this method to specify if the specified item should be highlighted during tracking
   /* override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }*/
 
    

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        /*guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell  else {
            fatalError("The dequeued cell is not an instance of CollectionViewCell.")
        }*/
        
        if let _cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                _cell.imageSelection()
        }
        
        
        
        
        
        
        
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
        dataModel=DatabaseManagement.shared.getContacts()
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
    
  

}
