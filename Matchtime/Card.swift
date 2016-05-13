//
//  Card.swift
//  Matchtime
//
//  Created by Raggios on 5/13/16.
//  Copyright © 2016 Raggios. All rights reserved.
//

import UIKit

class Card: NSObject {
    
    var image: UIImage?
    var id: String
    
    init(withID id:String, andImageName imageName:String){
        self.id = id
        
        self.image = UIImage(named:imageName)!
    }
    
    init(withID id:String, andImageURL imageURL:NSURL){
        self.id = id
        
        if let data = NSData(contentsOfURL: imageURL) {
            self.image = UIImage(data: data)!
        }
        
    }

}
