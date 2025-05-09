//
//  AVPlayerItem+vibrance.swift
//  Aerial
//
//  Created by Guillaume Louel on 02/08/2020.
//  Copyright © 2020 Guillaume Louel. All rights reserved.
//

import AVKit

extension AVPlayerItem {
    func setVibrance(_ value: Double) {
        var useValue = PrefsVideos.globalVibrance
        
        if value != 0 {
            useValue = value
        }
        
        guard useValue != 0 else {
            return
        }
        
        if #available(OSX 10.14, *) {
            debugLog("Applying vibrance of \(useValue)")
            let filter = CIFilter(name: "CIVibrance")!
            self.videoComposition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
                let source = request.sourceImage.clampedToExtent()
                filter.setValue(source, forKey: kCIInputImageKey)
                filter.setValue(useValue, forKey: kCIInputAmountKey)
                let output = filter.outputImage
                
                request.finish(with: output!, context: nil)
            })
        }
    }
    
    func setColorInvert() {
        if #available(OSX 10.14, *) {
            debugLog("Applying color invert")

            if let invertFilter = CIFilter(name: "CIColorInvert") {
                let context = CIContext(options: [.workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!])
                
                self.videoComposition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
                    let source = request.sourceImage.clampedToExtent()
                    
                    invertFilter.setValue(source, forKey: kCIInputImageKey)
                    
                    guard let output = invertFilter.outputImage else {
                        request.finish(with: source, context: nil)
                        return
                    }
                    
                    request.finish(with: output, context: context)
                })
            }
        }
    }
}
