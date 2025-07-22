#(C)Tsubasa Kato - 7/22/2025 - 23:35PM JST
#Used ChatGPT o3 & Perplexity Pro for coding this code.
#Some references from: https://www.jstage.jst.go.jp/article/jpssj/46/2/46_17/_pdf
# probabilistic_decision_model.mojo
import math
import random
from collections import List

# ---------- 1. Utility Functions ----------
fn linear_utility(x: Float64) -> Float64:
    """Linear utility function."""
    return x

fn log_utility(x: Float64) -> Float64:
    """Logarithmic utility (risk averse)."""
    if x <= 0:
        return -1000.0  # Large negative for invalid outcomes
    return math.log(x)

fn power_utility(x: Float64, gamma: Float64 = 0.5) -> Float64:
    """Power utility function (risk averse if gamma < 1)."""
    if x <= 0:
        return -1000.0
    return x ** gamma

# ---------- 2. Expected Utility Decision Model ----------
fn expected_utility_decision(
    outcomes: List[Float64],        # Possible outcome values
    probabilities: List[Float64],   # Associated probabilities
    utility_type: String = "linear"
) raises -> Float64:
    """Calculate expected utility for decision making."""
    if len(outcomes) != len(probabilities):
        raise Error("Outcomes and probabilities must have same length")
    
    var expected_utility: Float64 = 0.0
    var prob_sum: Float64 = 0.0
    
    for i in range(len(outcomes)):
        var prob = probabilities[i]
        var outcome = outcomes[i]
        prob_sum += prob
        
        var utility: Float64
        if utility_type == "log":
            utility = log_utility(outcome)
        elif utility_type == "power":
            utility = power_utility(outcome, 0.7)
        else:
            utility = linear_utility(outcome)
        
        expected_utility += prob * utility
    
    # Normalize if probabilities don't sum to 1
    if prob_sum > 0:
        expected_utility = expected_utility / prob_sum
    
    return expected_utility

# ---------- 3. Bayesian Decision Update ----------
struct BayesianDecisionModel:
    var prior_beliefs: List[Float64]
    var evidence_weight: Float64
    
    # Primary constructor
    fn __init__(out self, initial_beliefs: List[Float64], weight: Float64):
        self.prior_beliefs = initial_beliefs
        self.evidence_weight = weight
    
    # Overloaded constructor with default weight
    fn __init__(out self, initial_beliefs: List[Float64]):
        self.prior_beliefs = initial_beliefs
        self.evidence_weight = 1.0  # Default value
    
    fn update_beliefs(self, evidence: List[Float64]) raises -> List[Float64]:
        """Update beliefs using Bayesian inference."""
        if len(self.prior_beliefs) != len(evidence):
            raise Error("Prior beliefs and evidence must have same length")
        
        var updated_beliefs = List[Float64]()
        var normalization: Float64 = 0.0
        
        # Apply Bayes' rule: posterior ∝ prior × likelihood
        for i in range(len(self.prior_beliefs)):
            var posterior = self.prior_beliefs[i] * evidence[i] * self.evidence_weight
            updated_beliefs.append(posterior)
            normalization += posterior
        
        # Normalize to make probabilities sum to 1
        if normalization > 0:
            for i in range(len(updated_beliefs)):
                updated_beliefs[i] = updated_beliefs[i] / normalization
        
        return updated_beliefs


# ---------- 4. Multi-Criteria Decision Model ----------
fn multi_criteria_decision(
    alternatives: List[String],
    criteria_weights: List[Float64],
    criteria_scores: List[List[Float64]],  # scores[alternative][criterion]
    uncertainty_factor: Float64 = 0.1
) raises -> List[Float64]:
    """Make decisions considering multiple criteria with uncertainty."""
    if len(alternatives) == 0:
        raise Error("No alternatives provided")
    
    var decision_scores = List[Float64]()
    
    for alt_idx in range(len(alternatives)):
        var weighted_score: Float64 = 0.0
        var criteria_for_alt = criteria_scores[alt_idx]
        
        for crit_idx in range(len(criteria_weights)):
            var weight = criteria_weights[crit_idx]
            var score = criteria_for_alt[crit_idx]
            
            # Add uncertainty using simple random factor
            var uncertainty = (random.random_float64() - 0.5) * 2.0 * uncertainty_factor
            var adjusted_score = score * (1.0 + uncertainty)
            
            weighted_score += weight * adjusted_score
        
        decision_scores.append(weighted_score)
    
    return decision_scores

