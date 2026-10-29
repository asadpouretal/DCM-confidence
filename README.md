# DCM-confidence

Analysis code for:

> Asadpour, A., & Wong-Lin, K. (2025). **Effective connectivity predicts distributed neural coding of perceptual decision confidence, uncertainty, and speed.** *Imaging Neuroscience*, 3, imag_a_00441. https://doi.org/10.1162/imag_a_00441
> ([paper](https://direct.mit.edu/imag/article/doi/10.1162/imag_a_00441/126556/Effective-connectivity-predicts-distributed-neural))

## Purpose

Are decision confidence and choice-based reaction time (RT) carried by the same neural pathways? Using an open simultaneous EEG-fMRI dataset of a random-dot motion discrimination task with confidence ratings, the code:

1. runs an fMRI GLM (SPM12) to find active regions for **high vs. low confidence** and **fast vs. slow RT** trials;
2. uses those regions to build fMRI-informed **EEG dynamic causal models** (DCM for ERPs, canonical microcircuit model with SS, II, DP and SP populations);
3. compares models with random-effects Bayesian model selection and estimates group-level connection strengths with Parametric Empirical Bayes (PEB);
4. runs **trial-by-trial DCM** and relates the estimated neural population activity to behaviour with support vector regression (linear and Gaussian kernels), permutation importance, sensitivity analysis and bootstrapping.

## Data

Download the open dataset (Gherman & Philiastides) from OpenNeuro: https://openneuro.org/datasets/ds002739/versions/1.0.0. It has 24 participants; the paper analyses 23, and 17 of them (those with a significant confidence–RT correlation) in the main DCM analysis.

## Requirements

See `requirements.txt` (this is a MATLAB project, so there is nothing to `pip install`):
- MATLAB with the Statistics and Machine Learning Toolbox and Parallel Computing Toolbox (the paper used R2023a)
- [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
- [EEGLAB](https://sccn.ucsd.edu/eeglab/)

## How to run

1. Clone this repository.
2. Edit `getParameters.m`:
   - `params.main_dir`: folder containing the downloaded data (`sub-*` folders)
   - `params.spm_dir` and `params.EEGLAB_dir`: paths to SPM12 and EEGLAB
   - `params.numWorkers`: number of parallel workers
   - `params.total_subjects`: set to 23 for the full analysis (the default in the file is 2, a quick test)
   - the permutation and bootstrap settings (`num_permutations`, `number_of_important_feature_permutation`, `num_top_features`) are set low for testing; the file comments give the default values used for the paper (10000, 1250, 200)
3. Run the fMRI analysis:
   ```matlab
   main_script_for_fMRI
   ```
   This extracts events, preprocesses the fMRI data, and runs the contrasts for high-vs-low confidence and fast-vs-slow RT.
4. Run the EEG-DCM analysis:
   ```matlab
   main_script_for_EEG_DCM
   ```
   This runs the averaged ERP-DCM, Bayesian model selection and PEB, the estimated source activity, the trial-by-trial DCMs, the SVR analysis and the plotting.

Both scripts add `additional_files/`, `fMRI analysis/` and `EEG DCM analysis/` to the MATLAB path. Run them from the repository root. The full pipeline (DCM fitting especially) is computationally heavy.

## Repository layout

```
main_script_for_fMRI.m       fMRI pipeline entry point
main_script_for_EEG_DCM.m    EEG-DCM pipeline entry point
getParameters.m              all paths and analysis parameters
fMRI analysis/               event extraction, preprocessing, GLM contrasts
EEG DCM analysis/            ERP-DCM, BMS, PEB, trial-by-trial DCM, SVR, plotting
additional_files/            electrode locations, fiducials
```

## Results

Main findings (see the paper for figures and statistics):

- **Behaviour:** confidence ratings and RT were negatively correlated, with faster RTs for higher confidence. 17 of 23 participants showed a significant correlation.
- **Connectivity for confidence:** the fMRI-informed DCM found more frontoparietal connections for high confidence, with stronger forward connections from the lPreCUN and lMFG. Connections within the parietal cortex were stronger for low confidence.
- **Connectivity for RT:** fast RTs were associated with stronger connectivity in the frontal cortex, and slow RTs with stronger connectivity in the parietal cortex. The active regions differed from those for confidence, and only the lPreCUN was common to both. So confidence and speed appear to be supported by different networks.
- **Source activity:** estimated source activity was generally higher with higher confidence, except in the middle frontal gyrus, which may encode uncertainty.
- **Trial-by-trial DCM:** only nonlinear (Gaussian kernel) models showed significant correlations with behaviour. Layer-specific parietal populations coded confidence, uncertainty and RT: for example DP in the lPreCUN for objective confidence, and SS in the lSPL and DP in the rSPL for uncertainty. These deeper-layer populations do not contribute significantly to scalp EEG, so scalp-level analysis alone would miss them.

## How to cite

If you use this code, please cite:

> Asadpour, A., & Wong-Lin, K. (2025). Effective connectivity predicts distributed neural coding of perceptual decision confidence, uncertainty, and speed. *Imaging Neuroscience*, 3, imag_a_00441. https://doi.org/10.1162/imag_a_00441

```bibtex
@article{asadpour2025effective,
  title   = {Effective connectivity predicts distributed neural coding of perceptual decision confidence, uncertainty, and speed},
  author  = {Asadpour, Abdoreza and Wong-Lin, KongFatt},
  journal = {Imaging Neuroscience},
  volume  = {3},
  pages   = {imag_a_00441},
  year    = {2025},
  doi     = {10.1162/imag_a_00441}
}
```

Please also cite the original dataset (Gherman & Philiastides, OpenNeuro ds002739) and the SPM12 and EEGLAB toolboxes.
