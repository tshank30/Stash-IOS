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
            headerText.text = "\(deletionCount!) Photo moved to trash"
        }else
        {
            headerText.text = "\(deletionCount!) Photos moved to trash"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.finalScreenName)
    }
    
  
    @IBAction func shareAppFunction(_ sender: Any) {
    
        shareApp()
    }
    
    func shareApp()
    {
        
         GoogleAnalytics.shared.sendEvent(category: Constants.finalScreenName, action: Constants.share, label: "")
        
        let textToShare = "Swift is awesome!  Check out this website about it!"
        
        if let myWebsite = NSURL(string: "http://www.codingexplorer.com/") {
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
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
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
