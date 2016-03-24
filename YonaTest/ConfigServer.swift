
import Swifter

class ConfigServer: NSObject {
    
    //TODO: Don't foget to add your custom app url scheme to info.plist if you have one!
    
    private enum ConfigState: Int
    {
        case Stopped, Ready, InstalledConfig, BackToApp
    }
    
    internal let listeningPort: in_port_t! = 8080
    internal var configName: String! = "YonaVPNTest.mobileconfig"
    private var localServer: HttpServer!
    private var returnURL: String!
    private var configData: NSData!
    
    private var serverState: ConfigState = .Stopped
    private var startTime: NSDate!
    private var registeredForNotifications = false
    private var backgroundTask = UIBackgroundTaskInvalid
    
    deinit
    {
        unregisterFromNotifications()
    }
    
    init(configData: NSData, returnURL: String)
    {
        super.init()
        self.returnURL = returnURL
        self.configData = configData
        localServer = HttpServer()
        self.setupHandlers()
    }
    
    //MARK:- Control functions
    
    internal func start() -> Bool
    {
        let page = self.baseURL("start/")
        let url: NSURL = NSURL(string: page)!
        if UIApplication.sharedApplication().canOpenURL(url) {
            do {
                try localServer.start(listeningPort)
                startTime = NSDate()
                serverState = .Ready
                registerForNotifications()
                UIApplication.sharedApplication().openURL(url)
                return true
            } catch{
                self.stop()
            }
        }
        return false
    }
    
    internal func stop()
    {
        if serverState != .Stopped {
            serverState = .Stopped
            unregisterFromNotifications()
        }
    }
    
    //MARK:- Private functions
    
    private func setupHandlers()
    {
        localServer["/start"] = { request in
            if self.serverState == .Ready {
                let page = self.basePage("install/")
                return .OK(.Html(page))
            } else {
                return .NotFound
            }
        }
        localServer["/install"] = { request in
            switch self.serverState {
            case .Stopped:
                return .NotFound
            case .Ready:
                self.serverState = .InstalledConfig
                return HttpResponse.RAW(200, "OK", ["Content-Type": "application/x-apple-aspen-config"]) { (body: HttpResponseBodyWriter) in
                    body.write(Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(self.configData.bytes), count: self.configData.length)))
                }
            case .InstalledConfig:
                return .MovedPermanently(self.returnURL)
            case .BackToApp:
                let page = self.basePage(nil)
                return .OK(.Html(page))
            }
        }
    }
    
    private func baseURL(pathComponent: String?) -> String
    {
        var page = "http://localhost:\(listeningPort)"
        if let component = pathComponent {
            page += "/\(component)"
        }
        return page
    }
    
    private func basePage(pathComponent: String?) -> String
    {
        var page = "<!doctype html><html>" + "<head><meta charset='utf-8'><title>\(self.configName)</title></head>"
        if let component = pathComponent {
            let script = "function load() { window.location.href='\(self.baseURL(component))'; }window.setInterval(load, 600);"
            page += "<script>\(script)</script>"
        }
        page += "<body></body></html>"
        return page
    }
    
    private func returnedToApp() {
        if serverState != .Stopped {
            serverState = .BackToApp
            localServer.stop()
        }
        // Do whatever else you need to to
    }
    
    private func registerForNotifications() {
        if !registeredForNotifications {
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: #selector(ConfigServer.didEnterBackground(_:)), name: UIApplicationDidEnterBackgroundNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(ConfigServer.willEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
            registeredForNotifications = true
        }
    }
    
    private func unregisterFromNotifications() {
        if registeredForNotifications {
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
            notificationCenter.removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
            registeredForNotifications = false
        }
    }
    
    internal func didEnterBackground(notification: NSNotification) {
        if serverState != .Stopped {
            startBackgroundTask()
        }
    }
    
    internal func willEnterForeground(notification: NSNotification) {
        if backgroundTask != UIBackgroundTaskInvalid {
            stopBackgroundTask()
            returnedToApp()
        }
    }
    
    private func startBackgroundTask() {
        let application = UIApplication.sharedApplication()
        backgroundTask = application.beginBackgroundTaskWithExpirationHandler() {
            dispatch_async(dispatch_get_main_queue()) {
                self.stopBackgroundTask()
            }
        }
    }
    
    private func stopBackgroundTask() {
        if backgroundTask != UIBackgroundTaskInvalid {
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }
}