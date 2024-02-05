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
    @State var filterDistanceString: String
    
    @State var showUploadSuccess = false
    @State var showUploadFailure = false
    
    @State private var isPresented = false
    
    @ObservedObject var locationViewModel = LocationViewModel()
    
    @ObservedObject var stopwatch = StopWatchManager()
    
    init(){
        let deviceIDString_init = String(UserDefaults.standard.object(forKey: "deviceID") as? Int ?? 12345)
        
        let uploadURLString_init = (UserDefaults.standard.object(forKey: "uploadURL") as? URL ?? URL(string: "https://b9ac252e833b4afa399912e731d0da49.m.pipedream.net")!).absoluteString
        
        let filterDistanceString_init = String(UserDefaults.standard.object(forKey: "filterDistance") as? Int ?? 10)
        
        _filterDistanceString = State(initialValue: filterDistanceString_init)
        _uploadURLString = State(initialValue: uploadURLString_init)
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
        print("here")
        let json = self.pointsToJSON(points: self.locationViewModel.filteredPoints)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        let jsonString = String(data: jsonData!, encoding: String.Encoding.ascii)!
        print(jsonString)
        
        print("Upload started.")
        
        // create post request
        // let url = URL(string: "https://b9ac252e833b4afa399912e731d0da49.m.pipedream.net")!
        //let url = URL(string: "https://nabohund.no/craftsbury/craftsbury.php")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody =  jsonData
        
        // insert json data to the request
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            print()
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
                if str == "OK" {
                    self.showUploadSuccess = true
                    
                } else {
                    self.showUploadFailure = true
                }
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
                }
                VStack {
                    HStack {
                        Spacer()
                        HStack {
                            Text("Latitude: ")
                                .fontWeight(.bold)
                            Text("\(locationViewModel.userLatitude)")
                            Spacer()
                            Text("Longitude: ")
                                .fontWeight(.bold)
                            Text("\(locationViewModel.userLongitude)")
                            //Text(locationManager.location?.description ?? "No Location Provided!")
                            
                        }
                        Spacer()
                    }
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
                Button(action: {upload(url: (URL(string: "https://b9ac252e833b4afa399912e731d0da49.m.pipedream.net")!))})
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
                    
                }
                Spacer()
                Button(action: {self.locationViewModel.reset();self.stopwatch.reset()})
                {
                    Text("CLEAR")
                        .fontWeight(.bold)
                        .font(.title)
                        .frame(width: 150.0, height: 75.0, alignment: Alignment.center)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(10)
                    
                }.alert(isPresented: $showUploadSuccess) {
                    Alert(title: Text("Upload Successful."), message: Text(""), dismissButton: .default(Text("OK")))
                }
                Spacer()
                
                        }
            //HOME TAB END
            .tabItem {
                
                Label("Home", systemImage: "play")
            }
            //MAP TAB START
            Text("Display")
            //MAP TAB END
                .tabItem {
                    Label("Map", systemImage: "map")
                    
                }
            //SETTINGS TAB START
            VStack{
                Form {
                    
                    HStack{
                        Text("GPS Point Spacing (m): ")
                        TextField("",text: $filterDistanceString)
                    }
                    HStack{
                        Text("Device ID: ")
                        TextField("", text: $deviceIDString )
                        
                    }
                    HStack{
                        Text("Upload URL: ")
                        TextField("", text: $uploadURLString )
                    }
                    
                    
//                    Button("Save", action: {
//                        let deviceID: Int = Int(deviceIDString) ?? 12345
//                        let uploadURL: URL = URL(string: uploadURLString) ?? URL(string:"https://nabohund.no/craftsbury/craftsbury.php")!
//                        let filterDistance: Int = Int(filterDistanceString) ?? 10
//                        UserDefaults.standard.setValue(deviceID, forKey: "deviceID")
//                        UserDefaults.standard.setValue(uploadURL, forKey: "uploadURL")
//                        UserDefaults.standard.set(filterDistance, forKey: "filterDistance")
//                        
//                        self.isPresented.toggle()})
//                    
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
