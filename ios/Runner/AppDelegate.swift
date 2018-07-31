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
            let videoPath = call.arguments("videoPath");
            let bytes = getVideoThumbnail(videoPath)
            
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
    
    private func getVideoThumbnail(videoPath: String,result: FlutterResult) {
        
         do {
        var err: NSError? = nil
        let asset = AVURLAsset(URL: NSURL(fileURLWithPath: videoPath), options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        let cgImage = imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil, error: &err)
        // !! check the error before proceeding
        let uiImage = UIImage(CGImage: cgImage)
         }catch let error {
            
        }
        
    }
    
}
