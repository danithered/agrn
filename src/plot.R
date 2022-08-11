#### USAGE ####

# This file makes correlation plots of simulations based on agrn setting files.

# In case you are using Rstudio, just click on "Source" button in the topright corner of this pane!
# From command line invoke: `Rscript src/plot.R` or `R -f src/plot.R`

#### Installation of neccessary packages ####
if(!require(Rcpp, quietly = T)){install.packages("Rcpp"); library(Rcpp)}
if(!require(BH, quietly = T)) install.packages("BH")
if(!require(ggplot2, quietly = T)){install.packages("ggplot2"); library(ggplot2)}
if(!require(tidyr, quietly = T)){install.packages("tidyr"); library(tidyr)}

#### Compiling program ####
path <- NULL
if(!is.null(sys.calls())) { # in case of source()
  path <- as.character(sys.call(1))[2] 
} else { # in case of Rscript or R -f
  args <- commandArgs(trailingOnly = FALSE)
  arg = grep("--file", args, value=T)
  if(length(arg) > 0){ ## Rscript
    path <- paste(getwd(), strsplit(arg[1], "=")[[1]][2], sep="/")
  } else { # R -f
    path = paste(getwd(), grep(".R", args, value=T, fixed = T), sep="/")
  }
}
dir <- dirname(path)

Sys.setenv("PKG_CXXFLAGS" = paste0("-I", dir, "/include -lboost_system -lm -I/usr/local/include -L/usr/local/lib -lgsl -lgslcblas -fopenmp -D _EXPR_MOD_RCPP_"))
if(!".__C__Rcpp_ExpressionModell" %in% ls(a=T)) sourceCpp( paste0(dir, "/expr_mod.cpp") )

#### Get file loaction ####
if(interactive()){
  input <- file.choose()
  output <- NA
} else {
  input <- NA
  while(is.na(input)){
    cat("Please type a valid location of input file (or type 'q' to exit): ")
    input <- readLines("stdin", n=1)
    if(input == "q") quit(save="no")
    if(!file.exists(input)) input <- NA
  }
  output <- NA
  while(is.na(output)){
    cat( paste0("Current working dir is ", getwd(), ". Please type a filename for output (or type 'q' to exit): "))
    output <- readLines("stdin", n=1)
    if(output == "q") quit(save="no")
    if(!dir.exists(dirname(output))) output <- NA
  }
}

#### Initialise (and run) simulation ####
if("model" %in% ls()) rm("model")
model <- new(.__C__Rcpp_ExpressionModell)
invisible(model$changeOutput("R")) # to create R data.frame with output data
invisible(model$load(input))

#### plot results ####
if (model$time > 0){
  df_long <- gather(model$df(), type, value, !time)
  plot <- ggplot(df_long, aes(x=time, y=value, col=type))+
             geom_line()
  if( is.na(output) ){ # it is an interactive sessio
    if(require(plotly)) print(ggplotly(plot))
    else print(plot)
  } else { # not interactive
    suppressMessages(ggsave(output, plot=plot))
  }
}
