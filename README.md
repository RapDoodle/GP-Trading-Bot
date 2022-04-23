# Genetic-Programming-Based Trading Bot
This example presents a simple example of training a genetic-programming-based trading bot using the APIs provided by [Genetic Programming Toolbox for MATLAB](https://github.com/RapDoodle/Genetic-Programming-MATLAB).

## Getting Started
1. Clone the project
    ```bash
    git clone https://github.com/RapDoodle/GP-Trading-Bot.git
    ```

1. Change the current working directory to the project folder
    ```bash
    cd ./GP-Trading-Bot
    ```

1. Download Genetic Programming Toolbox for MATLAB
    ```bash
    git submodule update --init
    ```

1. Install MATLAB's Parallel Computing Toolbox. Skip this step if you have already installed the toolbox. If the toolbox is not available to you, change line 33 in `MyGPModel.m` to the following code
    ```matlab
    for s=1:n
    ```

1. Run `main.m`

## Disclaimer
The entire project is only a highly-stripped-down version of my research. None of the hyperparameters is optimized. The code provides absolutely no warranty on correctness and profitability. If you are using the trading strategy on your real account, you are doing it at your own risk.

## License
This project, including the documentation, is licensed under the MIT license. Copyright (c) 2022 Bohui WU.