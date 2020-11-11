![licence](https://img.shields.io/badge/Licence-GPL--3-blue.svg)
[![R build status](https://github.com/Jean-Romain/rlas/workflows/R-CMD-check/badge.svg)](https://github.com/Jean-Romain/rlas/actions)
[![Codecov test coverage](https://codecov.io/gh/Jean-Romain/rlas/branch/master/graph/badge.svg)](https://codecov.io/gh/Jean-Romain/rlas?branch=master)

R package to read and write `.las` and `.laz` binary files used to store LiDAR data.

`rlas` relies on a modified version of `LASlib` and `LASzip` that were modified to be compatible with `R`. The library can therefore be compiled into `R` without any complaints from `R CMD check`. It enables R users to read and write binary files commonly used to store LiDAR data. LAS version 1.0 to 1.4 are supported.

```r
library(rlas)
lasdata   <- read.las("<myfile.las>")
lasheader <- read.lasheader("<myfile.las>")
```

## Copyright Information

`rlas` contains code written  by both Jean-Romain Roussel and Martin Isenburg. The latter is included
for technical reasons. Details below.

* For `LASlib` and `LASzip`:
  - (c) 2007-2019 martin.isenburg@rapidlasso.com - http://rapidlasso.com
  - Provided under LGPL license and modified to be R-compliant by Jean-Romain Roussel.
* For `rlas` code enabling Martin Isenburg's code to be wrapped into R:
  - (c) 2016-2020 Jean-Romain Roussel
  - Provided under GPL-3 license.
