//
//  SettingsViewController.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 10/26/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class SettingsViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    @IBOutlet weak var apiIntervalStepper: UIStepper!
    @IBOutlet weak var apiIntervalLabel: UILabel!
    @IBOutlet weak var apiTokenField: UITextField!
    @IBOutlet weak var colorSchemeCell: ColorSchemeTableViewCell!

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return ColorScheme().statusBarStyle()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Settings Screen")
        tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    }

    @IBAction func doneButtonTapped(sender: AnyObject) {
        if CI2GoUserDefaults.standardUserDefaults().circleCIAPIToken == apiTokenField.text {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            validateAPIToken(true)
        }
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func intervalValueChanged(sender: AnyObject) {
        let d = CI2GoUserDefaults.standardUserDefaults()
        let stepper = sender as? UIStepper
        let value = stepper?.value
        if stepper == apiIntervalStepper {
            setStepperValue(value!, forStepper: nil, withLabel: apiIntervalLabel)
            d.apiRefreshInterval = value!
        }
        let tracker = GAI.sharedInstance().defaultTracker
        let dict = GAIDictionaryBuilder.createEventWithCategory("settings", action: "api-interval-change", label: value!.description, value: value!).build() as [NSObject : AnyObject]
        tracker.send(dict)
    }

    private func setStepperValue(value: Double, forStepper stepper: UIStepper?, withLabel label: UILabel?) {
        let unit = value == 1.0 ? "second" : "seconds"
        if(value > 0) {
            label?.text = NSString(format: "%.01f %@", Double(value), unit) as String
        } else {
            label?.text = "Manual"
        }
    }

    private func validateAPIToken(dismissAfterSuccess: Bool = false) {
        let hud = MBProgressHUD(view: self.navigationController?.view)
        self.navigationController?.view.addSubview(hud)
        hud.animationType = MBProgressHUDAnimation.Fade
        hud.dimBackground = true
        hud.labelText = "Authenticating"
        hud.show(true)
        let token = apiTokenField.text
        //    let m = CircleCIAPISessionManager(apiToken: token)
        //    m.GET("me", parameters: nil,
        //      success: { (op: AFHTTPRequestOperation!, res: AnyObject!) -> Void in
        //        CI2GoUserDefaults.standardUserDefaults().circleCIAPIToken = token
        //        hud.labelText = "Authenticated"
        //        hud.customView = UIImageView(image: UIImage(named: "1040-checkmark-hud"))
        //        hud.mode = MBProgressHUDMode.CustomView
        //        hud.hide(true, afterDelay: 1)
        //        if dismissAfterSuccess {
        //          self.dismissViewControllerAnimated(true, completion: nil)
        //        }
        //      },
        //      failure: { (op: AFHTTPRequestOperation!, err: NSError!) -> Void in
        //        hud.labelText = "Failed to authenticate"
        //        hud.customView = UIImageView(image: UIImage(named: "791-warning-hud"))
        //        hud.mode = MBProgressHUDMode.CustomView
        //        hud.hide(true, afterDelay: 1)
        //      }
        //    )
        apiTokenField.resignFirstResponder()
    }

    // MARK: UITableViewController

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let wrapper = UIView()
            wrapper.backgroundColor = UIColor.clearColor()
            let button = UIButton()
            let text = "Copy your CircleCI API token from the Account Settings."
            button.setTitle(text, forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(10)
            button.sizeToFit()
            button.frame = CGRectMake(15, 0, button.frame.size.width, button.frame.size.height + 20)
            button.addTarget(self, action: "openAPIDoc:", forControlEvents: .TouchUpInside)
            wrapper.addSubview(button)
            return wrapper
        }
        return nil
    }

    func openAPIDoc(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://circleci.com/account/api")!)
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 0
    }

    // MARK: UIViewController

    override func viewWillDisappear(animated: Bool) {
        apiTokenField.resignFirstResponder()
    }

    override func viewWillAppear(animated: Bool) {
        let d = CI2GoUserDefaults.standardUserDefaults()
        let scheme = ColorScheme()
        self.colorSchemeCell.colorScheme = scheme
        self.apiTokenField.setValue(scheme.placeholderColor(), forKeyPath: "_placeholderLabel.textColor")
        setStepperValue(d.apiRefreshInterval, forStepper: apiIntervalStepper, withLabel: apiIntervalLabel)
        apiTokenField.text = d.circleCIAPIToken ?? ""
        let valid = d.circleCIAPIToken?.utf8.count == 40
        cancelButtonItem.enabled = valid
        doneButtonItem.enabled = valid
        apiIntervalStepper.value = d.apiRefreshInterval
        super.viewWillAppear(animated)
    }

    // MARK: UITextFieldDelegate

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let s = textField.text! as NSString
        let after: NSString = s.stringByReplacingCharactersInRange(range, withString: string)
        if after.length > 40 { return false }
        let set = NSCharacterSet(charactersInString: "abcdef1234567890").invertedSet
        doneButtonItem.enabled = after.length == 40
        let range = after.rangeOfCharacterFromSet(set)
        return range.location == NSNotFound
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let b = textField.text?.utf8.count == 40
        if b {
            validateAPIToken()
        }
        return b
    }
    
}
