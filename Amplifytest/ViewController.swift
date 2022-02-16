//
//  ViewController.swift
//  Amplifytest
//
//  Created by Jennifer Patino on 11/1/21.
//

//IMPORTANT::
//Client ID cadde483e3e040898fc31e270397eac9
//Client Secret cf7513f37b69483285005a67183f2a9a


import UIKit
import StoreKit
import Foundation
import AVFoundation
import MediaPlayer
import CoreBluetooth
import CocoaMQTT


class ViewController: UIViewController {
    
    //creating the view controller for the bluetooth settings
   //  @IBOutlet var tableView: UITableView!
    //let mqttClient = CocoaMQTT(clientID: "iOS Device", host: "192.168.0.X", port: 1883)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

class IntroViewController: UIViewController {
    
    //creating the view controller for the bluetooth settings
   //  @IBOutlet var tableView: UITableView!
    let mqttClient = CocoaMQTT(clientID: "iOS Device", host: "169.254.66.36", port: 1883)
    
    @IBAction func connectButtonMQTT(_ sender: UIButton) {
        mqttClient.connect()
    }
    
    @IBAction func disconnectButtonMQTT(_ sender: UIButton) {
        mqttClient.disconnect()
    }
    
    @IBAction func gpio40SW(_ sender: UISwitch) {
        if sender.isOn {
            mqttClient.publish("rpi/gpio", withString: "on")
        }
        else {
            mqttClient.publish("rpi/gpio", withString: "off")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
}

    
class HomeViewController: UIViewController {
    
    //creating the view controller for the home page
    //running the audio plater in the home screen
    var player:AVAudioPlayer = AVAudioPlayer()

    //play, pause, replay buttons
    @IBAction func play(_ sender: AnyObject)
    {
        player.play()
    }
    @IBAction func pause(_ sender: AnyObject)
    {
        player.pause()
    }
    @IBAction func replay(_ sender: AnyObject)
    {
        player.currentTime = 0
    }
    @IBOutlet weak var volumeControl: UISlider!
    @IBAction func adjustVolume(sender: AnyObject) {
        if player != nil {
            player.volume = volumeControl.value
        }
    }
    
    //buttonCounters
    var likeButtonCount: Float = 0.0
    var dislikeButtonCount: Float = 0.0
    var dislikeString: String = " "
    var likeString: String = " "
    
    
    //Dislike button
    @IBAction func dislike(_ sender: AnyObject)
    {
        minClickCount()
    }
    
    //Like button
    @IBAction func like(_ sender: AnyObject)
    {
        posClickCount()
    }
    
    func minClickCount() {
        dislikeButtonCount = dislikeButtonCount + 1.0
        dislikeString = "Dislikes:" + dislikeButtonCount.description
        print(dislikeString)
    }
    
    func posClickCount() {
        likeButtonCount = likeButtonCount + 1.0
        likeString = "Likes:" + likeButtonCount.description
        print(likeString)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        do{
            let audioPath = Bundle.main.path(forResource: "oye_mi_amor", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL (fileURLWithPath: audioPath!) as URL)
        }
        catch{
            //ERROR
        }
    }
}

class EqualizerViewController: UIViewController {
    
    //creating the view controller for the equalizer settings
    var audioEngine: AVAudioEngine = AVAudioEngine()
    var equalizer: AVAudioUnitEQ!
    var audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    var audioFile: AVAudioFile!
    var filterType: AVAudioUnitEQFilterType = .parametric
    var bypass: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        equalizer = AVAudioUnitEQ(numberOfBands: 10)
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(equalizer)
        let bands = equalizer.bands
        let freqs = [32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        audioEngine.connect(audioPlayerNode, to: equalizer, format: nil)
        audioEngine.connect(equalizer, to: audioEngine.outputNode, format: nil)
        for i in 0...(bands.count - 1) {
            bands[i].frequency  = Float(freqs[i])
            bands[i].bypass     = false
            bands[i].filterType = .parametric
    }

            bands[0].gain = 10.0
            bands[0].filterType = .lowShelf
            bands[1].gain = 10.0
            bands[1].filterType = .lowShelf
            bands[2].gain = 10.0
            bands[2].filterType = .lowShelf
            bands[3].gain = 10.0
            bands[3].filterType = .lowShelf
            bands[4].gain = 10.0
            bands[4].filterType = .lowShelf
            bands[5].gain = 0.0
            bands[5].filterType = .highShelf
            bands[6].gain = 00.0
            bands[6].filterType = .highShelf
            bands[7].gain = 0.0
            bands[7].filterType = .highShelf
            bands[8].gain = 0.0
            bands[8].filterType = .highShelf
            bands[9].gain = 0.0
            bands[9].filterType = .highShelf

            do {
                if let filepath = Bundle.main.path(forResource: "oye_mi_amor", ofType: "mp3") {
                    let filepathURL = NSURL.fileURL(withPath: filepath)
                    audioFile = try AVAudioFile(forReading: filepathURL)
                    audioEngine.prepare()
                    try audioEngine.start()
                    audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
                    audioPlayerNode.play()
                }
            } catch _ {}
        }
}


class BluetoothViewController: UIViewController, CBPeripheralDelegate {

    //variables
    var centralManager: CBCentralManager!
    private var bluefruitPeripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    //scanning for bluetooths
    func startScanning() -> Void {
      //scanning
      centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
    }
    
    //discover bluetooths
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {

        bluefruitPeripheral = peripheral
        bluefruitPeripheral.delegate = self

        print("Peripheral Discovered: \(peripheral)")
        print("Peripheral name: \(String(describing: peripheral.name))")
        print ("Advertisement Data : \(advertisementData)")
            
        //scanning
        centralManager?.stopScan()
        //connection
        centralManager?.connect(bluefruitPeripheral!, options: nil)
       }
    
    //connecting to peripherals
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
       bluefruitPeripheral.discoverServices([CBUUIDs.BLEService_UUID])
    }
    
    //discovering services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            print("*******************************************************")

            if ((error) != nil) {
                print("Error discovering services: \(error!.localizedDescription)")
                return
            }
            guard let services = peripheral.services else {
                return
            }
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            print("Discovered Services: \(services)")
        }

}

//extension of the class
extension BluetoothViewController: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
     switch central.state {
          case .poweredOff:
              print("Is Powered Off.")
          case .poweredOn:
              print("Is Powered On.")
              startScanning()
          case .unsupported:
              print("Is Unsupported.")
          case .unauthorized:
          print("Is Unauthorized.")
          case .unknown:
              print("Unknown")
          case .resetting:
              print("Resetting")
          @unknown default:
            print("Error")
          }
  }

}

