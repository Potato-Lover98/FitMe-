import Foundation

public struct MLPModel: Sendable {
    public let dims: [Int]
    public let weights: [Float]

    public var numInputs: Int { dims.first ?? 0 }
    public var numOutputs: Int { dims.last ?? 0 }

    public func weightOffset(layer: Int) -> Int {
        var offset = 0
        for l in 0..<layer {
            offset += dims[l] * dims[l + 1]
        }
        return offset
    }

    public func biasOffset(layer: Int) -> Int {
        var totalWeights = 0
        for l in 0..<dims.count - 1 {
            totalWeights += dims[l] * dims[l + 1]
        }
        var offset = totalWeights
        for l in 0..<layer {
            offset += dims[l + 1]
        }
        return offset
    }

    public func weight(row: Int, col: Int, layer: Int) -> Float {
        // Weights stored row-major as [outputNeuron][inputNeuron] (nn.Linear layout).
        // row = input index, col = output index.
        let inputs = dims[layer]
        return weights[weightOffset(layer: layer) + col * inputs + row]
    }

    public func bias(neuron: Int, layer: Int) -> Float {
        return weights[biasOffset(layer: layer) + neuron]
    }
}

public enum ModelLoader {
    public enum LoadError: Error {
        case invalidFormat
        case unexpectedEndOfFile
    }

    public static func load(from url: URL) throws -> MLPModel {
        let data = try Data(contentsOf: url)
        var offset = 0

        let ndims = try data.extractUInt32(at: &offset)
        guard ndims >= 2 else { throw LoadError.invalidFormat }

        var dims: [Int] = []
        for _ in 0..<Int(ndims) {
            dims.append(Int(try data.extractUInt32(at: &offset)))
        }
        guard dims.allSatisfy({ $0 > 0 }) else { throw LoadError.invalidFormat }

        // Expected parameter count derived from layer dims (weights + biases).
        var expected = 0
        for l in 0..<(dims.count - 1) {
            expected += dims[l] * dims[l + 1] + dims[l + 1]
        }

        let numParams = Int(try data.extractUInt32(at: &offset))
        guard numParams > 0, numParams == expected else { throw LoadError.invalidFormat }
        // Overflow-safe bounds check.
        guard numParams <= (Int.max - offset) / 4,
              data.count >= offset + numParams * 4 else { throw LoadError.unexpectedEndOfFile }

        var params: [Float] = []
        params.reserveCapacity(numParams)
        for _ in 0..<numParams {
            params.append(try data.extractFloat32(at: &offset))
        }

        return MLPModel(dims: dims, weights: params)
    }

    public static func loadFromBundle(named resourceName: String = "FitMeML", withExtension ext: String = "bin") throws -> MLPModel {
        guard let url = Bundle.module.url(forResource: resourceName, withExtension: ext) else {
            throw LoadError.invalidFormat
        }
        return try load(from: url)
    }
}

private extension Data {
    func extractUInt32(at offset: inout Int) throws -> UInt32 {
        guard offset >= 0, count >= offset + 4 else {
            throw ModelLoader.LoadError.unexpectedEndOfFile
        }
        let value = self.withUnsafeBytes { ptr in
            ptr.loadUnaligned(fromByteOffset: offset, as: UInt32.self)
        }
        offset += 4
        return value
    }

    func extractFloat32(at offset: inout Int) throws -> Float {
        guard offset >= 0, count >= offset + 4 else {
            throw ModelLoader.LoadError.unexpectedEndOfFile
        }
        let value = self.withUnsafeBytes { ptr in
            ptr.loadUnaligned(fromByteOffset: offset, as: Float.self)
        }
        offset += 4
        return value
    }
}