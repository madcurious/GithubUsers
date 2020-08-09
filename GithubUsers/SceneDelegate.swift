//
//  SceneDelegate.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/5/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	
	func sceneWillEnterForeground(_ scene: UIScene) {
		Reachability.shared.startNotifier()
	}
	
	func sceneDidEnterBackground(_ scene: UIScene) {
		Reachability.shared.stopNotifier()
	}

}

