//
//  RatingControl.swift
//  Actual_foodtracker
//
//  Created by Carlos Huang on 2020-04-07.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    
    
    //MARK: Properties
    
    private var ratingButtons = [UIButton]()
    
    var rating = 0{
        didSet{
            updateButtonSelectionStates()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0){
        didSet{
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5{
        didSet{
            setupButtons()
        }
    }
    
    
    //MARK: Intializiation
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupButtons()
    }
    
    required init(coder: NSCoder){
        super.init(coder:coder)
        setupButtons()
    }
    
    
    //MARK: Button Action
    
    @objc func ratingButtonTapped(button:UIButton){
        guard let index = ratingButtons.firstIndex(of: button)else{
            fatalError("The button, \(button), is not in rating Buttons array: \(ratingButtons)")
        }
        
        let selectedRating = index + 1
        
        if selectedRating==rating{
            rating = 0
        }else{
            rating = selectedRating
        }
        
    }
    
    
    //MARK: Private Methods
    
    private func setupButtons(){
        
        //clears existing buttons
        for button in ratingButtons{
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        
        //Load Button Images
        
        let bundle = Bundle(for: type(of: self))
        
        let filledStar = UIImage(named:"filledStar", in:bundle, compatibleWith: self.traitCollection)
        
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        
        let highlightedStar = UIImage(named: "highlightedStar", in:bundle, compatibleWith: self.traitCollection)
        
        
        
        for index in 0..<starCount{
            
            let button = UIButton()
            
            //does accessibility stuff
            button.accessibilityLabel = "Set \(index+1) star rating"
            
            
            //does the star image stuff for buttons
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted,.selected])
            
            //adding constraints
            
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            //adds button to stack. This automatically adds it to the right side of the previous button
            addArrangedSubview(button)
            
            //adds button to array
           ratingButtons.append(button)
            
            updateButtonSelectionStates()
            
        }
    }
    
    private func updateButtonSelectionStates(){
        
        for(index,button) in ratingButtons.enumerated(){
            button.isSelected = index < rating
            
            
            //More accessibility stuff
            let hintString: String?
            
            if rating == index+1{
                hintString = "Tap to reset rating to zero"
            }else{
                hintString = nil
            }
            
            let valueString: String
            
            switch(rating){
            case 0:
                valueString = "No rating set"
            case 1:
                valueString = "1 star set"
            default:
                valueString = "\(rating) stars set"
            }
            
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
            
        }
        
    }
    
    

}
