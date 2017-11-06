//
//  HomeScreenViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 27/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftyGif

class HomeScreenViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VCFinalDelegate, ReviewDelegate, FinalDelegate  {
    
    
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var junkPhotoFound: UILabel!
    @IBOutlet weak var homeBkgImage: UIImageView!
    @IBOutlet weak var junkFoundView: UIStackView!
    
    @IBOutlet weak var junkNumber: UILabel!
    @IBOutlet var homeBackground: UIView!
    @IBOutlet weak var resultsLabel: UILabel!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var resultMessage : String?
    var totalImages=0,scannedImages=0
    var refresh = true
    //weak var weakSelf=self
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBAction func HomeToTrash(_ sender: Any) {
        
        GoogleAnalytics.shared.sendEvent(category: Constants.homeScreenName, action: Constants.trashBtn, label: "")
        
        performSegue(withIdentifier: "HomeToTrash", sender: nil)
        
        
    }
    
    func finishPassing(string: String) {
        print("Notified")
        
        performSegue(withIdentifier: "HomeToReview", sender: nil)
        
        /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         
         let nextViewController = storyBoard.instantiateViewController(withIdentifier: "review_grid") as! ReviewViewController
         //self.present(nextViewController, animated:true, completion:nil)
         self.navigationController?.pushViewController(nextViewController, animated: true)*/
    }
    
    func DeletionScreen(string: String) {
        
        print("Deletion screen")
        
        performSegue(withIdentifier: "HomeToDeletionProgress", sender: nil)
        
        /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         
         let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DeletingScreen") as! DeletionViewController
         //self.present(nextViewController, animated:true, completion:nil)
         self.navigationController?.pushViewController(nextViewController, animated: true)*/
    }
    
    func FinalScreen(string: String) {
        print("Deletion screen")
        
        performSegue(withIdentifier: "HomeToFinal", sender: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ScanningViewController {
            destination.delegate = self
        }
        
        if let destination = segue.destination as? ReviewViewController {
            destination.delegate = self
        }
        
        if let destination = segue.destination as? DeletionViewController {
            destination.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        homeBackground.backgroundColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0xFFFFFF)
        
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        
        let junkNumb = DatabaseManagement.shared.getContacts().count
        junkNumber.text=String(junkNumb)
        if(junkNumb != 0)
        {
            self.scanBtn.isEnabled=true
            self.scanBtn.backgroundColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0x23c795)
            self.scanBtn.layer.cornerRadius = 8
            self.scanBtn.layer.borderWidth = 1
            self.scanBtn.layer.borderColor = UIColor.init(red:35/255.0, green:199/255.0, blue:149/255.0, alpha: 1.0).cgColor
            self.scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
            
        }else{
            self.scanBtn.isEnabled=false
            self.scanBtn.backgroundColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0xdae0e7)
            self.scanBtn.layer.cornerRadius = 8
            self.scanBtn.layer.borderWidth = 1
            self.scanBtn.layer.borderColor = UIColor.init(red:218/255.0, green:224/255.0, blue:231/255.0, alpha: 1.0).cgColor
            self.scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
        }
        
        
        let dateFormatter = DateFormatter()
        let requestedComponent: Set<Calendar.Component> = [.year,.month,.day,.hour,.minute,.second]
        let userCalendar = Calendar.current
        
        
        dateFormatter.dateFormat = "ddMMyyhhmmss"
        let timeRightNow  = Date()
        let timeRightNowResult = dateFormatter.string(from: timeRightNow)
        
        let timePrevious  = Preferences.shared.getDayTimePreference()
        let startTime = dateFormatter.date(from: timePrevious)
        
