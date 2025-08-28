//
//  CameraAnimationManager.swift
//  CameraAnimationDemo
//
//  Created by yzf-macmini on 2025/8/28.
//

import UIKit

/// 相机闪光动画管理器
final class CameraAnimationManager {
    
    static let shared = CameraAnimationManager()
    private init() {}
    
    /// 执行屏幕闪光动画
    func flash(on view: UIView,
               color: UIColor = .white,
               duration: TimeInterval = 0.3) {
        
        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = color
        flashView.alpha = 0
        view.addSubview(flashView)
        
        UIView.animate(withDuration: duration * 0.3, animations: {
            flashView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: duration * 0.7, animations: {
                flashView.alpha = 0
            }) { _ in
                flashView.removeFromSuperview()
            }
        }
    }
}

