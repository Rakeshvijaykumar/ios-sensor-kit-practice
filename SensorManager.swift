
// SensorManager.swift
// Handles sensor operations and battery monitoring
import Foundation
import CoreMotion
import CoreLocation
import UIKit

struct SensorDataLog: Identifiable {
    let id = UUID()
    let sensorName: String
    let data: String
}

class SensorManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isAccelerometerOn = false {
        didSet { toggleAccelerometer(isOn: isAccelerometerOn) }
    }
    @Published var isGPSOn = false {
        didSet { toggleGPS(isOn: isGPSOn) }
    }
    @Published var batteryUsage: Float = 0.0
    @Published var sensorDataLogs: [SensorDataLog] = []

    private let motionManager = CMMotionManager()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        UIDevice.current.isBatteryMonitoringEnabled = true
        locationManager.delegate = self
    }

    func startMonitoringBattery() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let batteryLevel = UIDevice.current.batteryLevel * 100
            self.batteryUsage = batteryLevel
        }
    }

    func stopAllSensors() {
        motionManager.stopAccelerometerUpdates()
        locationManager.stopUpdatingLocation()
    }

    private func toggleAccelerometer(isOn: Bool) {
        if isOn {
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                guard let data = data, error == nil else { return }
                let log = SensorDataLog(sensorName: "Accelerometer", data: "x: \(data.acceleration.x), y: \(data.acceleration.y), z: \(data.acceleration.z)")
                self.sensorDataLogs.append(log)
            }
        } else {
            motionManager.stopAccelerometerUpdates()
        }
    }

    private func toggleGPS(isOn: Bool) {
        if isOn {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }

    // CLLocationManager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let log = SensorDataLog(sensorName: "GPS", data: "lat: \(location.coordinate.latitude), lon: \(location.coordinate.longitude)")
        sensorDataLogs.append(log)
    }
}
