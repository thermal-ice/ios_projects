//
//  ViewController.swift
//  Actual_foodtracker
//
//  Created by Carlos Huang on 2020-04-05.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    //MARK: Properties
    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //This is either constructed when making a new meal or passed by MealTableViewController
    
    var meal: Meal?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //handles the text field's user input through delegate callbacks
        //When viewcontroller loads, sets itself as the delegate of its nameTextField property.
        nameTextField.delegate = self
        updateSaveButtonState()
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hides the keyboard
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
        
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as?
            UIImage else{
                fatalError("Expected dictionary with image but got: \(info)")
        }
        photoImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
        
        
    }
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button == saveButton else{
            os_log("Save button not pressed, thus cancelling", log:OSLog.default,type: .debug)
            return
        }
        //Set meal to be passed to MealTableViewController after unwind segue
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        
        meal = Meal(name: name, photo: photo, rating: rating)
    }
    
    
    //MARK: Actions

    
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        nameTextField.resignFirstResponder()
        
        //view controller that lets user pick media from library
        let imagePickerController = UIImagePickerController()
        
        
        //selects photo from library, no where else
        imagePickerController.sourceType = .photoLibrary
        
        //Notifies the view controller
        imagePickerController.delegate = self
        present(imagePickerController,animated: true, completion: nil)
        
        
        
        
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState(){
        
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    
}

