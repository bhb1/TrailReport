//
//  StopWatchManager.swift
//  TrailReport
//
//  Created by Braden Becker on 12/10/23.
//

import Foundation

class StopWatchManager: ObservableObject {
    var timer = Timer()
    var index = 0
    @Published var secondsElapsed = 0
 
        
    
    enum stopWatchMode {
        case running
        case stopped
        case paused
    }
    @Published var mode: stopWatchMode = .stopped
    func start() {
        if mode != stopWatchMode.running {
            index += 1
            mode = .running
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.secondsElapsed = self.secondsElapsed + 1
            }
        }
    }
    func stop() {
        timer.invalidate()
        secondsElapsed = 0
        mode = .stopped
    }
    func toggle() {
        if mode == stopWatchMode.running {
            self.pause()
        } else {
            self.start()
        }
    }
    func pause() {
        timer.invalidate()
        mode = .paused
    }
    func reset() {
        timer.invalidate()
        mode = .paused
        secondsElapsed = 0
    }
    
    func formatElapsed(elapsed: Int ) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        let formattedString = formatter.string(from: TimeInterval(elapsed))!
        return formattedString

    }
}
