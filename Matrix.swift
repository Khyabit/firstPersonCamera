//
//  Matrix.swift
//  metal1
//
//  Created by NewTest on 2021-03-20.
//

import Foundation
import simd


extension float4x4 {
    
    init (scaleBy s: Float) {
        self.init(float4(s, 0, 0, 0),
                  float4(0, s, 0, 0),
                  float4(0, 0, s, 0),
                  float4(0, 0, 0, 1))
    }
    
    init (perspectiveProjectionFov fovRadians: Float, aspect: Float, zNear: Float, zFar: Float) {
        
        let yScale = 1 / tan(fovRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = zFar - zNear
        let zScale = -(zFar + zNear) / zRange
        let wzScale = -2 * zFar * zNear / zRange
        
        let xx = xScale
        let yy = yScale
        let zz = zScale
        let zw = Float(-1)
        let wz = wzScale
        
        self.init(float4(xx, 0, 0, 0),
                  float4( 0,yy, 0, 0),
                  float4( 0, 0,zz,zw),
                  float4( 0, 0,wz, 0))
    }
    
    init (lookAt position: float3, eye: float3, up: float3) {
        
        let z = normalize(position - eye)
        let x = normalize(cross(up, z))
        let y = normalize(cross(z, x))
        
        let xEye = -((x.x * position.x) + (x.y * position.y) + (x.z * position.z))
        let yEye = -((y.x * position.x) + (y.y * position.y) + (y.z * position.z))
        let zEye = -((z.x * position.x) + (z.y * position.y) + (z.z * position.z))
        
        self.init(float4(x.x,  y.x,  z.x,  0),
                  float4(x.y,  y.y,  z.y,  0),
                  float4(x.z,  y.z,  z.z,  0),
                  float4(xEye, yEye, zEye, 1))
    }
    
    init(translationBy t: float3) {
        self.init(float4(   1,    0,    0, 0),
                  float4(   0,    1,    0, 0),
                  float4(   0,    0,    1, 0),
                  float4(t[0], t[1], t[2], 1))
    }
}

class Matrix4 {
    
    func identity() -> float4x4 {
        return float4x4(scaleBy: 1)
    }
}
