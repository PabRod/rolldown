#' Approximate potential difference between two points
#'
#' @param x Position where we want to know the approximate potential
#' @param x0 Reference position (center of the Taylor expansion)
#' @param f Flow equations (right hand side of differential equation)
#' @param normType (default: 'f') Matrix norm used to compute the error
#'
#' @return A list containing the approximate potential difference between x and x0 and the estimated error
#' @export
#'
#' @author Pablo Rodríguez-Sánchez (\url{https://pabrod.github.io})
#' @references \url{https://arxiv.org/abs/1903.05615}
#'
#'
#' @seealso \code{\link{approxPot1D}, \link{approxPot2D}, \link{norm}}
#'
#' @examples
#' # One dimensional flow
#' f <- function(x) { cos(x) }
#'
#' # Evaluation points
#' x0 <- 1
#' x1 <- 1.02
#'
#' dV <- deltaV(f, x1, x0)
#'
#'  # Two dimensional flow
#' f <- function(x) { c(
#'  -2*x[1]*x[2],
#'  -x[1]^2 - 1
#' )}
#'
#' # Evaluation points
#' x0 <- matrix(c(1,2), ncol = 1)
#' x1 <- matrix(c(0.98,2.01), ncol = 1)
#'
#' dV <- deltaV(f, x1, x0)
deltaV <- function(f, x, x0, normType='f') {

  # Calculate the local Jacobian
  J0 <- numDeriv::jacobian(f, x0)

  # Perform the skew/symmetric decomposition
  J_symm <- Matrix::symmpart(J0)
  J_skew <- Matrix::skewpart(J0)

  # Use J_symm to estimate the difference in potential as 2nd order Taylor expansion
  #
  # Detailed information available at https://arxiv.org/abs/1903.05615
  dV <- as.numeric(
        -f(x0) %*% (x - x0) +  # Linear term
        -0.5 * t(x-x0) %*% J_symm %*% (x - x0) # Quadratic term
  )

  # Use J_skew to estimate the relative error
  #
  # Detailed information available at https://arxiv.org/abs/1903.05615
  rel_err <- norm(J_skew, type = normType)/(norm(J_skew, type = normType) + norm(J_symm, type = normType))

  # Return
  ls <- list(dV = dV, err = rel_err)
  return(ls)
}
