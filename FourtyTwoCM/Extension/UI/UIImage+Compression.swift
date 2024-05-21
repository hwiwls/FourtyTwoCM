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
        var increment: CGFloat = 0.1
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
        
        // Determine the scale factor that preserves aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0)
        self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
