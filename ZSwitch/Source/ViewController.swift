//
//  ViewController.swift
//  ZSwitch
//
//  Created by zhangshibo on 8/17/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var isCommandPressing = false
    var isShiftPressing = false
    var isShowingUI = false
    var isCoolingDown = false
    var currentAppIndex = 0
    var keyQdownCount = 0
    var _userInput = ""
    var backView: BackView?
    var circleCounter: JWGCircleCounter?
    var label: NSTextField?
    var timer = Timer()
    var _orderedAppModels: [AppModel] = []
    var notRunningAppModels: [AppModel] = []
    var _appModels:[AppModel] = []
    var _appItemViews: [AppItemView] = []
    var clearUserInputWork: DispatchWorkItem = DispatchWorkItem { }
    var clearKeyQCountWork: DispatchWorkItem = DispatchWorkItem { }
    var sortAppWork: DispatchWorkItem = DispatchWorkItem { }
    var didActivateWork: DispatchWorkItem = DispatchWorkItem { }

    
    var userInput: String {
        get {
            return _userInput
        }
        set {
            _userInput = newValue
            if newValue == "" {
                orderedAppModels = _appModels
            } else {
                sortAppWork.cancel()
                sortAppWork = DispatchWorkItem {
                    self.sortAppModels()
                }
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + .milliseconds(100), execute: sortAppWork)
            }
            updateLabel(stringValue: self._userInput)
        }
    }
    
    var orderedAppModels: [AppModel] {
        get {
            return _orderedAppModels
        }
        set {
            _orderedAppModels = newValue
            updateAppItemViews()
        }
    }
    
    var appItemViews:[AppItemView] {
        get {
            return _appItemViews
        }
        set {
            DispatchQueue.main.async {
                self.clearViews()
                self.backView = createBackView()
                self.view.addSubview(self.backView!)
                self._appItemViews = newValue
                for (index,item) in self.appItemViews.enumerated() {
                    if index == self.currentAppIndex {
                        item.isActive = true
                    }
                    self.view.addSubview(item.view)
                }
            }
        }
    }
    
    var appModels:[AppModel] {
        get {
            return _appModels
        }
        set {
            updateAppModels(newValue)
        }
    }
    
    // MARK: - life cycle
    override func loadView() {
        let view = NSView(frame: screenRect!)
        view.wantsLayer = true
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAppsStatObserver()
        self.getRunningAppModels()
        orderedAppModels = appModels
        self.notRunningAppModels = getNotRunningApps(
            runnings: self.appModels, norunnings: self.notRunningAppModels)
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        self.orderOut()
    }
    
    func resetInternalStatus() {
        isCommandPressing = false
        isShiftPressing = false
    }
    
    // MARK: - apps come and go
    func addAppsStatObserver() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(foremostAppActivated),
            name: NSWorkspace.didActivateApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appLaunchedOrTerminated),
            name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appLaunchedOrTerminated),
            name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appDidHide),
            name: NSWorkspace.didHideApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(appDidDeactive),
            name: NSWorkspace.didDeactivateApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(workspaceDidWake),
            name: NSWorkspace.screensDidWakeNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidChangeResolution),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)

    }
    
    @objc func foremostAppActivated(notification: NSNotification) {
        let app = notification.userInfo?[
            AnyHashable("NSWorkspaceApplicationKey")] as! NSRunningApplication

        didActivateWork.cancel()
        didActivateWork = DispatchWorkItem {
            DBManager.log(name: app.localizedName!)
        }
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(300), execute: didActivateWork)
        afterSelectApp(app: AppModel(app: app))

    }
    
    @objc func appDidHide(notification: NSNotification) {
//        NSLog("app \(notification) did hide")
    }
    
    @objc func appDidDeactive(notification: NSNotification) {
//        NSLog("app \(notification) did deactive")
    }
    
    @objc func appDidChangeResolution(notification: NSNotification) {
        screenRect = NSScreen.main?.frame
        self.view.setFrameSize((screenRect?.size)!)
    }
    
    @objc func workspaceDidWake(notification: NSNotification) {
        resetInternalStatus()
    }
    
    @objc func appLaunchedOrTerminated(notification: NSNotification) {
        self.getRunningAppModels()
        self.notRunningAppModels = getNotRunningApps(
            runnings: self.appModels, norunnings: self.notRunningAppModels)
    }
    
    // MARK: - view manipulation
    fileprivate func clearViews() {
        if self.backView != nil {
            self.backView?.removeFromSuperview()
        }
        for item in self._appItemViews {
            item.view.removeFromSuperview()
            item.isActive = false
        }
    }
    
    fileprivate func updateLabel(stringValue: String) {
        self.label = getInputLabel(label: self.label)
        self.label?.stringValue = stringValue
        if self.label?.superview == nil {
            self.view.addSubview(self.label!)
        }
    }
    
    fileprivate func updateAppItemViews() {
        if !Thread.isMainThread {
            return
        }
        if orderedAppModels.count > 0 {
            reCalculateSize(count: orderedAppModels.count)
        }
        var appItemViews:[AppItemView] = []
        for (index, appModel) in orderedAppModels.enumerated() {
            let appItem = createAppItem(appModel: appModel, index: index)
            appItem.afterSelectApp = afterSelectApp
            appItemViews.append(appItem)
        }
        self.appItemViews = appItemViews
    }
    
    fileprivate func addCycleCounterView(withSeconds: Int, offset: Int) {
        self.circleCounter = getSingletonCircleCounter(
            counter: self.circleCounter, left: offset * 4)
        self.view.addSubview(self.circleCounter!)
        self.circleCounter?.start(withSeconds: withSeconds)
    }
    
    @objc func afterSelectApp(app: AppModel?) {
        if let target = app {
            for (index, app) in appModels.enumerated() {
                if (app.pid != -1 && app.pid == target.pid)
                    || (app.pid == -1 && app.name == target.name) {
                    self.currentAppIndex = index
                }
            }
        }
        _appModels.rearrange(from: currentAppIndex, to: 0)
        currentAppIndex = 0
        isShowingUI = false
        userInput = ""
    }
    
    fileprivate func getRunningAppModels() {
        
        let ws = NSWorkspace.shared
        var tmpModels:[AppModel] = []
        for app in ws.runningApplications {
            if (app.activationPolicy == .regular) {
                let appModel = AppModel(app: app)
                tmpModels.append(appModel)
            }
        }
        self.appModels = tmpModels
    }
    
    fileprivate func sortAppModels() {
        var tmpApps:[AppModel] = []
        let count = _appModels.count
        
        for i in _appModels {
            if tmpApps.first(where: {$0.name == i.name}) == nil {
                tmpApps.append(i)
            }
        }
        for i in notRunningAppModels {
            if tmpApps.first(where: {$0.name == i.name}) == nil {
                tmpApps.append(i)
            }
        }
//        tmpApps += _appModels
//        tmpApps += notRunningAppModels
        
        DispatchQueue.global().async {
            tmpApps.sort(by: { (a, b) -> Bool in
                var distanceA = a.name?.distance(self.userInput)
                var distanceB = b.name?.distance(self.userInput)
                
                if a.pid != -1 {
                    distanceA = distanceA! - 0.5
                }
                if b.pid != -1 {
                    distanceB = distanceB! - 0.5
                }

                return distanceA! < distanceB!
            })
            DispatchQueue.main.async {
                let t = tmpApps[0..<count]
                self.orderedAppModels = Array(t)
            }
        }
    }
    
    fileprivate func updateAppModels(_ newValue: [AppModel]) {
        for model in newValue { // app add
            let found = _appModels.first(where: {$0.pid == model.pid})
            if found == nil {
                _appModels.insert(model, at: 0)
//                _appModels.append(model)
            } else {
                found?.pid = model.pid
                found?.runningApp = model.runningApp
                if (model.runningApp?.isActive)! {
                    _appModels = _appModels.filter({ $0.pid != found?.pid})
                    _appModels.insert(found!, at: 0)
                }
            }   
        }
        for (index, model) in _appModels.enumerated() { // app quit
            if newValue.first(where: {$0.pid == model.pid}) == nil {
                _appModels.remove(at: index)
            }
        }
        
        orderedAppModels = _appModels
    }
    
    // MARK: - user interaction
    
    @objc func interceptKeyChange(keycode: Int32, type: Int32) -> Bool {
        //        NSLog("current index: \(currentAppIndex)")
        //        NSLog("keycode: \(keycode) type: \(type)")
        updateModifierKeyState(keycode)
        if (self.orderedAppModels.count <= 0) { return true }
        if isCommandPressing && keycode == Key.tab.carbonKeyCode && !isShowingUI {
            isShowingUI = true
            willShowUI()
        }
        if isShowingUI {
            DispatchQueue.main.async {
                self.keyChangeProcess(keycode: keycode, type: type)
            }
            return false
        } else {
            return true
        }
    }
    
    fileprivate func keyChangeProcess(keycode: Int32, type: Int32) {
        if !isCommandPressing {
            launchIfCommandNotPress()
        } else if type == KeyDown && keycode == Key.return.carbonKeyCode {
            launchAnyway()
        } else if keycode == Key.tab.carbonKeyCode {
            if (type == KeyDown && appItemViews.count > 0) {
                if (isShiftPressing) {
                    currentAppIndex = (currentAppIndex + appItemViews.count - 1) % appItemViews.count
                } else {
                    currentAppIndex = (currentAppIndex + 1) % appItemViews.count
                }
            }
        } else if type == KeyDown && (keycode == Key.grave.carbonKeyCode || keycode == Key.escape.carbonKeyCode){
            self.orderFrontRegardless()
            if (appItemViews.count > 0) {
                currentAppIndex = (currentAppIndex + appItemViews.count - 1) % appItemViews.count
            }
        } else if type == KeyDown && keycode == Key.q.carbonKeyCode {
            processKeyQdown()
        } else if type == KeyDown && keycode == Key.delete.carbonKeyCode {
            if userInput.count > 0 {
                let index = userInput.index(userInput.endIndex, offsetBy: -1)
                userInput = String(userInput[..<index])
                if (userInput == "reset") {
                    isCommandPressing = false
                    isShiftPressing = false
                    userInput = ""
                }
            } else {
                self.updateLabel(stringValue: "")
                orderedAppModels = appModels
            }
        } else if type == KeyUp && Key.isAlphabetKey(code: UInt32(keycode)) {
            if shouldInput() {
                userInput += Key.toAlphabelt(keycode: UInt32(keycode))
                currentAppIndex = 0
            }
        }
        
        //        NSLog("\(userInput) \(userInput.count) \(type != KeyUp)")
        if userInput.count > 0 && type != KeyDown && keycode != Key.command.carbonKeyCode {
            resetCountDownTimer()
        }
        if isShowingUI {
            updateAppItemViews()
        }
    }
    
    fileprivate func willShowUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
            if self.isShowingUI == false { return }
            self.orderFrontRegardless()
        })
    }
    
    func orderFrontRegardless() -> Void {
        
        for w in NSApp.windows {
            w.orderFrontRegardless()
        }
        return
    }
    
    func orderOut() -> Void {
        for w in NSApp.windows {
            w.orderOut(nil)
        }
    }
    
    fileprivate func launchOrActiveApp() {
        let appNotReLaunch = ["Hopper Disassembler v4", "Xcode"]
        isShowingUI = false
        let v = self.appItemViews[self.currentAppIndex]
        
        // TODO: more configurable white list
        if (!appNotReLaunch.contains((v.appModel?.name)!)) {
            DispatchQueue.main.async {
                NSWorkspace.shared.launchApplication((v.appModel?.name)!)
            }
        }
        v.appModel?.runningApp?.activate(options: .activateIgnoringOtherApps)
        NSLog((v.appModel?.name!)!)
    }
    
    fileprivate func didLaunchOrActiveApp() {
       self.userInput = ""
    }
    
    fileprivate func launchIfCommandNotPress() {
//        if !isCommandPressing && !isCoolingDown {
        if !isCommandPressing {
            launchAnyway()
            NSLog("here")
        }
    }
    
    fileprivate func launchAnyway() {
        self.orderOut()
        launchOrActiveApp()
        didLaunchOrActiveApp()
    }
    
    fileprivate func resetCountDownTimer() {
        isCoolingDown = true
        addCycleCounterView(withSeconds: 1, offset: userInput.count)
        clearUserInputWork.cancel()
        clearUserInputWork = DispatchWorkItem {
            self.isCoolingDown = false
//            self.launchIfCommandNotPress()
            if self.userInput == "" {
                return
            }
            let str = self.userInput + " ⌫"
            self._userInput = "" // not reorder
            //            self.userInput = "" // will reorder
            self.updateLabel(stringValue: str)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1,
                                      execute: clearUserInputWork)
    }
    
    fileprivate func updateModifierKeyState(_ keycode: Int32) {
       
        if (UInt32(keycode) == Key.command.carbonKeyCode) {
            DispatchQueue.main.sync {
                self.isCommandPressing = !self.isCommandPressing
            }
        }
        
        // There is a bug that shift key is not released, to be fixed
        if (UInt32(keycode) == Key.shift.carbonKeyCode) {
            DispatchQueue.main.sync {
                self.isShiftPressing = !self.isShiftPressing
            }
        }
    }
    
    fileprivate func shouldInput() -> Bool {
        if keyQdownCount > 2 {
            keyQdownCount = 0
            return false
        }
        keyQdownCount = 0
        return true
    }
    
    fileprivate func processKeyQdown() {
        keyQdownCount += 1
        
        clearKeyQCountWork.cancel()
        clearKeyQCountWork = DispatchWorkItem {
            self.keyQdownCount = 0
            self.circleCounter?.removeFromSuperview()
            self.updateLabel(stringValue: "")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1),
                                      execute: clearKeyQCountWork)
        
        let name = orderedAppModels[currentAppIndex].name
        let s = "hold '⌘+Q' 2s to quit '\(name!)'"
        if keyQdownCount == 5 {
            updateLabel(stringValue: s)
            addCycleCounterView(withSeconds: 2, offset: s.count)
        }
        
        if keyQdownCount == 30 {
            keyQdownCount = -20
            self.circleCounter?.removeFromSuperview()
            let pid = orderedAppModels[currentAppIndex].pid!
            terminateApp(pid: pid)
            orderedAppModels = orderedAppModels.filter{ $0.pid != pid }
            appModels = appModels.filter{ $0.pid != pid}
            
            if currentAppIndex == appModels.count {
                currentAppIndex = appModels.count - 1
            } else {
                currentAppIndex = currentAppIndex % appModels.count
            }
        }
    }
    
}

