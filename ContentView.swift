
// ContentView.swift
import SwiftUI

// Main UI for toggling sensors and displaying data/battery usage

struct ContentView: View {
    @ObservedObject var sensorManager = SensorManager()
    
    var body: some View {
        VStack {
            Text("Sensor Battery Usage")
                .font(.largeTitle)
                .padding()

            Toggle("Accelerometer", isOn: $sensorManager.isAccelerometerOn)
                .padding()

            Toggle("GPS", isOn: $sensorManager.isGPSOn)
                .padding()

            Text("Battery Usage: \(sensorManager.batteryUsage, specifier: "%.2f")%")
                .font(.headline)
                .padding()

            List(sensorManager.sensorDataLogs, id: \..id) { log in
                Text("\(log.sensorName): \(log.data)")
            }
            .frame(height: 200)
            
            Spacer()
        }
        .onAppear {
            sensorManager.startMonitoringBattery()
        }
        .onDisappear {
            sensorManager.stopAllSensors()
        }
    }
}
