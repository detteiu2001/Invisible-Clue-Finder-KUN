//
//  MotionManager.swift
//  NewGraduationProject
//
//  Created by cmStudent on 2025/01/16.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject{
    let manager = CMMotionManager()
    @Published var direction = 0.0
    
    init() {
        startDeviceMotionUpdates()
    }

    func startDeviceMotionUpdates() {
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 1.0 / 60.0
            manager.startDeviceMotionUpdates(using: .xTrueNorthZVertical ,to: .main) { [weak self] motion, error in
                guard let motion = motion, error == nil else { return }
                self?.updateMotionData(motion: motion)
            }
        }
    }

    private func updateMotionData(motion: CMDeviceMotion) {
        direction = motion.heading
    }
}

