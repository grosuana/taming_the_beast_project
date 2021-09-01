# Taming the BEAST project
## Comparison between two different methods of inferring the effective reproduction number of an epidemic

  The aim of this paper is to compare Re estimates obtained by using two different estimation methods: the Birth-Death Skyline model implemented in BEAST, and the estimateR R package. The former uses phylogenetic trees to infer the epidemic’s parameters, while the latter is a statistical approach that estimates Re using the case incidence timeseries.
Both the BDSKY and estimateR assume the population to be well-mixed, so this assumption was tested before proceeding with the analysis. Indeed, under the BDSKY analysis described below, when looking at the inferred phylogeny, sequences did not form clades based on geographical origin.

  Moreover, being a statistical method, estimateR does not require making any previous assumptions (e.g., imposing the number of times Re changes). For a meaningful comparison to be possible, however, the same assumptions made using the BDSKY model, were also enforced when using the estimateR package. The exact implementation is detailed below. 
Both methods were used to estimate Re changes of the USA influenza epidemic, between 1/10/2017 and 28/05/2018, assuming the Re has 5 different values over this period, and the results were compared.
