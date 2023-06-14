# Option Implied Probability of Default

The goal of this project is to estimate default probabilities of banks implied
by observed market data using the method suggested by
[Christian Capuano (2008)](https://www.elibrary.imf.org/view/journals/001/2008/194/article-A001-en.xml)
which was updated by [Johannes Vilsmeier (2014)](https://www.bundesbank.de/en/publications/research/discussion-papers/updating-the-option-implied-probability-of-default-methodology-703900).



## Statistical Framework

This project applies the method of estimating option implied probability of
default suggested by
[Johannes Vilsmeier (2014)](https://www.bundesbank.de/en/publications/research/discussion-papers/updating-the-option-implied-probability-of-default-methodology-703900).
Using the principle of minimum cross-entropy and optimisation constraints
given by observable market prices, retrieving the probability density
function of future asset value is attempted. The obtained probability
density function then is integrated up to a threshold chosen to be optimal,
resulting in an estimate of the probability of default.

$$
1+1
$$

## Data

For Credit Suisse, data since 2005 

## Results


## About

This project attempts to apply the updated method of estimating default probabilities
proposed by [Johannes Vilsmeier (2014)](https://www.bundesbank.de/en/publications/research/discussion-papers/updating-the-option-implied-probability-of-default-methodology-703900) on the most recent banking crisis in March 2023 and was created
as a part of the Seminar "Workshop in Econometrics II" at the University of Bern.
