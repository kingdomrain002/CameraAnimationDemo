//
//  AppDelegate.swift
//  CameraAnimationDemo
//
//  Created by yzf-macmini on 2025/8/28.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
      func application(
          _ application: UIApplication,
          didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
      ) -> Bool {
          
          window = UIWindow(frame: UIScreen.main.bounds)
          window?.rootViewController = CameraViewController()
          window?.makeKeyAndVisible()
          return true
      }

}