class GeneralSettingsViewController: UIViewController {
    
    //creating the view controller for the general settings

   /* @IBAction func NoficationSettingsButton(){
        present(NotificationSettingsViewController(), animated: true)
    }
    
    @IBAction func FAQButton(){
        present(FAQViewController(), animated: true)
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}


class NotificationSettingsViewController: UIViewController {
    
    @IBOutlet weak var mcBatterySwitch: UISwitch!
   
    
    @IBOutlet weak var AlertSwitch: UISwitch!
    @IBAction func Alerts(_ sender: Any) {
        //permission
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }
        
        // notification content
        let content = UNMutableNotificationContent()
        content.title = "Alerts On"
        content.body = "Alert will appear if needed"
        
        // notificatio trigger
        let date = Date().addingTimeInterval(5) //seconds after notification is on
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // request
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // register request
        center.add(request) { (error) in}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up notification settings

    }
}


class GraphicalViewController: UIViewController {
    
    //creating the view controller for the bluetooth settings
   //  @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

class SpeakerViewController: UIViewController {
    
    //creating the view controller for the bluetooth settings
   //  @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

class SignInViewController: UIViewController {
    
    //creating the view controller for the Sign In settings

    @IBOutlet weak var UsernameTextField: UITextField!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // disposes of resources that can be recreated
    }
    @IBAction func LogingButtonTapped(_ sender: Any) {
       
        //Will validate all fields to make sure they are not empty
        if (UsernameTextField.text?.isEmpty)! || (PasswordTextField.text?.isEmpty)!
        {
            //Display Alert Message and return
            displayMessage(userMessage: "All fields are required.")
            return
        }
    }
     
    @IBAction func SignUpButtonTapped(_ sender: Any) {
    }
    
    //function that displays the message when an error occurs
    func displayMessage(userMessage:String) -> Void
    {
        DispatchQueue.main.async
        {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction!)in
                //Code in this block will trigger when OK button is tapped
                DispatchQueue.main.async
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            }
        }
}

class CreateAccountController: UIViewController {
    
    //creating the view controller for the bluetooth settings
   
    @IBOutlet weak var CreateUserTextField: UITextField!
    
    @IBOutlet weak var CreatePassTextField: UITextField!
    
    @IBOutlet weak var CreateRePassTextField: UITextField!
    
    @IBAction func CreateAccountButtonTapped(_ sender: Any) {
        
        //Will validate all fields to make sure they are not empty
        if (CreateUserTextField.text?.isEmpty)! || (CreatePassTextField.text?.isEmpty)!
        {
            //Display Alert Message and return
            displayMessage(userMessage: "All fields are required.")
            return
        }
        
        //Will validate passwords
        if ((CreatePassTextField.text?.elementsEqual(CreateRePassTextField.text!))! != true)
        {
            //Display Alert Message and return
            displayMessage(userMessage: "Please make sure that passwords match.")
            return
        }
    }
    //an UIActivity Indication can be added to the screen if I want the user to see that data is being retreived - look at video 10/15 on youtube minute 6
    
    //JSON request
  
    //function that displays the message when an error occurs
    func displayMessage(userMessage:String) -> Void
    {
        DispatchQueue.main.async
        {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction!)in
                //Code in this block will trigger when OK button is tapped
                DispatchQueue.main.async
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            }
        }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
}
