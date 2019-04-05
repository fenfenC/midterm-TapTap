import UIKit
import QuartzCore

////////////////////////////////////////////////////////////////////
// NOTE: Update to unique name.
// Service type must be a unique string, at most 15 characters long
// and can contain only ASCII lowercase letters, numbers and hyphens.
let ServiceType = "mobile-lab"


class ViewController: UIViewController, UITextFieldDelegate, MultipeerServiceDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var seconds: Int!
    var score: Int!
    var timer: Timer!
    
    var allScores: [String:Int] = [:]
    
    //@IBOutlet weak var textView: UITextView!
    @IBOutlet weak var connectionsTextView: UITextView!
    
    @IBOutlet weak var textView: UITextView!
    // Popup for entering username.
    var alert : UIAlertController!
    
    // Service for handling P2P communication.
    var multipeerService: MultipeerService?
    
    // Display name.
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        allScores[""] = 0
//        allScores[""] = 1
//        allScores.removeAll()
//        let sortedScores = allScores.sorted { (player1, player2) -> Bool in
//        return player1.value > player2.value
//        }
//        print(sortedScores.first)
        
        // Setting for text view to allow auto scroll to bottom.
        textView.layoutManager.allowsNonContiguousLayout = false
        timeLabel.layer.borderColor = UIColor.white.cgColor
        
        //setupGame()
        
        // Prompt user to input username and start P2P communication.
        restart()
        
    }
    
    
    func setupGame(){
        seconds = 20
        score = 0
        
        timeLabel.text = "Time : \(seconds!)"
        scoreLabel.text = "Score\n \(score!)"
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(subtractTime), userInfo: nil, repeats: true)
    }
    
    
    // Show popup for entering username, P2P servic will start when name entered.
    func restart() {
        // Clear text view.
        textView.text = ""
        
        // Create alert popup.
        alert = UIAlertController(title: "Enter your username", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Username..."
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })
        
        // Create action on OK press.
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            if let name = self.alert.textFields?.first?.text {
                // Save username and set to title.
                self.username = name
                self.navigationItem.title = name
                self.setupGame()
                ///////////////////////////////////////////////////////
                // NOTE: Start P2P.
                self.startMultipeerService(displayName: name)
                ///////////////////////////////////////////////////////
                
            }
        })
        action.isEnabled = false
        alert.addAction(action)
        
        // Show alert popup.
        self.present(alert, animated: true)
    }
    
    // Disable okay button when text field is empty.
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert.actions[0].isEnabled = sender.text!.count > 0
    }
    
    // Start multipeer service with display name.
    func startMultipeerService(displayName: String) {
        self.multipeerService = nil
        self.multipeerService = MultipeerService(dispayName: displayName)
        self.multipeerService?.delegate = self
        
    }
    
    
    @objc func subtractTime(){
        seconds = seconds - 1
        timeLabel.text = "Time : \(seconds!)"
        
        if seconds == 0 {
            let alert = UIAlertController(title: "Game Over", message: "You have scored\(score!) points.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Play Again?", style: .default, handler: { (action) in
                
                self.setupGame()
                
            })
            
            alert.addAction(action)
            present(alert, animated:true, completion: nil)
            
            timer.invalidate()
        }
    }
    
    
    func appendText(_ string: String) {
        textView.text += "\n" + string
        textView.scrollRangeToVisible(NSMakeRange(textView.text.count, 0))
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        print(score)
        score = score + 1
        scoreLabel.text = "Score : \(score!)"
        // Prepend usename to msg.
        let msg = "\(self.username) \(String(describing: score))"
        
        // ""
        
        multipeerService?.send(msg: msg)
    }
    
    
    
    // Send message to other peers and append to text view on button press.
    @IBAction func didTapSendButton(_ sender: UIButton) {
        //guard let text = msg.text.count > 0 else { return }
        
        // Prepend usename to msg.
        let msg = self.username + ":"
        
        /////////////////////////////////////////////
        // NOTE: Send msg to other peers.
        multipeerService?.send(msg: msg)
        /////////////////////////////////////////////
        
        // Append msg to text view.
        appendText(msg)
        
        
    }
    
    // Dismisses keyboard when done is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    
    @IBAction func didTapRestartButton(_ sender: UIBarButtonItem) {
        restart()
    }
    
    @IBAction func didTapClearButton(_ sender: UIBarButtonItem) {
        textView.text = ""
    }
    
    @IBAction func didTapDisconnectButton(_ sender: UIBarButtonItem) {
        multipeerService?.session.disconnect()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: - MultipeerServiceDelegate
    
    // NOTE: Process when onnected devices have changed.
    func connectedDevicesChanged(manager: MultipeerService, connectedDevices: [String]) {
        DispatchQueue.main.async {
            self.connectionsTextView.text = "\(connectedDevices)"
        }
    }
    
    // NOTE: Process recieved msg.
    func receivedMsg(manager: MultipeerService, msg: String) {
        DispatchQueue.main.async {
            print("Received message:", msg)
            //username:score
            
            //          Scoresdictionary
            var players: [String: Int] = [:]
            players[self.username] = self.score
            players[self.username] = self.score
            
            // Need to parse message to get the score
            // Save the scores somewhere
            let sorted = players.sorted { (player1, player2) -> Bool in
                player1.value < player2.value
            }
            self.appendText("\(sorted.first?.key) try to catch up!" )
            //print("The winner：\(String(describing: sorted.first))" )
            players.removeAll()
            
            
        }
    }
    
}
