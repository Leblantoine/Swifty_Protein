//
//  LoginViewController.swift
//  Protein
//
//  Created by Antoine LEBLANC on 12/10/17.
//  Copyright © 2017 Antoine LEBLANC. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    let reason = NSLocalizedString("Authentication 🔐", comment: "authReason")
    var errorPointer:NSError?
    var ligands: [Ligand] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
    }

    @IBAction func LogMe(_ sender: Any) {
        touchIDAuthentication()
    }
    
    func touchIDAuthentication() {
        
        //1
        let context = LAContext()
        
        //2
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &errorPointer) {

            //3
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, reply: { (success, error) in
                if success {
                    self.successGoToNextView()
                }else {
                    self.displayErrorMessage(error: error as! LAError )
                }
            })
        }else {
            //Touch ID is not available on Device, use password.
            self.showAlertWith(title: "Error", message: (errorPointer?.localizedDescription)!)
        }
    }
    
    func displayErrorMessage(error:LAError) {
        var message = ""
        switch error.code {
        case LAError.authenticationFailed:
            message = "Authentication was not successful because the user failed to provide valid credentials."
            break
        case LAError.userCancel:
            message = "Authentication was canceled by the user"
            break
        case LAError.userFallback:
            message = "Authentication was canceled because the user tapped the fallback button"
            break
        case LAError.biometryNotEnrolled:
            message = "Authentication could not start because Biometry has no enrolled fingers."
        case LAError.passcodeNotSet:
            message = "Passcode is not set on the device."
            break
        case LAError.systemCancel:
            message = "Authentication was canceled by system"
            break
        default:
            message = error.localizedDescription
        }
        
        self.showAlertWith(title: "Authentication Failed", message: message)
    }
    
    // SUCESS - Go to Next View
    
    func successGoToNextView() {
        print("Auth: Successful regular authentication")
        getLigands()
        self.performSegue(withIdentifier: "showTableView", sender: self)
    }
    
    
    // MARK: Get ligands from .txt file
    
    func getLigands() {
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt"), let data = try? String(contentsOfFile: path) {
            for line in data.components(separatedBy: .newlines) {
                ligands.append(Ligand(fromName: line))
            }
        } else {
            print("Ligands setup: Cannot reach file ligands.txt")
            
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTableView", let nav = segue.destination as? UINavigationController, let destination = nav.topViewController as? TableViewController {
            destination.ligands = self.ligands
        }
    }
}

extension UIViewController {
    @objc func showAlertWith(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(actionButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
