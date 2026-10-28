# Run steps 7, 8, and 9 for the three discount-rate scenarios.

# /*===========================================*/
#'=  Define helper functions  =
# /*===========================================*/
run_discount_scenarios <- function(analysis_dir, code_dir) {
  analysis_dir <- normalizePath(analysis_dir, mustWork = TRUE)
  code_dir <- normalizePath(code_dir, mustWork = TRUE)

  scripts <- file.path(code_dir, c(
    "7_city_water_cost_min.qmd",
    "8_selected_portfolio_replacement_cost.qmd",
    "9_selected_portfolio_replacement_cost.qmd"
  ))

  if (!all(file.exists(scripts))) {
    stop("Missing QMD file(s): ", paste(scripts[!file.exists(scripts)], collapse = ", "))
  }

  quarto <- Sys.which("quarto")
  if (!nzchar(quarto)) stop("The quarto command is not on PATH")

  old_analysis <- Sys.getenv("MUNI_ANALYSIS_DIR", unset = NA_character_)
  old_rate <- Sys.getenv("MUNI_DISCOUNT_RATE", unset = NA_character_)
  on.exit({
    if (is.na(old_analysis)) {
      Sys.unsetenv("MUNI_ANALYSIS_DIR")
    } else {
      Sys.setenv(MUNI_ANALYSIS_DIR = old_analysis)
    }

    if (is.na(old_rate)) {
      Sys.unsetenv("MUNI_DISCOUNT_RATE")
    } else {
      Sys.setenv(MUNI_DISCOUNT_RATE = old_rate)
    }
  })

  for (rate in c(0.01, 0.02, 0.03)) {
    tag <- sprintf("dr%02d", round(100 * rate))
    options_file <- file.path(
      analysis_dir,
      paste0("city_surface_water_capacity_options_", tag, ".csv")
    )
    if (!file.exists(options_file)) stop("Missing step 6 output: ", options_file)

    scenario_dir <- file.path(analysis_dir, tag)
    report_dir <- file.path(scenario_dir, "quarto_output")
    dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)

    Sys.setenv(
      MUNI_ANALYSIS_DIR = analysis_dir,
      MUNI_DISCOUNT_RATE = as.character(rate)
    )

    for (script in scripts) {
      message("Running ", tag, ": ", basename(script))
      status <- system2(
        quarto,
        args = c("render", shQuote(script), "--output-dir", shQuote(report_dir)),
        stdout = "",
        stderr = ""
      )
      if (status != 0L) stop("Failed: ", basename(script), " (", tag, ")")
    }

    message("Finished ", tag, ": ", scenario_dir)
  }

  invisible(TRUE)
}


# /*===========================================*/
#'=  Run code file 7, 8, 9 for various discount-rate scenarios  =
# /*===========================================*/
run_discount_scenarios(
  analysis_dir = here::here("Data/Analysis"),
  code_dir = here::here("Code/Analysis")
)
