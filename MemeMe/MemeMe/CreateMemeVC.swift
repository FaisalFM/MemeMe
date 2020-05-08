//
//  ViewController.swift
//  MemeMe
//
//  Created by FaisalFM on 05/05/2020.
//  Copyright © 2020 Faisal FM. All rights reserved.
//

import UIKit

class CreateMemeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {


    
    @IBOutlet weak var imgPickerView: UIImageView!
    @IBOutlet weak var takAPic: UIBarButtonItem!
    @IBOutlet weak var pickAlbum: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var share: UIBarButtonItem!
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        takAPic.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        imgPickerView.contentMode = .scaleAspectFit
        if imgPickerView.image == nil {
            share.isEnabled = false
        }
        setupTextFieldStyle( textField: topText, defaultText: "ENTER TOP TEXT")
        setupTextFieldStyle( textField: bottomText, defaultText: "ENTER BOTTOM TEXT")
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topText.delegate = self
        bottomText.delegate = self
              
    }
    
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
    }

    
    

    @IBAction func pickAlbum(_ sender: Any) {
        openImagePicker(.photoLibrary)
    }
    
    @IBAction func takeAPic(_ sender: Any) {
        openImagePicker(.camera)
    }
  
    func openImagePicker(_ type: UIImagePickerController.SourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[.originalImage] as? UIImage {
            
            imgPickerView.image = originalImage
            share.isEnabled = true
        }
        dismiss(animated: true, completion: nil )
    }
    
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if (bottomText.isEditing){
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }

   
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
        
    }
    
    //@KB
    func setupTextFieldStyle(textField: UITextField, defaultText: String) {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 30)!,
            NSAttributedString.Key.strokeWidth:  -3

        ]
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.textAlignment = .center

           }
        
    
    func textField(textField: UITextField, text: String) {
        setupTextFieldStyle( textField: topText, defaultText: "ENTER TOP TEXT")
        setupTextFieldStyle( textField: bottomText, defaultText: "ENTER BOTTOM TEXT")

        return
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "ENTER TOP TEXT" || textField.text == "ENTER BOTTOM TEXT"{
            textField.text = ""}
    }
    

    func save() {
        _ = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imgPickerView.image!, memedImage: generateMemedImage())
        
        
    }
    
    func generateMemedImage() -> UIImage {
        // TODO: Hide toolbar and navbar
        hideNavAndToolBars(isHidden: true)

        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // TODO: Show toolbar and navbar
        hideNavAndToolBars(isHidden: false)
        
        
        return memedImage
    }
    func hideNavAndToolBars(isHidden: Bool) {
        
        navBar.isHidden = isHidden
        toolbar.isHidden = isHidden
    }

    
    @IBAction func share(_ sender: Any) {

        let memedImage:UIImage = generateMemedImage()
        let activity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activity.completionWithItemsHandler = {(ActivityType,completed,returnedItems , activityError) in

            if completed {
                print("Completed")
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(activity, animated: true, completion: nil)
        
    }
    

    @IBAction func cancel(_ sender: Any) {
        imgPickerView.image = nil
        share.isEnabled = false
        setupTextFieldStyle( textField: topText, defaultText: "ENTER TOP TEXT")
        setupTextFieldStyle( textField: bottomText, defaultText: "ENTER BOTTOM TEXT")

    }
    
    
    
}


