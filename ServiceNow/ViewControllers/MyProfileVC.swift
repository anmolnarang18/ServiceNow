//
//  MyProfileVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit

class MyProfileVC: UIViewController {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    @IBOutlet weak var favImage: UIImageView!
    @IBOutlet weak var favTitle: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
checkUser()
        // Do any additional setup after loading the view.
    }
    func checkUser(){
        if isSP{
            self.favImage.image = UIImage(systemName: "plus")
            self.favTitle.text = "Add"
        }
        let userData = getJSON("isUserLogin")
        lblUserName.text = userData?["name"].stringValue
        lblUserEmail.text = userData?["email"].stringValue
    }

    @IBAction func onHome(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    @IBAction func onFav(_ sender: Any) {
        if isSP{
            let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "addNewServiceVC") as! addNewServiceVC
            self.navigationController?.pushViewController(vcStoreList, animated: true)
        }else{
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "FavoriteVC") as! FavoriteVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
        }
    }
    @IBAction func onMyOrder(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "MyOrderVC") as! MyOrderVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    
    @IBAction func onLogout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "isUserLogin")
        accessToken = UserDefaults.standard.string(forKey: "accessToken")
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
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
