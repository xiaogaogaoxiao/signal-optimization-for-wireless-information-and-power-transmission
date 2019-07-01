# Signal Optimization for SWIPT

This project implements SWIPT optimization based on a nonlinear harvest model with superposed waveforms containing modulated information and multisine power components. Please check [this article](https://ieeexplore.ieee.org/document/8115220) for more details.

## TODO

- Results
- Thesis

## Theory

### Topics

Topics include:

- Nonlinear harvest model
- Rate-energy region
- Transmitter and receiver architectures
- Waveform design
- Resource allocation
- Modulation, beamforming and input distribution
- Geometric programming

### System Structure

![System Structure](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/System%20Structure.png)

### Block Diagram

![Block Diagram](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/Block%20Diagram.png)



| Transmitter                                                  | Channel                                                      | Receiver                                                     |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| <a href="https://www.codecogs.com/eqnedit.php?latex=e_{1}=\frac{P_{rf}^{t}}{P_{dc}^{t}}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?e_{1}=\frac{P_{rf}^{t}}{P_{dc}^{t}}" title="e_{1}=\frac{P_{rf}^{t}}{P_{dc}^{t}}" /></a> | <a href="https://www.codecogs.com/eqnedit.php?latex=e_{2}=\frac{P_{rf}^{r}}{P_{rf}^{t}}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?e_{2}=\frac{P_{rf}^{r}}{P_{rf}^{t}}" title="e_{2}=\frac{P_{rf}^{r}}{P_{rf}^{t}}" /></a> | <a href="https://www.codecogs.com/eqnedit.php?latex=e_{3}=\frac{P_{dc}^{r}}{P_{rf}^{r}}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?e_{3}=\frac{P_{dc}^{r}}{P_{rf}^{r}}" title="e_{3}=\frac{P_{dc}^{r}}{P_{rf}^{r}}" /></a> |

- Diode linear model: e<sub>1</sub>, e<sub>3</sub> are independent of the power and shape of the input signal (optimize e<sub>1</sub>, e<sub>2</sub>, e<sub>3</sub> separately).
- Diode nonlinear model: e<sub>1</sub>, e<sub>2</sub>, e<sub>3</sub> are coupled; e<sub>3</sub> is a nonlinear function of the transmitted signal (jointly optimize e<sub>2</sub> &middot; e<sub>3</sub>).

### Diode Nonlinearity and Harvester Models

| ![Diode Characteristics](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/Diode%20Characteristics.png) | <a href="https://www.codecogs.com/eqnedit.php?latex=z_{dc}=\sum_{i\geq&space;2,&space;even}^{n_{0}}k_{i}\varepsilon[y_{rf}^{r}(t)^{i}]" target="_blank"><img src="https://latex.codecogs.com/gif.latex?z_{dc}=\sum_{i\geq&space;2,&space;even}^{n_{0}}k_{i}\varepsilon[y_{rf}^{r}(t)^{i}]" title="z_{dc}=\sum_{i\geq 2, even}^{n_{0}}k_{i}\varepsilon[y_{rf}^{r}(t)^{i}]" /></a> |
| :----------------------------------------------------------: | :----------------------------------------------------------: |
|                   _Diode Characteristics_                    |                    _Harvested DC Current_                    |

|                                     | Linear Regime (R<sub>1</sub>)                    | Nonlinear Regime (R<sub>2</sub>)                    | Saturation Regime (R<sub>3</sub>)        |
| ----------------------------------- | ------------------------------------------------ | --------------------------------------------------- | ---------------------------------------- |
| Model                               | Diode linear model (n<sub>0</sub>&nbsp;=&nbsp;2) | Diode nonlinear model (n<sub>0</sub>&nbsp;>&nbsp;2) | Saturation nonlinear model (not covered) |
| Operation Regime                    | Very low power (below -30&nbsp;dBm)              | Low power (-30&nbsp;dBm to 0&nbsp;dBm)              | High power (above 0&nbsp;dBm)            |
| Receiver efficiency (e<sub>3</sub>) | Constant                                         | Function of the rectifier input signal              | Function of the rectifier input signal   |
| Impact                              | Neutral                                          | Beneficial                                          | Detrimental (avoidable)                  |

- Multisine reduces the boundary between linear and nonlinear regions from -20&nbsp;dBm to -30&nbsp;dBm.
- Truncating at higher order leads to nonlinear behaviour.
- Diode nonlinear model holds when the high-order terms are not negligible.

### Receiver Architectures

|              | Time Switching (TS)                                          | Power Splitting (PS)                                         |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Diagram      | ![TS Receiver](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/TS%20Receiver.png) | ![PS Receiver](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/PS%20Receiver.png) |
| Function     | Switch the signal to either ID or EH                         | Split a portion to ID and the rest to EH                     |
| Optimization | Individual blocks                                            | Jointly                                                      |
| Control      | Slot length                                                  | PS ratio (&rho;)                                             |

### Rate-Energy Region Characterization

- Rate-energy region: <a href="https://www.codecogs.com/eqnedit.php?latex=\begin{aligned}&space;C_{R-I_{D}&space;C}(P)&space;&&space;\triangleq\left\{\left(R,&space;I_{D&space;C}\right)&space;:&space;R&space;\leq&space;I\right.\\&space;I_{D&space;C}&space;&&space;\leq&space;z_{D&space;C},&space;\frac{1}{2}\left[\left\|\mathbf{S}_{I}\right\|_{F}^{2}&plus;\left\|\mathbf{S}_{P}\right\|_{F}^{2}\right]&space;\leq&space;P&space;\}&space;\end{aligned}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\begin{aligned}&space;C_{R-I_{D}&space;C}(P)&space;&&space;\triangleq\left\{\left(R,&space;I_{D&space;C}\right)&space;:&space;R&space;\leq&space;I\right.\\&space;I_{D&space;C}&space;&&space;\leq&space;z_{D&space;C},&space;\frac{1}{2}\left[\left\|\mathbf{S}_{I}\right\|_{F}^{2}&plus;\left\|\mathbf{S}_{P}\right\|_{F}^{2}\right]&space;\leq&space;P&space;\}&space;\end{aligned}" title="\begin{aligned} C_{R-I_{D} C}(P) & \triangleq\left\{\left(R, I_{D C}\right) : R \leq I\right.\\ I_{D C} & \leq z_{D C}, \frac{1}{2}\left[\left\|\mathbf{S}_{I}\right\|_{F}^{2}+\left\|\mathbf{S}_{P}\right\|_{F}^{2}\right] \leq P \} \end{aligned}" /></a>

### Algorithms

---

| ![Algorithm 1](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/Algorithm%201.png) | ![Formula 1](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/Formula%201.png) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![Algorithm 2](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/Algorithm%202.png) | ![Formula 2](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/Formula%202.png) |
| ![Algorithm 3](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/Algorithm%203.png) | ![Formula 3](https://raw.githubusercontent.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/master/src/images/Formula%203.png) |

** Please check [the reference](https://ieeexplore.ieee.org/document/8115220) for more details.

## Running the simulations

### Prerequisites

- [MATLAB](https://www.mathworks.com/products/matlab.html)
- [CVX](http://cvxr.com/cvx/) (You may need academic license for the _MOSEK_ solver)

### Launch

For the `R-E region vs subband` plot, run

```
>> re_subband
```

For the `R-E region vs SNR` plot, run

```
>> re_snr
```

## Issues and Contributing

Please submit an [issue](https://github.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/issues) or [pull request](https://github.com/SnowzTail/signal-optimization-for-wireless-information-and-power-transmission/pulls) for any potential problem. Thank you!

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Dr Bruno Clerckx, the supervisor
- Dr Morteza Varasteh

