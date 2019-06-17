//
//  Option.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/25/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import Foundation
import UIKit
class Option {
 
    private var _textOption: String!
    private var _imageOption: UIImage!
    
    init(textOption:String,imageOption:UIImage) {
        self._textOption = textOption
        self._imageOption = imageOption
    }
    
    var textOption: String {
        return _textOption
    }
    
    var imageOption: UIImage {
        return _imageOption
    }
}
