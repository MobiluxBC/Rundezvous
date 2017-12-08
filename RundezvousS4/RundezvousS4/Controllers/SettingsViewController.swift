//
//  SettingsViewController.swift
//  RundezvousS4
//
//  Created by Niko Arellano on 2017-11-17.
//  Copyright © 2017 Mobilux. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var dropPoints: UITextField!
    
    @IBOutlet weak var gridSize: UITextField!
    @IBOutlet weak var debugSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gridSize.text = String(SettingsHandler.Instance.gridInMeters)
        dropPoints.text = String(SettingsHandler.Instance.rundePointsCount)
        debugSwitch.setOn(false, animated: false)
        
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: Any) {
        SettingsHandler.Instance.gridInMeters = Double(gridSize.text!)!
        SettingsHandler.Instance.rundePointsCount = Int(dropPoints.text!)!
        SettingsHandler.Instance.DEBUG_MODE = debugSwitch.isOn
        
        
        
        self.navigationController?.popViewController(animated: true)
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
