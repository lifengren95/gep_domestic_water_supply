# GEP: water use

**Objective:** Estimate the annual replacement cost of municipal raw-water provisioning for urban centres worldwide. The analysis compares the least-cost modeled supply portfolio for each city with the least-cost feasible portfolio available after the selected sources and their recorded shared-flow alternatives are removed.


## Descriptions:

The analysis uses 2025 urban centres and population-weighted centroids from [GHS-WUP-MTUC R2025A](https://human-settlement.emergency.copernicus.eu/ghs_wup_mtuc_r2025a.php). We estimate each city's annual municipal water demand by multiplying its population by its country's 2019 municipal withdrawal per capita from [FAO AQUASTAT](https://www.fao.org/aquastat/en/). These are estimated demands, not observations of each city's actual withdrawals.


+ Candidate river reaches, lakes and reservoirs come from RiverATLAS and LakeATLAS. We search within 100 km of each city, screen small sources and exclude proposed intake points inside mapped protected areas from the World Database on Protected Areas. A shortlist retains several kinds of river and lake alternatives and records source pairs that share a modeled flow path.
+ FABDEM, supplemented by Copernicus DEM GLO-30 where needed, provides elevations for cities and candidate intakes. Source distance, elevation difference, pipe design and city electricity price determine the surface-water cost options. The cost of a selected design includes annualized intake, pipeline and, where needed, pump-station construction and maintenance, plus electricity per cubic meter delivered.
+ For the 30% withdrawal scenario, a city's modeled annual source capacity is at most 30% of a river's mean annual flow or a lake or reservoir's mean outlet flow, converted to an annual volume. Groundwater costs and capacities come from the prepared city-level groundwater input. The city optimization meets estimated demand with the least-cost feasible mix of groundwater and compatible surface-water sources.
+ The main replacement scenario removes the sources used in that baseline portfolio and the recorded direct shared-flow conflict partners of selected surface-water sources. A separate sensitivity scenario removes only the selected source candidates. Each replacement model holds demand and cost assumptions fixed. Its additional annual cost is reported only when both the baseline and replacement portfolios are feasible. Missing input prices and infeasible portfolios are documented separately; undefined replacement costs are not treated as zero.


<br>


The scripts run in this order:

1. `1_population_center.qmd` — prepare urban centres and their representative locations.
2. `2_city_demand.qmd` — estimate city-level municipal water demand.
3. `3_get_electricity_price.qmd` — assign 2019 electricity prices to cities.
4. `4_1_identify_sw_source.qmd` — identify broad river, lake and reservoir candidates.
5. `4_2_surface_water_shortlist.qmd` — shortlist candidates and record shared-flow conflicts.
6. `5_1_elevation_updated.qmd` — extract and reuse elevations for cities and intake points.
7. `5_2_elevation_difference.qmd` — calculate source-to-city elevation differences.
8. `6_surface_water_cost_options.qmd` — calculate pipe-design capacities and fixed and variable surface-water costs.
9. `7_city_water_cost_min.qmd` — find the baseline least-cost supply portfolio for each city.
10. `8_selected_portfolio_replacement_cost.qmd` — calculate the main shared-flow-path replacement scenario.
11. `9_selected_portfolio_replacement_cost.qmd` — calculate the selected-candidates-only sensitivity scenario. Both replacement scripts use the baseline outputs from `7_city_water_cost_min.qmd`.
12. `10_country_municipal_replacement_cost.qmd` — aggregate the main scenario by country.

The city-level baseline outputs are `Data/Analysis/x_city_municipal_water_supply_30.csv` and `Data/Analysis/x_city_surface_water_chosen_designs_30.csv`. The main replacement result is `Data/Analysis/y_city_shared_flowpath_replacement_30.csv`. The sensitivity result is `Data/Analysis/z_city_selected_portfolio_replacement_30.csv`. Country summaries are saved under `Data/Results/`. Country totals sum values only for cities with feasible baseline and replacement portfolios; the files also report coverage and reasons that other cities have no calculated value.


## Folder Structures:

To reproduce the municipal analysis, keep the scripts and input data in the following project structure. The QMD files use `here()` paths relative to the project root.

```text
.
├── README.md
├── 1_population_center.qmd
├── 2_city_demand.qmd
├── 3_get_electricity_price.qmd
├── 4_1_identify_sw_source.qmd
├── 4_2_surface_water_shortlist.qmd
├── 5_1_elevation_updated.qmd
├── 5_2_elevation_difference.qmd
├── 6_surface_water_cost_options.qmd
├── 7_city_water_cost_min.qmd
├── 8_selected_portfolio_replacement_cost.qmd
├── 9_selected_portfolio_replacement_cost.qmd
├── 10_country_municipal_replacement_cost.qmd
└── Data
    ├── Raw
    │   ├── GHS_WUP_MTUC_R2025A/
    │   ├── RiverATLAS/RiverATLAS_v10.gdb/
    │   ├── WDPA_Sep2026_Public/WDPA_Sep2026_Public.gdb/
    │   ├── Boundary/z_ee_r250_correspondence.gpkg
    │   └── boundary/z_ee_r250_correspondence.gpkg
    ├── raw
    │   ├── AQUASTAT/AQUASTAT_muni_withdrawal_per_capita.csv
    │   └── LakeATLAS/LakeATLAS_v10.gdb/
    ├── Processed
    │   └── FABDEM/
    ├── Analysis
    │   └── ghsl_cities_gw_cost_compressed_20260921.csv
    └── Results/
```

The scripts also obtain World Bank electricity-price data and FABDEM elevation tiles. The current files refer to both `Data/Raw` and `Data/raw`, and to both `Boundary` and `boundary`. Check these path spellings when running on a case-sensitive filesystem.
