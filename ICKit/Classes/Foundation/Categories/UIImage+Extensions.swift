//
//  UIImage+Extensions.swift
//  ICKit
//
//  Created by _ivanc on 2019/1/20.
//  Copyright © 2019 ivanC. All rights reserved.
//

import UIKit

func DegreesToRadians(degrees:CGFloat) -> CGFloat { return (degrees * CGFloat.pi) / 180.0 };
func RadiansToDegrees(radians:CGFloat) -> CGFloat { return (radians * 180.0) / CGFloat.pi };


extension ICKit where Base : UIImage {
    
    public func cropping(to rect:CGRect) -> UIImage? {
        
        var subRect = rect
        subRect.size.width *= self.base.scale;
        subRect.size.height *= self.base.scale;
        subRect.origin.x *= self.base.scale;
        subRect.origin.y *= self.base.scale;
        
        guard let cgImage = self.base.cgImage else {
            return nil
        }
        
        guard let imageRef = cgImage.cropping(to: subRect) else {
            return nil
        }
        
        let subImage = UIImage(cgImage: imageRef, scale: self.base.scale, orientation: self.base.imageOrientation)
        
        return subImage;
    }
    
    public func scaling(to size:CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, self.base.scale)
        var rect:CGRect = .zero
        rect.size = size
        self.base.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    public func rotating(toDegress:CGFloat) -> UIImage? {
        return self.rotating(toRadians: DegreesToRadians(degrees: toDegress))
    }
    
    public func rotating(toRadians:CGFloat) -> UIImage? {
        if (toRadians == 0)
        {
            return self.base
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedSize = CGSize(self.base.size.width * self.base.scale, self.base.size.height * self.base.scale)
        
        // Create the bitmap context
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        UIGraphicsBeginImageContext(rotatedSize)

        // Move the origin to the middle of the image so we will rotate and scale around the center.
        context.translateBy(x: rotatedSize.width/2.0, y: rotatedSize.height/2.0)
        
        // Rotate the image context
        context.rotate(by: toRadians)
        
        // Now, draw the rotated/scaled image into the context
        context.scaleBy(x: self.base.scale, y: -self.base.scale);
        guard let cgImage = self.base.cgImage else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(-self.base.size.width / 2, -self.base.size.height / 2, self.base.size.width, self.base.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        guard let newCgImage = newImage?.cgImage else {
            return nil
        }
        
        let result = UIImage(cgImage: newCgImage, scale: self.base.scale, orientation: self.base.imageOrientation)
        
        return result;
    }
    
    public func round(diameter:CGFloat, borderColor:UIColor = .clear, borderWidth:CGFloat = 0) -> UIImage? {

        let width:CGFloat = diameter/self.base.scale
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: 0, y: 0, width: width, height: width)
        imageLayer.contents = self.base.cgImage;
        imageLayer.masksToBounds = true
        imageLayer.cornerRadius = width/2.0
        imageLayer.allowsEdgeAntialiasing = true
        
        if borderWidth > 0 {
            imageLayer.borderColor = borderColor.cgColor
            imageLayer.borderWidth = borderWidth
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(imageLayer.frame.size, false, self.base.scale)
        imageLayer.render(in: context)

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    public class func image(withColor:UIColor, size:CGSize) -> UIImage? {
        var rect:CGRect = .zero
        rect.size = size
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        UIGraphicsBeginImageContext(size)
        context.setFillColor(withColor.cgColor)
        context.fill(rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
