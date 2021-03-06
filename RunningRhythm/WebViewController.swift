//
//  WebViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 11/18/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import WebKit

@objc protocol WebViewControllerDelegate {
    func webViewControllerDidFinish(_ controller: WebViewController)
    @objc optional func webViewController(_ controller: WebViewController, didCompleteInitialLoad didLoadSuccessfully: Bool)
}

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var loadComplete: Bool = false
    var initialURL: URL!
    var webView: UIWebView!
    var delegate: WebViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SettingsViewController().UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        print(initialURL)
        let initialRequest = URLRequest(url: self.initialURL)
        self.webView = UIWebView(frame: self.view.bounds)
        self.webView.delegate = self
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.webView)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        self.webView.loadRequest(initialRequest)
    }
    
    func done() {
        
        self.delegate?.webViewControllerDidFinish(self)
        self.presentingViewController?.dismiss(animated: true, completion: { _ in })
        URLCache.shared.removeAllCachedResponses()
        
        // Delete any associated cookies
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if !self.loadComplete {
            delegate?.webViewController?(self, didCompleteInitialLoad: true)
            self.loadComplete = true
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if !self.loadComplete {
            
            delegate?.webViewController?(self, didCompleteInitialLoad: true)
            self.loadComplete = true
        }
    }
    
    init(url URL: URL) {
        super.init(nibName: nil, bundle: nil)
        self.initialURL = URL as URL!
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

