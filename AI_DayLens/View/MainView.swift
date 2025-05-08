import SwiftUI
import SwiftData

enum LLMModel: String, CaseIterable {
    case deepseekV3 = "deepseek/deepseek-v3-base:free"
    case gemini = "google/gemini-2.0-flash-exp:free"
    case llama = "meta-llama/llama-4-maverick:free"

    var displayName: String {
        switch self {
        case .deepseekV3: return "DeepSeek V3"
        case .gemini: return "Gemini 2.0"
        case .llama: return "Llama 3"
        }
    }
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationView {
            VStack (alignment: .leading, spacing: 20) {
                // Header
                Text("AI DayLens ☀️")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Date & Weather
                HStack {
                    DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()

                    Spacer()
                    
                    Text("\(viewModel.weatherIcon) \(viewModel.temperature)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 5)

                // Prompt
                Text("💬 今天過得怎麼樣？")
                    .font(.headline)

                // User Input area
                TextEditor(text: $viewModel.userInput)
                    .frame(height: 120)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                // Model Selection
                HStack{
                    Spacer()
                    HStack(spacing: 12) {
                        ForEach(LLMModel.allCases, id: \.self) { model in 
                            Button(action: {
                                viewModel.selectedModel = model.rawValue                        
                            }) {
                                Text(model.displayName)
                                    .padding(8)
                                    .background(viewModel.selectedModel == model.rawValue ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    Spacer()
                }
                // .padding(.vertical)

                // Mic Button (not yet functional)
                HStack {
                    Spacer()
                    Button(action: {
                        // speech-to-text action placeholder
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Button(action: {
                        viewModel.analyzeInput()
                    }) {
                        Text("分析")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    Spacer()
                }

                // AI analysis result
                if viewModel.isLoading {
                    ProgressView("分析中...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let emotion = viewModel.emotion, let message = viewModel.message {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(viewModel.emojiForEmotion())\(emotion)")
                            .font(.title)
                        Text("✨ \(message)")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Save Button
                Button(action: {
                    viewModel.saveTodayEntry()
                }) {
                    Text("紀錄今天")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom, 10)
                .alert(isPresented: $viewModel.showOverwriteAlert) {
                    Alert(
                        title: Text("今天已經有紀錄了"), 
                        message: Text("是否要覆蓋今天的紀錄？"),
                        primaryButton: .default(Text("覆蓋")) {
                            viewModel.confirmOverwrite()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.modelContext = modelContext
        }
    }
}


// example 今天外面天氣大太陽，沒有下雨，心情還不錯，但是有個小不幸，就是我踩到便便，我差點想要把地球上的狗肛門給堵上。

// 皆是正面
/*
1. 今天陽光很好，早上順利趕上公車，午餐吃到想吃很久的拉麵，一整天心情都超級好。

2. 在書店意外撿到一本心儀很久的絕版書，回家路上又遇到彩虹，感覺自己被宇宙特別眷顧了。

3. 今天和朋友聊天聊到深夜，彼此笑到肚子痛，覺得能擁有這樣的友情真的很幸福。
*/

// 皆是負面
/*
1. 今天一早就睡過頭，趕著出門又弄丟了鑰匙，整個人煩躁到不行，什麼事情都不順。

2. 公司開會時被當眾指責，心裡難過又無力，感覺自己怎麼努力都不被看見。

3. 晚上的時候突然覺得好孤單，朋友圈裡像沒有人真正理解我，心裡冷得像空房間一樣。
*/
// 正負皆有
/*
1. 早上本來心情很好，順利趕完報告，但一打開信箱看到上司否決的回覆，心情瞬間跌到谷底。

2. 今天和爸媽一起吃飯很溫馨，但聊到未來的計畫時，發現我們的想法完全不一樣，內心有點失落。

3. 早上收到了夢寐以求的offer，開心到快飛起來，但後來得知需要離開熟悉的城市，有些猶豫，不過最後想到能追夢，還是覺得值得一試。

4. 今天一早心情超差，因為報告出了一堆錯，但下午努力趕上進度，心情好轉了些，結果晚上又因為小失誤被念了一頓，情緒又跌回谷底。

5. 看著朋友們一個個成家立業，心裡替他們高興又感到落寞，好像只有自己還在原地打轉。

6. 今天在社群上分享了自己的畫作，收到很多讚美也有些批評，心裡一方面覺得被肯定，一方面又有點懷疑自己的價值。
*/