# Test installed rulearn asset, independent of source-root working directory.
pkg_root <- system.file(package = "rulearn", mustWork = TRUE)
catalogue <- system.file("extdata", "ru-curriculum.csv",
                         package = "rulearn", mustWork = TRUE)
stopifnot(file.exists(catalogue),
          identical(normalizePath(catalogue, winslash = "/", mustWork = TRUE),
                    normalizePath(file.path(pkg_root, "extdata", "ru-curriculum.csv"),
                                  winslash = "/", mustWork = TRUE)))
cat("L2 cwd=", getwd(), " installed=", pkg_root, " asset=", catalogue,
    " version=", as.character(utils::packageVersion("rulearn")),
    " libraries=", paste(.libPaths(), collapse = ";"), "\n", sep = "")
x <- utils::read.csv(catalogue, stringsAsFactors = FALSE,
                     check.names = FALSE, fileEncoding = "UTF-8")
required <- c("id", "block", "prerequisites", "outcome", "assessment",
              "transfer", "curriculum_version", "review_status")
expected_ids <- c(sprintf("ORI-%02d", 1:3), sprintf("R-%02d", 1:5),
                  unlist(lapply(c("DAT", "EXP", "DES", "PRO", "INF", "MOD", "RES", "TSP"),
                                function(p) sprintf("%s-%02d", p, 1:4)),
                         use.names = FALSE))
expected_blocks <- rep(c("01-orientation", "02-r-foundations", "03-data-work",
                         "04-exploration", "05-design", "06-probability",
                         "07-inference", "08-modelling", "09-research",
                         "10-temporal-spatial"), c(3, 5, rep(4, 8)))
prerequisite_anchors <- list("ORI-02" = "ORI-01", "ORI-03" = "ORI-02",
                             "R-01" = "ORI-02", "R-02" = "R-01",
                             "R-03" = "R-01", "R-04" = c("R-02", "R-03"),
                             "DAT-01" = c("ORI-03", "R-04"),
                             "DAT-02" = c("DAT-01", "R-03"),
                             "DAT-03" = "DAT-02", "EXP-01" = "DAT-03",
                             "EXP-02" = c("EXP-01", "R-02"))
validate_catalogue <- function(y) {
  stopifnot(is.data.frame(y), identical(names(y), required),
            nrow(y) == 40L, !anyNA(y),
            all(vapply(y, is.character, logical(1))))
  nonblank <- c("id", "block", "outcome", "assessment", "transfer",
                "curriculum_version", "review_status")
  stopifnot(all(vapply(y[nonblank],
                       function(z) all(nzchar(trimws(z))), logical(1))))
  stopifnot(!anyDuplicated(y$id), identical(y$id, expected_ids),
            identical(y$block, expected_blocks),
            all(y$curriculum_version == "ru-production-v1"),
            all(y$review_status == "NOT_REVIEWED"))
  edges <- setNames(vector("list", nrow(y)), y$id)
  for (i in seq_len(nrow(y))) {
    value <- y$prerequisites[[i]]
    deps <- if (nzchar(value)) strsplit(value, ";", fixed = TRUE)[[1L]] else character()
    stopifnot(!anyDuplicated(deps), all(nzchar(trimws(deps))),
              all(deps %in% y$id), !(y$id[[i]] %in% deps))
    edges[[y$id[[i]]]] <- deps
  }
  seen <- setNames(integer(nrow(y)), y$id)
  visit <- function(key) {
    if (seen[[key]] == 1L) stop("cyclic prerequisite graph")
    if (seen[[key]] == 2L) return(invisible(NULL))
    seen[[key]] <<- 1L
    for (dep in edges[[key]]) visit(dep)
    seen[[key]] <<- 2L
    invisible(NULL)
  }
  for (key in y$id) visit(key)
  for (i in seq_len(nrow(y)))
    stopifnot(all(match(edges[[y$id[[i]]]], y$id) < i))
  for (key in names(prerequisite_anchors))
    stopifnot(identical(edges[[key]], prerequisite_anchors[[key]]))
  TRUE
}
stopifnot(validate_catalogue(x))
negative_cases <- list(
  duplicate_id = function(z) { z$id[2] <- z$id[1]; z },
  blank_id = function(z) { z$id[1] <- ""; z },
  removed_row = function(z) z[-40L, , drop = FALSE],
  missing_column = function(z) { z$assessment <- NULL; z },
  blank_outcome = function(z) { z$outcome[2] <- ""; z },
  missing_transfer = function(z) { z$transfer[2] <- NA_character_; z },
  bad_version = function(z) { z$curriculum_version[1] <- "unknown"; z },
  bad_review = function(z) { z$review_status[1] <- "PASS"; z },
  unknown_prerequisite = function(z) { z$prerequisites[z$id == "DAT-01"] <- "ZZZ-99"; z },
  self_cycle = function(z) { z$prerequisites[z$id == "R-03"] <- "R-03"; z },
  two_node_cycle = function(z) { z$prerequisites[z$id == "ORI-02"] <- "R-01"; z },
  reordered = function(z) { order <- seq_len(nrow(z)); order[c(5, 6)] <- order[c(6, 5)]; z[order, , drop = FALSE] },
  deleted_required_edge = function(z) { z$prerequisites[z$id == "R-04"] <- "R-02"; z },
  duplicate_edge = function(z) { z$prerequisites[z$id == "R-04"] <- "R-02;R-03;R-03"; z },
  wrong_block = function(z) { z$block[1] <- "02-r-foundations"; z }
)
rejected <- vapply(negative_cases,
                   function(f) inherits(try(validate_catalogue(f(x)), silent = TRUE),
                                        "try-error"), logical(1))
if (!all(rejected))
  stop("Catalogue mutants accepted: ", paste(names(rejected)[!rejected], collapse = ", "))
cat("PASS installed L2 curriculum: 40 outcomes, 10 blocks, 15/15 invalid mutants rejected\n")
