//
//  ViewController.swift
//  DNB-Share.com
//
//  Created by M1 on 14/03/2021.
//

import Cocoa
import AVFoundation

var tableDataReady = [[String:String]]()
var playerItemContext = 0 //used to pass row to TimeControlStatus


class ViewController: NSViewController, ObservableObject {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet var dnbView: NSView! //our View
    @IBOutlet weak var nowPlayingLabel: NSTextField!
    @IBOutlet weak var playButtonOutlet: NSButton!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var bufferingView: NSView!
    
    private var totalTrackTime: Double = 0
    private var timeObserverToken: Any? //used to kill TimeObserver when seeking on slider.
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DispatchQueue.global(qos: .background).async {
            DataConnections().makeHTTPRequest(url: URL(string:  "https://dnbshare.com/feed/")!, httpCompletionHandler: { data, error in
                    if let data = data {
                    DataConnections().createPlayList(data: data, dataCompletionHandler: { returnedData in
                    // [[returnedData]] has now populated [[tableDataReady]] - were good to populate tableView
                    DispatchQueue.main.async { self.tableView.reloadData() }
                    })
                    }
                    })
        }
        
        

        
        DispatchQueue.main.async {
            self.startSpinner()
            //sets the colour for titlebar
            self.view.window?.titlebarAppearsTransparent = true
            self.view.window!.isMovableByWindowBackground = true
            self.view.window!.titleVisibility = NSWindow.TitleVisibility.hidden
            self.view.window!.backgroundColor = NSColor(cgColor: CGColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0))
            self.view.window!.standardWindowButton(.zoomButton)?.isHidden = true
              
           //set the background colour for NSView
            let color : CGColor = CGColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            self.view.layer?.backgroundColor = color    
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 40

    }
    
    
    @IBAction func playButton(_ sender: Any) {
        guard player != nil else { return }
        //0 = paused
        guard player.timeControlStatus.rawValue != 0 else {
            player.play()
            return
        }
        player.pause()

        
    }
    
    func startSpinner() {
        DispatchQueue.main.async {
            self.bufferingView.isHidden = false
            self.spinner.startAnimation(self)
        }
    }
    
    func stopSpinner() {
        DispatchQueue.main.async {
            self.bufferingView.isHidden = true
            self.spinner.stopAnimation(self)
        }
    }
    
    @IBAction func sliderAction(_ sender: Any) {
        
        guard player != nil else { return }
        /*
        This code is a mash up - ill explain -
        theres 2 senario's that we need to counter for:
         1: user clicks the slider bar not the slider knob either back or forth (clicks somewhere along the bar)
         2: user left clicks and drags slider knob.
         on mouse down we pause audio, rempve observer and seek to locstion when we release mouse (mouse-up) the seek to audio position
         is not always called. so we call it for both cases
         
         
         */

        if NSApplication.shared.currentEvent?.type == NSEvent.EventType.leftMouseDown {
                
                print("Mouse Down")
                player.pause()
                self.removePeriodicTimeObserver()
                player.seek(to: CMTime(seconds: Float64(self.slider.floatValue), preferredTimescale: 60000), toleranceBefore: .zero, toleranceAfter: .zero)
                
                } else if NSApplication.shared.currentEvent?.type == NSEvent.EventType.leftMouseUp {
                    
                        print("Mouise Up")
                        let myTime = CMTime(seconds: Float64(self.slider.floatValue), preferredTimescale: 60000)
                        player.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
                        self.addPeriodicTimeObserver()
                        player.play()
                        }
    }

    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "timeControlStatus" {

            let statusNumber = change?[.newKey] as? NSNumber
                // Switch over status value
                switch statusNumber {
                case 0:
                        print("paused")
                        DispatchQueue.main.async {
                        self.playButtonOutlet.image = NSImage(systemSymbolName: "play.circle.fill", accessibilityDescription: "Play")
                            }
                case 1:
                        print("waitingToPlayAtSpecifiedRate")
                        self.startSpinner()
                case 2:
                        print("playing")
                        DispatchQueue.main.async {
                        self.playButtonOutlet.image = NSImage(systemSymbolName: "pause.circle.fill", accessibilityDescription: "Pause")
                        self.nowPlayingLabel.stringValue = tableDataReady[playerItemContext]["MusicTitle"]!
                        self.stopSpinner()
                        }
                        self.addPeriodicTimeObserver()
                default:
                        fatalError()
                }
        }

    }


    
    func addPeriodicTimeObserver() {
        
        let interval = CMTime(seconds: 0.5,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Add time observer. Invoke closure on the main queue.
       
        self.timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
                [weak self] time in
                // update player slider UI
                self!.totalTrackTime = player.currentItem!.asset.duration.seconds
                self!.totalTrackTime = self!.totalTrackTime - time.seconds
                self?.slider.maxValue = player.currentItem!.asset.duration.seconds
                self!.timerLabel.stringValue = DataConnections().formatTimeString(self!.totalTrackTime)
                self!.slider.doubleValue = time.seconds
                }
    }
    
    
    func removePeriodicTimeObserver() {
        // If a time observer exists, remove it
        if let token = timeObserverToken {
                player.removeTimeObserver(token)
                self.timeObserverToken = nil
                }
    }
    

    
    
}


extension ViewController: NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int { return (tableDataReady.count) }
    
    
   
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
            
     //print("Row Selected: \(row)")

        DataConnections().makeHTTPRequest(url: URL(string: tableDataReady[row]["Link"]!)!, httpCompletionHandler: { data, error in
                                          
                if let data = data {
                    DataConnections().createHttpsToPlayAudio(data: data, url: URL(string: tableDataReady[row]["Link"]!)!, CreateHttpsToPlayAudioCompletionHandler: { url, error in
                        
                       
                       
                     
                        _ = Play(url: url!)
                        self.startSpinner()

                        player.play()
                        playerItemContext = row //this is used to pass the row to the observer in order to update nowPlayingLabel on UI
                        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: &playerItemContext)
                       
                        })
                }
            })

        return true
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
       
        self.stopSpinner()
        
        self.tableView.tableColumns.forEach { (column) in
            
            column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15)])

            // Optional: you can change title color also jsut by adding NSForegroundColorAttributeName
        }
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "MusicTitleColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "MusicTitleCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {
                return nil
            }
        
            cellView.textField?.font = NSFont.systemFont(ofSize: 14.0)
            cellView.textField?.stringValue = tableDataReady[row]["MusicTitle"]!
            return cellView
            
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "DurationColumn") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "DurationCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else {
                return nil
            }
            cellView.textField?.font = NSFont.systemFont(ofSize: 14.0)
            cellView.textField?.stringValue = tableDataReady[row]["Duration"]!
            return cellView
        }
        
        return nil
    }
    
}


