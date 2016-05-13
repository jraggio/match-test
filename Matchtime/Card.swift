//
//  Card.swift
//  Matchtime
//
//  Created by Raggios on 5/13/16.
//  Copyright © 2016 Raggios. All rights reserved.
//

import UIKit

class Card: NSObject {
    
    var image: UIImage // should this be optional?
    var id: String
    
    init(withID id:String, andImageName imageName:String){
        
        self.id = id
        self.image = UIImage(named:imageName)!
        
    }
    
    

}
