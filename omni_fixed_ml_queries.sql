-- =====================================================================
-- FIXED OMNI DASHBOARD: Flash vs Pro ML Performance Metrics
-- =====================================================================
-- Table: scope3-dev.research_bs_monitoring.BA_monitoring_results
-- Generated: 2025-07-22T17:40:51.581107
-- FIXED: Handles flash_classification values of 0/100 instead of 0/1
-- =====================================================================

-- =====================================================================
-- 1. FIXED ML PERFORMANCE METRICS - KPIs
-- =====================================================================

-- KPI: F1-Score (FIXED for 0/100 flash values)
-- Chart Type: Big Number Card (0-1 scale, Green >0.8, Yellow 0.6-0.8, Red <0.6)
WITH ml_metrics AS (
  SELECT 
    CASE 
      WHEN flash_classification = 100 THEN 1 
      WHEN flash_classification = 0 THEN 0 
    END as flash_pred,
    CASE 
      WHEN pro_verdict = 'Aligned' THEN 1 
      WHEN pro_verdict = 'Not-Aligned' THEN 0 
    END as pro_truth
  FROM `scope3-dev.research_bs_monitoring.BA_monitoring_results`
  WHERE pro_verdict IS NOT NULL
    AND flash_classification IN (0, 100)
    AND created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
),
confusion_matrix AS (
  SELECT 
    SUM(CASE WHEN pro_truth = 1 AND flash_pred = 1 THEN 1 ELSE 0 END) as tp,
    SUM(CASE WHEN pro_truth = 0 AND flash_pred = 1 THEN 1 ELSE 0 END) as fp,
    SUM(CASE WHEN pro_truth = 1 AND flash_pred = 0 THEN 1 ELSE 0 END) as fn,
    SUM(CASE WHEN pro_truth = 0 AND flash_pred = 0 THEN 1 ELSE 0 END) as tn
  FROM ml_metrics
)
SELECT 
  CASE 
    WHEN (2 * tp + fp + fn) = 0 THEN 0
    ELSE ROUND(2 * tp / (2 * tp + fp + fn), 3) 
  END as f1_score
FROM confusion_matrix;

-- KPI: Precision (FIXED)
WITH ml_metrics AS (
  SELECT 
    CASE 
      WHEN flash_classification = 100 THEN 1 
      WHEN flash_classification = 0 THEN 0 
    END as flash_pred,
    CASE 
      WHEN pro_verdict = 'Aligned' THEN 1 
      WHEN pro_verdict = 'Not-Aligned' THEN 0 
    END as pro_truth
  FROM `scope3-dev.research_bs_monitoring.BA_monitoring_results`
  WHERE pro_verdict IS NOT NULL
    AND flash_classification IN (0, 100)
    AND created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
),
confusion_matrix AS (
  SELECT 
    SUM(CASE WHEN pro_truth = 1 AND flash_pred = 1 THEN 1 ELSE 0 END) as tp,
    SUM(CASE WHEN pro_truth = 0 AND flash_pred = 1 THEN 1 ELSE 0 END) as fp
  FROM ml_metrics
)
SELECT 
  CASE 
    WHEN (tp + fp) = 0 THEN 0
    ELSE ROUND(tp / (tp + fp), 3) 
  END as precision
FROM confusion_matrix;

-- KPI: Recall/TPR (FIXED)
WITH ml_metrics AS (
  SELECT 
    CASE 
      WHEN flash_classification = 100 THEN 1 
      WHEN flash_classification = 0 THEN 0 
    END as flash_pred,
    CASE 
      WHEN pro_verdict = 'Aligned' THEN 1 
      WHEN pro_verdict = 'Not-Aligned' THEN 0 
    END as pro_truth
  FROM `scope3-dev.research_bs_monitoring.BA_monitoring_results`
  WHERE pro_verdict IS NOT NULL
    AND flash_classification IN (0, 100)
    AND created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
),
confusion_matrix AS (
  SELECT 
    SUM(CASE WHEN pro_truth = 1 AND flash_pred = 1 THEN 1 ELSE 0 END) as tp,
    SUM(CASE WHEN pro_truth = 1 AND flash_pred = 0 THEN 1 ELSE 0 END) as fn
  FROM ml_metrics
)
SELECT 
  CASE 
    WHEN (tp + fn) = 0 THEN 0
    ELSE ROUND(tp / (tp + fn), 3) 
  END as recall_tpr
