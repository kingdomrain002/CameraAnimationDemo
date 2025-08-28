//
//  GalleryThumbnailView.swift
//  CameraAnimationDemo
//
//  Created by yzf-macmini on 2025/8/28.
//

import UIKit

class GalleryThumbnailView: UIButton {
    
    private let imageViewThumb = UIImageView()
    
    /// 外部只读访问图片
    var thumbImage: UIImage? {
        return imageViewThumb.image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = UIColor(white: 0.2, alpha: 0.6)
        
        imageViewThumb.contentMode = .scaleAspectFill
        imageViewThumb.frame = bounds
        imageViewThumb.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageViewThumb)
    }
    
    /// 更新缩略图并播放“从中心放大”动画
    func updateThumbnail(with image: UIImage) {
        guard let superview = superview else { return }
        
        let snapshot = UIImageView(image: image)
        snapshot.contentMode = .scaleAspectFill
        snapshot.layer.cornerRadius = 8
        snapshot.clipsToBounds = true
        
        // 从缩略图中心生成动画
        let center = self.center
        snapshot.frame = CGRect(x: center.x, y: center.y, width: 10, height: 10)
        snapshot.center = center
        snapshot.alpha = 0.8
        superview.addSubview(snapshot)
        
        let targetFrame = self.frame
        
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseInOut,
                       animations: {
            snapshot.frame = targetFrame
            snapshot.alpha = 1.0
        }) { _ in
            self.imageViewThumb.image = image
            snapshot.removeFromSuperview()
        }
    }
}



