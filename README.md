# Gemini Judge Evaluation Pipeline

A comprehensive evaluation system that uses Google's Gemini models to judge and validate brand safety classifications from Gemini Flash decisions. The pipeline supports both Meta (social media) and Web datasets with multiple Gemini model variants.

## 🎯 Overview

This pipeline evaluates the quality of Gemini Flash's brand safety decisions by having more advanced Gemini models act as "judges". It processes large datasets from BigQuery, loads content from Google Cloud Storage, and saves detailed evaluation results back to BigQuery.

## 🏗️ Architecture

```
BigQuery Ground Truth → GCS Content Loading → Gemini Judge Evaluation → BigQuery Results
```

### Data Flow:
1. **Load Dataset**: Query BigQuery for ground truth data (Meta or Web)
2. **Content Retrieval**: Load actual content from GCS using URLs from dataset
3. **Judge Evaluation**: Use Gemini model to evaluate Flash's decisions
4. **Results Storage**: Save detailed analysis to BigQuery tables
5. **Dashboard Generation**: Create interactive HTML dashboards for analysis

## 📊 Available Pipelines

### Models Available:
- **Gemini 2.5 Pro**: Most advanced reasoning model (~$0.004/record)
- **Gemini 1.5 Flash**: Fast and cost-effective model (~$0.001/record)

### Datasets Supported:
- **Meta Dataset**: Social media content from `BA_Meta_Ground_Truth`
- **Web Dataset**: Web articles/pages from `BA_Web_Ground_Truth`

### 4 Complete Pipeline Combinations:

| Pipeline | Model | Dataset | Results Table | Use Case |
|----------|-------|---------|---------------|----------|
| `gemini_25_pro_meta.py` | Gemini 2.5 Pro | Meta | `BA_Meta_Gemini_25_Pro_Judge_Results_v2` | High-accuracy Meta evaluation |
| `gemini_25_pro_web.py` | Gemini 2.5 Pro | Web | `BA_Web_Gemini_25_Pro_Judge_Results_v2` | High-accuracy Web evaluation |
| `gemini_15_flash_meta.py` | Gemini 1.5 Flash | Meta | `BA_Meta_Gemini_15_Flash_Judge_Results` | Cost-effective Meta evaluation |
| `gemini_15_flash_web.py` | Gemini 1.5 Flash | Web | `BA_Web_Gemini_15_Flash_Judge_Results` | Cost-effective Web evaluation |

## 🚀 Quick Start

### Prerequisites

```bash
# Install required packages
pip install google-cloud-bigquery google-cloud-storage google-generativeai pandas numpy tqdm python-dotenv

# Set up authentication
gcloud auth application-default login
```

### Environment Setup

Create a `.env` file in your project directory:

```env
GEMINI_API_KEY=your_gemini_api_key_here
RESEARCH_BUCKET=your_research_bucket_name
```

### Running a Pipeline

```bash
# Example: Run Gemini 1.5 Flash on Meta dataset
python gemini_15_flash_meta.py

# Example: Run Gemini 2.5 Pro on Web dataset  
python gemini_25_pro_web.py
```

## 🔧 Features

### Robust Processing
- **Retry Logic**: 3-attempt retry with exponential backoff for both content loading and API calls
- **Error Handling**: Graceful failure handling with detailed error logging
- **Batch Processing**: Processes data in configurable batches (default: 50 records)
- **Progress Tracking**: Real-time progress bars and statistics

### Content Processing
- **Multi-format Support**: Handles structured JSON content from GCS
- **Text Extraction**: Extracts text from paragraphs, headings, and metadata
- **Image Detection**: Identifies and catalogues image content (text-only evaluation currently)
- **Fallback Handling**: Uses demo content when GCS loading fails

### Comprehensive Evaluation
Each evaluation includes:
- **Agreement Analysis**: Whether the judge agrees with Flash's decision
- **Confidence Scoring**: Judge's confidence level (0.0-1.0)
- **Detailed Reasoning**: Explanation of the judge's decision
- **Improvement Suggestions**: Recommendations for better classification
- **Model Comparison**: Analysis comparing Flash vs Judge capabilities

### BigQuery Integration
- **Automatic Table Creation**: Creates result tables with proper schema
- **Continuous Saves**: Saves results after each batch (no data loss)
- **Clean Schema**: Optimized table structure without unnecessary NULL fields
- **Timestamp Tracking**: Full audit trail of processing times

## 📈 Monitoring & Results

### Real-time Monitoring
- **Batch Progress**: Live updates on processing status
- **Agreement Rates**: Real-time calculation of judge agreement
- **API Usage**: Token consumption and cost estimation
- **Error Tracking**: Detailed error reporting and retry attempts

### Query Results
```sql
-- View recent results
SELECT * FROM `scope3-dev.research_bs_monitoring.BA_Meta_Gemini_15_Flash_Judge_Results` 
ORDER BY created_at DESC LIMIT 100;

-- Agreement rate analysis
SELECT 
  flash_classification,
  COUNT(*) as total_records,
  AVG(CAST(judge_agreement AS INT64)) as agreement_rate,
  AVG(confidence) as avg_confidence
FROM `scope3-dev.research_bs_monitoring.BA_Meta_Gemini_15_Flash_Judge_Results`
GROUP BY flash_classification;
```

## 📊 Omni HTML Dashboard Integration

The pipeline includes **Omni HTML Dashboard** generation for interactive analysis reports.

