# ===============================================================================
#
# PROGRAMMERS:
#
# jean-romain.roussel.1@ulaval.ca  -  https://github.com/Jean-Romain/rlas
#
# COPYRIGHT:
#
# Copyright 2016-2018 Jean-Romain Roussel
#
# This file is part of rlas R package.
#
# rlas is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>
#
# ===============================================================================



#' Read data from a .las or .laz file
#'
#' Reads data from .las or .laz files in format 1 to 4 according to LAS specifications and returns
#' a \code{data.table} labeled according to LAS specifications. See the ASPRS documentation for the
#' \href{http://www.asprs.org/a/society/committees/standards/LAS_1_4_r13.pdf}{LAS file format}.
#' The optional parameters enable the user to save memory by choosing to load only the
#' fields they need. Moreover, the function provides a streaming filter to load only the points of
#' interest into the memory and hence avoids allocating any superfluous memory.
#'
#' \strong{Select:} the 'select' argument specifies the data that will actually be loaded. For example,
#' 'xyzia' means that the x, y, and z coordinates, the intensity and the scan angle will be loaded.
#' The supported entries are t - gpstime, a - scan angle, i - intensity, n - number of returns,
#' r - return number, c - classification, s - synthetic flag, k - key-point flag, w - withheld flag,
#' u - user data, p - point source ID, e - edge of flight line flag, d - direction of scan flag,
#' R - red channel of RGB color, G - green channel of RGB color, B - blue channel of RGB color,
#' N - near-infrared channel. Also numbers from 1 to 9 for the extra bytes data numbers 1 to 9.
#' 0 enables all extra bytes to be loaded and '*' is the wildcard that enables everything to be
#' loaded from the LAS file. \cr
#' Note that x, y, z are implicit and always loaded. 'xyzia' is equivalent to 'ia'.\cr\cr
#' \strong{Filter:} the 'filter' argument allows filtering of the point cloud while reading files.
#' \code{rlas} relies on the well-known \code{LASlib} library written by Martin Isenburg
#' to read the binary files. Thus the package inherits the filter commands available in
#' \href{https://rapidlasso.com/lastools/}{LAStools}. To use these filters the user can pass the
#' common commands from \code{LAStools} into the parameter \code{'filter'}. Type \code{rlas:::lasfilterusage()}
#' to display the \code{LASlib} documentation and the available filters.
#'
#' @param files array of characters
#' @param select character. select only columns of interest to save memory (see details)
#' @param filter character. streaming filters - filter data while reading the file (see details)
#' @return A \code{data.table}
#' @export
#' @examples
#' lazfile <- system.file("extdata", "example.laz", package="rlas")
#'
#' lasdata <- read.las(lazfile)
#' lasdata <- read.las(lazfile, filter = "-keep_first")
#' lasdata <- read.las(lazfile, filter = "-drop_intensity_below 80")
#' lasdata <- read.las(lazfile, select = "xyzia")
#' @useDynLib rlas, .registration = TRUE
read.las = function(files, select = "*", filter = "")
{
  stream.las(files, select = select, filter = filter)
}

#' Read header from a .las or .laz file
#'
#' Reads header from .las or .laz files in format 1 to 4 according to LAS specifications and returns
#' a \code{list} labeled according to LAS specifications. See the ASPRS documentation for the
#' \href{http://www.asprs.org/a/society/committees/standards/LAS_1_4_r13.pdf}{LAS file format}.
#'
#' @param file filepath character string to the .las or .laz file
#' @family rlas
#' @return A \code{list}
#' @importFrom Rcpp sourceCpp
#' @export
#' @examples
#' lazfile   <- system.file("extdata", "example.laz", package="rlas")
#' lasheader <- read.lasheader(lazfile)
read.lasheader = function(file)
{
  valid = file.exists(file)
  islas = tools::file_ext(file) %in% c("las", "laz", "LAS", "LAZ")
  file = normalizePath(file)

  if(!valid)  stop("File not found", call. = F)
  if(!islas)  stop("File not supported", call. = F)

  data = lasheaderreader(file)

  return(data)
}

stream.las = function(ifiles, ofile = "", select = "*", filter = "")
{
  check_file(ifiles)
  check_filter(filter)

  ifiles = normalizePath(ifiles)

  if (ofile != "")
    ofile = suppressWarnings(normalizePath(ofile))

  data = C_reader(ifiles, ofile, select, filter)

  if (ofile != "")
    return(invisible())

  data.table::setDT(data)

  return(data)
}

stream.las_inpoly = function(ifiles, xpoly, ypoly, ofile = "", select = "*", filter = "")
{
  check_file(ifiles)
  check_filter(filter)

  ifiles = normalizePath(ifiles)

  if (ofile != "")
    ofile = suppressWarnings(normalizePath(ofile))

  if (length(xpoly) != length(ypoly))
      stop("Invalide polygon", call. = FALSE)

  if (xpoly[1] != xpoly[length(xpoly)] | xpoly[1] != xpoly[length(xpoly)])
      stop("The polygon is not closed", call. = FALSE)

  xmin <- min(xpoly)-0.1
  xmax <- max(xpoly)+0.1
  ymin <- min(ypoly)-0.1
  ymax <- max(ypoly)+0.1

  filter <- paste(paste("-inside", xmin, ymin, xmax, ymax), filter)

  data = C_reader_inpoly(ifiles, xpoly, ypoly, ofile, select, filter)

  if (ofile != "")
    return(invisible())

  data.table::setDT(data)

  return(data)
}

`%is_in%` <- function(char, str) grepl(char, str)
