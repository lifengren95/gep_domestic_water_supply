# GHSL City-Level Groundwater Cost and Capacity

*Construction and interpretation note for coauthors — revised 6 October 2026 for discount-rate sensitivity*

## 1) Cost and Capacity of Groundwater per City

We link urban centers in `uc_2025_with_electricity_price.csv` to Superwell groundwater extraction simulations, then construct groundwater cost and capacity variables for each of six scenarios. The revised coauthor-facing dataset has **12,140 cities, 83 columns, and one unique `urban_id` per row**: 17 city/electricity/spatial-match fields and 66 groundwater fields. Each scenario retains the five original variables and adds six unit-cost variables: nonenergy and total groundwater unit costs at each of **2%, 1%, and 3%** annual discount rates. Original variables follow `<variable>_<scenario>`; adjusted variables follow `<variable>_<scenario>_<rate>`, where `<rate>` is `2pcdr`, `1pcdr`, or `3pcdr`. The rate suffix is appended at the end. Scenario suffixes are listed in Section 2.2. [^project]

**Revision scope.** The updated script is `E:/research/gep/wateruse/2026_aug/code/calc_ghsl_citylevel_gwcost_withnear_fallback_2pcdr_20261006.R`. It supplies the requested primary 2% cost case and 1% and 3% sensitivities. The original Superwell capital annualization rate of 10% is retained in cost columns without a discount-rate suffix. The adjustment changes the annualized capital component and then reconstructs nonenergy and total costs.

**Files.** Both outputs are saved under `E:/research/gep/wateruse/2026_aug/data/`:

- **Coauthor/optimization file:** `ghsl_cities_gw_cost_compressed_2pcdr_20261006.csv` contains city attributes, electricity prices, spatial-match fields, and eleven derived `gw_*` variables per scenario. The filename identifies the primary 2% case; the same file also contains original 10% costs and the 1% and 3% sensitivities.
- **Detailed source file:** `uc_2025_with_electricity_price_superwell_earliest_nearest_2pcdr_20261006.csv` retains scenario-specific Superwell variables, adjusted annual capital/nonenergy/total costs, and source grid/year/method/distance. The revised script saves this file **after** adding the derived `gw_*` columns. Join it to the compressed file using `urban_id` when provenance or annual cost components are needed.
- **Audit files:** `uc_2025_superwell_fallback_audit_2pcdr_20261006.csv`, `uc_2025_superwell_fallback_summary_2pcdr_20261006.csv`, and `uc_2025_superwell_geometry_audit_2pcdr_20261006.csv` document scenario matching and polygon preparation. [^project]

**City-to-grid construction.** The R workflow uses `data.table`, `sf`, and `s2`. City `lon`/`lat` are treated as WGS84 coordinates, transformed to the grid shapefile's CRS, and matched to `inputs_recharge_plus_lakes.shp`. Its identifier, `GrdClID`, becomes `grid_id`. Interior matches are checked first, then boundary matches; ambiguous matches are not forced. The resulting crosswalk places **11,860 cities within a grid and 280 outside the polygons**. [^project]

For each scenario independently, the record-selection order is **own-grid year 1 → own-grid earliest available year ≥ 1 → nearest eligible grid's earliest available year**. The neighbor must have a scenario record and a valid polygon within **100 km**, measured from the city point to the polygon rather than its centroid. This cutoff is a processing choice, not a hydrogeological threshold. Donors are not restricted to the same country or basin. Polygons that remain invalid after repair are excluded from neighbor searches, without removing same-grid CSV records. [^project]

A fallback copies one complete source record, including its discount-rate variants; it does not mix variables across grids or years. Unresolved records remain `NA`. Missing capital or maintenance components propagate to adjusted nonenergy and total costs. The physical `grid_id` is never overwritten. The detailed file records `source_grid_id_<scenario>`, `source_year_<scenario>`, `source_method_<scenario>`, and `source_distance_km_<scenario>`; these are **not retained in the compressed file**. [^project]

### 1.1) Cost

For city *i* and scenario *s*, let **V** be the selected `volume_produced_allwells`, **E** its `energy`, **C_NE** its original `nonenergy_cost`, and **p_i** the recipient city's `electricity_price_2019usd_kwh`. The following original, unsuffixed cost columns retain Superwell's **10% capital annualization assumption**: [^project]

