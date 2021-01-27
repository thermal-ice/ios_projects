//
//  Meal.swift
//  Actual_foodtracker
//
//  Created by Carlos Huang on 2020-04-08.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit


class Meal{
    
    //MARK: properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    init?(name: String, photo: UIImage?, rating: Int) {
        
        //Intialization should fail if invalid input
        guard !name.isEmpty else{
            return nil
        }
        
        guard (rating>=0) && (rating <= 5) else{
            return nil
        }
        
        
        self.name = name
        self.photo = photo
        self.rating = rating
    }
    
    
}

