//
//  Receiver.swift
//  NewProject
//
//  Created by Shashank Tiwari on 28/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

class Receiver: UIViewController {

    @IBOutlet weak var receiverLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(Receiver.actOnSpecialNotification), name: NSNotification.Name(rawValue: mySpecialNotificationKey), object: nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func actOnSpecialNotification(notification: NSNotification) {
       if let label = notification.userInfo?["image"] as? UILabel {
        self.receiverLabel.text = label.text
        }
        
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
