//
//  XcodeMenuItemViewController.swift
//  XcodeSwitcherMenuBarExtra
//
//  Created by Hori,Masaki on 2021/05/24.
//

import Cocoa

final class XcodeMenuItemViewController: NSViewController {
    
    // MARK: - Inner Type
    
    enum State {
        
        case on, off
    }
    
    // MARK: - Outlet
    
    @IBOutlet private var applicationNameField: NSTextField!
    @IBOutlet private var versionLabel: NSTextField!
    @IBOutlet private var veresionNumerField: NSTextField!
    @IBOutlet private var applicationURLField: NSTextField!
    @IBOutlet private var hilightView: NSVisualEffectView!
    
    
    // MARK: - Constants
    
    let xcode: Xcode
    
    
    // MARK: - Variables
    
    var hilight: Bool = false {
        
        didSet {
            
            if hilight {
                
                hilightView.isHidden = false
                
                applicationNameField.cell?.backgroundStyle = .emphasized
                versionLabel.cell?.backgroundStyle = .emphasized
                veresionNumerField.cell?.backgroundStyle = .emphasized

                applicationURLField.cell?.backgroundStyle = .emphasized
            }
            else {
                
                hilightView.isHidden = true
                
                applicationNameField.cell?.backgroundStyle = .normal
                versionLabel.cell?.backgroundStyle = .normal
                veresionNumerField.cell?.backgroundStyle = .normal

                applicationURLField.cell?.backgroundStyle = .normal
            }
            
            view.display()
        }
    }
    
    var state: State = .off {
        
        didSet {
            
            switch state {
            case .on: applicationNameField.font = selectedTitleFont
            case .off: applicationNameField.font = deselectTitleFont
            }
        }
    }
    
    // MARK: - Private Variables
    
    private var deselectTitleFont: NSFont!
    private var selectedTitleFont: NSFont!
    
    private var blinkMode = false
    private var blinkTimer: Timer?
        
    // MARK: - Life Cycle
        
    init(xcode: Xcode) {
        
        self.xcode = xcode
        
        super.init(nibName: "XcodeMenuItemView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    func sendAction() {
        
        guard let menuItem = view.enclosingMenuItem,
              let menu = menuItem.menu else {
            
            return
        }
        
        menu.performActionForItem(at: menu.index(of: menuItem))
    }
    
    // MARK: - Private Functions
    
    private func updateLabels() {
        
        applicationNameField.stringValue = xcode.displayName
        veresionNumerField.stringValue = xcode.version
        applicationURLField.stringValue = xcode.url.deletingPathExtension().path
    }
    
    private func blink() {
        
        if blinkMode { return }
        
        blinkMode = true
        
        var blinkCount = 2
        blinkTimer = Timer(timeInterval: 0.09, repeats: true) { timer in
            
            defer {
                
                blinkCount -= 1
            }
            
            self.hilight = !blinkCount.isMultiple(of: 2)
            
            if blinkCount == 0 {
                
                timer.invalidate()
                
                self.view.enclosingMenuItem?.menu?.cancelTracking()
                
                self.blinkMode = false
                
                DispatchQueue.main.async {
                    
                    self.sendAction()
                }
            }
        }
        
        RunLoop.current.add(blinkTimer!, forMode: .eventTracking)
    }
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedTitleFont = applicationNameField.font
        let fm = NSFontManager.shared
        deselectTitleFont = fm.font(withFamily: selectedTitleFont.familyName!,
                                    traits: [],
                                    weight: 5,
                                    size: selectedTitleFont.pointSize)
        applicationNameField.font = deselectTitleFont
        
        updateLabels()
        
        hilightView.isEmphasized = true
        hilightView.wantsLayer = true
        hilightView.layer?.cornerRadius = 4
        hilightView.layer?.cornerCurve = .continuous
        hilightView.isHidden = true
        
        let area = NSTrackingArea(rect: view.bounds,
                                  options: [
                                    .mouseEnteredAndExited,
                                    .enabledDuringMouseDrag,
                                            .activeAlways
                                  ],
                                  owner: self,
                                  userInfo: nil)
        view.addTrackingArea(area)
    }
    
    // MARK: - Event Handling
    
    override func mouseEntered(with event: NSEvent) {
        
        if blinkMode { return }
        
        hilight = true
    }
    
    override func mouseExited(with event: NSEvent) {
        
        if blinkMode { return }
        
        hilight = false
    }
    
    override func mouseDown(with event: NSEvent) {
                
        blink()
    }
    
    override func mouseUp(with event: NSEvent) {
                
        blink()
    }
}
