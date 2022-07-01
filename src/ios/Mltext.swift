//
//  MLText.swift
//  Simplifier
//
//  Created by Florian Pechwitz on 27.06.22.
//

import Foundation
import MLImage
import MLKit
import UIKit
import Photos

@objc (Mltext) class Mltext : CDVPlugin {
	
	static let NORMFILEURI = Int(0)
	static let NORMNATIVEURI = Int(1)
	static let FASTFILEURI = Int(2)
	static let FASTNATIVEURI = Int(3)
	static let BASE64 = Int(4)
	
	@objc (getText:)
	func getText(command: CDVInvokedUrlCommand){
		
		self.commandDelegate.run {
			let stype: Int = command.argument(at: 0, withDefault: Mltext.NORMFILEURI) as? Int ?? Mltext.NORMFILEURI
			guard var imgSrc: String = command.argument(at: 1, withDefault: nil) as? String else {
				let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "argument/parameter type mismatch error")
				self.commandDelegate.send(pluginResult, callbackId:command.callbackId)
				return
			}
			
			guard let vc: CDVViewController = self.viewController as? CDVViewController,
				  let settings = vc.settings else {
				let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "error settings/scheme")
				self.commandDelegate.send(pluginResult, callbackId:command.callbackId)
				return
			}
			
			let scheme = (settings["scheme"] as? String)?.lowercased() ?? ""
			let hostname: String = (settings["hostname"] as? String)?.lowercased() ?? "localhost"
			
			let CDV_Converted_Uri_Prefix = "\(scheme)://\(hostname)/_app_file_"
			
			if imgSrc.hasPrefix(CDV_Converted_Uri_Prefix) {
				imgSrc = imgSrc.replacingOccurrences(of: CDV_Converted_Uri_Prefix, with: "")
			}
			
			var image: UIImage?
			
			switch stype {
				case Mltext.NORMFILEURI:
					image = UIImage(contentsOfFile: imgSrc)
					break
				
				case Mltext.NORMNATIVEURI:
					let url = URL(string: imgSrc.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
					if let imageData = self.retrieveAssetDataPhotosFramework(url) {
						image = UIImage(data: imageData)
					}
					break
				
				case Mltext.FASTFILEURI:
					image = UIImage(contentsOfFile: imgSrc)
					image = self.resizeImage(image: self.image)
					break
				
				case Mltext.FASTNATIVEURI:
					let url = URL(string: imgSrc.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
					if let imageData = self.retrieveAssetDataPhotosFramework(url) {
						image = UIImage(data: imageData)
						image = self.resizeImage(image: self.image)
					}
					break
				
				case Mltext.BASE64:
					if let imageData = Data(base64Encoded: imgSrc, options: .ignoreUnknownCharacters) {
						image = UIImage(data: imageData)
					}
					break
				
				default:
					let pluginResult = CDVPluginResult(status: .error, messageAs: "sourceType argument should be 0,1,2,3 or 4")
					self.commandDelegate.send(pluginResult, callbackId:command.callbackId)
					return
			}
			
			guard let image = image else {
				let result = CDVPluginResult(status: .error, messageAs: "Error in uri or base64 data!")
				self.commandDelegate.send(result, callbackId: command.callbackId)
				return
			}
			
			let visionImage = VisionImage(image: image)
			visionImage.orientation = image.imageOrientation
			
			let textRecognizer = TextRecognizer.textRecognizer()
			
			let imgSize = image.size
			
			textRecognizer.process(visionImage) { result, error in
				guard error == nil, let result = result else {
					if result == nil {
						let cdvResult = ["foundText" : false]
						let resultcor = CDVPluginResult(status: .ok, messageAs: cdvResult)
						self.commandDelegate.send(resultcor, callbackId: command.callbackId)
						return
					}
					
					let resulta = CDVPluginResult(status: .error, messageAs: "Error with Text Recognition Module")
					self.commandDelegate.send(resulta, callbackId: command.callbackId)
					return
				}
				// Recognized text
				self.handleTextRecognizerResult(command, result: result, imgSize: imgSize)
			}
		}
	}
	
	private func handleTextRecognizerResult(_ command: CDVInvokedUrlCommand, result: Text, imgSize: CGSize) -> Void {
		
		var blocktext: [String] = []
		var blockpoints: [[String:String]] = []
		var blockframe: [[String:String]] = []
		
		var linetext: [String] = []
		var linepoints: [[String:String]] = []
		var lineframe: [[String:String]] = []
		
		var wordtext: [String] = []
		var wordpoints: [[String:String]] = []
		var wordframe: [[String:String]] = []
		
		for block: TextBlock in result.blocks {
			//Block text
			blocktext.append(block.text)
			
			//Block Corner Points
			let bpoobj = [
				"x1": "\(block.cornerPoints[0].cgPointValue.x)",
				"y1": "\(block.cornerPoints[0].cgPointValue.y)",
				"x2": "\(block.cornerPoints[1].cgPointValue.x)",
				"y2": "\(block.cornerPoints[1].cgPointValue.y)",
				"x3": "\(block.cornerPoints[2].cgPointValue.x)",
				"y3": "\(block.cornerPoints[2].cgPointValue.y)",
				"x4": "\(block.cornerPoints[3].cgPointValue.x)",
				"y4": "\(block.cornerPoints[3].cgPointValue.y)"
			]
			
			blockpoints.append(bpoobj)
			
			//Block frame
			let bframeobj = [
				"x": "\(block.frame.origin.x)",
				"y": "\(block.frame.origin.y)",
				"height": "\(block.frame.size.height)",
				"width": "\(block.frame.size.width)"
			]
			
			blockframe.append(bframeobj)
			
			for line: TextLine in block.lines {
				linetext.append(line.text)
				
				let lpoobj = [
					"x1": "\(line.cornerPoints[0].cgPointValue.x)",
					"y1": "\(line.cornerPoints[0].cgPointValue.y)",
					"x2": "\(line.cornerPoints[1].cgPointValue.x)",
					"y2": "\(line.cornerPoints[1].cgPointValue.y)",
					"x3": "\(line.cornerPoints[2].cgPointValue.x)",
					"y3": "\(line.cornerPoints[2].cgPointValue.y)",
					"x4": "\(line.cornerPoints[3].cgPointValue.x)",
					"y4": "\(line.cornerPoints[3].cgPointValue.y)"
				]

				linepoints.append(lpoobj)
				
				//Line Frame
				let lframeobj = [
					"x": "\(line.frame.origin.x)",
					"y": "\(line.frame.size.height)",
					"height": "\(line.frame.size.height)",
					"width": "\(line.frame.size.width)"
				]

				lineframe.append(lframeobj)
				
				for element: TextElement in line.elements {
					//Word Text
					wordtext.append(element.text)
					
					//Word Corner Points
					let wpoobj = [
						"x1": "\(element.cornerPoints[0].cgPointValue.x)",
						"y1": "\(element.cornerPoints[0].cgPointValue.y)",
						"x2": "\(element.cornerPoints[1].cgPointValue.x)",
						"y2": "\(element.cornerPoints[1].cgPointValue.y)",
						"x3": "\(element.cornerPoints[2].cgPointValue.x)",
						"y3": "\(element.cornerPoints[2].cgPointValue.y)",
						"x4": "\(element.cornerPoints[3].cgPointValue.x)",
						"y4": "\(element.cornerPoints[3].cgPointValue.y)"
					]

					wordpoints.append(wpoobj)

					let wframeobj = [
						"x": "\(element.frame.origin.x)",
						"y": "\(element.frame.size.height)",
						"height": "\(element.frame.size.height)",
						"width": "\(element.frame.size.width)"
					]

					wordframe.append(wframeobj)
				}
			}
		}
		
		let blocks: [String : Any] = [
			"blocktext" : blocktext,
			"blockpoints" : blockpoints,
			"blockframe" : blockframe
		]
		
		let lines: [String : Any] = [
			"linetext" : linetext,
			"linepoints" : linepoints,
			"lineframe" : lineframe
		]

		let words: [String : Any] = [
			"wordtext" : wordtext,
			"wordpoints" : wordpoints,
			"wordframe" : wordframe
		]

		let result: [String : Any] = [
			"foundText" : true,
			"blocks" : blocks,
			"lines" : lines,
			"words" : words,
			"imgWidth": imgSize.width,
			"imgHeight": imgSize.height,
			"text": result.text
		]
		
		let resultcor = CDVPluginResult(status: .ok, messageAs: result)
		self.commandDelegate.send(resultcor, callbackId: command.callbackId)
	}
	
	private func resizeImage(image: UIImage?) -> UIImage? {
		guard let image = image else {
			return nil
		}
		
		var actualHeight: CGFloat = image.size.height
		var actualWidth: CGFloat = image.size.width
		var imgRatio: CGFloat = actualWidth / actualHeight
		
		let maxHeight: CGFloat = 600
		let maxWidth: CGFloat = 600
		let compressionQuality = 0.50 //50 percent compression
		
		if actualHeight > maxHeight || actualWidth > maxWidth {
			let maxRatio: CGFloat = maxWidth / maxHeight
			
			if imgRatio < maxRatio {
				//adjust width according to maxHeight
				imgRatio = maxHeight / actualHeight
				actualWidth = imgRatio * actualWidth
				actualHeight = maxHeight
			}
			else if imgRatio > maxRatio {
				//adjust height according to maxWidth
				imgRatio = maxWidth / actualWidth
				actualHeight = imgRatio * actualHeight
				actualWidth = maxWidth
			}
			else {
				actualHeight = maxHeight
				actualWidth = maxWidth
			}
		}
		
		let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
		
		UIGraphicsBeginImageContext(rect.size)
		image.draw(in: rect)
		guard let img: UIImage = UIGraphicsGetImageFromCurrentImageContext(),
			  let imageData = UIImageJPEGRepresentation(img, compressionQuality) else {
			UIGraphicsEndImageContext()
			return nil
		}
		UIGraphicsEndImageContext()
		
		return UIImage(data: imageData)
	}
	
	func retrieveAssetDataPhotosFramework(_ urlMedia: URL?) -> Data? {
		var iData: Data?
		let result = PHAsset.fetchAssets(withALAssetURLs: [urlMedia].compactMap { $0 }, options: nil) as? PHFetchResult
		guard let asset = result?.firstObject as? PHAsset else {
			return nil
		}
		
		let imageManager = PHImageManager.default()
		let options = PHImageRequestOptions()
		options.isSynchronous = true
		options.version = .current
		
		imageManager.requestImageDataAndOrientation(for: asset, options: options) { imageData, dataUTI, orientation, info in
			iData = imageData
		}
		
		return iData
	}
}
