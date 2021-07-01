//
//  PlantListViewController.swift
//  PlantInsta
//
//  Created by ulas özalp on 19.04.2021.
//

import UIKit
import Firebase
import SDWebImage

@available(iOS 13.0, *)
class PlantListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UISearchBarDelegate, UISearchResultsUpdating{
    
    
    // LONGCLİCK için UIGestureRecognizerDelegate ekle
    
  
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let firestoreDatabase = Firestore.firestore()
    var plantinstaUser = Auth.auth().currentUser?.email!

    var plantlist = [PlantDiary]() //plantdiary objelerinden oluşan bir dizi olacak
    
    var filteredPlants = [PlantDiary]()  // arama için oluşacak dizi
    var chosenPlant = ""
    var postCounterValue: String?
    var plantToDelete :String? // silinecek olan plant array adı
    var indexToDelete : Int? // silinicek olan plant array indexi
    
    /*** search METODU */
    let searchPlant = UISearchController()
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "My Plants"
        tableView.delegate = self
        tableView.dataSource = self
        initSearchController()
        
        
        getPlantData()
        
        //Long Press
           let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
           longPressGesture.minimumPressDuration = 0.8 // saniye olarak süre
           self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (searchPlant.isActive){
            chosenPlant = filteredPlants[indexPath.row].plantName
            postCounterValue = (filteredPlants[indexPath.row].plantPostCount)
                    self.performSegue(withIdentifier: "toFeedList", sender: nil)
        }
        else{
            chosenPlant = plantlist[indexPath.row].plantName
            postCounterValue = (plantlist[indexPath.row].plantPostCount)
                    self.performSegue(withIdentifier: "toFeedList", sender: nil)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFeedList"
        {
            if (searchPlant.isActive){
                let destinationVC1 = segue.destination as! FeedViewController // önce yol göster burada as! ile cast ediyorsun
                destinationVC1.choosenPlant = chosenPlant
                       
               destinationVC1.postCounterValue = postCounterValue
            }else {
                let destinationVC1 = segue.destination as! FeedViewController // önce yol göster burada as! ile cast ediyorsun
               destinationVC1.choosenPlant = self.chosenPlant
                        // burada destinationVC ye 2nci viewcontroller uzerindeki tüm elemanları getirir. myName 2nci viewcontroller uzerindeki text yazılacak değişken.
               destinationVC1.postCounterValue = postCounterValue
           
            }
             
           
                    
                }

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (searchPlant.isActive){
            return filteredPlants.count
        }
        return plantlist.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let formatter = DateFormatter()
        formatter.dateFormat = "DD/MM/YYYY"
        // oluşturulan procell in plantcell sınıfına bağlanması
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantCell", for: indexPath) as! PlantCell
       
        
        
        if (searchPlant.isActive)
        {
            cell.PlantAvatarImage.sd_setImage(with: URL (string: filteredPlants[indexPath.row].plantAvatar))
             cell.PlantCreatedDate.text = filteredPlants[indexPath.row].plantFirstDate
            cell.PlantDiaryName.text = filteredPlants[indexPath.row].plantName
             cell.PostCountLabel.text = "You have \(String(filteredPlants[indexPath.row].plantPostCount)) posts"
             self.postCounterValue = String(filteredPlants[indexPath.row].plantPostCount)
        }
        else{
            cell.PlantAvatarImage.sd_setImage(with: URL (string: plantlist[indexPath.row].plantAvatar))
             cell.PlantCreatedDate.text = plantlist[indexPath.row].plantFirstDate
            cell.PlantDiaryName.text = plantlist[indexPath.row].plantName
            
            if Int(self.plantlist[indexPath.row].plantPostCount)! > 1
            {
                let word = "posts"
                cell.PostCountLabel.text = "You have \(String(plantlist[indexPath.row].plantPostCount)) \(word)"
            }else
            {
                let word = "post"
                cell.PostCountLabel.text = "You have \(String(plantlist[indexPath.row].plantPostCount)) \(word)"
            }
            
             
             self.postCounterValue = String(plantlist[indexPath.row].plantPostCount)
        }
        return cell
    }
    
    
    
    /** ALERT DİAILOG*****/
    
    func makeAlert(title: String, message : String) {
        let alert = UIAlertController(title:title ,message: message, preferredStyle: UIAlertController.Style.alert)
        let okbutton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okbutton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /**FİREBASE DATA ALMAK ****/
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

    func makeDeleteAlert(title: String, message : String) {
        let alert = UIAlertController(title:title ,message: message, preferredStyle: UIAlertController.Style.alert)
        let okbutton = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
            //print ("OK pressed")
            self.deletePlant(planttodelete: self.plantToDelete!, index: self.indexToDelete! )
            
        } )
        let nokbutton = UIAlertAction(title:"No",style: UIAlertAction.Style.default,handler: { action in
            //print ("NOK pressed")
        })
        alert.addAction(okbutton)
        alert.addAction(nokbutton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
        
 /****SEARCH BAR *******/
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
       // let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
         
        filterForSearchTextAndScopeButton(searchText: searchText)
       
    }
    
    
    
    // https://www.youtube.com/watch?v=DAHG0orOxKo
    func filterForSearchTextAndScopeButton ( searchText: String ){
       
        filteredPlants = plantlist.filter
        
        { plant in
            
            if ( searchPlant.searchBar.text != "")
            {
                let searchTextMatch = plant.plantName.lowercased().contains(searchText.lowercased())
                return searchTextMatch
            }
            
          else
            {
                
                return true
            }
            
        }
        self.tableView.reloadData()
    }
    
    func initSearchController(){
        searchPlant.loadViewIfNeeded()
        searchPlant.searchResultsUpdater = self
        searchPlant.obscuresBackgroundDuringPresentation = false
        searchPlant.searchBar.enablesReturnKeyAutomatically = false
        searchPlant.searchBar.returnKeyType = UIReturnKeyType.done
        
        definesPresentationContext = true
        
        //searchPlant.searchBar.placeholder = "ara"
        searchPlant.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search My Plants...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightText])
        searchPlant.searchBar.barStyle = .black
        navigationItem.searchController = searchPlant
        navigationItem.hidesSearchBarWhenScrolling = false
        //searchPlant.searchBar.scopeButtonTitles = [""]
        searchPlant.searchBar.delegate = self
        
    }
     
/**LONG PRESS METODU ******/
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        print("index path \(String(describing: indexPath)) row at \(p)")
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            print("Long press on row, at \(indexPath!.row)")
            
            if (searchPlant.isActive){
                plantToDelete = filteredPlants[indexPath!.row].plantName
                
               //filtre edilen isimi ,plantlist içinde olduğu index numarasını buluyor
                let filteredIndex = plantlist.firstIndex(where: { $0.plantName.hasPrefix(filteredPlants[indexPath!.row].plantName)
                                                             })
                    do { try! indexToDelete = filteredIndex
                        
                }
                    
            }else {
                plantToDelete = plantlist[indexPath!.row].plantName
                indexToDelete = indexPath?.row
                print("\(plantlist[indexPath!.row].plantName)")
            }
           
            makeDeleteAlert(title: "Plant deleting", message: "\(plantToDelete!) diary will delete...")
        }
    }
    func deletePlant(planttodelete: String,index : Int){
     
        
            firestoreDatabase.collection(plantinstaUser!)
                .document(planttodelete)
                .delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Deleted!")
                   
                    
                }
            }
            self.plantlist.remove(at: index)
        
            searchPlant.searchBar.text = "" // search bar 'ı boş karakter tanımlayıp tüm listeyi göstermek için
            
            self.tableView.reloadData()
           
       
        }
}
