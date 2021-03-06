//
//  PlantDiaryModel.swift
//  PlantInsta
//
//  Created by ulas özalp on 19.04.2021.
//

import Foundation


struct PlantDiary  : Codable {
   
    var plantAvatar : String
    var plantFirstDate : String
    var plantName : String
    var plantPostCount : String
    var plantUserMail : String
    var plantFavorite : Bool
    
    enum CodingKeys: String, CodingKey {
        case plantAvatar
        case plantFirstDate
        case plantName
        case plantPostCount
        case plantUserMail
        case plantFavorite

        
    }
            
  
}



// usermail
/*
 
 let plantAvatar : String
 let plantFirstDate : String
 let plantName : String
let plantPostCount : String
 let plantUserMail : String
 
 
 */
