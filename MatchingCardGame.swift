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
    private var matchCount: Int = 0
    private var selectedIndices = [Int]()
    private var missCount = 0
    
    var score: Int {
        return missCount
    }
    
    
    init (withDeckSize deckSize:Int, andDelegate delegate:MatchingCardGameDelegate){
        self.deckSize = deckSize
        self.deck = [Card]()
        self.gameDelegate = delegate
    }
    
    /*
     Can't clear the selected indices until after the controller tells us it has flipped or removed the cards
     from the prior guess attempt.  Otherwise the user can cheat and tap many images beforre the timer fires 
     to flip the mismatched pair back over.  They shold only be able to see two ata time.
    */
    func clearSelected(){
        selectedIndices.removeAll()
    }
    
    
    
    func itemSelected(atIndex index:Int){
        // ignore any attempts to select more than 2 cards or a card that is already selected
        guard (selectedIndices.count < 2 && !selectedIndices.contains(index) ) else { return }
        
        // add this index to the selected set and show the card front in UI via delegate
        selectedIndices.append(index)
        gameDelegate.showCardFrontAtIndex(index)
        
        // if we have two cards now, we need to check for a match
        if(selectedIndices.count == 2){
            let c1 = deck[selectedIndices[0]]
            let c2 = deck[selectedIndices[1]]
            
            // we have a match
            if c1 == c2{
                gameDelegate.removeCardsAtIndices(selectedIndices)
                matchCount += 1
                if matchCount == deckSize / 2{
                    gameDelegate.gameOver()
                }
                
            }
            // we don't have a match
            else{
                missCount += 1
                gameDelegate.showCardBacksAtIndices(selectedIndices)
            }
            
        }
        
    }
    
    
    /*
        Load the deck and shuffle it on a worker thread and then notify the UI delegate when done
     */
    func loadDeck(){
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            sleep(10)
            
            // test with puppy images in bundle prior to coding the Flickr parts
            for i in 1...(self.deckSize/2){
                let newCard = Card(withID: "puppyID\(i)", andImageName: "puppy\(i)")
                
                // we want two copies of every card in the deck
                self.deck.append(newCard)
                self.deck.append(newCard)
            }
            
            self.shuffleDeck()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.gameDelegate.gameReady()
            }
        }
        
    }
    
    func getCard(atIndex index:Int) -> Card?{
        if index < deckSize && index >= 0{
            return deck[index]
        }
        else{
            return nil
        }        
    }
    
    
    // Fisher-Yates shuffle, https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
    private func shuffleDeck(){

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
    /*
     Called when there was a match found in the game and the cards in question will now be hidden
     */
    func removeCardsAtIndices(indices: [Int])
    
    /*
     Called when the user selects a card in the UI and the model determines that its front should be shown
     */
    func showCardFrontAtIndex(index: Int)
    
    /*
     Called when a match was not found in the game and the cards in question will now be turned back over to their backs
     */
    func showCardBacksAtIndices(indices: [Int])
    
    /*
     Called when the game model is finished loading all card images and has shuffled the deck
     */
    func gameReady()
    
    /*
     Called when the game model determined that all pairs have been found
     */
    func gameOver()
    
} // end MatchingCardGameDelegate
