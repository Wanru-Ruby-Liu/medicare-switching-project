# Medicare Plan Switching Among Assisted Living Residents: The Role of Memory Care 

This repository contains the code and synthetic data for a research project analyzing Medicare plan-switching behaviors among older adults who relocate to assisted living (AL) facilities. Specifically, the project explores transitions between Medicare Advantage (MA), Fee-for-Service (FFS), and switching within MA plans during the year following admission to AL.

The project is built using R, organized with modular scripts, and managed via GitHub and renv for full reproducibility. All data used are synthetic and modeled after real Medicare data, preserving the original variable names and relationships while ensuring privacy and compliance. This setup allows the entire analysis to be replicated by peers.

## Project Structure
- `data/`  
  Contains all raw synthetic datasets used for the project.

- `temp/`  
  Stores intermediate files generated during data processing. These files are not intended for final presentation but are necessary for running the pipeline.

- `output/`  
  Will contain final tables and figures included in the paper or presentation.

- `scripts/`  
  Modular R scripts used in each part of the pipeline.  
  └── `01_clean_data.R` — Performs all data import, merging, filtering, and variable creation.

- `main.R`  
  Master script that sequentially runs all scripts in the correct order.

- `renv/`  
  Package environment managed with `renv` to ensure reproducibility across machines.

- `README.md`  
  Project documentation describing the research question, datasets, and data processing steps.

## Datasets
All data files in the data/ folder are synthetic, preserving the structure and variable names of the original Medicare datasets.

- **ruby_adm_coho21.sas7bdat**: Contains all 2021 Medicare Beneficiary Summary File (MBSF) variables for beneficiaries admitted to AL in 2021.

- **all_hmo_mbsf21.sas7bdat**: Extends the 2021 MBSF data with select HMO variables from 2020 and 2022, and includes dementia indicators for both MA and FFS beneficiaries.

- **allmbsf20vars_coh21.sas7bdat**: Contains 2020 MBSF variables for the 2021 AL admission cohort.

- **new_al21.sas7bdat**: State-level AL memory care licensing data for 34 states, including indicators of whether each facility provides dementia care.

## Data Cleaning Workflow
1. The data cleaning pipeline is implemented in scripts/01_clean_data.R and is sourced by main.R. The following steps were executed:

2. Import and select relevant variables from the AL licensing dataset (new_al21.sas7bdat). Only FacilityID and the dementia indicator were retained.

3. Import 2020 MBSF data (allmbsf20vars_coh21.sas7bdat) and rename all variables (except the beneficiary ID) with a _20 suffix to prevent naming conflicts.

4. Import the extended 2021 MBSF dataset (all_hmo_mbsf21.sas7bdat) and merge it with the renamed 2020 variables using the beneficiary ID (bene_id_18900).

5. Merge dementia licensing data into the cohort based on FacilityID. Beneficiaries residing in facilities not matched to licensing data were excluded.

6. Restrict the sample to beneficiaries from 34 specified states, based on a numeric conversion of the hkstate variable.

7. Create indicators of enrollment status on January 1 of 2021 and 2022 using the hkhmo1 and hkhmo1_22 variables.

8. Identify and flag deaths occurring in 2021 using the date of death variable hkdod, and create an indicator for missing 2022 enrollment data.

9. Exclude individuals with missing 2022 status unless they died in 2021. A separate dataset (died_2021.csv) was saved for documentation.

10. Append back the decedent group to retain a full analytic sample, tagging those who died as "Died" in their 2022 status.

11. Construct Medicare switching categories, including MA-to-FFS, FFS-to-MA, within-MA switching, and non-switchers, based on changes in enrollment and MA plan codes (hkcptype01, hkcptype01_22).

12. Save the final cleaned analytic file as cleaned_2021.csv in the temp/ folder. This file will serve as input for the modeling and visualization steps.