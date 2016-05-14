//
//  Card.swift
//  Matchtime
//
//  Created by Raggios on 5/13/16.
//  Copyright © 2016 Raggios. All rights reserved.
//

import UIKit

class Card: NSObject {
    
    private var cardFrontImage: UIImage
    private var id: String
    private let cardBackImage = UIImage(named:"showtime")
    var state: CardState = .Unselected
    
    enum CardState{
        case Selected
        case Unselected
        case Removed
    }
    
    var image:UIImage{
        if state == .Unselected{
            return cardBackImage!
        }
        else{
            return cardFrontImage
        }
    }
    
    var isRemoved:Bool{
        return state == .Removed
    }
    
    init(withID id:String, andImageName imageName:String){
        self.id = id
        self.cardFrontImage = UIImage(named:imageName)!
    }
    
    init(withID id:String, andImageURL imageURL:NSURL){
        self.id = id
        let data = NSData(contentsOfURL: imageURL)
        self.cardFrontImage = UIImage(data: data!)!
        
        // todo show an error or set a default image of some sort if URL fails to produce an image
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let rhs = object as? Card else { return false }
        
        let lhs = self
        return lhs.id == rhs.id
    }
    
}


