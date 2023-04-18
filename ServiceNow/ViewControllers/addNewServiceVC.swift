//
//  addNewServiceVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit
import SkyFloatingLabelTextField
class addNewServiceVC: UIViewController {

    @IBOutlet weak var lblLocation: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func onHome(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    @IBAction func onMyProfile(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    @IBAction func onMyOrder(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "MyOrderVC") as! MyOrderVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    @IBAction func onLocation(_ sender: Any) {
        let vcSearchMap = self.storyboard?.instantiateViewController(withIdentifier: "SearchMapVC") as! SearchMapVC
        vcSearchMap.latitude = userlat
        vcSearchMap.longitude = userlong
        vcSearchMap.searchCallBack = { (latitude, longitude, address, screenType) in
            userlat = latitude
            userlong = longitude
            self.lblLocation.text = address
            currentAddress = address
            let updateAddreess:[String : Any] = ["latitude": "\(latitude)", "longitude":"\(longitude)", "address":address]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LocationUpdateNotification"), object: nil, userInfo: updateAddreess)
        }
        self.present(vcSearchMap, animated: true, completion: nil)
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
