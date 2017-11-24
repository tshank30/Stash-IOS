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

    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var scanningText: UILabel!
    var delegate: VCFinalDelegate!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
       // DatabaseManagement.shared.serialQueue.sync {
            let totalImages = DatabaseManagement.shared.getTotalImageCount()
            if(totalImages != 0)
            {
                scanningText.text = "Scanning \(DatabaseManagement.shared.getScannedImages())/\(totalImages)"
                self.progress.setProgress(Float(DatabaseManagement.shared.getScannedImages()*100/totalImages), animated: false)
            }
            else{
                scanningText.text = "Scanning 0 images"
                self.progress.setProgress(0,animated: false)
            }
       // }
        
        
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.isUserInteractionEnabled = false
        
        
        //progress.progress=Float(DatabaseManagement.shared.getScannedImages()*100/DatabaseManagement.shared.getTotalImageCount())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {            
            
            var viewControllersArray = self.navigationController?.viewControllers
            viewControllersArray?.removeLast()
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "review_grid")
//            self.present(controller, animated: true, completion: nil)
            
            
//            let reviewViewC = ReviewViewController()
            
            viewControllersArray?.append(controller)
            
            self.navigationController?.setViewControllers(viewControllersArray!, animated: true)
            
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
