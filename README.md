Repository for the software that implements the AGRN model described in

# Neural network formalism as a guide to the understanding and synthesis of large-scale genetic regulatory networks

Péter Szabó<sup>1</sup>; Mátyás Paczkó<sup>1,2</sup>; Dániel Vörös<sup>1,2</sup>; Eörs Szathmáry<sup>1</sup>; András Szilágyi<sup>1</sup>

<sup>1</sup>Institute of Evolution, Centre for Ecological Research, Budapest, Hungary

<sup>2</sup>Doctoral School of Biology, Institute of Biology, ELTE Eötvös Loránd University, Budapest, Hungary

Note: The code available from this repository is provided without any warranty or liability.

## Overview

Briefly, this program implements and visualizes a differentiation or developmental process that follows a certain trajectory through different intermediate stages and converges into an arbitrary developmental end state, or ‒ in terms of Weddington's epigenetic landscape view ‒ basin. A realized pathway is the result of an appropriate timing of certain external signals that promote cell-fate decisions and are controlled by the user demonstrating that the stages can be characterized as attractors and that the signals can provide forward momentum toward other attractors. The stages are represented by stage-specific gene expression vectors assembled from empirical data, which we provided in the repository, but can also be freely specified by the users. The modeled differentiation process is assumed to be in a certain stage, if the Pearson correlation coefficient between the expression vector (actual dynamical expression state of the genes) and a given developmental stage vector (user-defined, stage-specific gene expression vector) is above a certain threshold. The program also enables the users to design arbitrary topologies for the differentiation hierarchies. By using the default settings, results shown in the manuscript can be reproduced.

## Prerequisites

