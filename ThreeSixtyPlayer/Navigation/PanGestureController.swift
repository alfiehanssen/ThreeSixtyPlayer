//
//  PanGestureController.swift
//  ThreeSixtyPlayer
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
    fileprivate var previousPanTranslation = CGPoint.zero
    
    /// The translation delta between the previously and currently reported translations.
    var currentPanTranslationDelta = CGPoint.zero
    
    /// The pan gesture recognizer used for navigation.
    let panGestureRecognizer = UIPanGestureRecognizer()
    
    var viewBounds: CGRect
    {
        guard let view = self.panGestureRecognizer.view else
        {
            fatalError("Attempt to navigate with a pan gesture that's not yet added to a view.")
        }

        return view.bounds
    }
    
    /// A boolean that enables and disabled the pan gesture recognizer.
    var enabled = false
    {
        didSet
        {
            self.panGestureRecognizer.isEnabled = self.enabled
        }
    }
    
    init()
    {
        self.panGestureRecognizer.addTarget(self, action: #selector(self.didPan))
    }
    
    @objc fileprivate func didPan(_ recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .began:
            self.previousPanTranslation = .zero
            
        case .changed:
            // Calculate how much translation occurred between this step and the previous step.
            let previous = self.previousPanTranslation
            let current = recognizer.translation(in: recognizer.view)
            let delta = CGPoint(x: current.x - previous.x, y: current.y - previous.y)
            
            // Save the translation and delta for later use.
            self.previousPanTranslation = current
            self.currentPanTranslationDelta = delta
            
        case .ended, .cancelled, .failed:
            // Reset saved values for use in future pan gestures.
            self.previousPanTranslation = .zero
            self.currentPanTranslationDelta = .zero
            
        case .possible:
            break
        }
    }
}

