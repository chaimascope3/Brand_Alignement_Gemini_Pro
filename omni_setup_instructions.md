# Flash vs Pro Performance Dashboard Setup

## Quick Start Guide

### 1. Omni Data Source Setup
1. In Omni, go to **Data Sources** → **Add New**
2. Select **BigQuery** 
3. Enter connection details:
   - Project ID: `scope3-dev`
   - Dataset: `research_bs_monitoring`
   - Primary Table: `BA_monitoring_results`
4. Test connection and save

### 2. Create Dashboard
1. **Dashboards** → **Create New**
2. Name: "Flash vs Pro Performance Monitor"
3. Connect to your BigQuery data source

### 3. Add Charts (Use queries from omni_dashboard_queries.sql)

#### Row 1: KPI Cards (4 across)
- **Agreement Rate**: Big Number, format %, color rules (Green ≥80%, Yellow 70-80%, Red <70%)
- **Total Evaluations**: Big Number, format number
- **Average Confidence**: Big Number, format decimal(2)  
- **Disagreement Count**: Big Number, format number, color red

#### Row 2: Trends (2 across)
- **Agreement Over Time**: Line chart, X=date, Y=agreement_rate_percent
- **Performance by Source**: Horizontal bar chart

#### Row 3: Analysis (2 across)  
- **Confidence Distribution**: Column chart, group by confidence_bin
- **Classification Matrix**: Heatmap, Flash vs Pro decisions

#### Row 4: Details (full width)
- **Recent Disagreements**: Interactive table with drill-down

### 4. Configure Filters
Add dashboard-level filters:
- **Date Range**: Date picker (default: last 30 days)
- **Data Source**: Multi-select dropdown (Meta, Web)
- **Agreement Status**: Select dropdown (All, Agree, Disagree)

### 5. Set Up Alerts
- **Low Agreement**: Trigger when daily rate < 75%
- **High Disagreements**: Trigger when daily count > 10

### 6. Dashboard Settings
- **Auto-refresh**: Every 15 minutes
- **Permissions**: Set view/edit access for team
- **Export**: Enable PDF/PNG export options

## Current Data Summary
- **Total Records**: 108
- **Table**: `scope3-dev.research_bs_monitoring.BA_monitoring_results`
- **Last Updated**: 2025-07-22 15:33:20

## Color Scheme
- 🟢 **Excellent**: ≥90% agreement
- 🟡 **Good**: 80-89% agreement  
- 🟠 **Moderate**: 70-79% agreement
- 🔴 **Poor**: <70% agreement

## Support
- SQL Queries: Use omni_dashboard_queries.sql
- Configuration: Reference omni_dashboard_config.json
- Issues: Check BigQuery permissions and table access

---
Generated automatically on 2025-07-22T15:33:20.603985
