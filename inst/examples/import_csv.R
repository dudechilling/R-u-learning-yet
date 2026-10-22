## ---- quick-import-csv
# This makes a local CSV from a real dataset included with R.
# With your own file, use: d <- read.csv(file.choose()) in RStudio.
data(iris)
csv_file <- tempfile(fileext=".csv")
write.csv(iris, csv_file, row.names=FALSE)
d <- read.csv(csv_file)
names(d)
unlink(csv_file)

## ---- worked-import-csv
# QUESTION: How do I import a CSV and check its contents?
# Demonstration uses recorded iris data, not invented measurements.
data(iris)
csv_file <- tempfile(fileext=".csv")
write.csv(iris, csv_file, row.names=FALSE)

# 1. IMPORT: use your actual file instead of this demo file.
# In RStudio: d <- read.csv(file.choose())
# Alternatively: d <- read.csv("C:/path/to/observations.csv")
if (!file.exists(csv_file)) stop("The CSV path does not exist.")
d <- read.csv(csv_file)

# 2. INSPECT: what did R actually load?
cat("Observations:", nrow(d), "Columns:", ncol(d), "\n")
print(names(d))              # exact spellings, including capitalization
str(d)                       # numeric, character, factor, etc.
print(colSums(is.na(d)))      # missing values in each column

# 3. CHECK: unexpected columns can indicate extra delimiters.
if (any(grepl("^X([.]?[0-9]+)?$", names(d))))
  message("Review unexpected X columns and the CSV's delimiters.")

# 4. READ: successful import does not establish a sampling design.
# If a numeric column was read as text, inspect it before converting.
stopifnot(is.data.frame(d))
unlink(csv_file)