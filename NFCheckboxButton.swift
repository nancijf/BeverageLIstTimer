//
//  NFCheckboxButton.swift
//  Coffee Timer
//
//  Created by Nanci Frank on 8/30/15.
//  Copyright (c) 2015 Wildcat Productions. All rights reserved.
//

import Foundation
import UIKit

class NFCheckboxButton: UIButton {
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setImage(UIImage(named: "unchecked"), forState: UIControlState.Normal)
        self.setImage(UIImage(named: "checked"), forState: UIControlState.Selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setImage(UIImage(named: "unchecked"), forState: UIControlState.Normal)
        self.setImage(UIImage(named: "checked"), forState: UIControlState.Selected)        
    }
}