# ---------- 5. Probabilistic Logic Gates ----------
fn probabilistic_and(p1: Float64, p2: Float64, correlation: Float64 = 0.0) -> Float64:
    """Probabilistic AND with optional correlation."""
    return p1 * p2 + correlation * math.sqrt(p1 * (1-p1) * p2 * (1-p2))

fn probabilistic_or(p1: Float64, p2: Float64, correlation: Float64 = 0.0) -> Float64:
    """Probabilistic OR with optional correlation."""
    return p1 + p2 - probabilistic_and(p1, p2, correlation)

# ---------- 6. Demo: Intelligent Probabilistic Decision Making ----------
fn main() raises:
    print("=== Probabilistic Decision Model Demo ===\n")
    
    # 1. Expected Utility Comparison
    print("1. Expected Utility Decision:")
    var safe_outcomes = List[Float64]()
    safe_outcomes.append(100.0)
    var safe_probs = List[Float64]()
    safe_probs.append(1.0)
    
    var risky_outcomes = List[Float64]()
    risky_outcomes.append(0.0)
    risky_outcomes.append(300.0)
    var risky_probs = List[Float64]()
    risky_probs.append(0.7)
    risky_probs.append(0.3)
    
    var safe_utility = expected_utility_decision(safe_outcomes, safe_probs, "power")
    var risky_utility = expected_utility_decision(risky_outcomes, risky_probs, "power")
    
    print("Safe option utility:", safe_utility)
    print("Risky option utility:", risky_utility)
    if safe_utility > risky_utility:
        print("Optimal choice: Safe")
    else:
        print("Optimal choice: Risky")
    print("")
    
    # 2. Bayesian Decision Update
    print("2. Bayesian Belief Update:")
    var initial_beliefs = List[Float64]()
    initial_beliefs.append(0.3)
    initial_beliefs.append(0.4)
    initial_beliefs.append(0.3)  # Three hypotheses
    
    var model = BayesianDecisionModel(initial_beliefs, 1.2)
    
    var new_evidence = List[Float64]()
    new_evidence.append(0.8)
    new_evidence.append(0.2)
    new_evidence.append(0.5)  # Evidence favors hypothesis 1
    
    var updated = model.update_beliefs(new_evidence)
    print("Prior beliefs: [0.3, 0.4, 0.3]")
    print("Updated beliefs: [", updated[0], ",", updated[1], ",", updated[2], "]")
    print("")
    
    # 3. Multi-Criteria Decision with Uncertainty
    print("3. Multi-Criteria Decision (with uncertainty):")
    var alternatives = List[String]()
    alternatives.append("Option A")
    alternatives.append("Option B")
    alternatives.append("Option C")
    
    var weights = List[Float64]()
    weights.append(0.4)
    weights.append(0.35)
    weights.append(0.25)  # Cost, Quality, Risk weights
    
    # Scores for each alternative on each criterion
    var scores_a = List[Float64]()
    scores_a.append(0.8)
    scores_a.append(0.6)
    scores_a.append(0.9)  # Option A scores
    
    var scores_b = List[Float64]()
    scores_b.append(0.6)
    scores_b.append(0.9)
    scores_b.append(0.7)  # Option B scores
    
    var scores_c = List[Float64]()
    scores_c.append(0.7)
    scores_c.append(0.7)
    scores_c.append(0.8)  # Option C scores
    
    var all_scores = List[List[Float64]]()
    all_scores.append(scores_a)
    all_scores.append(scores_b)
    all_scores.append(scores_c)
    
    var final_scores = multi_criteria_decision(alternatives, weights, all_scores, 0.15)
    
    for i in range(len(alternatives)):
        print(alternatives[i], "score:", final_scores[i])
    
    print("")
    
    # 4. Probabilistic Logic
    print("4. Probabilistic Logic Gates:")
    var p_rain = 0.3
    var p_traffic = 0.4
    var correlation = 0.2  # Rain and traffic are positively correlated
    
    var p_both = probabilistic_and(p_rain, p_traffic, correlation)
    var p_either = probabilistic_or(p_rain, p_traffic, correlation)
    
    print("P(Rain) =", p_rain)
    print("P(Traffic) =", p_traffic)
    print("P(Rain AND Traffic) =", p_both)
    print("P(Rain OR Traffic) =", p_either)