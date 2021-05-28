//
//  PlantListViewController.swift
//  PlantInsta
//
//  Created by ulas özalp on 19.04.2021.
//

import UIKit
import Firebase
import SDWebImage

class PlantListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    let firestoreDatabase = Firestore.firestore()
    var plantinstaUser = Auth.auth().currentUser?.email!

    var plantlist = [PlantDiary]() //plantdiary objelerinden oluşan bir dizi olacak
    var chosenPlant = ""
    var postCounterValue: String?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "My Plants"
        tableView.delegate = self
        tableView.dataSource = self
     
        
        
        getPlantData()
        
        
       
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenPlant = plantlist[indexPath.row].plantName
        print("Plant listteki sayaç degeri \(plantlist[indexPath.row].plantPostCount)")
                self.performSegue(withIdentifier: "toFeedList", sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFeedList"
        {
      /*
             let destinationNavigationController = segue.destination as? UINavigationController
             let targetController = destinationNavigationController?.topViewController as! FeedViewController
             targetController.choosenPlant = chosenPlant
             
             */
    
             let destinationVC1 = segue.destination as! FeedViewController // önce yol göster burada as! ile cast ediyorsun
            destinationVC1.choosenPlant = self.chosenPlant
                     // burada destinationVC ye 2nci viewcontroller uzerindeki tüm elemanları getirir. myName 2nci viewcontroller uzerindeki text yazılacak değişken.
            destinationVC1.postCounterValue = postCounterValue
        
           
                    
                }

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantlist.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = "DD/MM/YYYY"
        // oluşturulan procell in plantcell sınıfına bağlanması
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath) as! PlantCell
       cell.PlantAvatarImage.sd_setImage(with: URL (string: plantlist[indexPath.row].plantAvatar))
        cell.PlantCreatedDate.text = plantlist[indexPath.row].plantFirstDate
       cell.PlantDiaryName.text = plantlist[indexPath.row].plantName
        cell.PostCountLabel.text = String(plantlist[indexPath.row].plantPostCount)
        self.postCounterValue = String(plantlist[indexPath.row].plantPostCount)
        return cell
    }
    
    func makeAlert(title: String, message : String) {
        let alert = UIAlertController(title:title ,message: message, preferredStyle: UIAlertController.Style.alert)
        let okbutton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okbutton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getPlantData() {
        
        firestoreDatabase.collection(plantinstaUser!)
            .order(by: "plantFirstDate")
            .addSnapshotListener{  (snapshot, error) in
            if ( error != nil ){
                
                self.makeAlert(title: "Database Error", message: error?.localizedDescription ??  "DBase Error")
                
            }else {
                self.plantlist.removeAll() // plantlist disizini boşaltıyor.
                if snapshot?.isEmpty == false && snapshot != nil {
                    for document in snapshot!.documents {
                        
                            let plantAvatar = document.get("plantAvatar") as! String
                            let plantFirstDate = document.get("plantFirstDate") as! String
                            let plantName = document.get("plantName") as! String
                            let plantPostCount = document.get("plantPostCount") as? String
                            let plantUserMail = document.get("plantUserMail") as! String
                        let plantDiary = PlantDiary(plantAvatar: plantAvatar, plantFirstDate: plantFirstDate, plantName: plantName, plantPostCount: plantPostCount ?? "0", plantUserMail: plantUserMail)
                        
                        self.plantlist.append(plantDiary)
                        
                        
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        
    }

    
    


}
