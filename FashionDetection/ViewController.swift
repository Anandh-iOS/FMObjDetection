//
//  ViewController.swift
//  FashionDetection
//
//  Created by Anandh Selvam on 28/11/20.
//  Copyright © 2020 Anandh Selvam. All rights reserved.
//

import UIKit
import SwiftyToolTip

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var img: UIImageView!
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func didClick_upload(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        img.image = image
        uploadImge(image: image)
    }
    
    func uploadImge(image: UIImage)
    {
        indicator.startAnimating()
        let ImageDic = ["image" :  image.jpegData(compressionQuality: 1)]
        // Here you can pass multiple image in array i am passing just one
        let ImageArray = NSMutableArray(array: [ImageDic as NSDictionary])
        img.subviews.forEach { $0.removeFromSuperview() }
        URLhandler.sharedinstance.postImageRequestWithURL(withUrl: "http://52e77e28e446.ngrok.io", withParam:[:], withImages: ImageArray) { (isSuccess, response) in
            self.indicator.stopAnimating()
                let objectArr = response["items"] as AnyObject? as! NSArray
                if objectArr.count>0
                {
                    for obj in objectArr
                    {
                        let dict = obj as? [String:Any]
                        let box = dict?["box"] as? Array<Double>
                        
                        let imageAspectRect = self.frame(for: self.img.image!, inImageViewAspectFit: self.img)
                        
                        let W = imageAspectRect.size.width
                        let H = imageAspectRect.size.height

                        var x = self.calculatePercentage(value:Double(box![0]), percentageVal:Double(W))
                        var y = self.calculatePercentage(value:Double(box![1]), percentageVal:Double(H))
                        let width = self.calculatePercentage(value:Double(box![2]), percentageVal:Double(W))
                        let height = self.calculatePercentage(value:Double(box![3]), percentageVal:Double(H))
                        let widthDiff = (self.img.frame.size.width-W)/2
                        let heightDiff = (self.img.frame.size.height-H)/2
                        x = ((x+(width/2))-15) + Double(widthDiff)
                        y = ((y+(height/2))-10) + Double(heightDiff)
                        
                        let name = dict?["class"] as! String
                        
                        let dotImg = UIImageView(image: UIImage(named: "dot"))
                        dotImg.isUserInteractionEnabled = true
                        dotImg.frame = CGRect(x: x, y: y, width: 30, height: 30)
                        self.img.addSubview(dotImg)
                        dotImg.addToolTip(description: name, gesture: .doubleTap, isEnabled: true)

//                        let clsid = dict?["classID"]
                    }
                }
            }
    }
    
    func frame(for image: UIImage, inImageViewAspectFit imageView: UIImageView) -> CGRect {
      let imageRatio = (image.size.width / image.size.height)
      let viewRatio = imageView.frame.size.width / imageView.frame.size.height
      if imageRatio < viewRatio {
        let scale = imageView.frame.size.height / image.size.height
        let width = scale * image.size.width
        let topLeftX = (imageView.frame.size.width - width) * 0.5
        return CGRect(x: topLeftX, y: 0, width: width, height: imageView.frame.size.height)
      } else {
        let scale = imageView.frame.size.width / image.size.width
        let height = scale * image.size.height
        let topLeftY = (imageView.frame.size.height - height) * 0.5
        return CGRect(x: 0.0, y: topLeftY, width: imageView.frame.size.width, height: height)
      }
    }
    
    public func calculatePercentage(value:Double,percentageVal:Double)->Double{
        let val = value * percentageVal
        return val / 100.0
    }
    
}

