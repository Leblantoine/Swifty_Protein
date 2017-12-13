//
//  LoginViewController.swift
//  Protein
//
//  Created by Antoine LEBLANC on 12/10/17.
//  Copyright © 2017 Antoine LEBLANC. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {

    let context = LAContext()
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var ligands: [Ligand] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.delegate = self
        password.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        biometricAuth()
    }

    // MARK: Regular Auth
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 0, let nextTextField = textField.superview?.viewWithTag(1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else if textField.tag == 1 {
            resignFirstResponder()
            regularAuth()
        }
        return true
    }
    
    @IBAction func touchLogin(_ sender: UIButton) {
        regularAuth()
    }
    
    func regularAuth() {
        if let username = username.text, let password = password.text, username == "antoine" && password == "antoine" {
            print("Auth: Successful regular authentication")
            getLigands()
            self.performSegue(withIdentifier: "showTableView", sender: self)
        } else {
            print("Auth: Bad regular authentication")
            let alert = UIAlertController(title: "Authentication failed", message: "Please try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: Biometric Auth
    
    @IBAction func touchFingerPrint(_ sender: UIButton) {
        biometricAuth()
    }
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func biometricAuth() {
        // Disable "Enter password" when TouchID fail the first time
        context.localizedFallbackTitle = ""
        
        if canEvaluatePolicy() {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We need your TouchID", reply: { (wasSuccessful, error) in
                if wasSuccessful {
                    print("Auth: Successful biometric authentication")
                    self.getLigands()
                    self.performSegue(withIdentifier: "showTableView", sender: self)
                } else {
                    print("Auth: Bad biometric authentication")
                    let alert = UIAlertController(title: "Authentication failed", message: "Please try again", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            let alert = UIAlertController(title: "Biometric authentication are not enabled", message: "Would you like to activate it ?", preferredStyle: .alert)

            let enableAction = UIAlertAction(title: "Enable it", style: .default, handler: { (_) in
                print("Auth: Enable biometrics authentication")
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Auth: Settings opened")
                    })
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                print("Auth: Cancel activation of biometrics authentication")
            })
            
            alert.addAction(enableAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
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
