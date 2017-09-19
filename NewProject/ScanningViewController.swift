//
//  ScanningViewController.swift
//  NewProject
//
//  Created by Shashank Tiwari on 23/08/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

protocol VCFinalDelegate {
    func finishPassing(string: String)
}

class ScanningViewController: UIViewController {

    
    @IBOutlet weak var scanningText: UILabel!
    var delegate: VCFinalDelegate!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isUserInteractionEnabled = false
        
        scanningText.text = "Scanning \(DatabaseManagement.shared.getScannedImages())/\(DatabaseManagement.shared.getTotalImageCount())"

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {            
            
            var viewControllersArray = self.navigationController?.viewControllers
            viewControllersArray?.removeLast()
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "review_grid")
//            self.present(controller, animated: true, completion: nil)
            
            
//            let reviewViewC = ReviewViewController()
            
            viewControllersArray?.append(controller)
            
            self.navigationController?.setViewControllers(viewControllersArray!, animated: true)
            
            
//                self.navigationController?.popViewController(animated: true)
//            self.navigationController
//                self.delegate?.finishPassing(string: "Sent from VCFinal")
            
            
            
                /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "review_grid") as! ReviewViewController
                //self.present(nextViewController, animated:true, completion:nil)
                self.navigationController?.pushViewController(nextViewController, animated: true)
                */
                
                // topController should now be your topmost view controller
            
            
            
          
            
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
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