| Variable, before adding `_<scenario>` | Calculation | Units and meaning |
|---|---|---|
| `gw_energy_intensity_kwh_m3` | `E / V` | kWh/m³; physical pumping electricity requirement |
| `gw_nonenergy_unit_cost_usd_m3` | `C_NE / V` | USD/m³; capital annualized at 10%, plus maintenance |
| `gw_energy_cost_2019_usd_m3` | `(E / V) * p_i` | USD/m³; electricity component at the city's 2019 price |
| **`gw_unit_cost_2019_usd_m3`** | **`(C_NE / V) + (E / V) * p_i`** | **USD/m³; groundwater production unit-cost input** |

Ratios are calculated only when `V` is nonmissing and positive. A missing electricity price leaves energy cost and total cost missing, even when pumping intensity and non-energy cost are available. Costs are never filled with zero. [^project]

We **replace**, rather than add to, the original Superwell electricity-cost component. Even for a neighboring-grid record, the recipient city's electricity price is used. The resulting total is an **average production unit cost**, which may be adopted as a fixed optimization coefficient; it is not an estimated marginal-cost curve. Its scope is groundwater extraction, not treatment, conveyance, or urban distribution. [^project] [^paper]

**Price-year qualification.** The `_2019_` name identifies the electricity-price vintage. The script does not rebase Superwell capital or maintenance costs to 2019. Therefore, describe the total as *groundwater production cost using 2019 electricity prices*, rather than claiming that every component is verified in constant 2019 USD. [^project]

### 1.1.1) Capital annualization at 2%, 1%, and 3%

Superwell annualizes capital over a **20-year well/loan lifetime**. We retain that term and change the annual rate. For rate *r* and lifetime *L* = 20 years, the capital-recovery factor is: [^paper] [^project]

$
\operatorname{CRF}(r,L) = \frac{r(1+r)^L}{(1+r)^L-1} = \frac{r}{1-(1+r)^{-L}}.
$

Let \(C_{K,is}^{10\%}\) be the exported grid-wide annual capital cost and \(C_{M,is}\) the exported grid-wide annual maintenance cost for the selected source record. For each alternative rate:

$
C_{K,is}^{r} = C_{K,is}^{10\%}\frac{\operatorname{CRF}(r,20)}{\operatorname{CRF}(0.10,20)},
\qquad r \in \{0.02,\ 0.01,\ 0.03\},
$

$
C_{NE,is}^{r} = C_{K,is}^{r} + C_{M,is}.
$

**Maintenance is added at its original annual amount.** The multiplier applies only to annual capital cost. Physical electricity requirements, recipient electricity prices, groundwater volumes, and source grid/year selections are retained.

| Annual rate | Column suffix | CRF over 20 years | Multiplier on original annual capital cost |
|---|---|---:|---:|
| 10% (original) | No rate suffix | 0.1174596 | 1.0000000 |
| 2% (primary revised case) | `_2pcdr` | 0.0611567 | 0.5206616 |
| 1% (sensitivity) | `_1pcdr` | 0.0554153 | 0.4717818 |
| 3% (sensitivity) | `_3pcdr` | 0.0672157 | 0.5722452 |

These factors reduce the **annual capital payment**. The reduction in total nonenergy or groundwater production cost depends on the shares of maintenance and electricity. This procedure changes capital annualization; it does not calculate a project's net present value.

The adjusted city unit costs are:

$
c_{NE,is}^{r} = \frac{C_{NE,is}^{r}}{V_{is}},
\qquad
c_{GW,is}^{r} = \frac{C_{NE,is}^{r}}{V_{is}} + \frac{E_{is}}{V_{is}}p_i.
$

For each scenario, the compressed file adds six columns:

| Added variable | Meaning |
|---|---|
| `gw_nonenergy_unit_cost_usd_m3_<scenario>_2pcdr` | Capital annualized at 2% plus original maintenance, divided by annual grid volume |
| `gw_unit_cost_2019_usd_m3_<scenario>_2pcdr` | 2% nonenergy unit cost plus city-priced electricity unit cost |
| `gw_nonenergy_unit_cost_usd_m3_<scenario>_1pcdr` | Capital annualized at 1% plus original maintenance, divided by annual grid volume |
| `gw_unit_cost_2019_usd_m3_<scenario>_1pcdr` | 1% nonenergy unit cost plus city-priced electricity unit cost |
| `gw_nonenergy_unit_cost_usd_m3_<scenario>_3pcdr` | Capital annualized at 3% plus original maintenance, divided by annual grid volume |
| `gw_unit_cost_2019_usd_m3_<scenario>_3pcdr` | 3% nonenergy unit cost plus city-priced electricity unit cost |

