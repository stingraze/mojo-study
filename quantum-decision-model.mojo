# quantum_decision_model.mojo
import math
from collections import List

# ---------- 1. Classical Law‑of‑Total‑Probability ----------
fn classical_LTP(
    Pb1: Float64, Pb2: Float64,
    Pa_given_b1: Float64, Pa_given_b2: Float64
) -> Float64:
    return Pb1 * Pa_given_b1 + Pb2 * Pa_given_b2


# ---------- 2. Quantum‑like LTP (with interference) ----------
fn quantum_LTP(
    Pb1: Float64, Pb2: Float64,
    Pa_given_b1: Float64, Pa_given_b2: Float64,
    theta: Float64            # phase in radians
) -> Float64:
    var interference = math.sqrt(Pb1 * Pb2 * Pa_given_b1 * Pa_given_b2) * math.cos(theta)
    return classical_LTP(Pb1, Pb2, Pa_given_b1, Pa_given_b2) + interference


# ---------- 3. Support: Euclidean norm -----------------------
fn vector_norm(v: List[Float64]) -> Float64:
    var acc: Float64 = 0.0
    for i in range(len(v)):
        var x = v[i]
        acc += x * x
    return math.sqrt(acc)


# ---------- 4. Neural‑population Ψ (optional) ----------------
fn neural_population_Psi(
    px: List[Float64], py: List[Float64],
    c1: Float64, c2: Float64,
    theta: Float64
) raises -> Float64:
    if len(px) != len(py):
        raise Error("Vector size mismatch")

    var nx = vector_norm(px)
    var ny = vector_norm(py)

    return (
        c1 * c1 * nx * nx +
        c2 * c2 * ny * ny +
        2.0 * c1 * c2 * nx * ny * math.cos(theta)
    )


# ---------- 5. Demo / quick sanity check --------------------
fn main() raises:
    var Pb1: Float64 = 0.5
    var Pb2: Float64 = 0.5
    var Pa_b1: Float64 = 0.2
    var Pa_b2: Float64 = 0.8
    var theta: Float64 = math.pi / 3.0     # 60°

    print("Classical  P(a) =", classical_LTP(Pb1, Pb2, Pa_b1, Pa_b2))
    print("Quantum    P(a) =", quantum_LTP(Pb1, Pb2, Pa_b1, Pa_b2, theta))

    var px = List[Float64]()
    px.append(0.9)
    px.append(1.0)
    px.append(1.1)

    var py = List[Float64]()
    py.append(0.4)
    py.append(0.5)
    py.append(0.6)

    var psi = neural_population_Psi(
        px, py,
        math.sqrt(Pb1), math.sqrt(Pb2),
        theta
    )
    print("Neural‑population Ψ =", psi)