        if startTime != nil {
            
            let timeDifference = userCalendar.dateComponents(requestedComponent, from: timeRightNow, to: startTime!)
            
            
            if let year = timeDifference.year { // If casting, use, eg, if let var = abc as? NSString
                // variableName will be abc, unwrapped
                if(year>0)
                {
                    let calendar = Calendar.current
                    let date = calendar.date(byAdding: .day, value: 1, to: startTime!)
                    let timeRightNowResult = dateFormatter.string(from: date!)
                    Preferences.shared.setDayTime(date: String(describing : timeRightNowResult))
                    //Preferences.shared.setDayCountDimension()
                    GoogleAnalytics.shared.signInGoogleAnalytics(custDimKey: Constants.dayCount, custDimVal:  Preferences.shared.setDayCountDimension())
                }
                
            }else if let month = timeDifference.month {
                // abc is nil
                if(month>0)
                {
                    let calendar = Calendar.current
                    let date = calendar.date(byAdding: .day, value: 1, to: startTime!)
                    let timeRightNowResult = dateFormatter.string(from: date!)
                    Preferences.shared.setDayTime(date: String(describing : timeRightNowResult))
                    //Preferences.shared.setDayCountDimension()
                    GoogleAnalytics.shared.signInGoogleAnalytics(custDimKey: Constants.dayCount, custDimVal: Preferences.shared.setDayCountDimension())
                }
            }else if let days = timeDifference.day
            {
                if(days > 0)
                {
                    let calendar = Calendar.current
                    let date = calendar.date(byAdding: .day, value: 1, to: startTime!)
                    let timeRightNowResult = dateFormatter.string(from: date!)
                    Preferences.shared.setDayTime(date: String(describing : timeRightNowResult))
                    //Preferences.shared.setDayCountDimension()
                    GoogleAnalytics.shared.signInGoogleAnalytics(custDimKey: Constants.dayCount, custDimVal:  Preferences.shared.setDayCountDimension())
                    
                }
            }
            
        }
        else
        {
            Preferences.shared.setDayTime(date: String(describing : timeRightNowResult))
            //Preferences.shared.setDayCountDimension()
            GoogleAnalytics.shared.signInGoogleAnalytics(custDimKey: Constants.dayCount, custDimVal:  Preferences.shared.setDayCountDimension())
        }
     
        
        backgroundDbCall(callRefresh: false)
        refreshScreen()
        
    }
    
    
    func backgroundDbCall(callRefresh :Bool)
    {
        var junkCount=0
        //var scannedImages = 0
        //var totalImages = 0
        DispatchQueue.global(qos:.background).async {
            
            junkCount =  DatabaseManagement.shared.getContacts().count
            self.scannedImages =  DatabaseManagement.shared.getScannedImages()
            self.totalImages = DatabaseManagement.shared.getTotalImageCount()
            
            
            DispatchQueue.main.async(execute: {
                
                if(self.totalImages==0)
                {
                    self.junkFoundView.isHidden=false
                    // self.scanningView.isHidden=true
                    self.junkNumber.text="Uh oh!"
                    self.junkPhotoFound.text = "No Photos Found"
                    self.scanBtn.isEnabled=false
                    self.homeBkgImage.image=UIImage(named:"no_photos_bkg")
                    
                    self.scanBtn.backgroundColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0xdae0e7)
                    self.scanBtn.layer.cornerRadius = 8
                    self.scanBtn.layer.borderWidth = 1
                    self.scanBtn.layer.borderColor = UIColor.init(red:218/255.0, green:224/255.0, blue:231/255.0, alpha: 1.0).cgColor
                    self.scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
                }
                else if(self.scannedImages >= self.totalImages && junkCount == 0)
                {
                    self.junkFoundView.isHidden=false
                    // self.scanningView.isHidden=true
                    self.junkNumber.text="Yay!"
                    self.junkPhotoFound.text = "No Junk Photos Found"
                    self.scanBtn.isEnabled=false
                    self.homeBkgImage.image=UIImage(named:"no_junk_bkg")
                    
                    self.scanBtn.backgroundColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0x23c795)
                    self.scanBtn.layer.cornerRadius = 8
                    self.scanBtn.layer.borderWidth = 1
                    self.scanBtn.layer.borderColor = UIColor.init(red:218/255.0, green:224/255.0, blue:231/255.0, alpha: 1.0).cgColor
                    
                    self.scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
                }
                else if(junkCount==0)
                {
                    self.junkFoundView.isHidden=false
                    // self.scanningView.isHidden=false
                    self.junkNumber.text="Scanning"
                    self.junkPhotoFound.text = "Images"
                    self.scanBtn.isEnabled=false
                    self.scanBtn.backgroundColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0xdae0e7)
                    self.scanBtn.layer.cornerRadius = 8
                    self.scanBtn.layer.borderWidth = 1
                    self.scanBtn.layer.borderColor = UIColor.init(red:218/255.0, green:224/255.0, blue:231/255.0, alpha: 1.0).cgColor
                    self.scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
                }
                else
                {
                    self.junkFoundView.isHidden=false
                    //self.scanningView.isHidden=true
                    self.junkNumber.text=String(junkCount)
                    self.junkPhotoFound.text = "Junk Photos Found"
                    self.scanBtn.isEnabled=true
                    
                    self.scanBtn.backgroundColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0x23c795)
                    self.scanBtn.layer.cornerRadius = 8
                    self.scanBtn.layer.borderWidth = 1
                    self.scanBtn.layer.borderColor = UIColor.init(red:35/255.0, green:199/255.0, blue:149/255.0, alpha: 1.0).cgColor
                    self.scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
                    
                }
            
                if(callRefresh)
                {
                    if(self.scannedImages==self.totalImages)
                    {
                        self.refresh=false
                        //self.scanningViewHeightConstraint.constant = 0
                        //self.scanningView.isHidden=true
                    }
            
                    if(self.refresh==true)
                    {
                        self.refreshScreen()
                    }
                }
            })
        }
    }
    
    
    func refreshScreen()
    {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            
            self.backgroundDbCall(callRefresh: true)
            
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.backgroundDbCall(callRefresh: false)
        
        GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.homeScreenName)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
         print("Memory warning")
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        refresh=false
    }
    
    
    @IBAction func scan(_ sender: UIButton) {
        
        print("Button pressed")
        
        GoogleAnalytics.shared.sendEvent(category: Constants.homeScreenName, action: Constants.scanBtn, label: "")
        
        performSegue(withIdentifier: "HomeToScanning", sender: nil)
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    /* @IBAction func ViewTap(_ sender: UITapGestureRecognizer) {
     
     resultsLabel.resignFirstResponder()
     
     // UIImagePickerController is a view controller that lets a user pick media from their photo library.
     let imagePickerController = UIImagePickerController()
     
     // Only allow photos to be picked, not taken.
     imagePickerController.sourceType = .photoLibrary
     
     // Make sure ViewController is notified when the user picks an image.
     imagePickerController.delegate = self
     present(imagePickerController, animated: true, completion: nil)
     
     
     
     }*/
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        UploadRequest(image: photoImageView)
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func UploadRequest(image : UIImageView)
    {
        let url = NSURL(string: "http://akshit92.pythonanywhere.com/")
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if (image.image == nil)
        {
            return
        }
        
        let image_data = UIImagePNGRepresentation(image.image!)
        
        
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
            
            guard let _:NSData = data! as NSData, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString ?? "No Data")
            
            self.resultsLabel.text = dataString! as String
            
        }
        
        task.resume()
        
    }
    
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
}
