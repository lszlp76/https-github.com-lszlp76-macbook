//
//  SelectImageViewController.swift
//  PlantInsta
//
//  Created by ulas özalp on 22.04.2021.
//
// galeri açma https://www.youtube.com/watch?v=wDzk5KDe6Uw
import UIKit
import FirebaseStorage
import FirebaseFirestoreSwift
import Firebase

class SelectImageViewController: UIViewController {
     
    var selectImage: UIImage!
    var entryFromFeed : String!
    var postCountValue : String?
    
    // entryFromFeed nil ise plant , 1 ise feed demek olacak
   
   
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var diaryNameText: UITextField!
    
    
    @IBOutlet weak var sendImage: UIButton!
    @IBOutlet var commentText: UITextView!
    
    /* progress view hazırlık */
    private let progressView : UIProgressView = {
        let progressView = UIProgressView (progressViewStyle: .bar)
        progressView.trackTintColor = .gray
            progressView.progressTintColor = .green
        return progressView
    }()
    
    var progress : Int64 = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Select image daki \(postCountValue)")
        
        // *** klavye nedeniyle yazımı engelleyen durumu ortadan kaldırma ***
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
       
        
        view.addSubview(progressView) // önce progress view i ana view e eklemek
        progressView.frame = CGRect (x: 10.0, y: view.frame.size.height-100, width: view.frame.size.width-20 ,height: 20.0) // frame in yerini ve boyutlarını hazırla
        NSLayoutConstraint.activate([
        
        
        progressView.bottomAnchor.constraint(equalTo: sendImage.bottomAnchor,constant: 4)
        ])
        // progress değeri yüklemeye göre değer alıyor .
       
        self.progressView.setProgress(Float(progress),animated: true)
        
       
        //
        selectedImageView.image = selectImage
        selectedImageView.contentMode = .scaleToFill
        
        // Do any additional setup after loading the view.
    }
    
    // klavye görülünce field leri yukarı al
    
   

override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
}
@objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
}

