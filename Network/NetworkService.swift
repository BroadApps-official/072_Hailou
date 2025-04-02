import Foundation
import UIKit
import ApphudSDK

enum VideoSource: String, Codable {
    case api1
    case api2
}

struct Filter: Codable {
    let id: Int
    let title: String
    var preview: String
    let previewSmall: String

    enum CodingKeys: String, CodingKey {
        case id, title, preview
        case previewSmall = "preview_small"
    }
}

struct FiltersResponse: Decodable {
    let error: Bool
    let messages: [String]
    let data: [Filter]
}

struct GeneratedVideo: Codable {
    var id: String
    let prompt: String?
    var isFinished: Bool
    var videoURL: String?
    let source: VideoSource
    var name: String?

    var cacheURL: URL {
        return CacheManager.shared.generatedVideosDirectory.appendingPathComponent("\(id).mp4")
    }

    init(id: String, prompt: String?, isFinished: Bool, source: VideoSource, name: String? = nil) {
        self.id = id
        self.prompt = prompt
        self.isFinished = isFinished
        self.source = source
        self.name = name
    }
    
    init(from response: GenerationStatusResponse.Data, source: VideoSource, name: String? = nil) {
        self.id = String(response.id)
        self.prompt = response.prompt
        self.isFinished = response.status == 3
        self.videoURL = response.result
        self.source = source
        self.name = name
    }
}

struct GenerationResponse: Decodable {
    struct Data: Decodable {
        let id: Int
    }
    let data: Data
}

struct GenerationStatusResponse: Decodable {
    struct Data: Decodable {
        let id: Int
        let status: Int
        let prompt: String?
        let photo: String
        let result: String?
    }
    let data: Data
}

import Foundation
import ApphudSDK