The detailed file also adds rate-suffixed versions of `annual_capital_cost`, `nonenergy_cost`, `total_cost_allwells`, `total_cost_perwell`, `unit_cost`, `unit_cost_per_km3`, and `unit_cost_per_acreft` for each scenario. Source `total_cost_*` and `unit_cost*` variants retain **Superwell's original electricity cost**. Use the derived `gw_unit_cost_2019_usd_m3_<scenario>_<rate>` columns for total costs with the **recipient city's electricity price**. Maintenance and installation-cost fields have no duplicate rate columns because their annual amounts and upfront costs are unchanged. [^project]

The script calculates these variants on each scenario's earliest available source record before city matching. Scaling an exported annual capital total by a common CRF ratio also covers accumulated replacement and deepening loans **provided every contributing loan uses the same 20-year term and original 10% rate**. It retains the modeled replacement/deepening schedules. Before adjustment, the script checks that observed nonenergy cost equals capital plus maintenance and verifies first-year capital against per-well installation cost × well count × CRF(10%, 20). [^project]

Adjusted unit costs require finite, positive volume. Missing capital or maintenance leaves adjusted nonenergy cost missing; missing city electricity price leaves adjusted total cost missing. Valid zero capital or maintenance is retained as zero. The price-year qualification above applies equally to all rate-suffixed columns: **changing the discount rate does not rebase monetary components to 2019**.

### 1.2) Capacity

The annual groundwater capacity variable is shared across all discount-rate cases:

```text
gw_capacity_m3_year_<scenario> = volume_produced_allwells_<scenario>
```

This is the **grid-wide volume produced during the selected model year**, expressed as an annual supply/capacity proxy. It is not cumulative production, `available_volume` in aquifer storage, or observed municipal pumping. The script copies the volume without scaling by city population or area, multiplying by DL, or extrapolating to 365 pumping days. The annual interpretation includes the model's assumed pumping schedule. [^project] [^overview]

**Do not count shared groundwater repeatedly.** Multiple cities can inherit the same grid's entire volume; consequently, city capacities are not automatically additive. Before using them as independent supply limits, allocate grid resources among cities or impose shared resource constraints. A nearest-grid match is a proxy for missing local information, not evidence of a physical water-transfer connection or a separately available resource.

Capacity is also **not a demonstrated sustainable yield or guaranteed long-term municipal supply**. These data retain one pumping year, and fallback years can differ. Use matching scenario suffixes for cost and capacity, and consult the detailed provenance before comparing scenarios or imposing resource constraints.

## 2) Details about Superwell Data We Used

The supplied repository overview describes `superwell_outputs.7z` as six global CSV files totaling approximately 6.3 GB, with extraction volumes and costs over grid-cell pumping lifetimes at a nominal **0.5° scale**. Filenames follow `superwell_py_deep_C_*_B_*_G_*_<PD>PD_<DL>DL_<RR>RR.csv`; C, B, and G identify country, basin, and grid filters. The global files use `all` for these filters. The 100-point sample and grid-72548 example are illustrative subsets, not the source of global city coverage. The separately published aquifer inputs have DOI `10.57931/2484226`. [^overview]

The explanations below combine the supplied output descriptions with the public Python implementation and parameter file. The hydrological and source-cost descriptions retain the original upstream assumptions; Section 1.1.1 describes the downstream 2%, 1%, and 3% capital annualization adjustment. **These are documented upstream formulas/defaults, not an independently verified run manifest for all six local CSVs.** The supplied single-grid example provides a numerical consistency check; the exact parameter file used to generate the full archive was not attached. [^code] [^params] [^sample]

### 2.1) Variables We Used: Assumptions and Calculations

