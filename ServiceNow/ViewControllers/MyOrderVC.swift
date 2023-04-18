//
//  MyOrderVC.swift
//  ServiceNow
//
//  Created by Anmol Narang on 17/04/23.
//

import UIKit

class MyOrderVC: UIViewController {

    var serviceArray = [services]()
    @IBOutlet weak var favImage: UIImageView!
    @IBOutlet weak var favTitle: UILabel!
    @IBOutlet weak var lblNoOrders: UILabel!
    @IBOutlet weak var serviceTableView: UITableView!{
        didSet{
            self.serviceTableView.register(UINib(nibName: "listViewCell", bundle: nil), forCellReuseIdentifier: "listViewCell")
            self.serviceTableView.dataSource = self
            self.serviceTableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dummyData()
        checkUser()
                self.serviceTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    func noOrdersView(){
        if serviceArray.isEmpty{
            self.lblNoOrders.isHidden = false
        }else{
            self.lblNoOrders.isHidden = true
        }
    }
    func checkUser(){
        if isSP{
            self.favImage.image = UIImage(systemName: "plus")
            self.favTitle.text = "Add"
        }
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
    @IBAction func onMyProfile(_ sender: Any) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "MyProfileVC") as! MyProfileVC
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }

}
extension MyOrderVC: UITableViewDataSource, UITableViewDelegate {
    
    func dummyData(){
        serviceArray.append(services(title: "Cleaning Services", companyName: "Air Duct Cleaner", location: "Kennedy & Williams", serviceDesc: "We thoroughly clean Air Ducts", currentPrice: 99.99,phoneNumber:"9057830299", isFavorite:1,postedDate: "03-16-2022"))
        serviceArray.append(services(title: "Internet Service", companyName: "Fast Fibre net", location: "James Potter", serviceDesc: "We provide fast internet service", currentPrice: 59.99,phoneNumber:"9057830902", isFavorite:0,postedDate: "04-11-2022",status: 1))
        serviceArray.append(services(title: "Food Service", companyName: "Fast Food", location: "Yonge Street", serviceDesc: "We provide fast Food service", currentPrice: 59.99,phoneNumber:"9057830902", isFavorite:0,postedDate: "03-16-2022",status: 0))
        noOrdersView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listViewCell", for: indexPath) as! listViewCell
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.serviceTitle.text = serviceArray[indexPath.row].title
        cell.companyName.text = serviceArray[indexPath.row].companyName
        cell.storeLocation.text = serviceArray[indexPath.row].location
        cell.serviceDesc.text = serviceArray[indexPath.row].serviceDesc
        cell.servicePrice.text = "$\(serviceArray[indexPath.row].currentPrice)"
        if isSP{
            cell.btnFav.isHidden = true
            cell.lblStatus.isHidden = false
           if serviceArray[indexPath.row].status == 1{
                cell.lblStatus.text = "Accepted"
            } else{
                cell.lblStatus.text = "Requested"
            }
        }else{
            if serviceArray[indexPath.row].isFavorite == 0{
                cell.btnFav.setImage(UIImage(systemName: "heart"), for: .normal)
            }else{
                cell.btnFav.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vcStoreList = storyboard?.instantiateViewController(withIdentifier: "ServiceDetailsVC") as! ServiceDetailsVC
        vcStoreList.fromMyOrder = true
        vcStoreList.currentService = serviceArray[indexPath.row]
        self.navigationController?.pushViewController(vcStoreList, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .normal, title: "") { (context, view, result) in
                self.serviceArray.remove(at: indexPath.row)
                self.serviceTableView.reloadData()
                self.noOrdersView()
            }
            
            deleteAction.image = UIImage(named: "ic_delete")
            deleteAction.backgroundColor = .white
            
            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            config.performsFirstActionWithFullSwipe = false
            
            return config
    }
}
