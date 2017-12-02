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
    let audioSession = AVAudioSession.sharedInstance()
    
    let motionManager = CMMotionManager()
    let activityManager = CMMotionActivityManager()
    let logItem = CMLogItem()
    
    var avgAcceleration = 0.0
//    let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: Selector(("getAcceleration")), userInfo: nil, repeats: true)
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.login()
        print("session: \(SPTAuth.defaultInstance().session.accessToken!)")
//        findNextSong()
    }
    
    func findNextSong() {
        getAcceleration()
        var tracksEnergy = [String: Float]()
        for track in trackList {
            let trackId = track.identifier
            Spartan.getAudioFeatures(trackId: trackId!, success: { (AudioFeaturesObject) in
                let energy = AudioFeaturesObject.energy
                let dance = AudioFeaturesObject.danceability
                let rrCoefficient = (energy! * 80 + dance! * 20)/100
                tracksEnergy[track.playableUri.absoluteString] = Float(rrCoefficient)
            }, failure: {(error) in
                print(error)
            })
        }
        var currentActivity = 0.0
        
        if avgAcceleration <= 1 {
            currentActivity = 0.1
        }
        if avgAcceleration <= 2 {
            currentActivity = 0.3
        }
        if avgAcceleration <= 3 {
            currentActivity = 0.4
        }
        if avgAcceleration <= 4 {
            currentActivity = 0.5
        }
        if avgAcceleration <= 5 {
            currentActivity = 0.6
        }
        if avgAcceleration <= 6 {
            currentActivity = 0.7
        }
        if avgAcceleration <= 7 {
            currentActivity = 0.8
        }
        if avgAcceleration > 7 {
            currentActivity = 0.9
        }
        
        var n = 0
        var nearestElement: Float!
        print(tracksEnergy)
        while Array(tracksEnergy.values)[n] <= Float(currentActivity) {
            n += 1
        }
        nearestElement = Array(tracksEnergy.values)[n]
        var queuedSpotifyURL = String()
        for (track, energy) in tracksEnergy
        {
            if (energy == nearestElement)
            {
                queuedSpotifyURL = track
            }
        }
        
        
        SPTAudioStreamingController.sharedInstance().queueSpotifyURI(queuedSpotifyURL, callback: { error in
            if error != nil {
                print("*** failed to play: \(error)")
                return
            }
        })
        print(queuedSpotifyURL)

        
    }
    
    func getAcceleration() {
        var accelerationList = [Double]()
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: {( acclData : CMAccelerometerData?, error: Error!) in
            let norm = sqrt(pow((acclData?.acceleration.x)!, 2.0) + pow((acclData?.acceleration.y)!, 2.0) + pow((acclData?.acceleration.z)!, 2.0))
            let absAcceleration = (norm - 1)/(9.81)
            accelerationList.append(absAcceleration)
            if (error != nil) {
                print("\(error)")
            }})
        var accelerationSum = 0.0
        for acceleration in accelerationList {
            accelerationSum += acceleration
        }
        avgAcceleration = accelerationSum/Double(accelerationList.count)
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
//            for track in trackList {
//                print(track.name)
//                SPTAudioStreamingController.sharedInstance().queueSpotifyURI(track.playableUri.absoluteString, callback: { error in
//                    if error != nil {
//                        print("*** failed to play: \(error)")
//                        return
//                    }
//                })
//            }
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
        print("is playing = \(isPlaying)")
        if isPlaying {
            self.activateAudioSession()
        }
        else {
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
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        }
        catch let error {
            print(error.localizedDescription)
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

