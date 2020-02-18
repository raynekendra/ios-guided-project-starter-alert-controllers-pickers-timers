//
//  CountdownViewController.swift
//  Countdown
//
//  Created by Paul Solt on 5/8/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var countdownPicker: UIPickerView!
    
    // MARK: - Properties
    
    private let countdown = Countdown()
    //instance or brain behind timer ^
    
    lazy private var countdownPickerData: [[String]] = {
        //[["1", "2", "3"... "60"]["min"]["1", "2", "3"... "59"]["sec"]] ~ what's going to be shown.
        // Create string arrays using numbers wrapped in string values: ["0", "1", ... "60"]
        let minutes: [String] = Array(0...60).map { String($0) }
        let seconds: [String] = Array(0...59).map { String($0) }
        
        // "min" and "sec" are the unit labels
        let data: [[String]] = [minutes, ["min"], seconds, ["sec"]]
        return data
    }()
    
    private var duration: TimeInterval {
        //Convert from minutes + seconds to total seconds
        let minuteString = countdownPicker.selectedRow(inComponent: 0)
        let secondString = countdownPicker.selectedRow(inComponent: 2)
        let minutes = Int(minuteString)
        let seconds = Int(secondString)
        let totalSeconds = TimeInterval(minutes * 60 + seconds)
        return totalSeconds
    }
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    // makes this a computed property, and then the () stores it once.
    
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        countdownPicker.dataSource = self
        countdownPicker.delegate = self
        
        countdownPicker.selectRow(1, inComponent: 0, animated: true)
        countdownPicker.selectRow(30, inComponent: 2, animated: true)
        
        countdown.delegate = self
        countdown.duration = duration
        
        
        timeLabel.font = UIFont.monospacedSystemFont(ofSize: timeLabel.font.pointSize, weight: .medium)
        //use a fixed width font so numbers don't pop and update UI to show duration
        startButton.layer.cornerRadius = 4.0
        resetButton.layer.cornerRadius = 4.0
        
        updateViews()
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        countdown.start()
    }
    private func timerFinished(timer: Timer) {
        showAlert()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        countdown.reset()
    }
    
    // MARK: - Private
    
    private func showAlert() {
        let alert = UIAlertController(title: "Timer Finished", message: "Your countdown is over :D", preferredStyle: .alert) // .alert, .actionSheet (pops up on the bottom, more for presentation style)
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil) // style: default and cancel look the same. .destructive actions turn the button red, it's to actually delete something off.
        // nil in handler dismisses the alert.
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateViews() {
        startButton.isEnabled = true
        
        switch countdown.state {
        case .started:
            timeLabel.text = string(from: countdown.timeRemaining)
            startButton.isEnabled = false
        case .finished:
            timeLabel.text = string(from: 0)
        case .reset:
            timeLabel.text = string(from: countdown.duration)
        }
        
    }
    
    private func string(from duration: TimeInterval) -> String {
       let date = Date(timeIntervalSinceReferenceDate: duration)
        return dateFormatter.string(from: date)
    }
}
// Adopting delegate and conforming.

extension CountdownViewController: CountdownDelegate {
    func countdownDidUpdate(timeRemaining: TimeInterval) {
        updateViews()
    }
    
    func countdownDidFinish() {
        showAlert()
        updateViews()
        
    }
}

extension CountdownViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return countdownPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return countdownPickerData[component].count // called subscript syntax []
    }
}

extension CountdownViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let timeValue = countdownPickerData[component][row]
        return String(timeValue)
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countdown.duration = duration
        updateViews()
    }
    
    
    func didChange<Value>(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, for keyPath: __owned KeyPath<CountdownViewController, Value>) {
        //UPdate UILabel
    }
}