### Key Features:
- **Interactive HTML Dashboards**: Professional analysis reports with ML metrics
- **Multi-Dataset Support**: Meta, Web, and Combined dataset analysis
- **Complete ML Metrics**: F1-Score, Confusion Matrix, Agreement Analysis, Performance Assessment
- **Responsive Design**: Works on desktop, tablet, and mobile devices

### Dashboard Generation:
```python
# Automatic dashboard creation after evaluation
dashboard_filename = pipeline.create_omni_html_dashboard(meta_results, web_results, combined_results)

# Standalone analysis tool for existing results
analyzer = GeminiPro15OmniAnalysis()
results, dashboard_file = analyzer.run_complete_analysis()
```

### What You Get:
- **Performance Metrics**: Accuracy, F1-Score, Precision, Recall with color-coded assessment
- **Confusion Matrix**: Visual breakdown of True/False Positives/Negatives
- **Agreement Analysis**: 4-category breakdown of judge vs Flash agreement patterns
- **Technical Summary**: Complete statistical breakdown for detailed analysis
- **Cross-Dataset Comparison**: Side-by-side performance across Meta and Web datasets

### Usage:
1. Run any evaluation pipeline - dashboard auto-generates
2. Use standalone analyzer for existing BigQuery results
3. Open HTML file in browser for interactive analysis
4. Export sections as needed for reports

*Dashboard code available in repository with examples for customization.*

## 💰 Cost Optimization

### Model Cost Comparison:
| Model | Input Cost | Output Cost | Recommended For |
|-------|------------|-------------|-----------------|
| Gemini 1.5 Flash | $0.00000075/token | $0.0000015/token | Large-scale evaluation |
| Gemini 2.5 Pro | $0.00000125/token | $0.00000375/token | Critical accuracy needs |

### Cost-Saving Tips:
1. **Start with 1.5 Flash** for initial evaluation
2. **Use batch processing** to minimize API overhead
3. **Monitor token usage** with built-in tracking
4. **Leverage retry logic** to avoid duplicate processing

## 🔍 Result Schema

Each evaluation produces comprehensive results:

```json
{
  "artifact_id": "unique_identifier",
  "flash_classification": 0,
  "flash_reasoning": "Original Flash decision reasoning",
  "judge_agreement": true,
  "verdict": "Aligned",
  "confidence": 0.95,
  "reasoning": "Judge's detailed analysis",
  "improvements": ["suggestion1", "suggestion2"],
  "api_call_time": 2.3,
  "retry_attempts": 1,
  "created_at": "2025-07-25T18:00:00Z"
}
```

## 🛠️ Configuration

### Pipeline Settings:
```python
# Configurable parameters
PROJECT_ID = "scope3-dev"
DATASET_ID = "research_bs_monitoring"
BATCH_SIZE = 50  # Records per batch
MAX_RETRIES = 3  # Retry attempts
GEMINI_MODEL_NAME = "gemini-1.5-flash"  # or "gemini-2.5-pro"
```

### Safety Settings:
All models run with safety blocks disabled for comprehensive content evaluation.

## 🚨 Error Handling

### Common Issues & Solutions:

**BigQuery Connection Issues:**
```bash
gcloud auth application-default login
gcloud config set project scope3-dev
```

**GCS Access Problems:**
- Verify storage client permissions
- Check bucket names in dataset
- Confirm GCS URLs are valid

**API Rate Limits:**
- Automatic retry with exponential backoff
- Batch size can be reduced if needed
- Built-in delay mechanisms

## 📝 Logging & Debugging

### Log Levels:
- **✅ Success**: Successful operations and completions
- **⚠️ Warning**: Retries and fallback operations
- **❌ Error**: Failed operations with details
- **📊 Stats**: Real-time metrics and progress

### Debug Mode:
Detailed logging shows:
- GCS URL parsing
- Content extraction results
- API request/response times
- Token usage per call
- Retry attempt details

## 🔄 Development Workflow

### Testing:
```python
# Test with small dataset first
results, summary = main_evaluation(test_mode=True, test_limit=10)

# Run full dataset after validation
results, summary = main_evaluation(test_mode=False)
```

### Adding New Models:
1. Update `GEMINI_MODEL_NAME` configuration
2. Adjust pricing in cost estimation
3. Modify prompt templates if needed
4. Update result table schema if required

## 🤝 Contributing

### Code Structure:
- **Pipeline Classes**: Main evaluation logic
- **Content Extraction**: GCS and JSON processing
- **BigQuery Integration**: Table management and saves
- **API Management**: Gemini calls with retry logic
- **Dashboard Generation**: HTML report creation

### Best Practices:
- Always test with small datasets first
- Monitor API costs during development
- Use descriptive logging for debugging
- Validate BigQuery schemas before deployment



### Performance Optimization:
- Adjust batch sizes based on API limits
- Use appropriate model for accuracy needs
- Monitor retry patterns for system issues
- Scale processing based on dataset size

---

## 📈 Dashboard Examples

The pipeline includes advanced dashboard capabilities with **Omni HTML** technology:

### Sample Dashboard Features:
- **Real-time Agreement Tracking**: Live updates of judge vs Flash agreement rates
- **Cost Analytics**: Token usage and cost breakdown by model and dataset
- **Performance Heatmaps**: Visual representation of agreement patterns
- **Temporal Analysis**: Trends over time for model performance
- **Interactive Filters**: Drill-down by classification type, confidence level, or error patterns
- **Export Capabilities**: PDF, PNG, and data export functionality
- **Responsive Design**: Works on desktop, tablet, and mobile devices

