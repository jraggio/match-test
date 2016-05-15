//
//  Card.swift
//  Matchtime
//
//  Created by Raggios on 5/13/16.
//  Copyright © 2016 Raggios. All rights reserved.
//

import UIKit

/**
 Card represents one of the cards in the Matching Game.
 */
class Card: NSObject {
    
    private var cardFrontImage: UIImage
    private var id: String
    private let cardBackImage = UIImage(named:"showtime")!
    var state: CardState = .Unselected
   
    /**
     The three possible states of card in the game
     - Selected: When the card's image is displayed face up
     - Unselected: When the card is placed face down, showing the back
     - Removed: When the card was part of amatched pair it is removed from the game screen
     */
    enum CardState{
        case Selected
        case Unselected
        case Removed
    }
    
    var image:UIImage{
        if state == .Selected{
            return cardFrontImage
        }
        else{
            return cardBackImage
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


