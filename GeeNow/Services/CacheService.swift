import Foundation

actor CacheService {
    static let shared = CacheService()
    
    private let cacheDirectory: URL
    private let cacheExpiration: TimeInterval = 30 * 60
    
    private init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("GeeNowCache")
        
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func save<T: Codable>(_ data: T, forKey key: String) async throws {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        let cacheData = CacheWrapper(data: data, timestamp: Date())
        let encoded = try JSONEncoder().encode(cacheData)
        try encoded.write(to: fileURL)
    }
    
    func load<T: Codable>(forKey key: String, type: T.Type) async throws -> T? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        let wrapper = try JSONDecoder().decode(CacheWrapper<T>.self, from: data)
        
        if Date().timeIntervalSince(wrapper.timestamp) > cacheExpiration {
            try? FileManager.default.removeItem(at: fileURL)
            return nil
        }
        
        return wrapper.data
    }
    
    func clear() async {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func clearExpired() async {
        guard let files = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) else {
            return
        }
        
        let now = Date()
        for file in files {
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: file.path),
                  let modDate = attributes[.modificationDate] as? Date else {
                continue
            }
            
            if now.timeIntervalSince(modDate) > cacheExpiration {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}

private struct CacheWrapper<T: Codable>: Codable {
    let data: T
    let timestamp: Date
}
