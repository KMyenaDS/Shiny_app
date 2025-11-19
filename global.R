# -------------------
# Packages
# -------------------

library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinycssloaders)
library(DT)
library(gtsummary)
library(gt)
library(ggplot2)
library(readr)
library(readxl)
library(survival)
library(broom)

# -------------------
# Fonctions utilitaires
# -------------------
detect_var_type <- function(x){
  if(is.numeric(x)) return("numeric")
  if(is.factor(x) || is.character(x)) return("categorical")
  if(inherits(x,"Date") || inherits(x,"POSIXt")) return("date")
  return("other")
}

choose_model_family <- function(y){
  if(is.numeric(y)) return("gaussian")
  if(is.factor(y) && length(levels(y))==2) return("binomial")
  if(inherits(y,"Surv")) return("cox")
  return("gaussian")
}

fit_model <- function(data, formula, family="gaussian"){
  if(family=="cox") return(survival::coxph(formula,data=data))
  if(family=="binomial") return(glm(formula,data=data,family=binomial))
  return(lm(formula,data=data))
}