**Aquifer properties and well hydraulics.** Superwell represents within-grid aquifer conditions using permeability, porosity, thickness, water-table depth, and recharge. It uses a Theis-based drawdown calculation, neighboring-well interference, and a Jacob correction for changing saturated thickness. Pumping rates are selected subject to drawdown constraints; wells may deepen and pumping rates may change. This is a model of hypothetical extraction conditions, not an inventory of existing city wells. [^paper]

**Important unit clarification.** Some labels in the supplied overview differ from the Python exports. The inspected code and sample use **m²** for grid/lake/well-service areas, **m³/s** for `well_yield`, a **0–1 fraction** for `porosity`, and **log10(intrinsic permeability in m²)** for `permeability`. Hydraulic conductivity and transmissivity are in **m/s** and **m²/s**, respectively. These distinctions matter when reproducing the calculations; the city script itself uses the already exported energy, cost, and volume totals. [^code] [^sample]

**Key upstream defaults** are 100 pumping days per year, pump efficiency **0.70**, water specific weight **9,800 N/m³**, a **20-year** well lifetime, **10%** annual interest, and maintenance at **7%** of installation cost. The revised city processing additionally annualizes the capital component at **2%, 1%, and 3%**, while retaining the physical and maintenance assumptions. Initial modeled saturated well penetration is capped at 200 m, with 50 m deepening increments. These are model assumptions, not city-specific measurements. [^params]

**Annual production and number of wells.** Let *q* be per-well yield in m³/s, *d* pumping days/year, *A_dry* grid area excluding lakes, and *D_net* the recharge-adjusted ponded-depth target. In the implementation: [^code]

```text
volume_produced_perwell = q × 86,400 × d
areal_extent           = volume_produced_perwell / D_net
number_of_wells         = A_dry / areal_extent
volume_produced_allwells = volume_produced_perwell × number_of_wells
```

`number_of_wells` is an equivalent modeled count and need not be an integer. By substitution, grid production is `A_dry × D_net`; it reflects the scenario target over the grid's modeled service area, not a city-demand calculation. In contrast, `available_volume` is initial saturated aquifer thickness × dry area × porosity: a storage stock, not an annual flow. [^code]

**Pumping electricity.** `total_head` is water-table depth plus modeled average corrected drawdown. In the inspected Python output, `drawdown` already includes the interference contribution before correction, so `drawdown_interference` should not be added again. For *N* equivalent wells, head *H* in meters, specific weight *γ*, and efficiency *η*, the implemented grid totals are: [^code]

```text
power  [kW]  = N × γ × H × q / (1,000 × η)
energy [kWh] = power × (24 × d)
```

Dividing by the corresponding grid volume gives:

$$
\frac{E}{V}=\frac{\gamma H}{3.6\times10^6\eta}\quad\text{kWh/m³}.
$$

Thus pumping intensity increases with lift and decreases with efficiency. The exported `energy` already accounts for all wells and efficiency; neither factor is applied again in the city calculation. In the supplied grid-72548 year-1 example, `H = 117.13 m` and `E/V = 0.4555 kWh/m³`, consistent with efficiency 0.70; `energy/power = 2,400 hours`, consistent with 100 pumping days. [^sample]

**Capital and maintenance.** `well_installation_cost` is per-well installed depth multiplied by an aquifer-class drilling cost. Default rates are approximately USD 82/m for WHY class 10, USD 164/m for class 20, and USD 50/m for the remaining category. [^params] Capital is annualized using the recovery factor `r(1+r)^L / [(1+r)^L − 1]`, with default *r* = 0.10 and *L* = 20 years. Maintenance is 7% of the applicable installation cost annually. The implementation accumulates costs across wells, replacements, and deepening. [^code]

The exported `annual_capital_cost` and `maintenance_cost` are grid totals, and `nonenergy_cost` is their sum. Consequently, the original **`nonenergy_cost / volume_produced_allwells` needs no further multiplication by well count or annualization**. For a new discount-rate case, we adjust the already annualized capital total once using the CRF ratio in Section 1.1.1, add the original annual maintenance total, and divide by volume. We do not annualize installation cost again or multiply grid totals by well count again. The original `unit_cost` includes Superwell's own electricity rate; our derived `gw_unit_cost_2019_usd_m3` uses the city's electricity price. [^code] [^project]

### 2.2) Scenarios and Recommended Baseline

