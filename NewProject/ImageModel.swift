//
//  ImageModel.swift
//  NewProject
//
//  Created by Shashank Tiwari on 26/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import Foundation
import Photos

class ImageModel
{
    private var mPath : URL!
    private var mResponseStatus : Int = 0;
    private var mActionStatus : Int = 0;
    private var mTrashPath : String = "";
    private var fileSize : Int16 = 0;
    private var score : String = "" ;
    private var imageType : String = "";
    private var checked : Bool;
    private var hitCount : Int = 0;
    private var analyserType : Int = 0;
    private var tags : String = "";
    private var time : Int16 = 0;
    private var identifier : String = "";
    private var asset : PHAsset? = nil
    
    
    init()
    {
        mPath = URL(string: "https://www.apple.com")
        mResponseStatus=0
        mActionStatus=0
        mTrashPath=""
        fileSize=0
        score=""
        imageType=""
        checked=false
        hitCount=0;
        analyserType=0
        tags=""
        time=0
        identifier="";
                
    }
    
    init(mPath : URL,mResponseStatus : Int,mTrashPath : String, identifier : String) {
        self.mPath=mPath
        self.mResponseStatus=mResponseStatus
        self.mTrashPath=mTrashPath
        mActionStatus=0
        fileSize=0
        score=""
        imageType=""
        checked=false
        hitCount=0;
        analyserType=0
        tags=""
        time=0
        self.identifier=identifier
    }
    
    public func setPath(mPath : URL)
    {
        self.mPath=mPath
    }
    
    
    func setResponseStatus(mResponseStatus : Int)
    {
        self.mResponseStatus=mResponseStatus
    }
    
    func setChecked(checked : Bool)
    {
        self.checked=checked
    }
    
    func setIdentifier(identifier : String)
    {
       self.identifier=identifier
    }
    
    func getPath() -> URL
    {
        return self.mPath
    }
    
    func getResponseStatus()->Int
    {
        return self.mResponseStatus
    }
    
    func getChecked()->Bool
    {
        return self.checked
    }
    
    func getIdentifier() -> String
    {
        return self.identifier
    }
    
    func setActionStatus(status : Int)  {
         self.mActionStatus=status
    }
    
    func getActionStatus() -> Int
    {
        return self.mActionStatus
    }
    
    func getTrashPath() -> String
    {
        return self.mTrashPath

    }
    
    func setPHAsset(asset : PHAsset)
    {
        self.asset = asset
    }
    
    func getPHAsset() -> PHAsset
    {
        return self.asset!
        
    }

    
}
