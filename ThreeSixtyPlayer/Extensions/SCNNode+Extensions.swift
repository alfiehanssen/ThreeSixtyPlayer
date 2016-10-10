//
//  SCNNode+Extensions.swift
//  ThreeSixtyPlayer
//
//  Created by Alfred Hanssen on 10/6/16.
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

import SceneKit
import SpriteKit

extension SCNNode
{
    /// Returns an SCNNode configured with a camera object.
    static func cameraNode() -> SCNNode
    {
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        
        return cameraNode
    }
}

extension SCNNode
{
    // TODO: Does this belong here?
    // TODO: How to choose the sphere radius? [AH] 7/7/2016
    /// The default radius for sphere geometry that receives a SpriteKit scene as its material.
    private static let DefaultSphereRadius: CGFloat = 100
    
    /// Returns an SCNNode configured with sphere geometry used for viewing spherical videos.
    static func sphereNode(skScene: SKScene) -> SCNNode
    {
        let material = SCNMaterial()
        material.diffuse.contents = skScene
        material.cullMode = .front // Ensure that the material renders on the inside of our sphere
        
        let sphere = SCNSphere()
        sphere.radius = SCNNode.DefaultSphereRadius
        sphere.firstMaterial = material
        
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        
        return sphereNode
    }
}

