//
//  ContentView.swift
//  TrailReport
//
//  Created by Braden Becker on 12/9/23.
//

import SwiftUI
import MapKit


struct ContentView: View {
    
    
    
    @State var deviceIDString: String
    @State var uploadURLString: String
    @State var logURLString: String
    @State var filterDistanceString: String
    
    @State var showUploadSuccess = false
    @State var showUploadFailure = false
    
    @State private var isPresented = false
    
    @ObservedObject var locationViewModel = LocationViewModel()
    
    @ObservedObject var stopwatch = StopWatchManager()
    
    init(){
        let deviceIDString_init = String(UserDefaults.standard.object(forKey: "deviceID") as? Int ?? 12345)
        
        let uploadURLString_init = (UserDefaults.standard.object(forKey: "uploadURL") as? URL ?? URL(string: "https://nabohund.no/craftsbury/craft.php")!).absoluteString
        
        let logURLString_init = (UserDefaults.standard.object(forKey: "logURL") as? URL ?? URL(string: "https://b9ac252e833b4afa399912e731d0da49.m.pipedream.net")!).absoluteString
        
        let filterDistanceString_init = String(UserDefaults.standard.object(forKey: "filterDistance") as? Int ?? 10)
        
        _filterDistanceString = State(initialValue: filterDistanceString_init)
        _uploadURLString = State(initialValue: uploadURLString_init)
        _logURLString = State(initialValue: logURLString_init)
        _deviceIDString = State(initialValue: deviceIDString_init)
        
        
        
    }
    
    func pointsToText(points: [CLLocation]) -> String {
        var text = ""
        for point in points {
            let lat = point.coordinate.latitude
            let long = point.coordinate.longitude
            text = text + "LAT: " + lat.description + " " + "LONG: " + long.description + "\r\n"
        }
        return text
    }
    
    func pointsToString(points: [CLLocation]) -> String {
        var text = """
        """
        for point in points {
            text = text + point.coordinate.latitude.description + "," + point.coordinate.longitude.description + "\n"
        }
        return text
    }
    
