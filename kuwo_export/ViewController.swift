//
//  ViewController.swift
//  kuwo_export
//
//  Created by xu on 2022/10/10.
//

import Cocoa
import FMDB
import AVKit

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        
    }
    /* if an error occurs while decoding it will be reported to the delegate. */
    @available(macOS 10.7, *)
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        
    }
}


class ViewController: NSViewController {
    @IBOutlet weak var textFieldDbPath: NSTextField!
    @IBOutlet weak var textFieldMusicPath: NSTextField!

    var player: AVPlayer!
    var audioPlayer: AVAudioPlayer!
    @objc func PlayerItemFailedToPlayToEndTime(noti: Notification) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        {
//          "songName": "就哦我机房间哦滴睡觉",
//          "Songauthor": "张三丰就几江苏佛山",
//          "currentTime": "189999",
//          "duration": "189999"
//        }
//        let x = "她从来不听我写的歌，于是我写了一首好蹦的歌…动力火车…3000…24900"
//        let xx = x.data(using: .utf8)
//        print(xx)
//
//        var bytes = Array(repeating: UInt8(0), count: 200)
//        let xBytes = [UInt8](xx!)
//        for i in 0..<xBytes.count {
//            bytes[i] = xBytes[i]
//        }
//
//        let newd = Data(bytes)
//        print(String(data: newd, encoding: .utf8))
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerItemFailedToPlayToEndTime), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerItemFailedToPlayToEndTime), name: Notification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerItemFailedToPlayToEndTime), name: Notification.Name.AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerItemFailedToPlayToEndTime), name: Notification.Name.AVPlayerItemNewAccessLogEntry, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerItemFailedToPlayToEndTime), name: Notification.Name.AVPlayerItemNewErrorLogEntry, object: nil)

//        var mp = Bundle.main.path(forResource: "319", ofType: "kwm")
//        mp = Bundle.main.path(forResource: "江湖笑-刘亦菲", ofType: "mp3")
//        self.player = AVPlayer(url: URL(fileURLWithPath: mp!))
//        self.player.play()
    
        // Do any additional setup after loading the view.
    }
    
    func test() {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("test.sqlite")

        let database = FMDatabase(url: fileURL)

        guard database.open() else {
            print("Unable to open database")
            return
        }

        do {
            try database.executeUpdate("create table test(x text, y text, z text)", values: nil)
            try database.executeUpdate("insert into test (x, y, z) values (?, ?, ?)", values: ["a", "b", "c"])
            try database.executeUpdate("insert into test (x, y, z) values (?, ?, ?)", values: ["e", "f", "g"])

            let rs = try database.executeQuery("select x, y, z from test", values: nil)
            while rs.next() {
                if let x = rs.string(forColumn: "x"), let y = rs.string(forColumn: "y"), let z = rs.string(forColumn: "z") {
                    print("x = \(x); y = \(y); z = \(z)")
                }
            }
        } catch {
            print("failed: \(error.localizedDescription)")
        }

        database.close()
    }
    
    @IBAction func actionParse(_ sender: Any) {
        
//        let p = Bundle.main.path(forResource: "cloud", ofType: "db")
        let fileURL = URL(fileURLWithPath: self.textFieldDbPath.stringValue)

        let database = FMDatabase(url: fileURL)

        guard database.open() else {
            print("Unable to open database")
            return
        }

        do {
            let rs = try database.executeQuery("SELECT title,artist,file FROM musicResource", values: nil)
            var errorFilesPath = Array<String>()
            while rs.next() {
                if var title = rs.string(forColumn: "title"), var artist = rs.string(forColumn: "artist"), let file = rs.string(forColumn: "file") {
                    
                    let p = "\(self.textFieldMusicPath.stringValue)/\(file)"
                    title = title.replacingOccurrences(of: "/", with: "·")
                    artist = artist.replacingOccurrences(of: "/", with: "·")
                    let new_p = "\(self.textFieldMusicPath.stringValue)/\(title)-\(artist).mp3"

                    if FileManager.default.fileExists(atPath: p) {
                        print(p, new_p)
                        do {
                            try FileManager.default.moveItem(atPath: p, toPath: new_p)
                        }catch {
                            print("moved: error⚠️: \(error), CCC:\(new_p)")
                            //重复的内容删掉
                            try FileManager.default.removeItem(atPath: p)
                            errorFilesPath.append(new_p)
                        }
                    }
                    
                    if FileManager.default.fileExists(atPath: new_p) {
                        do{
                            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: new_p))
                        }catch {
                            print("初始化音频失败:\(error), \(new_p)")
                            //不能播放的删掉
                            try FileManager.default.removeItem(atPath: new_p)
                        }
                    }
                    print("title = \(title); artist = \(artist); file = \(file)")
                }
            }
            
            NSWorkspace.shared.activateFileViewerSelecting(errorFilesPath.map({ s in
                return URL(fileURLWithPath: s)
            }))
        } catch {
            print("failed: \(error.localizedDescription)")
        }

        database.close()
    }
    
    @IBAction func actionDbPath(_ sender: Any) {
        self.showPanelWithTitle(title: "选择酷我数据库目录 cloud.db", canChooseFiles: true, canChooseDirectories: false, allowsMultipleSelection: false, allowedFileTypes: ["db"]) { flag, openPanel, path in
            
            if flag {
                self.textFieldDbPath.stringValue = path ?? ""
            }
        }
    }

    @IBAction func actionMusicPath(_ sender: Any) {
        self.showPanelWithTitle(title: "选择音乐目录", canChooseFiles: false, canChooseDirectories: true, allowsMultipleSelection: false, allowedFileTypes: []) { flag, openPanel, path in
            if flag {
                self.textFieldMusicPath.stringValue = path ?? ""
            }
        }
    }

    func showPanelWithTitle(title: String, canChooseFiles: Bool, canChooseDirectories: Bool, allowsMultipleSelection: Bool, allowedFileTypes: [String], complete: (_ flag: Bool, _ openPanel: NSOpenPanel, _ path: String?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.title = title
        openPanel.canChooseFiles = canChooseFiles
        openPanel.canChooseDirectories = canChooseDirectories
        openPanel.allowsMultipleSelection = allowsMultipleSelection
        
        if #available(macOS 11,*) {
            openPanel.allowedContentTypes = allowedFileTypes.map({ v in
                return UTType(filenameExtension: v)!
            })
        }else {
            openPanel.allowedFileTypes = allowedFileTypes
        }
        if openPanel.runModal() == .OK {
            let path = openPanel.url?.path
            
            complete(true, openPanel, path)
        }else {
            complete(false, openPanel, nil)
        }
    }


    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

