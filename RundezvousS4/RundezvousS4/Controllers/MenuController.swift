//
//  MenuController.swift
//  RundezvousS4
//
//  Created by Niko Arellano on 2017-09-29.
//  Copyright © 2017 Mobilux. All rights reserved.
//

import UIKit

class MenuController: UIViewController {

    let MAIN_TO_MAP = "MainToMap"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startGame(_ sender: Any) {
        if Connectivity.isConnectedToInternet() {
            self.performSegue(withIdentifier: MAIN_TO_MAP, sender: nil)
        } else {
            self.alertTheUser(title: "No Network Found", message: "You need to have an internet connection to use Collab.")
        }
    }
    
    private func alertTheUser(title : String, message : String) {
        let alert = UIAlertController(title : title, message : message, preferredStyle : .alert)
        
        let ok = UIAlertAction(title : "Ok", style: .default)
        
        alert.addAction(ok)
        
        present(alert, animated : true, completion: nil)
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
