# GEP: Domestic Water Supply

**Objective:** Estimate the annual replacement cost of municipal raw-water provisioning for urban centres worldwide. The analysis compares the least-cost modeled supply portfolio for each city with the least-cost feasible portfolio available after the selected sources and their recorded shared-flow alternatives are removed.


## Descriptions:

The analysis uses 2025 urban centres and population-weighted centroids from [GHS-WUP-MTUC R2025A](https://human-settlement.emergency.copernicus.eu/ghs_wup_mtuc_r2025a.php). We estimate each city's annual municipal water demand by multiplying its population by its country's 2019 municipal withdrawal per capita from [FAO AQUASTAT](https://www.fao.org/aquastat/en/). These are estimated demands, not observations of each city's actual withdrawals.


+ Candidate river reaches, lakes and reservoirs come from RiverATLAS and LakeATLAS. We search within 100 km of each city, screen small sources and exclude proposed intake points inside mapped protected areas from the World Database on Protected Areas. A shortlist retains several kinds of river and lake alternatives and records source pairs that share a modeled flow path.
+ FABDEM, supplemented by Copernicus DEM GLO-30 where needed, provides elevations for cities and candidate intakes. Source distance, elevation difference, pipe design and city electricity price determine the surface-water cost options. The cost of a selected design includes annualized intake, pipeline and, where needed, pump-station construction and maintenance, plus electricity per cubic meter delivered.
+ For the 30% withdrawal scenario, a city's modeled annual source capacity is at most 30% of a river's mean annual flow or a lake or reservoir's mean outlet flow, converted to an annual volume. Groundwater costs and capacities come from the prepared city-level groundwater input. The city optimization meets estimated demand with the least-cost feasible mix of groundwater and compatible surface-water sources.
+ The main replacement scenario removes the sources used in that baseline portfolio and the recorded direct shared-flow conflict partners of selected surface-water sources. A separate sensitivity scenario removes only the selected source candidates. Each replacement model holds demand and cost assumptions fixed. Its additional annual cost is reported only when both the baseline and replacement portfolios are feasible. Missing input prices and infeasible portfolios are documented separately; undefined replacement costs are not treated as zero.


<br>

## Project layout

Create a `WaterUse_municipal` folder and clone this repository into a subfolder named `Code`. Place the separate `Data` folder beside `Code`, not inside it. In RStudio, the simplest setup is to create and open an RStudio project in `WaterUse_municipal` (the `.Rproj` file in the diagram). Before running the analysis, check that `here::here()` prints the path to `WaterUse_municipal`; the code uses `here("Data", ...)` to find inputs and outputs.

```text
WaterUse_municipal/
├── WaterUse_municipal.Rproj    # create here if using RStudio
├── Code/                       # clone this repository here
│   ├── README.md
│   ├── DataPrep/
│   └── Analysis/
└── Data/                       # input data and generated outputs
```

The `.Rproj` file is a convenient way to set the working directory in RStudio; it is not required for `here()` itself. If `here::here()` prints the `Code` folder instead, the paths to `Data` will be wrong. Start the R session from `WaterUse_municipal` and check again.


The scripts run in this order (script paths below are relative to `Code/`; `Data/` paths are relative to `WaterUse_municipal/`):

1. `DataPrep/1_population_center.qmd` — prepare urban centres and their representative locations.
2. `DataPrep/2_city_demand.qmd` — estimate city-level municipal water demand.
3. `DataPrep/3_get_electricity_price.qmd` — assign 2019 electricity prices to cities.
4. `DataPrep/4_1_identify_sw_source.qmd` — identify broad river, lake and reservoir candidates.
5. `DataPrep/4_2_surface_water_shortlist.qmd` — shortlist candidates and record shared-flow conflicts.
6. `DataPrep/5_1_elevation_updated.qmd` — extract and reuse elevations for cities and intake points.
7. `DataPrep/5_2_elevation_difference.qmd` — calculate source-to-city elevation differences.
8. `DataPrep/6_surface_water_cost_options.qmd` — calculate pipe-design capacities and fixed and variable surface-water costs. One run writes `Data/Analysis/city_surface_water_capacity_options_dr01.csv`, `_dr02.csv`, and `_dr03.csv` for 1%, 2%, and 3% discount rates.
9. `Analysis/run_discount_scenarios.R` — run `Analysis/7_city_water_cost_min.qmd`, `Analysis/8_selected_portfolio_replacement_cost.qmd`, and `Analysis/9_selected_portfolio_replacement_cost.qmd` in that order for each of the three discount rates. Step 7 finds the baseline least-cost supply portfolio; step 8 calculates the main shared-flow-path replacement scenario; step 9 calculates the selected-candidates-only sensitivity scenario. Both replacement scripts use the baseline outputs from step 7.
10. `Analysis/10_country_municipal_replacement_cost.qmd` — aggregate the main replacement results by country for all three rates. The 2% (`dr02`) case is the main result.

After completing steps 1–8, run the remaining steps from `WaterUse_municipal/` with R and Quarto installed and `quarto` on your `PATH`:

```sh
Rscript Code/Analysis/run_discount_scenarios.R
quarto render Code/Analysis/10_country_municipal_replacement_cost.qmd
```

The R runner checks that the three step 6 cost-option files exist before rendering steps 7–9. It writes rate-specific outputs to `Data/Analysis/dr01/`, `dr02/`, and `dr03/`; rendered Quarto reports go into a `quarto_output/` subfolder of each. The city-level baseline outputs are `x_city_municipal_water_supply_30.csv` and `x_city_surface_water_chosen_designs_30.csv`. The main replacement result is `y_city_shared_flowpath_replacement_30.csv`, and the sensitivity result is `z_city_selected_portfolio_replacement_30.csv`. Country summaries are saved under `Data/Results/dr01/`, `dr02/`, and `dr03/`. Country totals sum values only for cities with feasible baseline and replacement portfolios; the files also report coverage and reasons that other cities have no calculated value.

## Data and path notes

The scripts also obtain World Bank electricity-price data and FABDEM elevation tiles. The current files refer to both `Data/Raw` and `Data/raw`, and to both `Boundary` and `boundary`. Check these path spellings when running on a case-sensitive filesystem.
