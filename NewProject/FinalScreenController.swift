//
//  FinalScreenController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 18/08/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

class FinalScreenController: UIViewController {

    var deletionCount : Int?
    
    @IBOutlet weak var reviewTrash: UIView!
    
    @IBOutlet weak var shareAppView: UIView!
    
    @IBOutlet weak var negativeRating: UIButton!
    @IBOutlet weak var positiveRating: UIButton!
    @IBOutlet weak var shareApp: UIButton!
    @IBOutlet weak var viewTrash: UIButton!
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
   
    @IBOutlet weak var ratingView: UIView!
    
    @IBOutlet weak var headerText: UILabel!
    
   
    
    @IBAction func feedbackOnNegativeRating(_ sender: Any) {
        feedBackPopUp()
    }
    
    func feedBackPopUp()
    {
         GoogleAnalytics.shared.sendEvent(category: Constants.finalScreenName, action: Constants.feedback, label: "")
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Feedback", message: "", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "I dont like the app because "
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text)")
            if(textField?.text?.trimmingCharacters(in: [" "])=="")
            {
               GoogleAnalytics.shared.sendEvent(category: Constants.finalScreenName, action: Constants.feedback, label: "no review given")
            }
            else{
                GoogleAnalytics.shared.sendEvent(category: Constants.feedback, action: Constants.negative, label: (textField?.text)!)
            }
            
            self.ratingView.isHidden=true
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    

    
    @IBAction func rateApp(_ sender: Any) {
        rateApp(appId: "id959379869") { success in
            print("RateApp \(success)")
            
            GoogleAnalytics.shared.sendEvent(category: Constants.feedback, action: Constants.positive, label: "")
            
            self.ratingView.isHidden=true
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

         GoogleAnalytics.shared.signInGoogleAnalytics(custDimKey: Constants.resultScreen, custDimVal: String(describing : Preferences.shared.setResultScreenPreference()))
        
        if(deletionCount == 1)
        {
            headerText.text = "\(deletionCount!) Junk Photo Cleaned"
        }else
        {
            headerText.text = "\(deletionCount!) Junk Photos Cleaned"
        }
     
        reviewTrash.layer.cornerRadius = 8
        shareAppView.layer.cornerRadius = 8
        ratingView.layer.cornerRadius = 8
        shareApp.layer.cornerRadius = 15
        viewTrash.layer.cornerRadius = 15
        positiveRating.layer.cornerRadius = 15
        negativeRating.layer.cornerRadius = 15
        negativeRating.layer.borderWidth = 1
        negativeRating.layer.borderColor = UIColor.init(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red:2/255.0, green:199/255.0, blue:149/255.0, alpha: 1.0)
         self.navigationController?.navigationBar.tintColor = UIColor.init(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0)
       
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
         self.navigationController?.navigationBar.tintColor = UIColor.init(red:2/255.0, green:199/255.0, blue:149/255.0, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.finalScreenName)
    }
    
  
    
    @IBAction func shareAppFunction(_ sender: Any) {
        shareAppFunc()
    }
    
    func shareAppFunc()
    {
        
         GoogleAnalytics.shared.sendEvent(category: Constants.finalScreenName, action: Constants.share, label: "")
        
        let textToShare = "Hey, hi! you know I just tried out an app that lets you Clean Junk Whatsapp Images. So no need of manually searching Good Morning/Good Night photos anymore Try it! I think you'll find it useful"
        
        if let myWebsite = NSURL(string: "http://itunes.apple.com/app/id1290150652") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
            
            //activityVC.popoverPresentationController?.sourceView = self.
            self.present(activityVC, animated: true, completion: nil)
        }
    }
  
  
    @IBAction func FinalToTrashScreen(_ sender: Any) {
        GoogleAnalytics.shared.sendEvent(category: Constants.finalScreenName, action: Constants.trashBtn, label: "")
        performSegue(withIdentifier: "FinalToTrash", sender: nil)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "http://itunes.apple.com/app/id1290150652") else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }

}