1. To build the program Linux or any compatible system needed. (Compatibility for Windows users will be provided soon.)
2. Install [boost](https://www.boost.org/) libraries
3. Install additional libraries:  
`sudo apt update`  
`sudo apt upgrade`  
`sudo apt intall git build-essentials`

## Installation

1. Move to a directory of your choice (in console): `cd /home/user/my/directory`
2. Clone the repository: `git clone https://github.com/danithered/agrn`
3. Move into cloned library: `cd agrn`
4. Compile program: `make`

## Basic usage

We have provided a simple description language for a concise representation of the regulatory systems described in the article. The program accepts a single input file and prints the results to a standard output. For example, to reproduce the results shown in Fig1:

`./simulation IN/Fig1.b1.txt`

To redirect output to a file:

`./simulation IN/Fig1.b1.txt > myfile.txt`

## Structure of the input files

### Sections

The input files are made up from 3 different sections, in an abritrary order. The start of the sections is indicated with a section header (a line with the content of "% data", "% topology" or "% settings").

- **data**: This section contains the expression pattern of different stages. This is a whitespace (tab) separated table, where **rows contain genes** and **columns contain stages**. Please note, that this table contains only the non-unique genes - unique genes and signal genes will be generated automatically! The table contains rownames and column names. 
    - Column names: The first row gives the column names and it is structured as follows: the first cell contains arbitrary content (it may be empty); and the following cells contain the names of different stages. (So for example, in case of a system with 10 different stages, the first row will have 11 cells!) Stage names can not include whitespace characters!
    - Row names: Starting from the second row of the table, first cells contain gene names, and the rest of the cells contain expression states in the form of '0's and '1's. '0' denotes that the gene is not expressed in the specific stage, while '1' denotes the expressed state. Gene names can not include whitespace characters!
- **topology**: A table describing the pathways (transitions) of the modeled system. The table has at least 2 and maximum 4 columns in the following order: `from`, `to`, `trigger` and `matrix`. The first row of the table is a header. The colums contain the following data:
    - from: The origin point of the transition. It can be the name of the stage (precisely as it is given in the data section header) or a positive integer which gives the number of the state (starting from 1, in the order as stated in data section).
    - to: The target point of the transition. It can be the name of the stage (precisely as it is given in the data section header) or a positive integer which gives the number of the state (starting from 1, in the order as stated in data section).
    - trigger: Contains the type of the transition and the number, or the name of the trigger (if needed). *Linear transitions* are defined by an empy cell or a cell with the content of '0' in this column. *Conditional transitions* should be indicated in the following form: 'C1' or 'Csignalname', where 'C' specifies the transition type and '1'/'signalname' denotes that it will proceed to its target, if signal number 1 (or signal named signalname) is present (we recommend the use of the numbers). *Fork transitions* have to be defined by two rows with the same initial stage name in the `from` column, but different target stage names in the `to` column with one row describing the default and the other one the triggered branch. In case of the default branch, the content of the `trigger` column will follow the pattern 'F-1' (or 'F-signalname') with the minus sign referring to the absence of the trigger and '1'/'signalname' indicating which signal is absent (in case of the default branch, signal indication can be omitted). Triggered branches follow the pattern of 'F+1' (or 'F+signalname'). Please note that trigger elements will be added to matrix M based on this section.
    - matrix (optional): By entering a value into this column, the user can split up the single transition matrix into multiple matrices so that the transitions in the given developmental process will be implemented by different matrices. The column value denotes the number of the matrix that implements the transition specified in its respective row. Numbering of the matices starts from 0. In case of leaving this column blank, all transition rules will be applied to the default matrix (0).
- **settings**: Additional settings and control sequences. Each row denotes a "command" which will be applied on the model. The structure of the commands is as follows: the first word specifies the type of the command (case-unsensitive), the rest are the arguments of the command (arguments are whitespace separated). The following commands can be applied:
    - `Runtime`: Run the simulation for the given time. Arguments:
        - time (double): The time interval to simulate. In case of a negative value or missing argument, the minimal time interval will be applied.
    - `Trigger`: Switches on a signal. Arguments:
        - signal (character / integer): Denotes which signal should be switched on.
        - strength (double - optional): The level of expression. Its defalt value is the maximal expression level ($E$).
    - `Set`: Sets the expression vector ($p$) to a given state to define the initial stage of the differentiation process. Arguments:
        - stage (character / integer - optional): Defines the initial stage. If it is left blank, the expression vector will be full of 0.0 values.
        - strength (double - optional): The level of expression of each expresed gene. Its default value is the maximal expression level ($E$).
    - `ChangeM`: Sets the use of alternative matrices. Be aware: if no alternative matrix is specified in the topology section, the program will crash! Arguments: 
        - number of matrix (integer - optional): The ID of the matrix (as declared in topology). Default value is 0.
    - `SetDecay`: Setting values for gene's decay rate(s). According to the number of arguments:
        - no argument: The default value will be set on all of the decay rate values. 
        - single argument: The same decay rate will be applied. 
        - argument vector (number of elements is the sum of the unique, non-unique and signal elements): Different decay rates will be applied.
    - `Output`: Set the type of output. Default value: `Pearson` - it prints Pearson correlation coefficients (see: Figures in article). Alternative option: `state` - it prints the expression level of genes.
    - Commands can be executed, if the system reaches a given stage, i.e., the Pearson correlation coefficient of the specified stage exceeds a threshold value for a predefined period of time. The structure of the timer is the following: `command [ARGS] @ stage [expression length] [treshold]`, where: 
        - `command`: The command to be timed. 
        - `ARGS`: The arguments of the command.
        - `stage` (character / integer): The name (or number) of the stage in which the command is executed.
        - `expression length` (double - optional): The minimum length of expression of the specified stage to evoke the command. The default value is zero (immediate response).
        - `threshold` (double - optional): The critical value of the Pearson correlation coefficient. The default value is 0.95.

## Rcpp wrapper

For the results to be immediately plotted, we have provided an R wrapper. To use it, the recent version of [R](https://cran.r-project.org/) has to be installed with the *Rcpp*, *ggplot2*, *BH* and *tidyr* R packages. For more detailed information on the usage of the wrapper, see the src/plot.R file.
