//
//  MainHeaderViewController.swift
//  OWT_Swift
//
//  Created by Matthias BUREL on 03.03.19.
//  Copyright © 2019 Matthias BUREL. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import AFNetworking

enum URLValidationStatus: Int {
    case URL_EMPTY = 0
    case URL_BAD_FORMAT // 1
    case SERVER_ERROR // 1
}

class MainHeaderViewController:UIViewController, UITextFieldDelegate {
    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var sendUrlButton: UIButton!
    private var authorizationToken = ""
    
    var url: URLObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setTextFieldBorder(urlTextField)
        urlTextField.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return false
    }

    @IBAction func sendUrlAction(_ sender: Any) {

        if urlHasBeenValidate(urlTextField.text) {
            
            //************ Method 1 - Generate fake token ****************//
            // Method to generate fake TinyUrl with random Token.
            
            createFakeTinyUrl(StringUrl: urlTextField.text)
            //************************************************************//

            ///************ Method 2 - Generate real token from server ****************//
            // Method to generate Token from server (REST API).
            // The Api should return a Token for a given url
            
            //sendDNSAndCreateTokenRequest(urlTextField.text)
            //************************************************************************//
            
            urlTextField.text = nil
        }
    }

    func urlHasBeenValidate(_ url: String?) -> Bool {

        if (urlTextField.text?.count ?? 0) <= 0 {

            popErrorMessage(.URL_EMPTY)

            return false
        } else if !urlisValid(urlTextField.text) {

            popErrorMessage(.URL_BAD_FORMAT)

            return false
        } else {
            return true
        }
    }

    func urlisValid(_ candidate: String?) -> Bool {

        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        return urlTest.evaluate(with: candidate)

    }
    
    func setTextFieldBorder(_ textField: UITextField?) {

        let border = CALayer()
        let borderWidth: CGFloat = 1
        border.borderColor = UIColor.gray.cgColor
        border.frame = CGRect(x: 0, y: (textField?.frame.size.height ?? 0.0) - borderWidth, width: textField?.frame.size.width ?? 0.0, height: textField?.frame.size.height ?? 0.0)
        border.borderWidth = borderWidth
        textField?.layer.addSublayer(border)
        textField?.layer.masksToBounds = true
    }

    func popErrorMessage(_ error: URLValidationStatus) {

        var ErrorMessage: String

        switch error {
            case .URL_EMPTY:
                ErrorMessage = "Please complete the textfield to generate a tiny URL."
            case .URL_BAD_FORMAT:
                ErrorMessage = "URL appear not to be in a valid format. URL should be in this format:\nhttp(s)://xxx.com"
            case .SERVER_ERROR:
                ErrorMessage = "Server error."
        }

        let alertController = UIAlertController(title: "Info", message: ErrorMessage, preferredStyle: .alert)

        // Add Action
        alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))

        // Show Alert
        present(alertController, animated: true)
    }
    
    func createFakeTinyUrl(StringUrl: String?) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fakeToken = AppDelegate().randomStringWithLength(length: 6)
        
        let entity = NSEntityDescription.entity(forEntityName: "URL", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        
        
        newUser.setValue(UUID().uuidString, forKey: "uid")
        newUser.setValue(Date(), forKey: "date")
        newUser.setValue(StringUrl, forKey: "url")
        newUser.setValue(TINY_URL_DNS, forKey: "dns")
        newUser.setValue(fakeToken, forKey: "token")
        newUser.setValue(false, forKey: "isDemo")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
        NotificationCenter.default.post(name: Notification.Name("URL_DATA_UPDATED_NOTIFICATION"), object: nil)
    }

    
    func sendDNSAndCreateTokenRequest(_ url: String?) {
        // URL
        let urlString = "\(APP_BASE_URL)/\(CREATE_URL_TOKEN_REQUEST_PATH)"

        // Parameters
        let parameters = [
            "client_id": APP_CLIENT_ID,
            "client_secret": APP_CLIENT_SECRET,
            "url": url
        ]

        // Request
        let urlRequest: URLRequest? = AFJSONRequestSerializer().request(withMethod: "POST", urlString: urlString, parameters: parameters, error: nil) as URLRequest

        let dataTask: URLSessionDataTask? = AFHTTPSessionManager().dataTask(
            with: urlRequest!,
            uploadProgress: nil,
            downloadProgress: nil,
            completionHandler: {
                
                response, responseObject, error in

                if error != nil {
                    // Manage Error
                    self.popErrorMessage(.SERVER_ERROR)
                } else {
                    
                    // Create url and save locally
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    let entity = NSEntityDescription.entity(forEntityName: "URL", in: context)
                    let newUser = NSManagedObject(entity: entity!, insertInto: context)
                    
                    newUser.setValue(UUID().uuidString, forKey: "uid")
                    newUser.setValue((responseObject as? [AnyHashable : Any])?["Date"], forKey: "date")
                    newUser.setValue((responseObject as? [AnyHashable : Any])?["Url"], forKey: "url")
                    newUser.setValue((responseObject as? [AnyHashable : Any])?["Dns"], forKey: "dns")
                    newUser.setValue((responseObject as? [AnyHashable : Any])?["Token"], forKey: "token")
                    newUser.setValue((responseObject as? [AnyHashable : Any])?["IsDemo"], forKey: "isDemo")
                    
                    do {
                        try context.save()
                    } catch {}
                    
                    NotificationCenter.default.post(name: Notification.Name("URL_DATA_UPDATED_NOTIFICATION"), object: nil)
                }
        })
        dataTask?.resume()
    }
}
