//
//  ImageUtils.swift
//  again
//
//  Created by user on 14/12/9.
//  Copyright (c) 2014年 yzlpie. All rights reserved.
//

import Foundation

struct ImageUtils {
    
    static func imageScale(originImage:UIImage) -> UIImage {
        
        var baseWidth:CGFloat?
        var baseHeight:CGFloat?
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            baseWidth = 450
            baseHeight = 300
        } else {
            baseWidth = 180
            baseHeight = 120
        }
        
        let h = originImage.size.height
        let w = originImage.size.width
        
        if(h <= baseHeight && w <= baseWidth) {
            return originImage
        } else {
            let b = baseHeight!/w > baseWidth!/h ? baseHeight!/w : baseWidth!/h
            let photoSize = CGSizeMake(b*w, b*h)
            UIGraphicsBeginImageContext(photoSize)
            let imageRect = CGRectMake(0, 0, b*w, b*h)
            originImage.drawInRect(imageRect)
            let targetImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return targetImage
        }
    }
}