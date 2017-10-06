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
    @IBOutlet weak var scanningView: UIStackView!
    @IBOutlet weak var junkFoundView: UIStackView!
    @IBOutlet weak var ghost: UIImageView!
    @IBOutlet weak var junkNumber: UILabel!
    @IBOutlet var homeBackground: UIView!
    @IBOutlet weak var resultsLabel: UILabel!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var resultMessage : String?
    var totalImages=0

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

        navigationController?.navigationBar.barTintColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0x1D8C7E)
        homeBackground.backgroundColor = UtilityMethods.shared.UIColorFromRGB(rgbValue: 0x1D8C7E)
        

        navigationController?.navigationBar.barStyle = UIBarStyle.black
        navigationController?.navigationBar.tintColor = UIColor.white
        
        junkNumber.text=String(DatabaseManagement.shared.getContacts().count)
        
        
        
        
    
        
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
        
        
        let junkCount=DatabaseManagement.shared.getContacts().count
        
        let gifManager = SwiftyGifManager(memoryLimit:20)
        let gif = UIImage(gifName: "loading_gif")
        self.gifImageView.setGifImage(gif, manager: gifManager)
        
        totalImages = DatabaseManagement.shared.getTotalImageCount()
        
        
        if(totalImages==0)
        {
            junkFoundView.isHidden=false
            scanningView.isHidden=true
            junkNumber.text="NO"
            junkPhotoFound.text = "PHOTOS FOUND"
            scanBtn.isEnabled=false
            
            scanBtn.backgroundColor = UIColor.gray
            scanBtn.layer.cornerRadius = 25
            
            scanBtn.layer.borderWidth = 1
            scanBtn.layer.borderColor = UIColor.gray.cgColor
            scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
        }
        else if(junkCount==0)
        {
            junkFoundView.isHidden=true
            scanningView.isHidden=false
            scanBtn.isEnabled=false
            
            scanBtn.backgroundColor = UIColor.gray
            scanBtn.layer.cornerRadius = 25
            
            scanBtn.layer.borderWidth = 1
            scanBtn.layer.borderColor = UIColor.gray.cgColor
            scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
        }
        else
        {
            junkFoundView.isHidden=false
            scanningView.isHidden=true
            junkNumber.text=String(junkCount)
            junkPhotoFound.text = "JUNK FOUND"
             scanBtn.isEnabled=true
            
            scanBtn.backgroundColor = UIColor.white
            scanBtn.layer.cornerRadius = 25
            
            scanBtn.layer.borderWidth = 1
            scanBtn.layer.borderColor = UIColor.white.cgColor
            scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let junkCount=DatabaseManagement.shared.getContacts().count
        
        if(totalImages==0)
        {
            junkFoundView.isHidden=false
            scanningView.isHidden=true
            junkNumber.text="NO"
            junkPhotoFound.text = "PHOTOS FOUND"
            scanBtn.isEnabled=false
            
            scanBtn.backgroundColor = UIColor.gray
            scanBtn.layer.cornerRadius = 25
            
            scanBtn.layer.borderWidth = 1
            scanBtn.layer.borderColor = UIColor.gray.cgColor
            scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
        }
        else if(junkCount==0)
        {
            junkFoundView.isHidden=true
            scanningView.isHidden=false
            scanBtn.isEnabled=false
            scanBtn.backgroundColor = UIColor.gray
            scanBtn.layer.cornerRadius = 25
            
            scanBtn.layer.borderWidth = 1
            scanBtn.layer.borderColor = UIColor.gray.cgColor
            scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
        }
        else
        {
            junkFoundView.isHidden=false
            scanningView.isHidden=true
            junkNumber.text=String(junkCount)
            junkPhotoFound.text = "JUNK FOUND"
            scanBtn.isEnabled=true
            
            scanBtn.backgroundColor = UIColor.white
            scanBtn.layer.cornerRadius = 25
            
            scanBtn.layer.borderWidth = 1
            scanBtn.layer.borderColor = UIColor.white.cgColor
            scanBtn.titleLabel?.textAlignment = NSTextAlignment.center
            
        }
        GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.homeScreenName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func scan(_ sender: UIButton) {
        
        print("Button pressed")
        
        GoogleAnalytics.shared.sendEvent(category: Constants.homeScreenName, action: Constants.scanBtn, label: "")
        
        performSegue(withIdentifier: "HomeToScanning", sender: nil)
        
        //let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
       // let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Scanning") as! ScanningViewController
        //self.present(nextViewController, animated:true, completion:nil)
        //self.navigationController?.pushViewController(nextViewController, animated: true)
        
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
