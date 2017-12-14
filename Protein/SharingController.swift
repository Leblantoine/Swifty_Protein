//
//  SharingController.swift
//  Protein
//
//  Created by Julian SCARPONE on 12/14/17.
//  Copyright © 2017 Antoine LEBLANC. All rights reserved.
//

import UIKit

class SharingController {
    
    private func takeScreenShotOf(viewSnap: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: viewSnap.bounds.size)
        let image = renderer.image { ctx in
            viewSnap.drawHierarchy(in: viewSnap.bounds, afterScreenUpdates: false)
        }

        return image
    }
    
    private func generateAlert(image: UIImage, vc: UIViewController) -> UIAlertController {
        
        // generate Alert for previsualisation
        let alert = UIAlertController(
            title:"Screenshot made!",
            message: "What do you want to do ?",
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        // Add Image w/ resize to alert
        alert.addImage(image: image)
        
        // Add Action for sharing
        alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { alertAction in
            
            // dismiss alert
            alert.dismiss(animated: true, completion: nil)
            
            // set up activity view controller
            let imageToShare = [ image ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = vc.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            // activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            
            // present the view controller
            vc.present(activityViewController, animated: true, completion: nil)
            
        }))
        
        // Add action Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: { alertAction in
            alert.dismiss(animated: true, completion: nil)
        }))

        return alert
    }
    
    public func takeScreenshot(viewSnap: UIView, vc: UIViewController) -> Bool {

        let image = takeScreenShotOf(viewSnap: viewSnap)
        let alert = generateAlert(image: image, vc: vc)
        vc.present(alert, animated: true, completion: nil)
        return true
    }
}

extension UIAlertController {
    func addImage(image: UIImage) {
        let maxSize = CGSize(width: 245, height: 300)
        let imgSize = image.size
        
        var ratio: CGFloat!
        if (imgSize.width > imgSize.height) {
            ratio = maxSize.width / imgSize.width
        } else {
            ratio = maxSize.height / imgSize.height
        }
        
        let scaledSize = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)
        
        var resizedImage = image.imageWithSize(scaledSize)
        if (imgSize.height > imgSize.width) {
            let left = (maxSize.width - resizedImage.size.width) / 2
            resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsetsMake(0, -left, 0, 0))
        }
        
        let imgAction = UIAlertAction(title: "", style: .default, handler: nil)
        imgAction.isEnabled = false
        imgAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imgAction)
        
    }
}

extension UIImage {
    func imageWithSize(_ size:CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
