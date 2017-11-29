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

public var workoutState = false

class MusicPlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    var username: String?
    var track: SPTPlaylistTrack?
    var playlist: SPTPartialPlaylist?
    @IBOutlet weak var startStop: UIButton!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var artistTitle: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playbackSourceTitle: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    
    @IBOutlet weak var backBtnMusic: UIButton!
    
    var isChangingProgress: Bool = false
    let audioSession = AVAudioSession.sharedInstance()
    
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
        backBtnMusic.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: UIControlState(rawValue: 0))
        
        SPTAudioStreamingController.sharedInstance().delegate = self
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        SPTAudioStreamingController.sharedInstance().diskCache = SPTDiskCache() /* capacity: 1024 * 1024 * 64 */
        self.updateUI()
        print(track?.playableUri)
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
        self.playbackSourceTitle.text = SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.playbackSourceName
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.login()
        print("session: \(SPTAuth.defaultInstance().session.accessToken!)")
    }
    
    func login() {
        if SPTAudioStreamingController.sharedInstance().loggedIn { return }
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
        self.updateUI()
        let trackNum = track!.trackNumber as? UInt
        print(trackNum)
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(playlist?.playableUri.absoluteString, startingWith: trackNum!, startingWithPosition: 0) { error in
            if error != nil {
                print("*** failed to play: \(error)")
                return
            }
        }
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
    }
    
}

