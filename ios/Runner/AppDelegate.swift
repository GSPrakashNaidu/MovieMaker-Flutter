import UIKit
import Flutter
import AVFoundation
import AVKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;

        let flutterMethodChannel = FlutterMethodChannel.init(name: "moviemaker.devunion.com/movie_maker_channel", binaryMessenger: controller);
        flutterMethodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard let arguments = call.arguments as? [String:Any?] else {
                print("Bipin - Argument failed")
                return
            }
            if ("getBatteryLevel" == call.method) {
                self.receiveBatteryLevel(result: result);
            } else if("getVideoThumbnail" == call.method) {
                guard let videoPath = arguments["videoPath"] as? String else {
                    print("Bipin - VideoPath failed")
                    return
                }
                print("Video path: \(videoPath)")
                do {
                    let data = try self.getVideoThumbnail(videoPath: videoPath)
                    //FIXME: Showing warning when fetching video thumbnail
                    if let data = data {
                        print("Bipin - data: \(data)")
                        result(FlutterStandardTypedData(bytes: data))
                    } else {
                        result(FlutterError.init(code: "UNAVAILABLE",
                                                 message: "Video thumbnail not found",
                                                 details: nil))
                    }
                } catch {
                    result(FlutterError.init(code: "UNAVAILABLE",
                                             message: "Video thumbnail not found",
                                             details: nil))
                }
            } else if("createMovie" == call.method) {
                guard let videoPaths = arguments["videoPaths"] as? [String] else {
                    print("Bipin - Video paths reading failed.")
                    return
                }
                
                do {
                    print("Bipin - Video Paths: \(videoPaths)")
                    let moviePath = try self.createMovie(videoPaths: videoPaths)
                    if let moviePath = moviePath {
                        print("Bipin - movie path: \(String(describing: moviePath))")
                        result(moviePath)
                    } else {
                        result(FlutterError(code: "UNAVAILABLE", message: "Movie creation failed", details: nil))
                    }
                } catch {
                    result(FlutterError(code: "UNAVAILABLE", message: "Movie creation failed", details: nil))
                }
            } else if("startMovie" == call.method) {
                guard let moviePath = arguments["moviePath"] as? String else {
                    print("Bipin - movie path reading failed.")
                    return
                }
                
                print("Bipin - Movie Paths: \(moviePath)")
                let started = self.startMovie(moviePath: moviePath)
                if(started) {
                    print("Bipin - Movie started!")
                    result(started)
                } else {
                    result(FlutterError(code: "UNAVAILABLE", message: "Start Movie failed", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented);
            }
        });
        
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    private func receiveBatteryLevel(result: FlutterResult) {
        let device = UIDevice.current;
        device.isBatteryMonitoringEnabled = true;
        if (device.batteryState == UIDeviceBatteryState.unknown) {
            result(FlutterError.init(code: "UNAVAILABLE",
                                     message: "Battery info unavailable",
                                     details: nil));
        } else {
            result(Int(device.batteryLevel * 100));
        }
    }
    
    private func getVideoThumbnail(videoPath: String)throws -> Data?  {
        let asset = AVURLAsset(url: URL(fileURLWithPath: videoPath))
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
        let uiImage = UIImage(cgImage: cgImage)
        return UIImageJPEGRepresentation(uiImage, 1.0)
    }
    
    
    private func createMovie(videoPaths: [String]) throws -> String? {
        
        guard videoPaths.count >= 2 else {
            print("There is no enough items to create movie")
            return nil
        }
        
        var arrayVideos = [AVAsset]()
        for videoPath in videoPaths {
            let assets = AVURLAsset(url: URL(fileURLWithPath: videoPath))
            arrayVideos.append(assets)
        }
        
        let mainComposition = AVMutableComposition()
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)
        
        let soundtrackTrack = mainComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var insertTime = kCMTimeZero
        
        for videoAsset in arrayVideos {
            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
            try soundtrackTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: insertTime)
            
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        
        
        let outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "MM-iOS-Movie.mp4")
        
//        let fileManager = FileManager()
//        fileManager.removeItemIfExisted(outputFileURL)
        let source = DispatchSemaphore(value: 0)
        
        let exporter = AVAssetExportSession(asset: mainComposition, presetName: AVAssetExportPresetHighestQuality)
        
        exporter?.outputURL = outputFileURL
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        
        exporter?.exportAsynchronously {
            source.signal()
        }
        
        source.wait()
        return exporter?.outputURL?.path
    }
    
    private func startMovie(moviePath: String) -> Bool {
        let url = URL(fileURLWithPath: moviePath)
        let moviePlayerVC = AVPlayerViewController()
        let avPlayer = AVPlayer(url: url)
        moviePlayerVC.player = avPlayer
        self.window.rootViewController?.present(moviePlayerVC, animated: true, completion: nil)
        return true
    }
    
}


extension String : Error {
    
}
