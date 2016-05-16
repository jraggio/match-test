//
//  MatchingCardGame.swift
//  Matchtime
//
//  Created by Raggios on 5/13/16.
//  Copyright © 2016 Raggios. All rights reserved.
//

import UIKit

class MatchingCardGame{
    private var deck:[Card]
    let deckSize:Int
    private let gameDelegate: MatchingCardGameDelegate
    private(set) var matchCount: Int = 0
    private var selectedIndices = [Int]()
    private var missCount = 0
    
    let flickrURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=5423dbab63f23a62ca4a986e7cbb35e2&tags=kitten&sort=relevance&safe_search=1&media=photos&extras=url_q&format=json&nojsoncallback=1"
    
    init (withDeckSize deckSize:Int, andDelegate delegate:MatchingCardGameDelegate){
        self.deckSize = deckSize
        self.deck = [Card]()
        self.gameDelegate = delegate
        self.loadDeckFromFlickr()
    }
    
    /**
     Game Delegates use this method to indicate that the game should no longer track previously selected items
     
     Can't clear the selected indices in the model until after the controller tells us it has flipped or removed the cards
     from the prior guess attempt.  Otherwise the user can cheat and tap many images before the timer fires
     to flip the mismatched pair back over.  They should only be able to see two at a time.  I didn't want the view controller
     to enforce this rule.  I thought it was better for the model to do it.
    */
    func clearSelected(){
        selectedIndices.removeAll()
    }    
    
    
    /**
     Game delegates use this method to inform the model when a card is selected.  The model will determine
     if the item selected is valid or not.  It will then enforce the game rules to see if there was a match etc.
     The model will call back tot he delegate using methods defined in the MatchingCardGameDelegate protocol
     so that thye may update the UI based on changes in the game state.
     */
    func itemSelected(atIndex index:Int){
        // ignore any attempts to select more than 2 cards or a card that is already selected
        guard (deck[index].state != .Removed && selectedIndices.count < 2 && !selectedIndices.contains(index) ) else { return }
        
        // add this index to the selected set and show the card front in UI via delegate
        selectedIndices.append(index)
        deck[index].state = Card.CardState.Selected
        gameDelegate.showCardFrontAtIndex(index)
        
        // if we have two cards now, we need to check for a match
        if(selectedIndices.count == 2){
            let c1 = deck[selectedIndices[0]]
            let c2 = deck[selectedIndices[1]]
            
            // we have a match
            if c1.isEqual(c2){
                c1.state=Card.CardState.Removed
                c2.state=Card.CardState.Removed
                gameDelegate.removeCardsAtIndices(selectedIndices)
                matchCount += 1
                if matchCount == deckSize / 2{
                    gameDelegate.gameOver()
                }
            }
            // we don't have a match
            else{
                c1.state=Card.CardState.Unselected
                c2.state=Card.CardState.Unselected
                missCount += 1
                gameDelegate.showCardBacksAtIndices(selectedIndices)
            }
        }
    }
    
    
    /**
     Load the deck and shuffle it on a worker thread and then notify the UI delegate when done.  This version of the
     method uses images of puppies that are included in the app bundle.  It was used to code the game logic and UI
     without making calls to Flickr.  It is left in for future testing etc., but won't be called.
     */
    private func loadDeck(){
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // this sleep was used to test the full screen activity indicator
            // sleep(3)
            
            // test with puppy images in bundle prior to coding the Flickr parts
            for i in 1...(self.deckSize/2){
                
                // create two cards with the same image and id
                // can't use two references to the same card as it caused issues with the UI when it needed to scroll.
                let newCard = Card(withID: "puppyID\(i)", andImageName: "puppy\(i)")
                self.deck.append(newCard)
                
                let newCard2 = Card(withID: "puppyID\(i)", andImageName: "puppy\(i)")
                self.deck.append(newCard2)
            }
            
            self.shuffleDeck()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.gameDelegate.gameReady()
            }
        }
    }
    
    /**
     Load the deck and shuffle it on a worker thread and then notify the UI delegate when done.  This version of the
     method uses images of kittens from Flickr
     */
    private func loadDeckFromFlickr(){
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let url: NSURL = NSURL(string:self.flickrURL)!
            
            if let jsonData:NSData = NSData(contentsOfURL: url){
                do {
                    if let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        if let photoArray = jsonDict["photos"]?["photo"] as? [[String:AnyObject]] {
                            for index in 1...(self.deckSize/2){
                                if let flickrImageRecord = photoArray[index] as Dictionary?{
                                    if let imageURL = NSURL(string:flickrImageRecord["url_q"] as! String){
                                        // create two cards with the same image and id
                                        // can't use two references to the same card as it caused issues with the UI when it needed to scroll.
                                        let newCard = Card(withID: flickrImageRecord["id"] as! String, andImageURL:imageURL)
                                        self.deck.append(newCard)
                                        
                                        let newCard2 = Card(withID: flickrImageRecord["id"] as! String, andImageURL:imageURL)
                                        self.deck.append(newCard2)
                                    }
                                }
                            }
                            
                            self.shuffleDeck()
                        }
                        
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            }
            
            // let the UI know if the game can start or not
            dispatch_async(dispatch_get_main_queue()) {
                if self.deck.count == self.deckSize{
                    self.gameDelegate.gameReady()
                }
                else{
                    self.gameDelegate.gameInitFailure()
                }
            }
        }
    }

    
    /**
     Returns a Card at a given index
     - parameter index: The index of the card to retrieve from the deck
     - returns: The desired Card
    */
    func getCard(atIndex index:Int) -> Card?{
        if index < deck.count && index >= 0{
            return deck[index]
        }
        else{
            return nil
        }        
    }
    
    /// [Fisher-Yates shuffle](https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle)
    private func shuffleDeck(){
        guard deck.count > 2 else {return}

        for i in 0..<(deck.count - 1) {
            let j = Int(arc4random_uniform(UInt32(deck.count - i))) + i
            guard i != j else { continue }
            swap(&deck[i], &deck[j])
        }

       
    }
    
    
} // end MatchingCardGame

/*
 Used to ask the UI of the game to update itself based on the state of deck, cards and matches etc.
 */

protocol MatchingCardGameDelegate{
    /**
     Called when there was a match found in the game and the cards in question will now be hidden
     */
    func removeCardsAtIndices(indices: [Int])
    
    /**
     Called when the user selects a card in the UI and the model determines that its front should be shown
     */
    func showCardFrontAtIndex(index: Int)
    
    /**
     Called when a match was not found in the game and the cards in question will now be turned back over to their backs
     */
    func showCardBacksAtIndices(indices: [Int])
    
    /**
     Called when the game model is finished loading all card images and has shuffled the deck
     */
    func gameReady()
    
    /**
     Called when the game model determined that all pairs have been found
     */
    func gameOver()
    
    /**
     Called when the game model failed to load the cards
     */
    func gameInitFailure()

    
} // end MatchingCardGameDelegate
