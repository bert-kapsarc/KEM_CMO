# Oligopolistic Electricity Market Model

A partial equilbirum model to simulate the liberalization of Saudi Arabia's wholesale electricity market. This includes the unbundling of generation assets owned by the state owned Saudi Electricity Company into 4 new regional gencos, introduction of regional capacity markets, and the formation of indepenent transmission system operator (TSO), and arbitrageur. The Gencos can be modeled in oligopolistic or perfect competition.

## Energy & Capacity Markets

The model includes linear equations used to represent indepedent energy and capacity market segements. Power demand is represented by regional linear inverse demand functions for different segements, representing different seasons and groups of hours with similar levels of demand.  

## Accompanying publication

This code accompnaies the article titled "Capacity Expansion in Oligopolistic Electricity Markets with Locational Pricing: Restructuring Saudi Arabia’s Power Generation Sector".

In the origial formualtion all produciton and capacity units are presented in GigaWatts (GW) and all costs in USD per Kilo watt (USD/KW). All variable produciton costs used are, therefore, indexed by load segement and adjusted propotional to the number of hours assigned to each demand segement. 

However, the model presented here represents variable production costs in USD per Mega Watt hour (USD/Mhw). When constructing the objective fucntion (total profits) of a given agent in the model (e.g. Genco) variable costs are multiplied by the number of hours in a given load segment.

## Getting Started

### Prerequisites
Built using the General Algebraic Modeling System (GAMS).
Model is compiled using the Extended Mathmatical Programin (EMP) framework.

### Running the
Execute run.gms from GAMS IDE or from comand line.

### Scenario Configuration
...



