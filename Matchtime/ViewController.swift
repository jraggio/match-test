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
    private var numberOfCards = 0 // until user selects difficulty
    private let removedAlpha = 0.20 // used to dim the matched cards
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
        pickGameLevel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startNewGame(level:Int){
        cardsCollectionView.hidden = true
        numberOfCards = level
        startActivityIndicator()
        scoreLabel.text = "Building new deck..."
        gameModel = MatchingCardGame(withDeckSize: numberOfCards, andDelegate: self)        
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
        // print("cv.cellForItemAtIndexPath caled for \(indexPath.row)")
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cardReuseIdentifier, forIndexPath: indexPath) as!CardCollectionViewCell
        
        if let card = gameModel?.getCard(atIndex: indexPath.row){
            
            if card.isRemoved{
                cell.alpha = CGFloat(removedAlpha)
            }
            else{
                cell.alpha = 1
            }
            
            cell.cardImage.image = card.image
            cell.cardLabel.text = String(indexPath.row + 1)
        }
        
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
        numberOfCards = 4
        pickGameLevel()
    }
    
    enum Difficulty:Int{
        case Easy = 8
        case Medium = 16
        case Extreme = 32
    }
    
    func pickGameLevel() {
  
        let optionMenu = UIAlertController(title: nil, message: "Choose Difficulty", preferredStyle: .ActionSheet)
        
  
        let easyAction = UIAlertAction(title: "Easy (\(Difficulty.Easy.rawValue))", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.startNewGame(Difficulty.Easy.rawValue)
        })
  
        let mediumAction = UIAlertAction(title: "Medium (\(Difficulty.Medium.rawValue))", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.startNewGame(Difficulty.Medium.rawValue)
        })
        
        let extremeAction = UIAlertAction(title: "Extreme (\(Difficulty.Extreme.rawValue))", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.startNewGame(Difficulty.Extreme.rawValue)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        optionMenu.addAction(easyAction)
        optionMenu.addAction(mediumAction)
        optionMenu.addAction(extremeAction)
        optionMenu.addAction(cancelAction)

        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    // MARK:-
    // MARK:MatchingCardGameDelegate
    
    func removeCardsAtIndices(indices: [Int]){
        
        delayClosure(1.0){
            for index in indices{
                if let cell = self.cardsCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as?CardCollectionViewCell{
                    
                    UIView.animateWithDuration(1,
                                               animations: {
                                                cell.alpha = CGFloat(self.removedAlpha) },
                                               completion: nil)
                }
                
                self.gameModel?.clearSelected()
                
            }
        }
    }
    
    func showCardFrontAtIndex(index: Int){
        if let cell = cardsCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as?CardCollectionViewCell{
            let card = gameModel?.getCard(atIndex: index)
            
            UIView.transitionWithView(cell.contentView,
                                      duration: 0.75,
                                      options: .TransitionFlipFromRight,
                                      animations: { cell.cardImage.image = card?.image },
                                      completion: nil)
            
        }
    }
    
    func showCardBacksAtIndices(indices: [Int]){
        
        delayClosure(1.5){
            for index in indices{
                
                if let cell = self.cardsCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as?CardCollectionViewCell{
                    let card = self.gameModel?.getCard(atIndex: index)

                    UIView.transitionWithView(cell.contentView,
                                              duration: 1,
                                              options: .TransitionFlipFromLeft,
                                              animations: { cell.cardImage.image = card?.image },
                                              completion: nil)
                }
            }
            
            self.scoreLabel.text = "Mismatches: \(self.gameModel?.missCount)"
            self.gameModel?.clearSelected()
        }
        
    }
    
    func gameReady(){
        scoreLabel.text = "Mismatches: 0"
        cardsCollectionView.hidden = false
        
        // need to reload the data source since the new game may have a different number of cards
        cardsCollectionView.reloadData()

        stopActivityIndicator()        
    }
    
    func gameOver(){
        
        let score = gameModel?.missCount
        
        let alert = UIAlertController(title: "All matches found",
                                      message: "You finished with \(score!) mismatch\(score == 1 ? "":"es")",
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.pickGameLevel()
            return
        }))
        
        // delay this slightly to give the final two cards a little bit of time to fade away
        delayClosure(2.0){
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func gameInitFailure(){
        
        let alert = UIAlertController(title: "Error",
                                      message: "Unable to load the card deck from Flickr",
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
            self.pickGameLevel()
            return
        }))

        stopActivityIndicator()
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
       
}

