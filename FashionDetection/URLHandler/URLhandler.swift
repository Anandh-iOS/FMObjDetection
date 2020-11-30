//
//  URLhandler.swift
//  AgencyPortal
//
//  Created by Azees Mac Mini on 06/08/19.
//  Copyright © 2019 Azees Mac Mini. All rights reserved.
//

import Foundation
import Alamofire


class URLhandler: NSObject
{
    static let sharedinstance = URLhandler()
    
    func postImageRequestWithURL(withUrl strURL: String,withParam postParam: Dictionary<String, Any>,withImages imageArray:NSMutableArray,completion:@escaping (_ isSuccess: Bool, _ response:NSDictionary) -> Void)
    {

        Alamofire.upload(multipartFormData: { (MultipartFormData) in

            // Here is your Image Array
            for (imageDic) in imageArray
            {
                let imageDic = imageDic as! NSDictionary

                for (key,valus) in imageDic
                {
                    MultipartFormData.append(valus as! Data, withName:key as! String,fileName: "file.jpg", mimeType: "image/jpg")
                }
            }

            // Here is your Post paramaters
            for (key, value) in postParam
            {
                MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }

        }, usingThreshold: UInt64.init(), to: strURL, method: .post) { (result) in

            switch result {
            case .success(let upload, _, _):

                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })

                upload.responseJSON { response in

                    if response.response?.statusCode == 200
                    {
                        let json = response.result.value as? NSDictionary

                        completion(true,json!);
                    }
                    else
                    {
                        completion(false,[:]);
                    }
                }

            case .failure(let encodingError):
                print(encodingError)

                completion(false,[:]);
            }

        }
    }
    
}
