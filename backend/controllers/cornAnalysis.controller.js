// controllers/cornAnalysisController.js
import { getAllCornAnalysis, getCornAnalysisByFieldId, getMostRecentAnalysis } from '../services/cornAnalysis.service.js';

// Get all corn analysis records
export async function getAllAnalysis(req, res) {
  try {
    const analyses = await getAllCornAnalysis();
    res.json(analyses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

// Get corn analysis by field ID
export async function getAnalysisByFieldId(req, res) {
  try {
    const analyses = await getCornAnalysisByFieldId(req.params.fieldId);
    res.json(analyses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}

// Get most recent corn analysis
export async function getRecentAnalysis(req, res) {
  try {
    const fieldId = req.query.fieldId || null;
    const analysis = await getMostRecentAnalysis(fieldId);
    
    if (!analysis) {
      return res.status(404).json({ message: 'No analysis found' });
    }
    
    res.json(analysis);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}
