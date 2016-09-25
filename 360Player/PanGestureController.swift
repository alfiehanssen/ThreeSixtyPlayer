//
//  PanGestureController.swift
//  360Player
//
//  Created by Alfred Hanssen on 9/25/16.
//  Copyright © 2016 Alfie Hanssen. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

/// A controller that manages a pan gesture recognizer.
class PanGestureController
{    
    /// The translation value previously reported via the UIPanGestureRecognizerDelegate.
    private var previousPanTranslation: CGPoint?
    
    /// The translation delta between the previously and currently reported translations.
    private(set) var currentPanTranslationDelta: CGPoint?
    
    /// The pan gesture recognizer used for navigation.
    let panGestureRecognizer = UIPanGestureRecognizer()
    
    /// A boolean that enables and disabled the pan gesture recognizer.
    var enabled = false
    {
        didSet
        {
            self.panGestureRecognizer.isEnabled = enabled
        }
    }
    
    init()
    {
        self.panGestureRecognizer.addTarget(self, action: #selector(self.didPan))
    }
    
    @objc func didPan(_ recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .began:
            self.previousPanTranslation = .zero
            
        case .changed:
            guard let previous = self.previousPanTranslation else
            {
                assertionFailure("Attempt to unwrap previous pan translation failed.")
                
                return
            }
            
            // Calculate how much translation occurred between this step and the previous step.
            let translation = recognizer.translation(in: recognizer.view)
            let delta = CGPoint(x: translation.x - previous.x, y: translation.y - previous.y)
            
            // Save the translation and delta for later use.
            self.previousPanTranslation = translation
            self.currentPanTranslationDelta = delta
            
        case .ended, .cancelled, .failed:
            // Reset saved values for use in future pan gestures.
            self.previousPanTranslation = nil
            self.currentPanTranslationDelta = nil
            
        case .possible:
            break
        }
    }
}

