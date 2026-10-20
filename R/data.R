# Public teaching datasets. Source tables are not copied into this package.
ru_datasets <- function() {
  data.frame(
    dataset=c("iris","mtcars","airquality","faithful","ToothGrowth",
              "PlantGrowth","sleep","cars","anscombe","quakes",
              "ChickWeight","CO2","Nile","AirPassengers","Titanic",
              "HairEyeColor","penguins"),
    source=c(rep("datasets (included with R)",16),
             "palmerpenguins (optional; CC0 data)"),
    useful_for=c(
      "flowers: numerical summaries, groups, distributions",
      "vehicle mileage, cylinders, transmission, regression",
      "air pollution: missing values, time and weather",
      "geyser eruption durations and waiting times",
      "tooth measurements, supplement and dose groups",
      "plant weight: treatment and control groups",
      "paired before/after-like measurements by subject",
      "speed and stopping distances; regression and prediction",
      "why similar correlations hide different patterns",
      "earthquake magnitude, location and depth",
      "repeated measurements and animal growth",
      "uptake values and experimental categories",
      "annual river flow and interpolation",
      "monthly passenger counts, trends and seasonality",
      "historical contingency counts, not unit records",
      "historical hair-eye contingency counts",
      "penguin body and bill measurements, species and missing values"),
    stringsAsFactors=FALSE
  )
}

ru_data <- function(name) {
  if (!is.character(name) || length(name)!=1L || is.na(name))
    stop("Provide one dataset name from ru_datasets().",call.=FALSE)
  valid <- ru_datasets()$dataset
  if (!(name %in% valid))
    stop("Unknown dataset. See ru_datasets() for supported names.",call.=FALSE)
  if (name=="penguins") {
    if (!requireNamespace("palmerpenguins",quietly=TRUE))
      stop("Penguin data are optional. Run install.packages('palmerpenguins') ",
           "then ru_data('penguins'). No substitute is loaded.",call.=FALSE)
    return(as.data.frame(palmerpenguins::penguins))
  }
  e <- new.env(parent=baseenv())
  utils::data(list=name,package="datasets",envir=e)
  d <- get(name,envir=e,inherits=FALSE)
  if (name=="Nile")
    return(data.frame(year=as.numeric(stats::time(d)),flow=as.numeric(d)))
  if (name=="AirPassengers") {
    years <- floor(as.numeric(stats::time(d)) + 1e-8)
    months <- as.integer(stats::cycle(d))
    dates <- as.Date(sprintf("%04d-%02d-01",years,months))
    return(data.frame(date=dates,passengers=as.numeric(d)))
  }
  if (is.table(d)) return(as.data.frame(d,stringsAsFactors=FALSE))
  as.data.frame(d)
}

ru_columns <- function(data) {
  if (!is.data.frame(data))
    stop("Supply a data frame, for example ru_data('iris').",call.=FALSE)
  out <- data.frame(
    column=names(data),
    type=vapply(data,function(v) paste(class(v),collapse="/"),character(1)),
    missing=vapply(data,function(v) sum(is.na(v)),integer(1)),
    non_missing=vapply(data,function(v) sum(!is.na(v)),integer(1)),
    stringsAsFactors=FALSE
  )
  print(out,row.names=FALSE,right=FALSE)
  invisible(out)
}