@objc func keyboardWillHide(notification: NSNotification) {
    if self.view.frame.origin.y != 0 {
        self.view.frame.origin.y = 0
    }
}
    
    
    
    
    var sendingPermission = false
    var uploadTask : StorageUploadTask?
   
    func sendPlant(){
        
       
        if uploadTask == nil {
            let data = Data()
            let storage = Storage.storage()
            let storageReference = storage.reference()
            let images = storageReference.child("images")
            
            let uuid = UUID().uuidString
            print(selectedImageView.image?.size)
            if let data = selectedImageView.image?.jpegData(compressionQuality: 0.5)
            {
            let imageReference = images.child( "\(uuid).jpg")
                
                uploadTask =
                imageReference.putData(data, metadata: nil)
                { (storage, error) in
                    if ( error != nil){
                        print(error?.localizedDescription)
                    }else {
                         imageReference.downloadURL { [self] (url, error) in
                            if error != nil {
                                print(error?.localizedDescription as Any)
                                
                            } else {
                                let storagesize = storage?.size
                                let downloadUrl = url?.absoluteString
                                let now = Date()  // bugünün tarihin alıyor
                                let formatter = DateFormatter()  // format belirleyici
                                /*
                                 dateStyle= .full > Sunday, April 25, 2021 at 1:14:20 PM"
                                 .long > "April 25, 2021 at 1:15:11 PM"
                                 .medium > "Apr 25, 2021 at 1:15:54 PM"
                                 .short > 4/25/21, 1:16:22 PM
                                 isteğe bağlı format için
                                 ////formatter.dateFormat="dd/MM/yyyy HH:mm"
                                 */
                                formatter.dateStyle = .short
                                formatter.timeStyle = .medium
                                formatter.locale = Locale.current
                                let currentDate = formatter.string(from: now)
                                // DATABASE İŞLEMLERİ Burada başlayacak
                                /*New Plant*/
                                let newPlant = PlantDiary (
                                    plantAvatar: downloadUrl!, // resim adresi
                                    plantFirstDate: currentDate,
                                    plantName: self.diaryNameText.text!,
                                    plantPostCount: "1" ,
                                plantUserMail: (Auth.auth().currentUser?.email)!)
                                
                                let db = Firestore.firestore()
                                
                                /*
                                 // Upload the file to the path "folderName/file.jpg"
                                 let uploadTask = storageRef.putFile(localFile, metadata: nil)

                                 */
                                
                                
                                if (self.entryFromFeed != nil ){
                                    
                                    do {
                                        // feed olarak eklemek
                                    try
                                            db.collection((Auth.auth().currentUser?.email)!).document(self.entryFromFeed).collection("history")
                                            .addDocument(data: ["comment" : commentText.text!,
                                                                "date" : FieldValue.serverTimestamp(),
                                                "image" : downloadUrl! ])
                                       
                                        let postcounter =  String((Int(postCountValue!)! + 1))
                                       db.collection((Auth.auth().currentUser?.email)!).document(self.entryFromFeed).setData([
                                        "plantPostCount": postcounter,
                                        
                                    ]
                                        
                        , merge: true)
                                       
                                        
                                        /*
                                        let newPostCount = [ "plantPostCount" : ]
                                        db.collection((Auth.auth().currentUser?.email)!).document(self.entryFromFeed).setData(newPostCount, merge: true)
 */
                                    }
                                    catch let error
                                    { print("Error writing city to Firestore: \(error)")
                                        
                                        
                                    }
                                    
                                }else {
                                    do
                                    // plant olarak eklemek
                                    {
                                        try
                                            db.collection((Auth.auth().currentUser?.email)!).document(diaryNameText.text!)
                                            .setData(from: newPlant, merge: true, encoder: Firestore.Encoder(), completion: { (error) in
                                                if error == nil {
                                                   
                                                    // Plant detail
                                                    addPlantDetail(usermail: newPlant.plantUserMail,
                                                                   plantName: diaryNameText.text!,
                                                                   date: now,
                                                                   imageUrl: downloadUrl!)
                                                    
                                                    
                                                }
                                            })

                                    }
                                    
                                    
                                    
                                    catch let error
                                    { print("Error writing city to Firestore: \(error)")
                                        
                                        
                                    }
                                }
                                
                                
                            }
                        }
                        
                    }
                }
                
                let observer = uploadTask!.observe(.progress) { snapshot in
                    let realbyte =  (snapshot.progress?.completedUnitCount)
                    let totalbyte = (snapshot.progress?.totalUnitCount)
                    self.progress = realbyte! * 100 / totalbyte!
                    print("Loading ratio : % \(self.progress)")// NSProgress object
                    
                    self.progressView.progress = Float(self.progress)
                    
                }
                uploadTask!.observe(.success) { (StorageTaskSnapshot) in
                   
                    print("Loaded")
                    self.uploadTask?.removeAllObservers()
                    self.performSegue(withIdentifier: "toTabBarView", sender: nil)
                }
               
            }
            
            
        } else {
            ServingUtility().makeAlert(vc: self,title: "Loading Alert",message: "Your uploading is ongoing...")
            
            
               
       
        }
        }
       
    func addPlantDetail(usermail : String, plantName: String,date: Date , imageUrl: String) {
            
            let db = Firestore.firestore()
        let newFeed = FeedPlant (comment: commentText.text!, date: date, image: imageUrl)
            do {
                try db.collection(usermail).document(plantName).collection("history")
                    
                    .addDocument(from: newFeed)
                
            }catch let error
            { print("Error writing city to Firestore: \(error)")}
            
            
        
    }
    @IBAction func sendImageClicked(_ sender: Any) {
        if diaryNameText!.text != "" && commentText!.text != ""{
        sendPlant()
        }else {
            ServingUtility().makeAlert(vc: self,title: "Loading Alert",message: "deneme mesajı")
        }
        
       
    }


/* Alert diyalog ile açılan menulerdeki picker ın fonksiyonları*/
   
        
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}