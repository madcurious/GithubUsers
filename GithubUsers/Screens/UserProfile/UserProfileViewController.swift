//
//  UserProfileViewController.swift
//  GithubUsers
//
//  Created by Matthew Quiros on 8/10/20.
//  Copyright © 2020 Matthew Quiros. All rights reserved.
//

import UIKit
import CoreData

class UserProfileViewController: UIViewController {
	
	@IBOutlet var customView: UserProfileView!
	
	var username: String?
	
	fileprivate var hasAppearedBefore = false
	fileprivate let queue = OperationQueue()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		customView.saveButton.addTarget(self, action: #selector(handleTapOnSaveButton(_:)), for: .touchUpInside)
		registerForNotifications()
		addTapGestureForDismissingKeyboard()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if hasAppearedBefore == false {
			begin()
			hasAppearedBefore = true
		}
	}
	
	deinit {
		customView.saveButton.removeTarget(self, action: #selector(handleTapOnSaveButton(_:)), for: .touchUpInside)
		NotificationCenter.default.removeObserver(self)
	}
	
}

// MARK: - Convenience functions
fileprivate extension UserProfileViewController {
	
	/// Shows the view for displaying errors.
	func showFailureView(forError error: Error) {
		customView.informationLabel.text = error.localizedDescription
		customView.state = .failure
	}
	
	func showSuccessView(with userProfile: UserProfile?) {
		customView.setUserProfile(userProfile)
		customView.state = .success
	}
	
	func showDialog(forError error: Error) {
		let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alertController, animated: true, completion: nil)
	}
	
	func showDialogForSuccessfulSave() {
		let alertController = UIAlertController(title: "Success", message: "Note saved.", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alertController, animated: true, completion: nil)
	}
	
	func registerForNotifications() {
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	func addTapGestureForDismissingKeyboard() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnView(_:)))
		view.addGestureRecognizer(tapGesture)
	}
	
}

// MARK: - Objective-C selectors
@objc fileprivate extension UserProfileViewController {
	
	func handleKeyboardWillShow(_ notification: NSNotification) {
		guard let userInfo = notification.userInfo,
			let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			else {
				return
		}
		let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
		customView.scrollView.contentInset = contentInsets
		customView.scrollView.scrollIndicatorInsets = contentInsets
		var viewFrame = customView.frame
		viewFrame.size.height -= keyboardSize.height
		if viewFrame.contains(customView.noteTextField.frame.origin) == false {
			customView.scrollView.scrollRectToVisible(customView.noteTextField.frame, animated: true)
		}
	}
	
	func handleKeyboardWillHide(_ notification: NSNotification) {
		customView.scrollView.contentInset = .zero
		customView.scrollView.scrollIndicatorInsets = .zero
	}
	
	func handleTapOnView(_ sender: UITapGestureRecognizer) {
		view.endEditing(true)
	}
	
	func handleTapOnSaveButton(_ sender: UIButton) {
		saveNoteInTextField()
	}
	
}

// MARK: - Worker functions
fileprivate extension UserProfileViewController {
	
	func begin() {
		guard let username = username
			else {
				return
		}
		
		customView.state = .loading
		do {
			if let userProfile = try fetchUserProfileFromCoreData(username: username) {
				showSuccessView(with: userProfile)
			} else {
				fetchUserProfileFromNetwork(username: username)
			}
		} catch {
			showFailureView(forError: error)
		}
	}
	
	func fetchUserProfileFromCoreData(username: String) throws -> UserProfile? {
		let result = CoreDataService.UserProfile.Fetch.execute(username: username, context: CoreDataStack.shared.viewContext)
		switch result {
		case .failure(let error):
			throw error
		case .success(let userProfile):
			return userProfile
		}
	}
	
	func fetchUserProfileFromNetwork(username: String) {
		let retryID = "\(UserProfileViewController.self).\(#function).\(username)"
		let operation = CombinedService.UserProfile.FetchAndSave(username: username) { (operation) in
			guard operation.isCancelled == false,
				let result = operation.result
				else {
					return
			}
			DispatchQueue.main.async {
				switch result {
				case .failure(let error):
					self.showFailureView(forError: error)
					RetryController.shared.mark(identifier: retryID) {
						self.fetchUserProfileFromNetwork(username: username)
					}
				case .success(let objectID):
					let userProfile = CoreDataStack.shared.viewContext.object(with: objectID) as? UserProfile
					self.showSuccessView(with: userProfile)
				}
			}
		}
		
		customView.state = .loading
		queue.addOperation(operation)
	}
	
	func saveNoteInTextField() {
//		guard let username = username
//			else {
//				return
//		}
//		let saveContext = PersistentContainer.shared.newBackgroundContext()
//		let note: String? = {
//			if let text = customView.noteTextField.text,
//				text.trim().isEmpty {
//				return nil
//			}
//			return customView.noteTextField.text?.trim()
//		}()
//		let saveOperation = SaveNoteCoreDataOperation(context: saveContext, username: username, note: note) { (operation) in
//			guard operation.isCancelled == false,
//				let result = operation.result
//				else {
//					return
//			}
//			DispatchQueue.main.async {
//				switch result {
//				case .failure(let error):
//					self.showDialog(forError: error)
//				case .success(_):
//					self.showDialogForSuccessfulSave()
//				}
//			}
//		}
//		PersistentContainer.queue.addOperation(saveOperation)
	}
	
}

