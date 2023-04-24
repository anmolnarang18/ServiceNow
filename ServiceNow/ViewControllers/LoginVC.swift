//
//  LoginVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 14/04/23.
//

import UIKit
import SVProgressHUD
import SwiftyJSON
import Alamofire
import SkyFloatingLabelTextField

class LoginVC: UIViewController {

    @IBOutlet weak var emailTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var userSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func onLogin(){
        SVProgressHUD.show()
        var userType = ""
        if userSwitch.isOn{
            userType = "MANAGER"
        }else{
            userType = "WORKER"
        }
        isSP = userSwitch.isOn
        var param: [String: Any] = [:]
        param["email"] = emailTxt.text ?? ""
        param["password"] = passwordTxt.text ?? ""
        param["type"] = userType
        
        let url = API.newLogin
        
        TrackOrderModel.sendRequestToServerWithParam(baseUrl: url, "", httpMethod: "POST", isZipped: false, param: param) { (isSuccess, response) in
            print(response)
            if let json = response["data"] as? [String: Any]{
                DispatchQueue.main.async {
                    
                    UserDefaults.standard.set(json["token"] as? String, forKey: "accessToken")
                    accessToken = UserDefaults.standard.string(forKey: "accessToken")
                    
                    saveJSON(json: JSON(response["data"]!), key: "isUserLogin")
                    UserDefaults.standard.synchronize()
                    
                    let vcStoreList = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    self.navigationController?.pushViewController(vcStoreList, animated: true)
                    SVProgressHUD.dismiss()
                }
            }else{
                if let message = response["message"] as? String{
                    showAlertMsg(Message:message, AutoHide: false)
                }else{
                    showAlertMsg(Message:"Please check Credentials", AutoHide: false)
                }
                SVProgressHUD.dismiss()
            }
        }
    }

    @IBAction func onSignUp(_ sender: Any) {
       onLogin()
    }
}