    func upload(url: URL) {
        let json = self.pointsToJSON(points: self.locationViewModel.filteredPoints)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        let jsonString = String(data: jsonData!, encoding: String.Encoding.ascii)!
           
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody =  jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
    
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            } else {
                let str = String(decoding: data, as: UTF8.self)
                print(str)
            }
        }
        task.resume()
    }
    
    func pointsToJSON(points: [CLLocation]) -> [String:Any] {
        
        var json: [String:Any] = [ "id":self.deviceIDString, "points":[]]
        var pointArray = [Any]()
        for point in points {
            
            let lat = point.coordinate.latitude.description
            let long = point.coordinate.longitude.description
            let tms = point.timestamp
            let elv = point.altitude.description
            
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let tmsFormatted = formatter.string(from: tms).description
            
            pointArray.append(["lat":lat, "long":long, "elv":elv, "time":tmsFormatted])
            
        }
        json["points"] = pointArray
        return json
    }
    var body: some View {
        TabView {
            //HOME TAB START
            VStack {
                
                Spacer()
                HStack{
                    Text("Duration: ")
                        .fontWeight(.bold)
                    Text(stopwatch.formatElapsed(elapsed: self.stopwatch.secondsElapsed))
                }
                Spacer()
                HStack{
                    Text("Distance: ")
                        .fontWeight(.bold)
                    Text("\(self.locationViewModel.distance, specifier: "%.2f")")
                }
                
                
                Spacer()
                HStack{
                    Text("Latitude: ")
                        .fontWeight(.bold)
                    
                    Text("\(locationViewModel.userLatitude)")
                    
                }
                Spacer()
                HStack{
                    Text("Longitude: ")
                        .fontWeight(.bold)
                    
                    Text("\(locationViewModel.userLongitude)")
                    
                    //Text(locationManager.location?.description ?? "No Location Provided!")
                }
                
                
                Spacer()
                
                
                
                Button(action: { self.locationViewModel.live.toggle(); self.stopwatch.toggle()})
                {
                    if (self.locationViewModel.live) {
                        Text("PAUSE")
                            .fontWeight(.bold)
                            .font(.title)
                            .frame(width: 150.0, height: 75.0, alignment: Alignment.center)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .padding(10)
                        
                    } else {
                        Text("START")
                            .fontWeight(.bold)
                            .font(.title)
                            .frame(width: 150.0, height: 75.0, alignment: Alignment.center)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .padding(10)
                        
                    }
                    
                }
                Spacer()
                Button(action: {upload(url: (URL(string: self.uploadURLString)!))})
                {
                    Text("UPLOAD")
                        .fontWeight(.bold)
                        .font(.title)
                        .frame(width: 150.0, height: 75.0, alignment: Alignment.center)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(10)
                    
                }.alert(isPresented: $showUploadSuccess) {
                    Alert(title: Text("Upload Successful."), message: Text(""), dismissButton: .default(Text("OK")))
                }
                Spacer()
                Button(action: {self.locationViewModel.reset();self.stopwatch.reset()})
                {
                    Text("RESET")
                        .fontWeight(.bold)
                        .font(.title)
                        .frame(width: 150.0, height: 75.0, alignment: Alignment.center)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(10)
                    
                }
                Spacer()
                
            }
            //HOME TAB END
            .tabItem {
                
                Label("Run", systemImage: "play")
            }
            //MAP TAB START
         
            Map() {
                //if (self.locationViewModel.filteredPoints2D.isEmpty) {
                  //  MapPolyline(coordinates: self.locationViewModel.filteredPoints2D, contourStyle: MapPolyline.ContourStyle.geodesic)
                    //   .stroke(.blue, lineWidth: 13)
                //}
                    
            }
            //MAP TAB END
                .tabItem {
                    Label("Map", systemImage: "map")
                    
                }
            //SETTINGS TAB START
            VStack{
                Form {
                    
                    HStack{
                        Text("GPS Point Spacing (m): ")
                            .bold()
                        TextField("",text: $filterDistanceString)
                        
                    }
                    HStack{
                        Text("Device ID: ")
                            .bold()
                        TextField("", text: $deviceIDString )
                        
                    }
                    HStack{
                        Text("Upload URL: ")
                            .bold()
                        TextField("", text: $uploadURLString )
                    }
                    HStack{
                        Text("Logger URL: ")
                            .bold()
                        TextField("", text: $logURLString )
                    }
                    
                    
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Button("Send Log", action: {upload(url: (URL(string: self.logURLString)!))})
                                .fontWeight(.bold)
                                .font(.title)
                                .frame(width: 125.0, height: 25.0, alignment: Alignment.center)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .padding(10)
                                .buttonStyle(BorderlessButtonStyle())
                            Spacer()
                        }
                        
                        Spacer()
                        Button("Save", action: {
                            let deviceID: Int = Int(deviceIDString) ?? 12345
                            let filterDistance: Int = Int(filterDistanceString) ?? 10
                           
                            UserDefaults.standard.setValue(deviceID, forKey: "deviceID")
                            UserDefaults.standard.setValue(uploadURLString, forKey: "uploadURL")
                            UserDefaults.standard.setValue(logURLString, forKey: "logURL")
                            UserDefaults.standard.set(filterDistance, forKey: "filterDistance")
                            
                            self.isPresented.toggle()})
                        .fontWeight(.bold)
                        .font(.title)
                        .frame(width: 125.0, height: 25.0, alignment: Alignment.center)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(10)
                        .buttonStyle(BorderlessButtonStyle())
                        Spacer()
                        
                    }
                }
                
            }
            
            //SETTINGS TAB END
            .tabItem {
                
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}




#Preview {
    ContentView()
}
