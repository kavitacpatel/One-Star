//
//  ViewController.swift
//  One Star
//
//  Created by sid patel on 8/1/16.
//  Copyright © 2016 coretwist. All rights reserved.
//
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import TwitterKit
import GoogleSignIn
import Google

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate
{
   
    var url: URL!
    var userNM: String = "User"
    var provider: String = ""
    var ref = FIRDatabaseReference.init()
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var pwTxt: UITextField!
    @IBOutlet weak var fbLoginBtn: FBSDKLoginButton!
    @IBOutlet weak var twitterLogin: TWTRLogInButton!
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = "1037434301168-0m55pao2fqsn3ktkhq23ntgm4dcstsgj.apps.googleusercontent.com"
    
        let Base_URL: String = "https://one-star.firebaseio.com/"
        ref = FIRDatabase.database().reference(fromURL: Base_URL)
        getUser()
        emailTxt.text = ""
        pwTxt.text = ""
        fbLoginBtn.readPermissions = ["public_profile", "email"]
        fbLoginBtn.delegate = self
       
    }
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
       /* try! FIRAuth.auth()?.signOut()
        if GIDSignIn.sharedInstance().currentUser != nil
        {
            GIDSignIn.sharedInstance().signOut()
        }
        if Twitter.sharedInstance().sessionStore.session()?.userID != nil
        {
           Twitter.sharedInstance().sessionStore.logOutUserID((Twitter.sharedInstance().sessionStore.session()?.userID)!)
        }*/
    }
    func getUser()
    {
        if FIRAuth.auth()?.currentUser != nil
        {
            self.provider = "email"
            if FIRAuth.auth()?.currentUser?.displayName != nil
            {
                userNM = (FIRAuth.auth()?.currentUser?.displayName)!
            }
            if FIRAuth.auth()?.currentUser?.email != nil
            {
                userNM = (FIRAuth.auth()?.currentUser?.email)!
                
            }
            
            self.performSegue(withIdentifier: "mainControllerSegue", sender: self)
        }
        else
        {
            print("No user is signed in.")
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "mainControllerSegue"
        {
            let vc = (segue.destination as! UITabBarController)
            let destinationViewController = vc.viewControllers![1] as! EarnStickersViewController
            destinationViewController.user = userNM
            
        }
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    func keyboardWillShow(sender: NSNotification)
    {
        self.view.frame.origin.y -= 150
    }
    func keyboardWillHide(sender: NSNotification)
    {
        self.view.frame.origin.y += 150
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textField.resignFirstResponder()
    }
    @IBAction func CreatAccount(_ sender: AnyObject)
    {
        if FIRAuth.auth()?.currentUser != nil
        {
            try! FIRAuth.auth()?.signOut()
        }
        FIRAuth.auth()?.createUser(withEmail: emailTxt.text!, password: pwTxt.text!) { (user, error) in
            
            if error != nil
            {
                
                if let errCode = FIRAuthErrorCode(rawValue: error!._code)
                {
                    
                    switch errCode
                    {
                    case .errorCodeInvalidEmail:
                        self.showalert("Email Login Error", msg: "Invalid Email or Password.")
                    case .errorCodeEmailAlreadyInUse:
                        self.showalert("Email Login Error", msg: "This email is in use.")
                    default:
                        self.showalert("Email Login Error", msg: error.debugDescription)
                    }
                    
                }
                
            }
            else
            {
                
                print("all good... continue")
                self.getUser()
            }
        }
    }
    @IBAction func emailLogin_Pressed(_ sender: AnyObject)
    {
        if FIRAuth.auth()?.currentUser != nil
        {
            try! FIRAuth.auth()?.signOut()
        }
        FIRAuth.auth()?.signIn(withEmail: self.emailTxt.text!, password: self.pwTxt.text!, completion: { (user: FIRUser?, err: Error?) in
              if err != nil
            {
                if err?._code == 17011
                {
                    self.showalert("Email Login Error", msg: "User not found.")
                }
                else if err?._code == 17009
                {
                    self.showalert("Email Login Error", msg: "The password is invalid")
                }
                else if err?._code == 17999
                {
                    self.showalert("Email Login Error", msg: "Missing password.")
                }
                else
                {
                    self.showalert("Email Login Error", msg: "Email login failed. \(err)")
                }
            }
            else
            {
                print("successfully logged ")
                
                // self.performSegue(withIdentifier: "DetailSegue", sender: self)
                self.getUser()
            }
        })
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
       FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name,last_name"]).start { (connection, fbresult, error) -> Void in
                
                if error != nil
                {
                    print(error)
                }
                else
                {
                    let resultdict = fbresult as! NSDictionary
                    self.userNM = ("\(resultdict.object(forKey: "first_name") as! String) \(resultdict.object(forKey: "last_name") as! String)")
                    
                    self.performSegue(withIdentifier: "mainControllerSegue", sender: self)
                }
                
            }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
    }
    
    @IBAction func twitterLogin_Pressed(_ sender: AnyObject)
    {
        Twitter.sharedInstance().logIn { (session: TWTRSession?, err: Error?) in
            if (session != nil)
            {
                //print("signed in as \(session?.userName)")
                self.userNM = (session?.userName)!
                self.performSegue(withIdentifier: "mainControllerSegue", sender: self)
                
            }
            else
            {
                print("error: \(err?.localizedDescription)")
            }
        }
           
    }
    
    @IBAction func googleLogin_Pressed(_ sender: AnyObject)
    {
        if GIDSignIn.sharedInstance().currentUser != nil
        {
            userNM = GIDSignIn.sharedInstance().currentUser.profile.email
           
           // self.performSegue(withIdentifier: "mainControllerSegue", sender: self)
        }
        else
        {
            GIDSignIn.sharedInstance().signIn()
        }
        
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if error != nil
        {
            showalert("Google Login Error", msg: error.localizedDescription)
        }
        else
        {
            
            userNM = user.profile.email
            self.performSegue(withIdentifier: "mainControllerSegue", sender: self)
        }
        
    }
   
    
    func showalert(_ title: String, msg:String)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertaction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertaction)
        present(alert, animated: true, completion: nil)
        
    }
    
}

