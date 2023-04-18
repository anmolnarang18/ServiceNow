//
//  LoginVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 14/04/23.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var userSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onSignUp(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        isSP = userSwitch.isOn
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
}
