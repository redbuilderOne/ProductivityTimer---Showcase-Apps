
import UIKit

final class TimerViewController: UIViewController, TimerViewDelegate {

    var timerView = TimerView()
    let timerFormat = TimerFormat()
    var constants = LetsAndVarsForTimer()

    let secFormat = SecondsPickerFormat()
    let minFormat = MinutesPickerFormat()
    let hourFormat = HoursPickerFormat()

    override func loadView() {
        view = timerView
    }

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        timerView.delegate = self

        constants.startTime = constants.userDefaults.object(forKey: LetsAndVarsForTimer.Keys.START_TIME_KEY.rawValue) as? Date
        constants.stopTime = constants.userDefaults.object(forKey: LetsAndVarsForTimer.Keys.STOP_TIME_KEY.rawValue) as? Date
        constants.isTimerActivated = constants.userDefaults.bool(forKey: LetsAndVarsForTimer.Keys.COUNTING_KEY.rawValue)
        constants.countDownTime = constants.userDefaults.object(forKey: LetsAndVarsForTimer.Keys.SET_TIME_KEY.rawValue) as? Date

        if constants.isTimerActivated {
            startTimer(timeInterval: 0.1, action: #selector(refreshValue))
        } else {
            stopTimer()
            if let start = constants.startTime {
                if let stop = constants.stopTime {
                    let time = countRestartTime(start: start, stop: stop)
                    let difference = Date().timeIntervalSince(time)
                    setTimeLabel(Int(difference))
                }
            }
        }
    }

    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timerView.animateCircular()
        timerView.verticalLineView.layer.opacity = 0.0
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - Round Animation
    let roundAnimation = CABasicAnimation(keyPath: "strokeEnd")

    func startStopAnimation(toValue: Int, repeatCount: Float) {
        roundAnimation.toValue = toValue
        roundAnimation.duration = CFTimeInterval(60)
        roundAnimation.fillMode = CAMediaTimingFillMode.forwards
        roundAnimation.isRemovedOnCompletion = false
        roundAnimation.repeatCount = repeatCount
        timerView.shapeLayer.add(roundAnimation, forKey: "roundAnimation")
    }

    //MARK: - startActionDidPressed
    func startActionDidPressed() {
        timerView.timerLabel.isHidden = false
        if constants.isTimerActivated {
            setStopTime(date: Date())
            stopTimer()
            setButtonImg(title: "Play", img: "play")
        } else {
            if let stop = constants.stopTime {
                let restartTime = countRestartTime(start: constants.startTime!, stop: stop)
                setStopTime(date: nil)
                setStartTime(date: restartTime)
            } else {
                setStartTime(date: Date())
            }
            startTimer(timeInterval: 0.1, action: #selector(refreshValue))
            setButtonImg(title: "Pause", img: "pause")
        }
    }

    private func countRestartTime(start: Date, stop: Date) -> Date {
        let difference = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(difference)
    }

    //MARK: - stopActionDidPressed
    func stopActionDidPressed() {
        setStopTime(date: nil)
        setStartTime(date: nil)
        stopTimer()
        startStopAnimation(toValue: 1, repeatCount: 1)
        timerView.timerLabel.text = "STOP"
        timerView.timerLabel.textColor = .systemRed
        timerView.timerLabel.isHidden = false
        timerView.timePickerView.isHidden = true
        timerView.startButton.isHidden = false
        timerView.startButton.isEnabled = true
        UIView.animate(withDuration: 3.0, delay: 2.0) {
            self.timerView.verticalLineView.layer.opacity = 0.0
        }
    }

    // MARK: - Start, Pause, Stop Timers
    private func setStartTime(date: Date?) {
        constants.startTime = date
        constants.userDefaults.set(constants.startTime, forKey: LetsAndVarsForTimer.Keys.START_TIME_KEY.rawValue)
        timerView.timerLabel.textColor = .white
    }

    private func setStopTime(date: Date?) {
        constants.stopTime = date
        constants.userDefaults.set(constants.stopTime, forKey: LetsAndVarsForTimer.Keys.STOP_TIME_KEY.rawValue)
        setButtonImg(title: "Play", img: "play")
    }

    private func setTimerCounting(_ val: Bool) {
        constants.isTimerActivated = val
        constants.userDefaults.set(constants.isTimerActivated, forKey: LetsAndVarsForTimer.Keys.COUNTING_KEY.rawValue)
    }

    func startTimer(timeInterval: TimeInterval, action: Selector) {
        constants.scheduledTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: action, userInfo: nil, repeats: true)
        setTimerCounting(true)
        startStopAnimation(toValue: 0, repeatCount: 999)
    }

    @objc func refreshValue() {
        if let start = constants.startTime {
            let differrence = Date().timeIntervalSince(start)
            setTimeLabel(Int(differrence))
        } else {
            stopTimer()
            setTimeLabel(0)
        }
    }

    func stopTimer() {
        if constants.scheduledTimer != nil {
            constants.scheduledTimer.invalidate()
        }
        setTimerCounting(false)
        startStopAnimation(toValue: 1, repeatCount: 1)
    }

    func setTimeLabel(_ val: Int) {
        let time = timerFormat.setSecondsToHoursMinutesToHours(val)
        let timeString = timerFormat.convertTimeToString(hour: time.0, min: time.1, sec: time.2)
        timerView.timerLabel.text = timeString
    }

    @objc func pauseTimer() {
        constants.timer.invalidate()
        startStopAnimation(toValue: 1, repeatCount: 1)
    }

    func setButtonImg(title: String, img: String) {
        timerView.startButton.setTitle(title, for: .normal)
        timerView.startButton.setImage(UIImage(systemName: img), for: .normal)
    }

    //MARK: - Обратный таймер
    func startSetTimerButtonDidPressed() {
        constants.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(beginCountDown), userInfo: nil, repeats: false)
    }

    func setActionDidPressed() {
        stopTimer()
        timerView.timerLabel.isHidden = true
        timerView.timePickerView.isHidden = false
    }

    private func setCountDownTime(date: Date?) {
        constants.countDownTime = date
        constants.userDefaults.set(constants.countDownTime, forKey: LetsAndVarsForTimer.Keys.COUNTING_KEY.rawValue)
    }

    @objc func beginCountDown() {

        timerView.timerLabel.text = String(constants.countdown)
        timerView.timerLabel.textColor = .white

        if constants.countdown > 0 {
            setButtonImg(title: "Countdown", img: "")
            constants.countdown -= 1
        } else {
            constants.timer.invalidate()
            timerView.startButton.isEnabled = true
            timerView.timerLabel.text = "TIME'S UP"
            timerView.timerLabel.textColor = sandyYellowColor
            setButtonImg(title: "Play", img: "play")
            stopTimer()
        }
    }
}
