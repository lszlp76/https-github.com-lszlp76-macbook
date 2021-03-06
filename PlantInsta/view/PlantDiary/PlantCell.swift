//
//  PlantCell.swift
//  PlantInsta
//
//  Created by ulas özalp on 19.04.2021.
//

import UIKit

protocol tableViewNew{
    func addToFavClicked(index : Int)
}

@available(iOS 13.0, *)
class PlantCell: UITableViewCell  {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var postcountlabel: UILabel!
    @IBOutlet weak var add_toFav: UIButton!
    @IBOutlet weak var PlantCreatedDate: UILabel!
    @IBOutlet weak var PlantDiaryName: UILabel!
    
    var cellDelegate: tableViewNew?
    var index : IndexPath = []
    
    @IBAction func AddToFavButton(_ sender: Any) {
        
        cellDelegate?.addToFavClicked(index: index.row)
       //FAV feedden yapılyor buraya gerek yok
//        if self.AddToFav.image(for: .normal) == UIImage(systemName: "star.fill"){
//                self.AddToFav.setImage(UIImage(systemName: "star"), for: .normal)
//               print("PlantCell indexi : \(index)")
//
//                }else { // eğer plant fav olarak işaretli DEĞİL ise
//                    self.AddToFav.setImage(UIImage(systemName: "star.fill"), for: .normal)
//                    print("PlantCell indexi : \(index)")
//                }
        

    }
    
    
    
    
    
    @IBOutlet weak var PlantAvatarImage: UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
