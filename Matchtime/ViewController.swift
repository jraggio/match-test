//
//  ViewController.swift
//  Matchtime
//
//  Created by Raggios on 5/12/16.
//  Copyright © 2016 Raggios. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private let cardReuseIdentifier = "CardCell"
    private let numberOfItemsPerRow = 4
    private let numberOfCards = 16 // game defaults to a 4x4 grid, but bonus items in the challenge may make this variable
    
    @IBOutlet weak var scoreLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCards
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Item selected at index: \(indexPath.row)")
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cardReuseIdentifier, forIndexPath: indexPath) 
        
        
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
    
    @IBAction func dealClicked(sender: AnyObject) {
        print("Deal clicked")
    }
    
}

