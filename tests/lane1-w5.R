library(rulearn)
ids <- rulearn:::.ru_w5_method_ids()
stopifnot(length(ids)==46L,length(unique(ids))==46L)
for (id in ids) {
  route <- rulearn:::.ru_w5_method_route(id)
  stopifnot(identical(route$method_id,id),
            identical(route$status,"NEEDS_INPUT"),
            identical(route$executed,FALSE),
            identical(route$accepted_parameters,
                      setdiff(rulearn:::.ru_allowed_arguments(id),
                        c(route$required_data,route$required_columns,
                          "show_plot","title","col","xlab","ylab","units"))))
}
stopifnot(is.null(rulearn:::.ru_w5_method_route("histogram and boxplot")),
          is.null(rulearn:::.ru_w5_method_route("")),
          is.null(rulearn:::.ru_w5_method_route(NA_character_)),
          is.null(rulearn:::.ru_w5_method_route("histogramming")),
          is.null(rulearn:::.ru_w5_method_route(paste(rep("a",5000),collapse=""))))
cat("A1 W5 46 exact method contracts and conservative ambiguity checks PASS\n")
