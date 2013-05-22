Programming Life: Gigabase
================ 
Gigabase: Synthetic Biology Cell Modeling Project

## The virtual Cell
Developing a visual environment for designing and simulating virtual cells.

- Substrate, s.
- Metabolism converting substrate s into product p.
- Substrate and product transporter.
- DNA synthesis.
- Protein synthesis and degratation.
- Lipid synthesis.

The lipid membrane separates the inside of the cell from the outside environment, 
allowing for unequal substrate and product concentrations inside and outside the 
cell (s#in, p#in and s#ext, p#ext respectively). Each of the components is 
associated with a cellular process (e.g. molecule synthesis or substrate conversion), 
which is modeled by one or more diﬀerential equations. The proposed model describes
an av- erage cell in a growing population of cells. Ordinary Diﬀerential Equations (ODEs) 
in this model describe the change of molecule concentrations in time.

## Installation
Gigabase runs on Rails. You can load this repository onto your hard drive and directly use
it as a rails app. Just run `bundle install` and `rake db: setup` and you are good to go. 
For windows users, some gems might not install and display a message such as not native build.
Download the Ruby Devkit and run the `bundle install` command in `mysys` terminal. All the
gems will then perfectly build. Don't forget you might need administrator rights.

## Build Status

### develop 
[![develop](https://travis-ci.org/Derkje-J/programming-life.png?branch=develop)](https://travis-ci.org/Derkje-J/programming-life)

### master
[![master](https://travis-ci.org/Derkje-J/programming-life.png?branch=master)](https://travis-ci.org/Derkje-J/programming-life)

## Pull Requests
We are always open to pull requests. After June 2013 the project will no longer be
fixed in direction, so more freedom on where to go. We do not allow pull requests on master
or release branches. Fork the repository, create a patch/feature/issue branch and 
merge to develop.
