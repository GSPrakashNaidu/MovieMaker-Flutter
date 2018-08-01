import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
        let batteryChannel = FlutterMethodChannel.init(name: "moviemaker.devunion.com/movie_maker_channel",
                                                       binaryMessenger: controller);
        batteryChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if ("getBatteryLevel" == call.method) {
                self.receiveBatteryLevel(result: result);
            } else if("getVideoThumbnail" == call.method) {
                guard let arguments = call.arguments as? [String:Any?] else {
                    print("Bipin - Argument failed")
                    return
                }
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
}


extension String : Error {
    
}
