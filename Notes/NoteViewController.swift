//
//  NoteViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 07/02/16.
//  Copyright © 2016 Bart Jacobs. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var contentTextView: UITextView!

    var note: Note!

    // MARK: -
    // MARK: View Life Cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Update User Interface
        titleTextField.text = note.title
        contentTextView.text = note.content
    }

    // MARK: -
    // MARK: Actions
    @IBAction func save(sender: UIBarButtonItem) {
        if let title = titleTextField.text, let content = contentTextView.text {
            // Update Note
            note.title = title
            note.content = content
            note.updatedAt = NSDate().timeIntervalSinceReferenceDate

            // Pop View Controller From Navigation Stack
            navigationController?.popViewControllerAnimated(true)
        }
    }

}