final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    private let filtersBaseURL = "https://futuretechapps.shop/filters"
    private let generateBaseURL = "https://futuretechapps.shop/generate"
    private let appId = Bundle.main.bundleIdentifier ?? "com.test.test"
    private let token = "0e9560af-ab3c-4480-8930-5b6c76b03eea"
    
    private let promptURL = URL(string: "https://backend.viewprotech.shop")!
    private let promptToken = "bb05e887-82a8-4801-b09f-2b8d10dca121"

    func fetchFilters() async throws -> [Filter] {
        if let cachedFilters = CacheManager.shared.loadFiltersFromCache() {
            return cachedFilters
        }

        guard var urlComponents = URLComponents(string: filtersBaseURL) else {
            throw URLError(.badURL)
        }

        let userId = await Apphud.userID()
        
        urlComponents.queryItems = [
            URLQueryItem(name: "appId", value: appId),
            URLQueryItem(name: "userId", value: userId)
        ]

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("Error: Failed to get HTTP respons")
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode != 200 {
            let responseString = String(data: data, encoding: .utf8) ?? "Нет данных"
            print("Error: Server returned status \(httpResponse.statusCode), response: \(responseString)")
            throw URLError(.badServerResponse)
        }

        let filtersResponse = try JSONDecoder().decode(FiltersResponse.self, from: data)
        print("Received raw data: \(String(data: data, encoding: .utf8) ?? "failed to convert to string")")
        
        if filtersResponse.error {
            throw NSError(domain: "APIError", code: 1, userInfo: [NSLocalizedDescriptionKey: filtersResponse.messages.joined(separator: ", ")])
        }

        CacheManager.shared.saveFiltersToCache(filters: filtersResponse.data)
        let updatedFilters = await withTaskGroup(of: Filter?.self) { group in
            var tempFilters: [Filter] = []

            for filter in filtersResponse.data {
                group.addTask {
                    var updatedFilter = filter

                    guard let videoURL = URL(string: updatedFilter.preview) else { return updatedFilter }

                    do {
                        let videoData = try await self.downloadVideo(from: videoURL)
                        let videoFileName = "\(updatedFilter.id)_preview.mp4"
                        let videoPath = try CacheManager.shared.saveVideoToCache(videoData: videoData, fileName: videoFileName)
                        updatedFilter.preview = videoPath
                    } catch {
                        print("Error loading video for filter \(updatedFilter.id): \(error.localizedDescription)")
                    }

                    return updatedFilter
                }
            }

            for await updatedFilter in group {
                if let filter = updatedFilter {
                    tempFilters.append(filter)
                }
            }

            return tempFilters
        }

        CacheManager.shared.saveFiltersToCache(filters: updatedFilters)
        return updatedFilters
    }

    private func downloadVideo(from url: URL) async throws -> Data {
        let (videoData, _) = try await URLSession.shared.data(from: url)
        return videoData
    }
    
    /// Getting Generation Id for .api2
    func generateVideo(from image: UIImage, filterID: String?) async throws -> Int {
        guard let url = URL(string: generateBaseURL) else {
            throw URLError(.badURL)
        }

        let userId = await Apphud.userID()
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let imageData = image.jpegData(compressionQuality: 0.8)
        guard let imageData else {
            throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"appId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(appId)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"userId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)

        if let filterID = filterID {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"filter_id\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(filterID)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Request failed"])
        }

        let decodedResponse = try JSONDecoder().decode(GenerationResponse.self, from: data)
        let generationId = decodedResponse.data.id

        print("Video Generation ID: \(generationId)")
        return generationId
    }

    /// Getting Generation Status for .api2
    func getGenerationStatus(generationId: Int) async throws -> GenerationStatusResponse.Data {
        guard var components = URLComponents(string: "https://futuretechapps.shop/generation/\(generationId)") else {
            throw URLError(.badURL)
        }

        let userId = await Apphud.userID()
        components.queryItems = [
            URLQueryItem(name: "appId", value: appId),
            URLQueryItem(name: "userId", value: userId)
        ]

        guard let finalURL = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP status: \(httpResponse.statusCode)")
        }

        if let rawResponse = String(data: data, encoding: .utf8) {
            print("RAW RESPONSE: \(rawResponse)")
        } else {
            print("Response is not UTF-8")
        }

        let decodedResponse = try JSONDecoder().decode(GenerationStatusResponse.self, from: data)

        if decodedResponse.data.status == 3 {
            _ = try await downloadVideoFileFromAPI2(generationData: decodedResponse.data)
        }

        return decodedResponse.data
    }

    func downloadVideoFileFromAPI2(generationData: GenerationStatusResponse.Data) async throws -> URL {
        guard let resultURLString = generationData.result, let resultURL = URL(string: resultURLString) else {
            throw NSError(domain: "NetworkService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid video URL from API2"])
        }

        let (data, response) = try await URLSession.shared.data(from: resultURL)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "NetworkService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Downloading video error"])
        }

        let videoFileURL = CacheManager.shared.generatedVideosDirectory.appendingPathComponent("\(generationData.id).mp4")

        do {
            try data.write(to: videoFileURL)

            let videoModel = GeneratedVideo(from: generationData, source: .api2)
            CacheManager.shared.saveGeneratedVideoModel(videoModel)

            print("Video saved for API2: \(videoFileURL)")
            return videoFileURL
        } catch {
            throw error
        }
    }

    /// Create Generation Task for .api1
    func createVideoTask(imagePath: String?, userId: String, appBundle: String, prompt: String) async throws -> String {
        let url = promptURL.appendingPathComponent("/video")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(promptToken, forHTTPHeaderField: "access-token")
        request.addValue("application/json", forHTTPHeaderField: "accept")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()

        func addFormField(named name: String, value: String) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        let schema = """
        {"prompt": "\(prompt)", "image_url": "\(imagePath ?? "")", "user_id": "\(userId)", "app_bundle": "\(appBundle)"}
        """
        addFormField(named: "schema", value: schema)

        if let imagePath = imagePath, let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) {
            let fileName = URL(fileURLWithPath: imagePath).lastPathComponent
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status-code: \(httpResponse.statusCode)")
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                throw NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Incorrect HTTP response"])
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("Response Data: \(jsonResponse)")
            }

            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let videoId = json?["id"] as? String else {
                throw NSError(domain: "NetworkService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Incorrect response format"])
            }

            return videoId

        } catch {
            print("Request error: \(error.localizedDescription)")
            throw error
        }
    }

    /// Check Generation Status for .api1
    func checkVideoTaskStatus(videoId: String) async throws -> [String: Any] {
        let url = promptURL.appendingPathComponent("/video/\(videoId)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(promptToken, forHTTPHeaderField: "access-token")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP status-code: \(httpResponse.statusCode)")
        } else {
            print("Response is not HTTPResponse: \(response)")
        }
        
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) {
            print("Response Data: \(jsonResponse)")
        }

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Incorrect HTTP response"])
        }

        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        if let isInvalid = json?["is_invalid"] as? Bool, isInvalid {
             if let comment = json?["comment"] as? String {
                 print("Error: \(comment)")
             }
             throw NSError(domain: "NetworkService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Image failed moderation"])
         }
        
        return json ?? [:]
    }
    
    /// Downloading Video-file for .api1
    func downloadVideoFile(videoId: String, prompt: String) async throws -> URL {
        let url = promptURL.appendingPathComponent("/video/file/\(videoId)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(promptToken, forHTTPHeaderField: "access-token")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP status-code: \(httpResponse.statusCode)")
        }

        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) {
            print("Response Data: \(jsonResponse)")
        } else {
            print("Failed to serialize response data.")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "NetworkService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Downloading video error"])
        }
    
        let videoFileURL = CacheManager.shared.generatedVideosDirectory.appendingPathComponent("\(videoId).mp4")

        do {
            try data.write(to: videoFileURL)

            let videoModel = GeneratedVideo(id: videoId, prompt: prompt, isFinished: true, source: .api1)
            CacheManager.shared.saveGeneratedVideoModel(videoModel)
            
            return videoFileURL
        } catch {
            throw error
        }
    }
}

// MARK: - Data Extension
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
