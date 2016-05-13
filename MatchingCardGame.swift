//
//  MatchingCardGame.swift
//  Matchtime
//
//  Created by Raggios on 5/13/16.
//  Copyright © 2016 Raggios. All rights reserved.
//

import Foundation

class MatchingCardGame{
    private var deck:[Card]
    private var deckSize:Int
    var gameDelegate: MatchingCardGameDelegate
    
    init (withDeckSize deckSize:Int, andDelegate:MatchingCardGameDelegate){
        self.deckSize = deckSize
        self.deck = [Card]()
        self.gameDelegate = andDelegate
        
        print(deck.count)
    }
    
    
    func loadDeck(){
        deck.append(Card())
        deck.append(Card())
        
        print(deck.count)

        gameDelegate.gameReady()
        
        
    }
    
    
    // Fisher-Yates shuffle, https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
    private func shuffleDeck(){
        var temp:[Card] = deck
        
        for i in 0..<(temp.count - 1) {
            let j = Int(arc4random_uniform(UInt32(temp.count - i))) + i
            swap(&temp[i], &temp[j])
        }
        
        self.deck = temp
       
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
    
} // end MatchingCardGameDelegate
