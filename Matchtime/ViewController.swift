//
//  ViewController.swift
//  Matchtime
//
//  Created by Raggios on 5/12/16.
//  Copyright © 2016 Raggios. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MatchingCardGameDelegate {

    private let cardReuseIdentifier = "CardCell"
    private let numberOfItemsPerRow = 4
    private let numberOfCards = 4 // game defaults to a 4x4 grid, but bonus items in the challenge may make this variable
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private var gameModel:MatchingCardGame?
    
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
    @IBOutlet weak var scoreLabel: UILabel!
  
    // MARK: Lifetime
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startNewGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startNewGame(){
        startActivityIndicator()
        scoreLabel.text = "Building new deck..."
        gameModel = MatchingCardGame(withDeckSize: self.numberOfCards, andDelegate: self)
        gameModel?.loadDeck()
        showAllCardBacks()
        cardsCollectionView.hidden = true
    }
    
    
    // MARK: UICollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCards
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        gameModel?.itemSelected(atIndex: indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cardReuseIdentifier, forIndexPath: indexPath) as!CardCollectionViewCell
        return cell
    }
    

    /*
     Allows the cells to be sized perfectly to fit the specified number across each row.  The constant below is set to 4 for this sample app.
     Sizing the cells in IB would not work since even if the correct size was determined it would only work on certain device types and not others.
     */
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: size)
    }
    
    
    // MARK: Utility
    func showAllCardBacks(){
        for index in 0..<numberOfCards{
            if let cell = self.cardsCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as?CardCollectionViewCell{
                
                cell.cardImage.image = UIImage(named:"showtime")
                
                UIView.animateWithDuration(0,
                                           animations: {
                                            cell.alpha = 1 },
                                           completion: { completed in
                                            cell.hidden = false }
                )
            }
        }
    }
    
    func startActivityIndicator() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        
        // Change background color and alpha channel here
        activityIndicator.backgroundColor = UIColor.blackColor()
        activityIndicator.clipsToBounds = true
        activityIndicator.alpha = 0.5
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }

    
    /*
     Executes the given block on the main thread after a specified delay in seconds.
     This is used to flip cards over afer a specified delay if they match and also if
     they do not match.  Each uses a different delay.
     */
    func delayClosure(delay: Double, closure: () -> Void) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    
    // MARK: UI Events
    
    @IBAction func dealClicked(sender: AnyObject) {
        startNewGame()
    }
    
    
    // MARK: MatchingCardGameDelegate
    
    func removeCardsAtIndices(indices: [Int]){
        
        delayClosure(1.0){
            for index in indices{
                if let cell = self.cardsCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)){
                    
                    UIView.animateWithDuration(1,
                                               animations: {
                                                cell.alpha = 0 },
                                               completion: { completed in
                                                cell.hidden = true }
                    )
                }
            }
            
            self.gameModel?.clearSelected()
            
        }
    }
    
    func showCardFrontAtIndex(index: Int){
        if let cell = cardsCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as?CardCollectionViewCell{
            
            UIView.transitionWithView(cell.contentView,
                                      duration: 1,
                                      options: .TransitionFlipFromRight,
                                      animations: {
                                        cell.cardImage.image = self.gameModel?.getCard(atIndex: index)?.image                                      },
                                      completion: nil)
            
        }
    }
    
    func showCardBacksAtIndices(indices: [Int]){
        
        delayClosure(2.0){
            for index in indices{
                
                if let cell = self.cardsCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as?CardCollectionViewCell{
                    
                    UIView.transitionWithView(cell.contentView,
                                              duration: 1,
                                              options: .TransitionFlipFromLeft,
                                              animations: {
                                                cell.cardImage.image = UIImage(named:"showtime")
                        },
                                              completion: nil)
                }
            }
            
            self.scoreLabel.text = "Mismatches: \(self.gameModel!.score)"
            self.gameModel?.clearSelected()
        }
        
    }
    
    func gameReady(){
        scoreLabel.text = "Mismatches:"
        cardsCollectionView.hidden = false
        stopActivityIndicator()        
    }
    
    func gameOver(){
        
        let score = gameModel!.score
        
        
        let alert = UIAlertController(title: "Game over",
                                      message: "You finished with \(score) mismatch\(score == 1 ? "":"es")",
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.startNewGame()
            return
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
       
}

