//
//  RegisterVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit
import SkyFloatingLabelTextField
import SVProgressHUD
import SwiftyJSON

class RegisterVC: UIViewController {

    @IBOutlet weak var lastNameTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var firstNameTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPasswordTxt: SkyFloatingLabelTextField!
    
    @IBOutlet weak var userSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func onSignUp(_ sender: Any) {
        let pass = passwordTxt.text ?? ""
        let confPass = confirmPasswordTxt.text ?? ""
        if confPass == pass{
            onSign()
        }else{
          showAlertMsg(Message: "passwords do not match", AutoHide: false)
        }
      
    }
    func onSign(){
        SVProgressHUD.show()
        var userType = ""
        if userSwitch.isOn{
            userType = "MANAGER"
        }else{
            userType = "WORKER"
        }
        isSP = userSwitch.isOn
        let firstName = firstNameTxt.text ?? ""
        let lastName = lastNameTxt.text ?? ""
        var param: [String: Any] = [:]
        param["name"] = firstName + " " + lastName
        param["email"] = emailTxt.text ?? ""
        param["password"] = passwordTxt.text ?? ""
        param["type"] = userType
        
        let url = API.newSignUp
        
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
                showAlertMsg(Message: response["message"] as? String ?? "", AutoHide: false)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        _=navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
