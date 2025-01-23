//
//  ContentView.swift
//  NewGraduationProject
//
//  Created by cmStudent on 2025/01/16.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State var screenState = Screen.TITLE
    @StateObject var motionManager = MotionManager()
    @StateObject var locationManager = LocationManager()
    
    @State var areaRenge = Area.near
    
    @State var startLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    @State var targets: [CLLocationCoordinate2D] = []
    @State var phase = 0
    
    @State var roundTime = 0.0
    @State var roundDistance = 0.0
    @State var roundLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    @State var additionalTime = 0.0
    
    @State var subResult: [(time: Double, distance: Double, shift: Double)] = []
    
    @State var currentDistance: Double = 0.0
    @State var hintText = ""
    
    @State var resultTime = 0.0
    @State var resultText = ""
    @State var resultDistance = 0.0
    
    @State var isClear = false
    
    @AppStorage("highscore_near") var highscoreNear: Double = 0
    @AppStorage("highscore_middle") var highscoreMiddle: Double = 0
    @AppStorage("highscore_wide") var highscoreWide: Double = 0
    @AppStorage("highscore_hardcore") var highscoreHardcore: Double = 0
    @AppStorage("highscore_lunatic") var highscoreLunatic: Double = 0
    
    @State var lastScore = 0.0
    
    
    @State var isDebug = false

    var body: some View {
        switch screenState {
        case .TITLE:
            VStack {
//                Text("ここにめちゃめちゃいい感じのロゴを挿入")
//                    .onLongPressGesture(minimumDuration: isDebug ? 1 : 5) {
//                        let haptic = UIImpactFeedbackGenerator(style: .light)
//                        haptic.prepare()
//                        haptic.impactOccurred()
//                        isDebug.toggle()
//                    }
//                Text("なんかすごい猛獣ハンティングみたいな")
//                    .font(.footnote)
                Image("title")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                                    .onLongPressGesture(minimumDuration: isDebug ? 1 : 5) {
                                        let haptic = UIImpactFeedbackGenerator(style: .light)
                                        haptic.prepare()
                                        haptic.impactOccurred()
                                        isDebug.toggle()
                                    }
                Button(isDebug ? "デバッグ" : "スタート"){
                    resultTime = 0
                    resultDistance = 0
                    resultText = ""
                    hintText = "頑張って"
                    currentDistance = 0
                    additionalTime = 0.0
                    roundDistance = 0.0
                    subResult = []
                    
                    isClear = false
                    
                    startLocation = locationManager.center
                    roundLocation = locationManager.center
                    
                    
                    
                    targets = []
                    phase = 0
                    roundTime = Date().timeIntervalSince1970
                    let region = getRegion(center: locationManager.center, area: areaRenge)
                    for _ in 0...4{
                        targets.append(generateRandomCoordinate(in: region))
                    }
                    
                    locationManager.target = targets[0]
                    (roundDistance, _) = locationManager.calculateBearing(pos1: locationManager.center, pos2: targets[0])
                    
                    screenState = .CAMERA
                }
                Picker("", selection: $areaRenge){
                    ForEach(Area.allCases, id: \.self){ area in
                        Text(area.rawValue).tag(area)
                    }
                }
                Text("ハイスコア: \(String(format: "%.2f", getHighscore(area: areaRenge)))")
                
                Divider()
                Text("ルール")
                    .font(.title)
                Text("選択したエリア内に5件の見えない「手がかり」をばら撒いた。\(getAimTime(area: areaRenge).label)以内に全ての「手がかり」集めて「判定」しろ！\nただし、なんらかの理由で近づくことが出来ない場合は、その「手がかり」だけ再配置してあげよう。躊躇なく「到達不能」を押すといい。")
            }
            .padding()
        case .CAMERA:
            ZStack{
                CameraView()
                    .ignoresSafeArea()
                VStack{
                    HStack{
                        Image("rightMaker")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .opacity(getDir() == .leftFront ? 1 : 0)
                        Image("scope")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        Image("leftMaker")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .opacity(getDir() == .rightFront ? 1 : 0)
                    }
                    Image("backMaker")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .opacity(getDir() == .back ? 1 : 0)
                }
                .padding()
                VStack{
                    HStack{
                        Button{
                            resultTime = 0
                            resultDistance = 0
                            subResult = []
                            startLocation = CLLocationCoordinate2D()
                            targets = []
                            phase = 0
                            screenState = .TITLE
                        } label: {
                            Image(systemName: "xmark.app.fill")
                                .foregroundStyle(.red)
                                .font(.title)
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()
                    Text(hintText)
                    Text("ラウンド: \(phase + 1)")
                }
                VStack{
                    Text("方位: \(String(format: "%.2f", motionManager.direction))°")
                    Text("緯度: \(locationManager.center.latitude), 経度: \(locationManager.center.longitude)")
                    Spacer()
                    HStack{
                        Spacer()
                        VStack{
                            Button{
                                if (Date().timeIntervalSince1970 - roundTime) < getAdditionalTime(area: areaRenge){
                                    additionalTime += getAdditionalTime(area: areaRenge) - (Date().timeIntervalSince1970 - roundTime)
                                }
                                let region = getRegion(center: startLocation ,area: areaRenge)
                                targets[phase] = generateRandomCoordinate(in: region)
                                
                                locationManager.target = targets[phase]
                                
                                currentDistance = 0.0
                                hintText = "頑張って！！"
                            }label: {
                                Circle()
                                    .foregroundStyle(.red)
                                    .frame(width: 80, height: 80)
                                    .overlay {
                                        Text("到達\n不能")
                                            .foregroundStyle(.background)
                                    }
                            }
                            Button{
                                let result = locationManager.calculateBearing(pos1: locationManager.center, pos2: targets[phase])
                                print(result.distance)
                                if result.distance < getClearDistance(area: areaRenge) || isDebug{
                                    // 成功
                                    let (_, distance) = locationManager.calculateBearing(pos1: roundLocation, pos2: locationManager.center)
                                    subResult.append(
                                        (
                                            Date().timeIntervalSince1970 - roundTime,
                                            distance,
                                            result.distance
                                        )
                                    )
                                    roundLocation = locationManager.center

                                        phase += 1
                                    print("-----第\(phase)フェーズ-----")
                                    if(phase > 4){
                                        phase = 0
                                        screenState = .RESULT
                                    } else {
                                        hintText = "第\(phase + 1)ラウンドも頑張って！！"
                                        currentDistance = 0.0
                                        locationManager.target = targets[phase]
                                    }
                                } else {
                                    // 失敗
                                    hintText = getHintText(area: areaRenge, remain: result.distance).rawValue
                                    if currentDistance != 0.0 {
                                        if currentDistance == result.distance {
                                            hintText += "\n変わってないね"
                                    }else if currentDistance < result.distance{
                                            hintText += "\n離れちゃったね"
                                        } else  {
                                            hintText += "\n近づいたね！"
                                        }
                                    }
                                    if result.distance > getRangeMeter(area: areaRenge) {
                                        hintText += "\n範囲外に出ています"
                                    }
                                    currentDistance = result.distance
                                }
                            } label: {
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .overlay {
                                        Text("判定")
                                            .foregroundStyle(.background)
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
        case .RESULT:
            VStack{
                if isClear {
                    Image("sucsess")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    Text("スコア: \(String(format: "%.2f", lastScore))")
                } else {
                    Image("fail")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
//                    Text("ここに残念感のある画像を挿入")
                }
                    
                Text("かかった時間: \(resultText)")
                    .onAppear(perform: {
                        for result in subResult{
                            resultTime += result.time
                        }
                        resultTime += additionalTime
                        
                        let dateFormatter = DateComponentsFormatter()
                        dateFormatter.unitsStyle = .full
                        dateFormatter.allowedUnits = [.hour, .minute, .second]
                        
                        resultText = dateFormatter.string(from: resultTime) ?? "変換エラー(\(String(format: "%.2f", resultTime))秒)"
                        
                        if resultTime < getAimTime(area: areaRenge).second {
                            isClear = true
                            let score = (getAimTime(area: areaRenge).second - resultTime) / getAimTime(area: areaRenge).second * 10000
                            if getHighscore(area: areaRenge) < score && !isDebug {
                                setHighScore(area: areaRenge, score: score)
                            }
                            lastScore = score
                        }
                        
                    })
                Text("ペナルティ: \(String(format: "%.2f", additionalTime))秒")
                Text("総移動距離: \(String(format: "%.2f", resultDistance))m")
                    .onAppear(perform: {
                        for result in subResult {
                            resultDistance += result.distance
                        }
                    })
                Divider()
                Text("1回目 距離: \(String(format: "%.2f", subResult[0].distance))m, 時間: \(String(format: "%.2f", subResult[0].time))秒, 誤差: \(String(format: "%.2f", subResult[0].shift))m")
                Text("2回目 距離: \(String(format: "%.2f", subResult[1].distance))m, 時間: \(String(format: "%.2f", subResult[1].time))秒, 誤差: \(String(format: "%.2f", subResult[1].shift))m")
                Text("3回目 距離: \(String(format: "%.2f", subResult[2].distance))m, 時間: \(String(format: "%.2f", subResult[2].time))秒, 誤差: \(String(format: "%.2f", subResult[2].shift))m")
                Text("4回目 距離: \(String(format: "%.2f", subResult[3].distance))m, 時間: \(String(format: "%.2f", subResult[3].time))秒, 誤差: \(String(format: "%.2f", subResult[3].shift))m")
                Text("5回目 距離: \(String(format: "%.2f", subResult[4].distance))m, 時間: \(String(format: "%.2f", subResult[4].time))秒, 誤差: \(String(format: "%.2f", subResult[4].shift))m")
                Button("タイトルに戻る"){
                    screenState = .TITLE
                }
            }
        }
    }
    
    func generateRandomCoordinate(in region: MKCoordinateRegion) -> CLLocationCoordinate2D {
        let latMin = region.center.latitude - region.span.latitudeDelta / 2
        let latMax = region.center.latitude + region.span.latitudeDelta / 2
        let lonMin = region.center.longitude - region.span.longitudeDelta / 2
        let lonMax = region.center.longitude + region.span.longitudeDelta / 2
        
        let randomLatitude = Double.random(in: latMin...latMax)
        let randomLongitude = Double.random(in: lonMin...lonMax)
        
        return CLLocationCoordinate2D(latitude: randomLatitude, longitude: randomLongitude)
    }
    
    enum RelativeDirection: String {
        case front = "前方"
        case back = "後方"
        case leftFront = "左前方"
        case rightFront = "右前方"
    }
    
    func determineRelativeDirection(currentHeading: Double, targetBearing: Double) -> RelativeDirection {
        // 方位角の差を計算
        var angleDifference = targetBearing - currentHeading
        angleDifference = (angleDifference + 360).truncatingRemainder(dividingBy: 360) // 0〜360度に正規化
        
        if angleDifference > 180 {
            angleDifference -= 360 // -180〜180度の範囲に正規化
        }
        
        // 判定ロジック
        switch angleDifference {
        case -20...20:
            return .front
        case -90..<(-20):
            return .leftFront
        case 20...90:
            return .rightFront
        default:
            return .back
        }
    }
    
    func getDir() -> RelativeDirection{
        determineRelativeDirection(
            currentHeading: motionManager.direction,
            targetBearing: locationManager.calculateBearing(
                pos1: locationManager.center,
                pos2: targets[phase]).bearing
        )
    }
    
    func getAdditionalTime(area: Area) -> Double{
        switch area {
        case .near:
            60.0
        case .middle:
            300.0
        case .wide:
            1200
        case .hardcore:
            1800
        case .lunatic:
            5400
        }
    }
    
    func getClearDistance(area: Area) -> Double{
        switch area {
        case .near:
            5.0
        case .middle:
            25.0
        case .wide:
            100.0
        case .hardcore:
            100.0
        case .lunatic:
            100.0
        }
    }
    
    func getRangeMeter(area: Area) -> Double{
        switch area {
        case .near:
            20
        case .middle:
            100
        case .wide:
            1000
        case .hardcore:
            10000
        case .lunatic:
            100000
        }
    }
    
    func getRegion(center: CLLocationCoordinate2D , area: Area) -> MKCoordinateRegion{
        switch(areaRenge){
        case .near:
            MKCoordinateRegion(center: center, latitudinalMeters: 20, longitudinalMeters: 20)
        case .middle:
            MKCoordinateRegion(center: center, latitudinalMeters: 100, longitudinalMeters: 100)
        case .wide:
            MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        case .hardcore:
            MKCoordinateRegion(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
        case .lunatic:
            MKCoordinateRegion(center: center, latitudinalMeters: 100000, longitudinalMeters: 100000)
        }
    }
    
    func getHintText(area: Area, remain: Double) -> Distance{
        switch area {
        case .near:
            switch remain {
            case 0...7.5: Distance.veryClose
            case 7.5...10: Distance.close
            case 10...15: Distance.somewhatFar
            default: Distance.far
            }
        case .middle:
            switch remain {
            case 0...40: Distance.veryClose
            case 40...70: Distance.close
            case 70...125: Distance.somewhatFar
            default: Distance.far
            }
        case .wide:
            switch remain {
            case 0...200: Distance.veryClose
            case 200...350: Distance.close
            case 350...600: Distance.somewhatFar
            default: Distance.far
            }
        case .hardcore:
            switch remain {
            case 0...200: Distance.veryClose
            case 200...500: Distance.close
            case 500...1500: Distance.somewhatFar
            default: Distance.far
            }
        case .lunatic:
            switch remain {
            case 0...200: Distance.veryClose
            case 200...1000: Distance.close
            case 1000...3000: Distance.somewhatFar
            default: Distance.far
            }
        }
    }
    
    func getAimTime(area: Area) -> (label: String, second: Double){
        switch area {
        case .near:
            ("5分", 300)
        case .middle:
            ("20分", 1200)
        case .wide:
            ("1時間", 3600)
        case .hardcore:
            ("1.5時間", 5400)
        case .lunatic:
            ("12時間", 43200)
        }
    }
    
    func getHighscore(area: Area) -> Double{
        switch area{
        case .near:
            highscoreNear
        case .middle:
            highscoreMiddle
        case .wide:
            highscoreWide
        case .hardcore:
            highscoreHardcore
        case .lunatic:
            highscoreLunatic
        }
    }
    
    func setHighScore(area: Area, score: Double){
        switch area{
        case .near:
            highscoreNear = score
        case .middle:
            highscoreMiddle = score
        case .wide:
            highscoreWide = score
        case .hardcore:
            highscoreHardcore = score
        case .lunatic:
            highscoreLunatic = score
        }
    }
}

#Preview {
    ContentView()
}

enum Area: String, CaseIterable {
    case near = "20m圏内"
    case middle = "100m圏内"
    case wide = "1km圏内"
    case hardcore = "10km圏内"
    case lunatic = "100km圏内"
}

enum Distance: String {
    case veryClose = "かなり近いね！"
    case close = "近いね！"
    case somewhatFar = "まだ少し遠いね！"
    case far = "結構遠いね！"
}