FROM confusion_matrix;

-- KPI: False Positive Rate (FIXED)
WITH ml_metrics AS (
  SELECT 
    CASE 
      WHEN flash_classification = 100 THEN 1 
      WHEN flash_classification = 0 THEN 0 
    END as flash_pred,
    CASE 
      WHEN pro_verdict = 'Aligned' THEN 1 
      WHEN pro_verdict = 'Not-Aligned' THEN 0 
    END as pro_truth
  FROM `scope3-dev.research_bs_monitoring.BA_monitoring_results`
  WHERE pro_verdict IS NOT NULL
    AND flash_classification IN (0, 100)
    AND created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
),
confusion_matrix AS (
  SELECT 
    SUM(CASE WHEN pro_truth = 0 AND flash_pred = 1 THEN 1 ELSE 0 END) as fp,
    SUM(CASE WHEN pro_truth = 0 AND flash_pred = 0 THEN 1 ELSE 0 END) as tn
  FROM ml_metrics
)
SELECT 
  CASE 
    WHEN (fp + tn) = 0 THEN 0
    ELSE ROUND(fp / (fp + tn), 3) 
  END as false_positive_rate
FROM confusion_matrix;

-- =====================================================================
-- 2. FIXED CONFUSION MATRIX - Detailed Breakdown
-- =====================================================================

-- Chart Type: Heatmap showing actual ML performance
WITH ml_metrics AS (
  SELECT 
    CASE 
      WHEN flash_classification = 100 THEN 'Flash: Aligned' 
      WHEN flash_classification = 0 THEN 'Flash: Not-Aligned'
    END as flash_decision,
    CASE 
      WHEN pro_verdict = 'Aligned' THEN 'Pro: Aligned' 
      WHEN pro_verdict = 'Not-Aligned' THEN 'Pro: Not-Aligned'
    END as pro_decision
  FROM `scope3-dev.research_bs_monitoring.BA_monitoring_results`
  WHERE pro_verdict IS NOT NULL
    AND flash_classification IN (0, 100)
    AND created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
)
SELECT 
  flash_decision,
  pro_decision,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage,
  -- Add ML labels
  CASE 
    WHEN flash_decision = 'Flash: Aligned' AND pro_decision = 'Pro: Aligned' THEN 'True Positive (TP)'
    WHEN flash_decision = 'Flash: Aligned' AND pro_decision = 'Pro: Not-Aligned' THEN 'False Positive (FP)'
    WHEN flash_decision = 'Flash: Not-Aligned' AND pro_decision = 'Pro: Aligned' THEN 'False Negative (FN)'
    WHEN flash_decision = 'Flash: Not-Aligned' AND pro_decision = 'Pro: Not-Aligned' THEN 'True Negative (TN)'
  END as ml_category
FROM ml_metrics
GROUP BY flash_decision, pro_decision
ORDER BY flash_decision, pro_decision;

-- =====================================================================
-- 3. FIXED ML METRICS TRENDS OVER TIME
-- =====================================================================

