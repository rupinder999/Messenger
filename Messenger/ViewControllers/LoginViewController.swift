//
//  LoginViewController.swift
//  Messenger
//
//  Created by Rupinder on 07/10/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import JGProgressHUD

class LoginViewController: UIViewController {

//    @IBOutlet weak var loginImageView: UIImageView!
//    @IBOutlet weak var emailAddressTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var signInButton: UIButton!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder  = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder  = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
//        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font  = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email","public_profile"]
        return button
    }()
    
    private let googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        //button.permissions = ["email","public_profile"]
        return button
    }()
    
    override func viewDidLoad() {

        
        
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        emailField.delegate = self
        passwordField.delegate = self

        facebookLoginButton.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
        /// ADD SUBVIEWS
        view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
        
//
//        passwordTextField.layer.cornerRadius = 12
//        emailAddressTextField.layer.cornerRadius = 12
//        signInButton.layer.cornerRadius = 12
//        passwordTextField.layer.borderWidth = 1
//        emailAddressTextField.layer.borderWidth = 1
//        signInButton.layer.borderWidth = 1
//        passwordTextField.isSecureTextEntry = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width - size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom+10, width: scrollView.width-60, height: 52)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+10, width: scrollView.width-60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom+10, width: scrollView.width-60, height: 52)
        facebookLoginButton.frame = CGRect(x: 30, y: loginButton.bottom+10, width: scrollView.width-60, height: 52)
        facebookLoginButton.frame.origin.y = loginButton.bottom+20
        googleLoginButton.frame = CGRect(x: 30, y: facebookLoginButton.bottom+10, width: scrollView.width-60, height: 52)
        googleLoginButton.frame.origin.y = facebookLoginButton.bottom+20
    }
    
    @objc private func loginButtonTapped(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else{
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            
            guard let result = authResult, error == nil else{
                print("Error creating result")
                return
            }
            
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.geteDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let value):
                    guard let userData = value as? [String:Any], let firstName = userData["first_name"] as? String, let lastName = userData["first_name"] as? String else {
                        return
                    }
                    
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    
                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            print("\(user)  Successfully Logged In")
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
      
        })

    }
    
    @objc private func googleLoginButtonTapped(){
                guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
                // Create Google Sign In configuration object.
                let config = GIDConfiguration(clientID: clientID)
        
                // Start the sign in flow!
                GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] user, error in
        
                        guard let strongSelf = self else{
                            return
                        }
                    
                        
                          if error != nil{
                            // ...
                            return
                          }
                    
                    guard let email = user?.profile?.email, let firstName = user?.profile?.givenName, let lastName = user?.profile?.familyName else{
                        return
                    }
                    
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    
                    DatabaseManager.shared.userExists(with: email, completion: { exists in
                        if !exists{
                            
                            let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                            
                            DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                                if success {
                                    //upload image
                                    
                                    if ((user?.profile?.hasImage) != nil) {
                                        guard let url = user?.profile?.imageURL(withDimension: 200) else {
                                            return
                                        }
                                        
                                        URLSession.shared.dataTask(with: url, completionHandler: { data, _ , error in
                                            guard let data = data else{
                                                print("failed to get data from facebook")
                                                return
                                            }
                                            
                                            print("got data from FB, uploading...")
                                            
                                            let fileName = chatUser.profilePictureFileName
                                            StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                                switch result {
                                                case .success(let downloadUrl):
                                                    UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                                    print(downloadUrl)
                                                case .failure(let error):
                                                    print("storage manger error: \(error)")
                                                }
                                            })
                                        }).resume()
                                    }
                                    
                                }
                            })
                        }
                    })
                    
                          guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                            return
                          }
                
                          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                         accessToken: authentication.accessToken)
                    
                    FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                        guard authResult != nil, error == nil else{
                            print("Something went wrong")
                            return
                        }
                        
                        print("Successfully signed in with google credential")
                        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                    })

                        }
        
        
        

    }
    
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Woops", message: "Please enter all information correctly.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    }
    
    @objc private func didTapRegister() {
        //let vc = (storyboard?.instantiateViewController(withIdentifier: "registerViewController"))!
        let vc  = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

//    @IBAction func signInButtonTapped(){
//        print("Sign In tapped")
//    }

}

extension LoginViewController: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to login with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make a facebook graph request.")
                return
            }
            
            print("\(result)")
            
            guard let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let email = result["email"] as? String, let picture = result["picture"] as? [String:Any], let data = picture["data"] as? [String:Any], let pictureUrl = data["url"] as? String else{
                print("Failed to get email and name from fb result")
                return
            }
                
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists{
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser,completion: { success in
                        if success {
                           //upload image
                            guard let url = URL(string: pictureUrl) else{
                                return
                            }
                            print("downloading image from facebook")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _ , error in
                                guard let data = data else{
                                    print("failed to get data from facebook")
                                    return
                                }
                                
                                print("got data from FB, uploading...")
                                
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("storage manger error: \(error)")
                                    }
                                })
                            }).resume()
                        }
                    })
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else{
                    return
                }
                
                guard authResult != nil, error == nil else{
                    print("Facebook credential login failed. MFA may be needed.")
                    return
                }
                
                print("Successfully Logged user in.")
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })

        })
    }
    
    
}