**PD** is the annual ponded-depth pumping target, **DL** is the specified depletion-limit fraction of available groundwater, and **RR = 0.2** assigns 20% of recharge to the shallow response. Although the overview calls RR a shallow-to-deep ratio, the code implements it as a **share of total recharge**. With the default 0.75 threshold, `D_net = PD − min(0.2 × recharge, 0.75 × PD)`; remaining and excess recharge contribute to the deep component, whose imposed volume is capped at annual pumping. Recharge is already incorporated upstream and is not added again to city capacity. [^overview] [^code] [^params]

| Scenario suffix | PD (m/year) | DL |
|---|---:|---:|
| `0.3PD_0.05DL_0.2RR` | 0.3 | 5% |
| **`0.3PD_0.25DL_0.2RR`** | **0.3** | **25%** |
| `0.3PD_0.4DL_0.2RR` | 0.3 | 40% |
| `0.6PD_0.05DL_0.2RR` | 0.6 | 5% |
| `0.6PD_0.25DL_0.2RR` | 0.6 | 25% |
| `0.6PD_0.4DL_0.2RR` | 0.6 | 40% |

DL is **not an annual withdrawal fraction**. The exported `depleted_vol_fraction` tracks cumulative pumped volume divided by initial available volume; it is a realized model ratio, not automatically equal to the DL target. With recharge, it should not be read directly as net physical storage loss. [^code]

**Recommended reference case: `0.3PD_0.25DL_0.2RR`.** We propose the lower pumping target and middle depletion limit as a transparent starting point, retaining the other five scenarios for sensitivity analysis. This matches the moderate-depletion benchmark used for diagnostics and global maps in the Superwell paper. It is a reference modeling choice, **not evidence that 25% depletion is sustainable everywhere or that this is the best-fitting scenario for every city**. [^paper]

For this hydrological baseline and the requested **2% capital annualization case**, the optimization-facing pair is:

```text
gw_unit_cost_2019_usd_m3_0.3PD_0.25DL_0.2RR_2pcdr
gw_capacity_m3_year_0.3PD_0.25DL_0.2RR
```

Use the corresponding `_1pcdr` and `_3pcdr` total-cost columns for discount-rate sensitivities and the unsuffixed total-cost column for the original 10% comparison. All four cases use the same capacity column. The 2% choice is the study's requested financing assumption; it does not alter the physical PD/DL/RR scenario.

Compare alternative scenarios using a common set of cities and examine source grid/year changes. Because only the first available pumping year is retained, this dataset does not preserve the full lifetime cost–depletion trajectory.

---

**Sources and verification**

[^project]: Project script `E:/research/gep/wateruse/2026_aug/code/calc_ghsl_citylevel_gwcost_withnear_fallback_2pcdr_20261006.R`, revised 6 October 2026, together with the original city/grid crosswalk workflow. The revised compressed file `ghsl_cities_gw_cost_compressed_2pcdr_20261006.csv` contains 12,140 unique cities and 83 columns, including 36 additional nonenergy/total unit-cost columns. Revised costs were checked against the detailed source records and the original `ghsl_cities_gw_cost_compressed_20260921.csv`; the 47 baseline columns were retained. The same source grid/year is used for every discount-rate case within a hydrological scenario.
[^overview]: SuperWells Data Repository Overview and Outputs Description supplied with this project. Outputs DOI: `10.57931/2307832`; aquifer inputs DOI: `10.57931/2484226`.
[^paper]: Niazi et al. (2025), *Long-term hydro-economic analysis tool for evaluating global groundwater cost and supply: Superwell v1.1*, Geoscientific Model Development, 18, 1737–1767; Sections 2–4. DOI: `10.5194/gmd-18-1737-2025`.
[^code]: JGCRI, `superwell/python/superwell_deepening.py`, inspected 21 September 2026: `https://github.com/JGCRI/superwell/blob/main/python/superwell_deepening.py`. Implementation descriptions above distinguish code behavior from inconsistent overview labels.
[^params]: JGCRI, `superwell/inputs/params.csv`, inspected 21 September 2026: `https://github.com/JGCRI/superwell/blob/main/inputs/params.csv`.
[^sample]: Supplied `superwell_py_deep_C_all_B_all_G_72548_0.3PD_0.25DL_0.2RR(1).csv`, year 1; arithmetic checked directly from the uploaded record.

