//
//  SenderViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 28/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

let mySpecialNotificationKey = "com.andrewcbancroft.specialNotificationKey"

class SenderViewController: UIViewController {

    @IBOutlet weak var senderLabel: UILabel!
    var imageDataDict :[String: UILabel]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageDataDict = ["image": senderLabel]
        
        NotificationCenter.default.addObserver(self, selector: #selector(SenderViewController.updateNotificationSentLabel), name: NSNotification.Name(rawValue: mySpecialNotificationKey), object: nil)
        

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendNotification(_ sender: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: mySpecialNotificationKey), object: self,userInfo : self.imageDataDict)
    }
    
    func updateNotificationSentLabel() {
        self.senderLabel.text = "Notification sent!"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
