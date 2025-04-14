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

  └── `02_table1_switching_patterns.R` — Generates switching pattern tables (Table 1 and 1b) by facility type.

  └── `03_figure1_sankey_data.R` — Prepares input and draws Figure 1: a four-level Sankey diagram of Medicare switching flows.

  └── `04_table2_dual_switching.R` - Generates Table 2 and Table 2b: switching patterns stratified by dual eligibility (both full cohort and switchers only).

  └── `05_table3_adrd_switching.R` — Generates Table 3: chi-square tests and summary statistics examining the relationship between ADRD status, facility type, and Medicare switching behavior. 

  └──  `06_table4_switching_by_adrd.R` — Generates Table 4: switching type distributions by ADRD status and 2022 enrollment outcome.

  └──  `07_table7_multinomial_regression.R` — Generates Table 7: multinomial logistic regression model of switching outcomes, using demographics, chronic conditions, and assisted living characteristics.

- `main.R`  
  Master script that sequentially runs all scripts in the correct order.

- `renv/`  
  Package environment managed with `renv` to ensure reproducibility across machines.

- `README.md`  
  Project documentation describing the research question, datasets, and data processing steps.

## Datasets
All data files in the data/ folder are synthetic, preserving the structure and variable names of the original Medicare datasets.

- **ruby_adm_coho21.sas7bdat**: Contains all 2021 Medicare Beneficiary Summary File (MBSF) variables for beneficiaries admitted to AL in 2021.

- **all_hmo_mbsf21.dta**: A 1/3 random sample of the full synthetic 2021 MBSF data, extended with select HMO variables from 2020 and 2022. Includes dementia indicators for both MA and FFS beneficiaries.

- **allmbsf20vars_coh21.dta**: A 1/3 random sample of the 2020 MBSF variables for the 2021 assisted living admission cohort. Filtered to match the sampled beneficiaries in `all_hmo_mbsf21.dta`.

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

## Output Description
### Table 1 & Table 1b – Switching Patterns by Facility Type
- `table1_nondementia_switching.csv`: Summary of switching outcomes for general assisted living (non-memory-care licensed) residents.
- `table1_dementia_switching.csv`: Summary of switching outcomes for memory care-licensed assisted living residents.
- `table1b_switcher_general_switching.csv`: Switching-only subgroup from general ALs.
- `table1b_switcher_mc_switching.csv`: Switching-only subgroup from memory care-licensed ALs.

### Figure 1 – Sankey Diagram of Medicare Switching Flows
- `figure1_sankey_links.csv`: Edge data for the four-level Sankey diagram.
- `figure1_sankey_nodes.csv`: Node label definitions (with counts and percentages).
- `figure1_sankey.html`: Interactive Sankey visualization showing transitions from total beneficiaries to AL type, Medicare plan type, and switching outcome.

### Table 2 & Table 2b – Switching by Dual Eligibility
- `table2_dual_switching.csv`: Switching patterns for dually eligible beneficiaries.
- `table2_nondual_switching.csv`: Switching patterns for non-dually eligible beneficiaries.
- `table2b_switcher_dual_switching.csv`: Dual switchers only.
- `table2b_switcher_nondual_switching.csv`: Non-dual switchers only.

### Table 3 – ADRD Status and Facility/Plan Associations
- `table3_adrd_dementia_AL.csv`: Summary table showing distribution of beneficiaries by ADRD status and memory care licensing.
- (Chi-square results are printed to the R console when the script is run.)

### Table 4 – Switching Outcomes by ADRD Status
- `table4_adrd_switching.csv`: Distribution of switching types among beneficiaries with ADRD.
- `table4_nonadrd_switching.csv`: Distribution of switching types among beneficiaries without ADRD.

### Table 7 – Multinomial Regression on Switching Behavior
- `table7_mlogit_results.csv`: Multinomial regression output reporting exponentiated coefficients (relative risk ratios) and confidence intervals. The base outcome is "Stayed in MA or FFS," and comparisons are made against switching behaviors (MA_to_FFS, FFS_to_MA, MA_switch).
