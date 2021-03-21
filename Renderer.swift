//
//  Renderer.swift
//  metal1
//
//  Created by NewTest on 2021-03-21.
//

import Foundation
import MetalKit
import ModelIO
import simd

struct Uniforms {
    var modelViewMatrix: float4x4
    var projectionMatrix: float4x4
}

class Renderer: NSObject, MTKViewDelegate {
    
    
    var position: float3
    var eye: float3
    let up: float3
    
    var yRotation: Float! = 45
    var xRotation: Float! = 0
    let rotateSpeed: Float! = 0.5
    
    let device: MTLDevice
    let mtkView: MTKView
    let commandQueue: MTLCommandQueue
    
    var vertexDescriptor: MTLVertexDescriptor!
    var renderPipeline: MTLRenderPipelineState!
    
    var meshes: [MTKMesh] = []
    
    init(mtkView: MTKView, device: MTLDevice) {
        
        self.position = float3(0,0,-10)
        self.eye = float3(0,0,0)
        self.up = float3(0,1,0)
        
        self.device = device
        self.mtkView = mtkView
        self.commandQueue = device.makeCommandQueue()!
        
        super.init()
        loadModel()
        buildRenderPipline()
    }
    
    
    func loadModel() {
        let modelPath = Bundle.main.url(forResource: "cube", withExtension: "obj")
        let vertexDescriptor = MDLVertexDescriptor()
        
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition, format: .float3, offset: 0, bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal, format: .float3, offset: MemoryLayout<Float>.size * 3, bufferIndex: 0)
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: MemoryLayout<Float>.size * 6, bufferIndex: 0)
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.size * 8)
        
        self.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        let bufferAllocator = MTKMeshBufferAllocator(device: device)
        let asset = MDLAsset(url: modelPath, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        
        do {
            (_, meshes) = try MTKMesh.newMeshes(asset: asset, device: device)
        }
        catch {
            fatalError("Could not extract meshes from Model I/O asset")
        }
    }
    
    func buildRenderPipline() {
        guard let library = device.makeDefaultLibrary() else { fatalError("cannot make library") }
                
        let vertexFunc = library.makeFunction(name: "vertex_main")
        let fragmentFunc = library.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            renderPipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Could not create render pipeline state object: \(error)")
        }
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        
        eye = normalize(float3(
            cos(xRotation) * cos(yRotation),
            sin(xRotation),
            cos(xRotation) * sin(yRotation)
        ))
                
        let modelMatrix = float4x4(scaleBy: 2)
        let viewMatrix = float4x4(lookAt: position, eye: position+eye, up: up)
        let modelViewMatrix = viewMatrix*modelMatrix
                
        let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
        let projectionMatrix = float4x4(perspectiveProjectionFov: Float.pi / 3, aspect: aspectRatio, zNear: 0.1, zFar: 1000)
        
        var uniforms = Uniforms(modelViewMatrix: modelViewMatrix, projectionMatrix: projectionMatrix)
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        if let renderPassDescriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
            
            for mesh in meshes {
                let vertexBuffer = mesh.vertexBuffers.first!
                commandEncoder?.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
                commandEncoder?.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 1)
                commandEncoder?.setRenderPipelineState(renderPipeline)
                
                for submesh in mesh.submeshes {
                    let indexBuffer = submesh.indexBuffer
                    commandEncoder?.drawIndexedPrimitives(type: submesh.primitiveType,
                                                         indexCount: submesh.indexCount,
                                                         indexType: submesh.indexType,
                                                         indexBuffer: indexBuffer.buffer,
                                                         indexBufferOffset: indexBuffer.offset)
                }
            }
            commandEncoder?.endEncoding()
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
    
    public func rotateCamera(rotation: float2) {
        yRotation += rotation.x * 0.0174533 * rotateSpeed
        xRotation -= rotation.y * 0.0174533 * rotateSpeed
    }
}
