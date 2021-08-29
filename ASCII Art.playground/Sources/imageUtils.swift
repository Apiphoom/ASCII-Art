import AVFoundation
import Foundation
import UIKit

public extension UIImage
{
    class func imageOfSymbol(_ symbol: String, _ font: UIFont) -> UIImage
    {
        let
        length = font.pointSize * 2,
        size   = CGSize(width: length, height: length),
        rect   = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)
        let nsString = NSString(string: symbol)
        nsString.draw(at: rect.origin, withAttributes: convertToOptionalNSAttributedStringKeyDictionary([
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.black
            ]))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageConstrainedToMaxSize(_ maxSize: CGSize) -> UIImage
    {
        let isTooBig =
            size.width  > maxSize.width ||
            size.height > maxSize.height
        if isTooBig
        {
            let
            maxRect       = CGRect(origin: CGPoint.zero, size: maxSize),
            scaledRect    = AVMakeRect(aspectRatio: self.size, insideRect: maxRect),
            scaledSize    = scaledRect.size,
            targetRect    = CGRect(origin: CGPoint.zero, size: scaledSize),
            width         = Int(scaledSize.width),
            height        = Int(scaledSize.height),
            cgImage       = self.cgImage,
            bitsPerComp   = cgImage?.bitsPerComponent,
            compsPerPixel = 4,
            bytesPerRow   = width * compsPerPixel,
            colorSpace    = cgImage?.colorSpace,
            bitmapInfo    = cgImage?.bitmapInfo,
            context       = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComp!,
                bytesPerRow: bytesPerRow,
                space: colorSpace!,
                bitmapInfo: (bitmapInfo?.rawValue)!)
        
            if context != nil
            {
                context!.interpolationQuality = CGInterpolationQuality.low
                context?.draw(cgImage!, in: targetRect)
                if let scaledCGImage = context?.makeImage()
                {
                    return UIImage(cgImage: scaledCGImage)
                }
            }
        }
        return self
    }

    func imageRotatedToPortraitOrientation() -> UIImage
    {
        let mustRotate = self.imageOrientation != .up
        if mustRotate
        {
            let rotatedSize = CGSize(width: size.height, height: size.width)
            UIGraphicsBeginImageContext(rotatedSize)
            if let context = UIGraphicsGetCurrentContext()
            {
                context.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)
                let
                degrees = self.degreesToRotate(),
                    radians = degrees * Double.pi / 180.0
                context.rotate(by: CGFloat(radians))
                context.scaleBy(x: 1.0, y: -1.0)
                
                let
                targetOrigin = CGPoint(x: -size.width/2, y: -size.height/2),
                targetRect   = CGRect(origin: targetOrigin, size: self.size)
                
                context.draw(self.cgImage!, in: targetRect)
                let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                return rotatedImage
            }
        }
        return self
    }
    
    fileprivate func degreesToRotate() -> Double
    {
        switch self.imageOrientation
        {
        case .right: return  90
        case .down:  return 180
        case .left:  return -90
        default:     return   0
        }
    }
}

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}