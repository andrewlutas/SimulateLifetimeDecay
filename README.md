# SimulateLifetimeDecay

Put all of the files in your Matlab path and run the GUI.

You can simulate a two exponential decay (used to model a biosensor in a bound and unbound state where lifetime changes between these two states). Set the lifetimes of the two components and the proportion of each component. Then you can explore how changing the instrument response function (IRF) sigma value (standard deviation; in nanoseconds units) affects the simulated decays.

Next you can explore three ways for analyzing this data (first moment, monoexponential fit, or biexponential fit). One take away is that as IRF gets broader the shorter lifetime component is more compromised and biexponential fitting becomes much worse at returning values near the ground truth.
