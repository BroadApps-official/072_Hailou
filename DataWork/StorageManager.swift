import Disk
import UIKit

final class StorageManager: NSObject {
    static let shared = StorageManager()
    private var completion: ((Bool) -> Void)?

    private let fileManager = FileManager.default
    private let generatedVideosFileName = "generated_video_cache.json"
    let generatedVideosDirectory: URL
    private var generatedVideosFileURL: URL {
        return generatedVideosDirectory.appendingPathComponent("generated_video_cache.json")
    }

    override private init() {
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        generatedVideosDirectory = documentsDir.appendingPathComponent("generatedVideos")
        try? fileManager.createDirectory(at: generatedVideosDirectory, withIntermediateDirectories: true, attributes: nil)
        super.init()
    }

    // MARK: - Filters

    /// Save filters in cache
    func saveFiltersToCache(filters: [Filter]) {
        do {
            try Disk.save(filters, to: .caches, as: "filters.json")
            print("Filters succesfully saved in cache.")
        } catch {
            print("Filters saving error: \(error)")
        }
    }

    /// Load filters from cache
    func loadFiltersFromCache() -> [Filter]? {
        do {
            return try Disk.retrieve("filters.json", from: .caches, as: [Filter].self)
        } catch {
            print("Filters loading error: \(error)")
        }
        return nil
    }

    /// Save video in cache
    func saveVideoToCache(videoData: Data, fileName: String) throws -> String {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        try videoData.write(to: fileURL)

        return fileURL.path
    }

    /// Load video URL from cache
    func loadVideoURLFromCache(fileName: String) -> URL? {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    // MARK: - GeneratedVideo

    /// Saving GeneratedVideo in cache
    func saveGeneratedVideoModel(_ video: GeneratedVideo) {
        do {
            var videos = loadGeneratedVideos()
            if let index = videos.firstIndex(where: { $0.id == video.id }) {
                videos[index] = video
            } else {
                videos.append(video)
            }

            try Disk.save(videos, to: .documents, as: generatedVideosFileName)
            print("Video model succesfully saved in cache.")
        } catch {
            print("Video model saving error: \(error)")
        }
    }

    /// Loading GeneratedVideo
    func loadGeneratedVideos() -> [GeneratedVideo] {
        do {
            return try Disk.retrieve(generatedVideosFileName, from: .documents, as: [GeneratedVideo].self)
        } catch {
            print("Video model loading error: \(error)")
            return []
        }
    }

    /// Loading Video
    func getVideo(for model: GeneratedVideo) -> URL? {
        do {
            let videos = try Disk.retrieve(generatedVideosFileName, from: .documents, as: [GeneratedVideo].self)

            if let video = videos.first(where: { $0.id == model.id }) {
                let videoFileURL = StorageManager.shared.generatedVideosDirectory.appendingPathComponent("\(video.id).mp4")
                return videoFileURL
            } else {
                print("No video whith model id: \(model.id)")
                return nil
            }
        } catch {
            print("Video model loading error: \(error)")
            return nil
        }
    }

    /// Deleting Video and Model
    func deleteVideoModel(_ video: GeneratedVideo) {
        do {
            var videos = loadGeneratedVideos()

            if let index = videos.firstIndex(where: { $0.id == video.id }) {
                videos.remove(at: index)
                try Disk.save(videos, to: .documents, as: generatedVideosFileName)
                print("Video Model whith id \(video.id) succesfully deleted frome cache.")
            } else {
                print("Video Model whith id \(video.id) not found in cache.")
            }

            let videoFileURL = StorageManager.shared.generatedVideosDirectory.appendingPathComponent("\(video.id).mp4")
            if FileManager.default.fileExists(atPath: videoFileURL.path) {
                try FileManager.default.removeItem(at: videoFileURL)
                print("Video file whith id \(video.id) succesfully deleted frome cache.")
            } else {
                print("Video file whith id \(video.id) not found in cache.")
            }

        } catch {
            print("Video model and file deleting error: \(error)")
        }
    }

    /// Saving Video in Gallery
    func saveVideoToGallery(videoURL: URL, completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: videoURL.path) {
            self.completion = completion
            UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            print("Video file does not exist at path: \(videoURL.path)")
            completion(false)
        }
    }

    @objc private func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving video: \(error.localizedDescription)")
            completion?(false)
        } else {
            print("Video saved successfully to gallery.")
            completion?(true)
        }
        completion = nil
    }

    /// Deleting all GeneratedVideo and videos
    func clearAllGeneratedVideosAndCache() {
        do {
            var videos = loadGeneratedVideos()
            videos.removeAll()

            try Disk.save(videos, to: .documents, as: generatedVideosFileName)
            print("All Video Models deleted.")

            for video in videos {
                let videoFileURL = generatedVideosDirectory.appendingPathComponent("\(video.id).mp4")
                if FileManager.default.fileExists(atPath: videoFileURL.path) {
                    try FileManager.default.removeItem(at: videoFileURL)
                    print("Video file whith id \(video.id) succesfully deleted frome cache.")
                } else {
                    print("Video Model whith id \(video.id) not found in cache.")
                }
            }
        } catch {
            print("All Video model and file deleting error: \(error)")
        }
    }
}
