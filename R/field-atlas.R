# Field Atlas hex colors come from one installed CSS token definition.
# Parsing avoids separate R and CSS palettes diverging.
.ru_palette_from_css <- function(path) {
  if(!file.exists(path))stop("Field Atlas token source is missing.",call.=FALSE)
  lines <- readLines(path,warn=FALSE)
  pattern <- "^\\s*--atlas-([a-z-]+):\\s*(#[0-9A-Fa-f]{6});\\s*$"
  lines <- grep(pattern,lines,value=TRUE,perl=TRUE)
  role <- sub(pattern,"\\1",lines,perl=TRUE)
  value <- toupper(sub(pattern,"\\2",lines,perl=TRUE))
  want <- c("ocean","clay","jade","ochre","iris","slate",
            "warm-paper","deep-ink","grid")
  if(length(role)!=9L || anyDuplicated(role) || !setequal(role,want))
    stop("Field Atlas must define exactly nine unique named roles.",call.=FALSE)
  stats::setNames(value[match(want,role)],want)
}
#' Named Field Atlas color tokens
#' Returns colors only; does not set par(), options() or RStudio preferences.
ru_palette <- function(role=NULL) {
  file <- system.file("www","field-atlas.css",package="rulearn")
  if(!nzchar(file))stop("Field Atlas token source not installed.",call.=FALSE)
  pal <- .ru_palette_from_css(file)
  if(is.null(role))return(pal)
  if(!is.character(role) || anyNA(role) || !all(role %in% names(pal)))
    stop("Unknown Field Atlas role.",call.=FALSE)
  pal[role]
}