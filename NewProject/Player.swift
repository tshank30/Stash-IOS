//
//  Player.swift
//  NewProject
//
//  Created by Shashank Tiwari on 19/07/17.
//  Copyright © 2017 Shashank Tiwari. All rights reserved.
//

import UIKit

struct Player {
    var name: String?
    var game: String?
    var rating: Int
    
    init(name: String?, game: String?, rating: Int) {
        self.name = name
        self.game = game
        self.rating = rating
    }
}
