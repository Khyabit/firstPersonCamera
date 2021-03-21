//
//  ViewController.swift
//  metal1
//
//  Created by NewTest on 2021-03-20.
//

import Cocoa
import MetalKit
import simd

class ViewController: NSViewController {
    
    let matrix = Matrix4()
    var mtkView: MTKView!
    var renderer: Renderer!
    
    var isRightDown: Bool! = false
    
    override func rightMouseDragged(with event: NSEvent) {
        print("down")
        print("\(event.deltaX) \(event.deltaY)")
        
        let rot = float2(Float(event.deltaX), Float(event.deltaY))
        
        renderer.rotateCamera(rotation: rot)
    }
    
    override func keyDown(with event: NSEvent) {
        if (event.keyCode == 13) {
            print("w")
            renderer.position += renderer.eye
        }
        else if (event.keyCode == 1) {
            print("s")
            renderer.position -= renderer.eye
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mtkView = MTKView()
        mtkView.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(mtkView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[mtkView]|", options: [], metrics: nil, views: ["mtkView" : mtkView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mtkView]|", options: [], metrics: nil, views: ["mtkView" : mtkView]))
       
        title = "Rotating Container"
        preferredContentSize.width = 1000
        preferredContentSize.height = 720
       
        let device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm
       
        renderer = Renderer(mtkView: mtkView, device: device)
        mtkView.delegate = renderer
        
        NSEvent.addLocalMonitorForEvents(matching: .rightMouseDragged) { (aEvent) -> NSEvent? in
            self.rightMouseDragged(with: aEvent)
            return nil
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
            self.keyDown(with: aEvent)
            return nil
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

