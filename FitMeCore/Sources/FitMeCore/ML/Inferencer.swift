import Foundation

public enum Inferencer {
    public static func predict(model: MLPModel, input: [Float]) -> Float {
        var activations = input

        for layer in 0..<(model.dims.count - 1) {
            let inputSize = model.dims[layer]
            let outputSize = model.dims[layer + 1]
            var output = [Float](repeating: 0, count: outputSize)

            for j in 0..<outputSize {
                var sum = model.bias(neuron: j, layer: layer)
                for i in 0..<inputSize {
                    sum += activations[i] * model.weight(row: i, col: j, layer: layer)
                }
                let isLastLayer = (layer == model.dims.count - 2)
                output[j] = isLastLayer ? sigmoid(sum) : tanh(sum)
            }

            activations = output
        }

        return activations.first ?? 0
    }

    private static func sigmoid(_ x: Float) -> Float {
        if x < -50 { return 0 }
        if x > 50 { return 1 }
        return 1 / (1 + exp(-x))
    }

    private static func tanh(_ x: Float) -> Float {
        if x < -20 { return -1 }
        if x > 20 { return 1 }
        let e2x = exp(2 * x)
        return (e2x - 1) / (e2x + 1)
    }
}