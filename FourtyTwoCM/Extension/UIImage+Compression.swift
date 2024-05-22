//
//  UIImage+Compression.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/21/24.
//

import UIKit

extension UIImage {
    func compressedData(targetSizeInKB: Int) -> Data? {
        let maxByteSize = targetSizeInKB * 1024
        var compression: CGFloat = 1.0
        let increment: CGFloat = 0.1
        var data = self.jpegData(compressionQuality: compression)
        
        while let imageData = data, imageData.count > maxByteSize && compression > 0 {
            compression -= increment
            data = self.jpegData(compressionQuality: compression)
        }
        
        return data
    }
    
    func resizedImage(targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0)
        self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
