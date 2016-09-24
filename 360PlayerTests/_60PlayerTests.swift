//
//  _60PlayerTests.swift
//  360PlayerTests
//
//  Created by Alfred Hanssen on 7/5/16.
//  Copyright © 2016 Alfie Hanssen. All rights reserved.
//

import XCTest
import SceneKit

@testable import _60Player

class _60PlayerTests: XCTestCase
{
    let scene = SCNScene()
    let cameraNode = SCNNode()

    override func setUp()
    {
        super.setUp()
        
        // Camera
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        
        // Camera node
        self.cameraNode.camera = camera
        self.cameraNode.position = SCNVector3Zero
        self.scene.rootNode.addChildNode(self.cameraNode)
    }
    
    func testIdentity()
    {
        XCTAssert(SCNMatrix4EqualToMatrix4(self.scene.rootNode.transform, self.cameraNode.transform), "Scene and camera transforms are expected to be equal.")
        XCTAssert(SCNMatrix4IsIdentity(self.scene.rootNode.transform), "Scene transform is expected to be identity.")
        XCTAssert(SCNMatrix4IsIdentity(self.cameraNode.transform), "Camera transform is expected to be identity.")
    }
    
    func testCommutative()
    {
        let node = SCNNode()
        let radians = GLKMathDegreesToRadians(45)
        let xRotation = SCNMatrix4MakeRotation(radians, 1, 0, 0)

        var cameraTransformA = node.transform
        cameraTransformA = SCNMatrix4Mult(cameraTransformA, xRotation)

        var cameraTransformB = node.transform
        cameraTransformB = SCNMatrix4Mult(xRotation, cameraTransformB)
        
        XCTAssert(SCNMatrix4EqualToMatrix4(cameraTransformA, cameraTransformB), "Transforms are expected to be equal.")
    }

    func testNotAssociative()
    {
        let node = SCNNode()
        let angle = GLKMathDegreesToRadians(45)
        let xRotation = SCNMatrix4MakeRotation(angle, 1, 0, 0)
        let yRotation = SCNMatrix4MakeRotation(angle, 0, 1, 0)

        var cameraTransformA = node.transform
        cameraTransformA = SCNMatrix4Rotate(cameraTransformA, angle, 1, 0, 0) // x
        cameraTransformA = SCNMatrix4Rotate(cameraTransformA, angle, 0, 1, 0) // y

        var cameraTransformB = node.transform
        cameraTransformB = SCNMatrix4Rotate(cameraTransformB, angle, 0, 1, 0) // y
        cameraTransformB = SCNMatrix4Rotate(cameraTransformB, angle, 1, 0, 0) // x

        var cameraTransformC = node.transform
        cameraTransformC = SCNMatrix4Mult(cameraTransformC, xRotation)
        cameraTransformC = SCNMatrix4Mult(cameraTransformC, yRotation)

        var cameraTransformD = node.transform
        cameraTransformD = SCNMatrix4Mult(cameraTransformD, yRotation)
        cameraTransformD = SCNMatrix4Mult(cameraTransformD, xRotation)

        var cameraTransformE = node.transform
        cameraTransformE = SCNMatrix4Mult(xRotation, cameraTransformE)
        cameraTransformE = SCNMatrix4Mult(yRotation, cameraTransformE)

        XCTAssert(SCNMatrix4EqualToMatrix4(cameraTransformA, cameraTransformB) == false, "Transforms are expected to be non-equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(cameraTransformA, cameraTransformC), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(cameraTransformB, cameraTransformD), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(cameraTransformD, cameraTransformE), "Transforms are expected to be equal.")
    }

    func testTransformEqualsEuler()
    {
        let angle = GLKMathDegreesToRadians(45)
        let xRotation = SCNMatrix4MakeRotation(angle, 1, 0, 0)
        let yRotation = SCNMatrix4MakeRotation(angle, 0, 1, 0)

        let node = SCNNode()
        XCTAssert(SCNVector3EqualToVector3(node.position, SCNVector3Zero), "Position is expected to be zero.")
        XCTAssert(SCNMatrix4IsIdentity(node.transform), "Transform is expected to be identity.")
        
        node.eulerAngles.x += angle
        node.eulerAngles.y += angle
        
        let transform = node.transform
        let worldTransform = node.worldTransform
        
        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Rotate(node.transform, angle, 1, 0, 0)
        node.transform = SCNMatrix4Rotate(node.transform, angle, 0, 1, 0)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Rotate(node.transform, angle, 0, 1, 0)
        node.transform = SCNMatrix4Rotate(node.transform, angle, 1, 0, 0)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Mult(node.transform, SCNMatrix4Mult(xRotation, yRotation))
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        let xy = SCNMatrix4Mult(xRotation, yRotation)
        let yx = SCNMatrix4Mult(yRotation, xRotation)
        
        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Mult(node.transform, xy)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Mult(node.transform, yx)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Mult(xy, node.transform)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")
        
        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Mult(yx, node.transform)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Mult(node.worldTransform, xy)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Mult(node.worldTransform, yx)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Mult(xy, node.worldTransform)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")
        
        node.transform = SCNMatrix4Identity
        node.transform = SCNMatrix4Mult(yx, node.worldTransform)
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        node.transform = SCNMatrix4Identity
        node.rotation = SCNVector4Zero
        XCTAssert(SCNMatrix4EqualToMatrix4(node.transform, transform), "Transforms are expected to be equal.")
        XCTAssert(SCNMatrix4EqualToMatrix4(node.worldTransform, worldTransform), "Transforms are expected to be equal.")

        
//        let nodeF = SCNNode()
//        nodeF.transform = SCNMatrix4Rotate(nodeF.worldTransform, angle, 1, 0, 0)
//        nodeF.transform = SCNMatrix4Rotate(nodeF.worldTransform, angle, 0, 1, 0)
        
    }

    //        let glkMatrix = SCNMatrix4ToGLKMatrix4(cameraTransformA)
    //        var string = NSStringFromGLKMatrix4(glkMatrix)

}
