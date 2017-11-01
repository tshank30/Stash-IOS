//
//  ImageZoomViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 27/10/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
///Users/shashanktiwari/Downloads/MBProgressHUD-master/MBProgressHUD.h

import UIKit
import Photos


protocol VCImageZoomDelegate {
    func selectImage(string: Int, selected : Bool)
}

class ImageZoomViewController: UIViewController, EFImageViewZoomDelegate {

   
    @IBOutlet weak var selectedText: UIButton!
    @IBOutlet weak var selectorImage: UIButton!
    var delegate:VCImageZoomDelegate!
    var data: Data?
    var identifier : String?
    var position : Int = -1
    var selected : Bool = false
    
    @IBOutlet weak var imageViewZoom: EFImageViewZoom!
    @IBInspectable public var _minimumZoomScale: CGFloat = 1.0
    @IBInspectable public var _maximumZoomScale: CGFloat = 6.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageViewZoom._delegate = self
        //self.imageViewZoom.image = UIImage(named: "reviewTrashIllustration.png")
        self.imageViewZoom.image = getImageFromIdentifier(identifier: identifier!)
        self.imageViewZoom.contentMode = .left
        imageViewZoom._maximumZoomScale=6.0
        imageViewZoom._minimumZoomScale=1.0
        
        if(selected)
        {
            selectedText.setTitle("Selected", for: .normal)
            let btnImage = UIImage(named: "checked.png")
            selectorImage.setImage(btnImage , for: UIControlState.normal)
        }
        else{
            selectedText.setTitle("Select", for: .normal)
             let btnImage = UIImage(named: "none_selected.png")
            selectorImage.setImage(btnImage , for: UIControlState.normal)
        }
        
        
    }
    
    @IBAction func imageSelection(_ sender: Any) {
        self.delegate.selectImage(string: position,selected: !selected)
        navigationController?.popViewController(animated: true)
    }
    @IBAction func selectUnselectImage(_ sender: Any) {
        self.delegate.selectImage(string: position,selected: !selected)
        navigationController?.popViewController(animated: true)
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
        manager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }

}
