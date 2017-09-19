//
//  DeletionViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 23/08/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit


protocol FinalDelegate {
    func FinalScreen(string: String)
}

class DeletionViewController: UIViewController {

    @IBOutlet weak var deletionScreenText: UILabel!
    
    var delegate: FinalDelegate?
    var deletionNumber : Int!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isUserInteractionEnabled = false
        
        if(deletionNumber==1)
        {
        deletionScreenText.text="Deleting \(String(describing: deletionNumber!)) photo"
        }
        else{
            deletionScreenText.text="Deleting \(String(describing: deletionNumber!)) photos"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            
            print("Deletion done")
            
            
            var viewControllersArray = self.navigationController?.viewControllers
            viewControllersArray?.removeLast()
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "finalScreen") as! FinalScreenController
            //            self.present(controller, animated: true, completion: nil)
            controller.deletionCount=self.deletionNumber
        
            //            let reviewViewC = ReviewViewController()
            
            viewControllersArray?.append(controller)
          
            
            self.navigationController?.setViewControllers(viewControllersArray!, animated: true)
            
            
            
//            self.navigationController?.popViewController(animated: false)
//
//            //self.performSegue(withIdentifier: "DeletionProgress", sender: nil)
//            
//            self.delegate?.FinalScreen(string: "Sent from DeletionController")
//            
            /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "finalScreen")
                    
                    //self.navigationController?.popViewController(animated: true)
                    
                    topController.dismiss(animated: true, completion: nil)
                    
                    topController.present(nextViewController, animated:true, completion:nil)
                    
                    
                }
                
                // topController should now be your topmost view controller
            }*/
            
            
            
            
        })
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
     
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        GoogleAnalytics.shared.sendScreenTracking(screenName: Constants.deletionScreenName)
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
