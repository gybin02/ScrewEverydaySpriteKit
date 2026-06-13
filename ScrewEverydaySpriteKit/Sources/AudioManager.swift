import AVFoundation
import UIKit

final class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    @Published var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "screw.music.enabled")
            if isMusicEnabled {
                playBGM()
            } else {
                pauseBGM()
            }
        }
    }
    
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "screw.sound.enabled")
        }
    }
    
    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    
    private override init() {
        // 默认开启
        if UserDefaults.standard.object(forKey: "screw.music.enabled") == nil {
            self.isMusicEnabled = true
        } else {
            self.isMusicEnabled = UserDefaults.standard.bool(forKey: "screw.music.enabled")
        }
        
        if UserDefaults.standard.object(forKey: "screw.sound.enabled") == nil {
            self.isSoundEnabled = true
        } else {
            self.isSoundEnabled = UserDefaults.standard.bool(forKey: "screw.sound.enabled")
        }
        
        super.init()
        setupAudioSession()
        preparePlayers()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("音效 Session 初始化失败: \(error)")
        }
    }
    
    private func preparePlayers() {
        // 预加载 BGM
        if let bgmURL = Bundle.main.url(forResource: "bgm", withExtension: "mp3") {
            do {
                bgmPlayer = try AVAudioPlayer(contentsOf: bgmURL)
                bgmPlayer?.numberOfLoops = -1 // 无限循环
                bgmPlayer?.volume = 0.4
                bgmPlayer?.prepareToPlay()
            } catch {
                print("加载 BGM 失败: \(error)")
            }
        }
    }
    
    // 播放背景乐
    func playBGM() {
        guard isMusicEnabled else { return }
        bgmPlayer?.play()
    }
    
    // 暂停背景乐
    func pauseBGM() {
        bgmPlayer?.pause()
    }
    
    // 播放音效
    func playSFX(named name: String, withExtension ext: String = "wav") {
        guard isSoundEnabled else { return }
        
        let playerKey = "\(name).\(ext)"
        if let player = sfxPlayers[playerKey] {
            player.currentTime = 0
            player.play()
            return
        }
        
        guard let sfxURL = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("找不到音效文件: \(name).\(ext)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: sfxURL)
            player.volume = 0.8
            player.prepareToPlay()
            sfxPlayers[playerKey] = player
            player.play()
        } catch {
            print("播放音效 \(name) 失败: \(error)")
        }
    }
    
    // 触发iOS原生物理触觉反馈
    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isSoundEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
