//
//  MusicPlayerViewController.swift
//  RunningRhythm
//
//  Created by Pulicken, Christopher on 10/31/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import HealthKit
import AudioToolbox
import AVFoundation
import CoreMotion
import Alamofire
import Spartan

public var workoutState = false

class MusicPlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    var username: String?
    var track: SPTPlaylistTrack?
    var playlist: SPTPartialPlaylist?
    var trackList = [SPTPlaylistTrack]()
    var trackIds = [String]()
    var alertController: UIAlertController?
    @IBOutlet weak var startStop: UIButton!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var artistTitle: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playbackSourceTitle: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    
    @IBOutlet weak var pauseImage: UIImageView!
    
    
    var isChangingProgress: Bool = false
    
    let motionManager = CMMotionManager()
    let activityManager = CMMotionActivityManager()
    let logItem = CMLogItem()
    var accelerationList = [Double]()
    
    var avgAcceleration = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if workoutState == false {
            startStop.setTitle("Start Workout", for: UIControlState(rawValue: 0))
        }
        else if workoutState == true {
            startStop.setTitle("End Workout", for: UIControlState(rawValue: 0))
        }
        self.view.backgroundColor = SettingsViewController().UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        self.trackTitle.text = "Nothing Playing"
        self.artistTitle.text = ""
        artistTitle.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        playbackSourceTitle.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        trackTitle.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        workoutLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        
        SPTAudioStreamingController.sharedInstance().delegate = self
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        SPTAudioStreamingController.sharedInstance().diskCache = SPTDiskCache() /* capacity: 1024 * 1024 * 64 */
        self.updateUI()
        for track in self.trackList {
            let trackId = track.identifier
            if trackId != self.track?.identifier{
                trackIds.append(trackId!)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.login()
        print("session: \(SPTAuth.defaultInstance().session.accessToken!)")
        Spartan.loggingEnabled = false
        motionManager.startAccelerometerUpdates()
        let date = Date().addingTimeInterval(5)
        let timer = Timer.init(fireAt: date, interval: 30, target: self, selector: #selector(MusicPlayerViewController.getAcceleration), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    func getPlaylistJSON(completion: @escaping ([[String: Any]]?) -> ()) {
        var json: [[String: Any]]?
        if SPTAuth.defaultInstance().session.accessToken == nil {
            self.login()
        }
        Spartan.authorizationToken = SPTAuth.defaultInstance().session.accessToken!
        Spartan.getAudioFeatures(trackIds: self.trackIds, success: { (AudioFeaturesObject) in
            json = AudioFeaturesObject.toJSON()
            completion(json)
        }, failure: {(error) in
            print(error)
        })
    }
    
    
    func findNextSong() {
        var tracksEnergy = [String: Float]()
        getPlaylistJSON(completion: {(jsonObject) -> () in
            for track in jsonObject! {
                let trackURL = track["uri"] as? String
                let energy = track["energy"] as? Double
                let dance = track["danceability"] as? Double
                let rrCoefficient = (energy! * 80 + dance! * 20)/100
                tracksEnergy[trackURL!] = Float(rrCoefficient)
            }
            var currentActivity = 0.0
            
            if self.avgAcceleration >= 0.0 {
                currentActivity = 0.3
            }
            if self.avgAcceleration >= 0.05 {
                currentActivity = 0.4
            }
            if self.avgAcceleration >= 0.1 {
                currentActivity = 0.5
            }
            if self.avgAcceleration >= 0.15 {
                currentActivity = 0.55
            }
            if self.avgAcceleration >= 0.2 {
                currentActivity = 0.6
            }
            if self.avgAcceleration >= 0.25 {
                currentActivity = 0.65
            }
            if self.avgAcceleration >= 0.3 {
                currentActivity = 0.7
            }
            if self.avgAcceleration >= 0.35 {
                currentActivity = 0.75
            }
            if self.avgAcceleration >= 0.4 {
                currentActivity = 0.8
            }
            if self.avgAcceleration >= 0.45 {
                currentActivity = 0.85
            }
            if self.avgAcceleration >= 0.5 {
                currentActivity = 0.9
            }
            
            var n = 0
            var nearestElement: Float!
            var energyArray = Array(tracksEnergy.values).sorted()
            while energyArray[n] <= Float(currentActivity) {
                n += 1
            }
            nearestElement = Array(tracksEnergy.values)[n]
            var queuedSpotifyURL = String()
            for (track, energy) in tracksEnergy {
                if (energy == nearestElement) {
                    queuedSpotifyURL = track
                }
            }
            let startIndex = queuedSpotifyURL.index(queuedSpotifyURL.startIndex, offsetBy: 14)
            let trackID = queuedSpotifyURL.substring(from: startIndex)
            var i = 0
            for track in self.trackIds {
                if (track == trackID) {
                    self.trackIds.remove(at: i)
                } else {
                    i += 1
                }
            }
            
            SPTAudioStreamingController.sharedInstance().queueSpotifyURI(queuedSpotifyURL, callback: { error in
                if error != nil {
                    print("*** failed to play: \(error)")
                    return
                }
            })
        })
    }
    
    func getAcceleration() {
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {( acclData : CMAccelerometerData?, error: Error!) in
            // calculate magnitude of the 3 dimensional acceleration vector and normalize to m/s
            let norm = sqrt(pow((acclData?.acceleration.x)!, 2.0) + pow((acclData?.acceleration.y)!, 2.0) + pow((acclData?.acceleration.z)!, 2.0))
            let absAcceleration = abs((norm - 1)/(9.81))
            self.accelerationList.append(absAcceleration)
            var accelerationSum = 0.0
            for acceleration in self.accelerationList {
                accelerationSum += acceleration
            }
            self.avgAcceleration = accelerationSum/Double(self.accelerationList.count)
            print(self.avgAcceleration)
            if self.avgAcceleration <= 0.1 {
                self.workoutLabel.text = "Workout Level: Very Low"
            } else if self.avgAcceleration <= 0.2 {
                self.workoutLabel.text = "Workout Level: Low"
            } else if self.avgAcceleration <= 0.3 {
                self.workoutLabel.text = "Workout Level: Medium"
            } else if self.avgAcceleration <= 0.4 {
                self.workoutLabel.text = "Workout Level: High"
            } else if self.avgAcceleration > 0.5 {
                self.workoutLabel.text = "Workout Level: Very High"
            }
            
            if (error != nil) {
                print("\(error)")
            }})
    }
    
    @IBAction func switchPic(_ sender: Any) {
        if SPTAudioStreamingController.sharedInstance().playbackState.isPlaying {
            pauseImage.image = UIImage(named:"play_button")
        }
        else {
            pauseImage.image = UIImage(named:"Pause")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rewind(_ sender: Any) {
        SPTAudioStreamingController.sharedInstance().skipPrevious(nil)
    }
    
    @IBAction func playPause(_ sender: Any) {
        SPTAudioStreamingController.sharedInstance().setIsPlaying(!SPTAudioStreamingController.sharedInstance().playbackState.isPlaying, callback: nil)
    }
    
    @IBAction func fastForward(_ sender: Any) {
        SPTAudioStreamingController.sharedInstance().skipNext(nil)
    }
    
    @IBAction func seekValueChanged(_ sender: UISlider) {
        self.isChangingProgress = false
        let dest = SPTAudioStreamingController.sharedInstance().metadata!.currentTrack!.duration * Double(self.progressSlider.value)
        SPTAudioStreamingController.sharedInstance().seek(to: dest, callback: nil)
    }
    
    @IBAction func progressTouchDown(_ sender: UISlider) {
        self.isChangingProgress = true
    }
    
    func updateUI() {
        let auth = SPTAuth.defaultInstance()
        if SPTAudioStreamingController.sharedInstance().metadata == nil || SPTAudioStreamingController.sharedInstance().metadata.currentTrack == nil {
            self.coverView.image = nil
            return
        }
        self.nextButton.isEnabled = SPTAudioStreamingController.sharedInstance().metadata.nextTrack != nil
        self.prevButton.isEnabled = SPTAudioStreamingController.sharedInstance().metadata.prevTrack != nil
        self.trackTitle.text = SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.name
        self.artistTitle.text = SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.artistName
        self.playbackSourceTitle.text = playlist?.name
        
        let imageURL = URL.init(string: (SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.albumCoverArtURL)!)
        if imageURL == nil {
            print("Album \(SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.albumName) doesn't have any images!")
            self.coverView.image = nil
            return
        }
        // Pop over to a background queue to load the image over the network.
        
        DispatchQueue.global().async {
            do {
                let imageData = try Data(contentsOf: imageURL!, options: [])
                let image = UIImage(data: imageData)
                // …and back to the main queue to display the image.
                DispatchQueue.main.async {
                    self.coverView.image = image
                    if image == nil {
                        print("Couldn't load cover image with error")
                        return
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func login() {
        if SPTAudioStreamingController.sharedInstance().loggedIn {
            SPTAudioStreamingController.sharedInstance().playSpotifyURI(track?.playableUri.absoluteString, startingWith: 0, startingWithPosition: 0) { error in
                if error != nil {
                    print("*** failed to play: \(error)")
                    return
                }
            }
            self.updateUI()
            return
        }
        do {
            try SPTAudioStreamingController.sharedInstance().start(withClientId: SPTAuth.defaultInstance().clientID, audioController: nil, allowCaching: true)
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: SPTAuth.defaultInstance().session.accessToken!)
        } catch let error {
            let alert = UIAlertController(title: "Error init", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: { _ in })
            self.closeSession()
        }
    }
    
    func closeSession() {
        do {
            try SPTAudioStreamingController.sharedInstance().stop()
            SPTAuth.defaultInstance().session = nil
//            _ = self.navigationController!.popViewController(animated: true)
        } catch let error {
            let alert = UIAlertController(title: "Error deinit", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: { _ in })
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        let alert = UIAlertController(title: "Message from Spotify", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: { _ in })
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying {
            self.activateAudioSession()
        } else {
            self.deactivateAudioSession()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        self.updateUI()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceive event: SpPlaybackEvent, withName name: String) {
        print("didReceivePlaybackEvent: \(event) \(name)")
        print("isPlaying=\(SPTAudioStreamingController.sharedInstance().playbackState.isPlaying) isRepeating=\(SPTAudioStreamingController.sharedInstance().playbackState.isRepeating) isShuffling=\(SPTAudioStreamingController.sharedInstance().playbackState.isShuffling) isActiveDevice=\(SPTAudioStreamingController.sharedInstance().playbackState.isActiveDevice) positionMs=\(SPTAudioStreamingController.sharedInstance().playbackState.position)")
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        self.closeSession()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        print("didReceiveError: \(error!.localizedDescription)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        if self.isChangingProgress {
            return
        }
        if SPTAudioStreamingController.sharedInstance().metadata.currentTrack == nil {
            return 
        }
        let positionDouble = Double(position)
        let durationDouble = Double(SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.duration)
        self.progressSlider.value = Float(positionDouble / durationDouble)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStartPlayingTrack trackUri: String) {
        print("Starting \(trackUri)")
        print("Source \(SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.playbackSourceUri)")
        // If context is a single track and the uri of the actual track being played is different
        // than we can assume that relink has happended.
        let isRelinked = SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.playbackSourceUri.contains("spotify:track") && !(SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.playbackSourceUri == trackUri)
        print("Relinked \(isRelinked)")
        if self.trackIds.count != 0 {
            findNextSong()
        } else {
            self.alertController = UIAlertController(title: "End of Playlist", message: "Go back and choose another playlist.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            self.alertController!.addAction(OKAction)
            self.present(self.alertController!, animated: true, completion:nil)
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStopPlayingTrack trackUri: String) {
        print("Finishing: \(trackUri)")
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController) {
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(track?.playableUri.absoluteString, startingWith: 0, startingWithPosition: 0) { error in
            if error != nil {
                print("*** failed to play: \(error)")
                return
            }
        }
        self.updateUI()
    }
    
    func activateAudioSession() {
        do {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
        }
    }
    
    func deactivateAudioSession() {
        do {
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    @IBAction func startStop(_ sender: UIButton) {
        if workoutState == false {
            workoutState = true
            startStop.setTitle("End Workout", for: UIControlState(rawValue: 0))
            TimerModel.sharedTimer.startTimer(withInterval: 1)
        }
        else {
            workoutState = false
            startStop.setTitle("Start Workout", for: UIControlState(rawValue: 0))
            TimerModel.sharedTimer.pauseTimer()
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller
        if segue.identifier == "goBackTracks" {
            let destination = segue.destination as? TrackListTableViewController;
            destination?.playlist = playlist
        }
    }
    
}

