# Option Implied Probability of Default

The goal of this project is to estimate default probabilities of banks implied
by observed market data using the method suggested by
[Christian Capuano (2008)](https://www.elibrary.imf.org/view/journals/001/2008/194/article-A001-en.xml)
which was updated by [Johannes Vilsmeier (2014)](https://www.bundesbank.de/en/publications/research/discussion-papers/updating-the-option-implied-probability-of-default-methodology-703900).

For a full description of this project and further details, please consult
the [final report](https://github.com/bt-koch/optipod/blob/master/paper_final.pdf).

Note that the files must be opened within the corresponding RProject.

## Statistical Framework

This project applies the method of estimating option implied probability of
default suggested by
[Johannes Vilsmeier (2014)](https://www.bundesbank.de/en/publications/research/discussion-papers/updating-the-option-implied-probability-of-default-methodology-703900).
Using the principle of minimum cross-entropy and optimisation constraints
given by observable market prices, retrieving the probability density
function of future asset value is attempted. The obtained probability
density function then is integrated up to a threshold chosen to be optimal,
resulting in an estimate of the probability of default.

## Data

Data since 2021 was obtained for several banks from  the [polygon.io API](https://polygon.io).
Additionally, data since 2005 was obtained from
[WRDS](https://wrds-www.wharton.upenn.edu) for Credit Suisse.
Unfortunately, since the data is not openly accessible, the SQL database
cannot be published in this repository.

## Results

Although key events are mapped as episodes of increased stress with this
indicator, no strong predictive power was found in this specific application.

## About

This project was created as a part of the Seminar "Workshop in Econometrics II"
at the University of Bern.