-- Chart Type: Multi-line Chart tracking F1, Precision, Recall daily
WITH daily_metrics AS (
  SELECT 
    DATE(created_at) as evaluation_date,
    CASE 
      WHEN flash_classification = 100 THEN 1 
      WHEN flash_classification = 0 THEN 0 
    END as flash_pred,
    CASE 
      WHEN pro_verdict = 'Aligned' THEN 1 
      WHEN pro_verdict = 'Not-Aligned' THEN 0 
    END as pro_truth
  FROM `scope3-dev.research_bs_monitoring.BA_monitoring_results`
  WHERE pro_verdict IS NOT NULL
    AND flash_classification IN (0, 100)
    AND created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
),
daily_confusion AS (
  SELECT 
    evaluation_date,
    SUM(CASE WHEN pro_truth = 1 AND flash_pred = 1 THEN 1 ELSE 0 END) as tp,
    SUM(CASE WHEN pro_truth = 0 AND flash_pred = 1 THEN 1 ELSE 0 END) as fp,
    SUM(CASE WHEN pro_truth = 1 AND flash_pred = 0 THEN 1 ELSE 0 END) as fn,
    SUM(CASE WHEN pro_truth = 0 AND flash_pred = 0 THEN 1 ELSE 0 END) as tn,
    COUNT(*) as total_predictions
  FROM daily_metrics
  GROUP BY evaluation_date
)
SELECT 
  evaluation_date,
  total_predictions,
  CASE WHEN (tp + fp) = 0 THEN 0 ELSE ROUND(tp / (tp + fp), 3) END as daily_precision,
  CASE WHEN (tp + fn) = 0 THEN 0 ELSE ROUND(tp / (tp + fn), 3) END as daily_recall,
  CASE WHEN (2 * tp + fp + fn) = 0 THEN 0 ELSE ROUND(2 * tp / (2 * tp + fp + fn), 3) END as daily_f1_score,
  CASE WHEN total_predictions = 0 THEN 0 ELSE ROUND((tp + tn) / total_predictions, 3) END as daily_accuracy,
  tp, fp, fn, tn
FROM daily_confusion
WHERE total_predictions >= 5
ORDER BY evaluation_date DESC;

-- =====================================================================
-- 4. FIXED ERROR ANALYSIS
-- =====================================================================

-- False Positives: Flash said Aligned (100) but Pro said Not-Aligned
SELECT 
  'False Positive' as error_type,
  artifact_id,
  data_source,
  flash_classification,
  pro_verdict,
  pro_confidence,
  created_at,
  SUBSTR(flash_reasoning, 1, 150) as flash_reasoning_excerpt,
  SUBSTR(pro_reasoning, 1, 150) as pro_reasoning_excerpt
FROM `scope3-dev.research_bs_monitoring.BA_monitoring_results`
WHERE flash_classification = 100 
  AND pro_verdict = 'Not-Aligned'
  AND created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
ORDER BY pro_confidence DESC
LIMIT 25;

-- False Negatives: Flash said Not-Aligned (0) but Pro said Aligned
SELECT 
  'False Negative' as error_type,
  artifact_id,
  data_source,
  flash_classification,
  pro_verdict,
  pro_confidence,
  created_at,
  SUBSTR(flash_reasoning, 1, 150) as flash_reasoning_excerpt,
  SUBSTR(pro_reasoning, 1, 150) as pro_reasoning_excerpt
FROM `scope3-dev.research_bs_monitoring.BA_monitoring_results`
WHERE flash_classification = 0 
  AND pro_verdict = 'Aligned'
  AND created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
ORDER BY pro_confidence DESC
LIMIT 25;

/*
=====================================================================
FIXED DASHBOARD SETUP NOTES:
=====================================================================

KEY FIX: Flash uses 0/100 instead of 0/1
- flash_classification = 100 means "Aligned" 
- flash_classification = 0 means "Not-Aligned"

CURRENT PERFORMANCE (from your data):
- Total Predictions: 108
- Accuracy: 0.509
- F1-Score: 0.293
- Precision: 0.204
- Recall: 0.524
- False Positive Rate: 0.494

CLASS DISTRIBUTION:
- Pro Aligned: 21 (19.4%)
- Pro Not-Aligned: 87 (80.6%)

CONFUSION MATRIX:
- True Positives (TP): 11
- False Positives (FP): 43
- True Negatives (TN): 44  
- False Negatives (FN): 10
*/
