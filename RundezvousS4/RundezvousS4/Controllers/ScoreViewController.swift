//
//  ScoreViewController.swift
//  RundezvousS4
//
//  Created by iMac03 on 2017-12-02.
//  Copyright © 2017 Mobilux. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    var finalScore: String?
    @IBOutlet weak var scoreLabel: UILabel!
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated:true);
        super.viewDidLoad();
        scoreLabel.text = finalScore;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
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
